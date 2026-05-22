/// Operator BLoC
///
/// Responsibility:
/// - Manage operator feature state
/// - Handle operator-specific realtime updates
/// - Coordinate with socket service

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/socket/socket_service.dart';
import '../models/operator_product.dart';
import '../repository/operator_repository.dart';

part 'operator_event.dart';
part 'operator_state.dart';

class OperatorBloc extends Bloc<OperatorEvent, OperatorState> {
  final OperatorRepository _repository;
  StreamSubscription<SocketConnectionStatus>? _connectionSubscription;
  bool _socketListenersAttached = false;

  OperatorBloc({required OperatorRepository repository})
    : _repository = repository,
      super(OperatorState.initial(products: OperatorProduct.mockCatalog())) {
    on<OperatorStarted>(_onStarted);
    on<OperatorRoomCodeUpdated>(_onRoomCodeUpdated);
    on<OperatorProductSelected>(_onProductSelected);
    on<OperatorProductCleared>(_onProductCleared);
    on<OperatorDiscountTriggered>(_onDiscountTriggered);
    on<OperatorDiscountStopped>(_onDiscountStopped);
    on<OperatorConnectionStatusChanged>(_onConnectionStatusChanged);
    on<OperatorSyncLost>(_onSyncLost);

    _connectionSubscription = _repository.connectionStatusStream.listen((
      status,
    ) {
      add(OperatorConnectionStatusChanged(status));
    });

    _attachSocketListeners();
  }

  void _attachSocketListeners() {
    if (_socketListenersAttached) {
      return;
    }

    _socketListenersAttached = true;

    _repository.onSocketEvent('ROOM_SYNC_LOST', (data) {
      add(OperatorSyncLost(_extractMessage(data, fallback: 'Room sync lost')));
    });

    _repository.onSocketEvent('OPERATOR_SYNC_LOST', (data) {
      add(
        OperatorSyncLost(_extractMessage(data, fallback: 'Operator sync lost')),
      );
    });

    _repository.onSocketEvent('ROOM_ERROR', (data) {
      add(OperatorSyncLost(_extractMessage(data, fallback: 'Room error')));
    });
  }

  Future<void> _onStarted(
    OperatorStarted event,
    Emitter<OperatorState> emit,
  ) async {
    final roomCode = event.roomCode.trim();
    final products = OperatorProduct.mockCatalog();

    emit(
      state.copyWith(
        phase: OperatorPhase.loading,
        roomCode: roomCode,
        products: products,
        connectionStatus: _repository.connectionStatus,
        statusMessage: roomCode.isEmpty
            ? 'Set a room code to begin'
            : 'Loading control dashboard',
        errorMessage: null,
      ),
    );

    emit(
      state.copyWith(
        phase: OperatorPhase.ready,
        roomCode: roomCode,
        products: products,
        connectionStatus: _repository.connectionStatus,
        statusMessage: roomCode.isEmpty
            ? 'Set a room code to begin'
            : 'Control dashboard ready',
        errorMessage: null,
      ),
    );
  }

  void _onRoomCodeUpdated(
    OperatorRoomCodeUpdated event,
    Emitter<OperatorState> emit,
  ) {
    final roomCode = event.roomCode.trim();
    emit(
      state.copyWith(
        roomCode: roomCode,
        statusMessage: roomCode.isEmpty
            ? 'Set a room code to begin'
            : 'Room code updated',
        errorMessage: null,
      ),
    );
  }

  Future<void> _onProductSelected(
    OperatorProductSelected event,
    Emitter<OperatorState> emit,
  ) async {
    if (state.roomCode.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Set a room code before showing a product',
          statusMessage: 'Room code required',
        ),
      );
      return;
    }

    final success = await _repository.showProduct(
      roomCode: state.roomCode,
      product: event.product,
    );

    if (!success) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Unable to emit SHOW_PRODUCT',
          statusMessage: 'Product emit failed',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: OperatorPhase.ready,
        activeProduct: event.product,
        errorMessage: null,
        statusMessage: 'Showing ${event.product.name}',
        lastActionAt: DateTime.now(),
      ),
    );
  }

  Future<void> _onProductCleared(
    OperatorProductCleared event,
    Emitter<OperatorState> emit,
  ) async {
    if (state.roomCode.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Set a room code before clearing a product',
          statusMessage: 'Room code required',
        ),
      );
      return;
    }

    final success = await _repository.clearProduct(roomCode: state.roomCode);
    if (!success) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Unable to emit CLEAR_PRODUCT',
          statusMessage: 'Clear product failed',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: OperatorPhase.ready,
        activeProduct: null,
        errorMessage: null,
        statusMessage: 'Product cleared',
        lastActionAt: DateTime.now(),
      ),
    );
  }

  Future<void> _onDiscountTriggered(
    OperatorDiscountTriggered event,
    Emitter<OperatorState> emit,
  ) async {
    if (state.roomCode.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Set a room code before triggering a discount',
          statusMessage: 'Room code required',
        ),
      );
      return;
    }

    final success = await _repository.startDiscount(
      roomCode: state.roomCode,
      title: event.preset.label,
      percentage: event.preset.percentage,
    );

    if (!success) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Unable to emit START_DISCOUNT',
          statusMessage: 'Discount emit failed',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: OperatorPhase.ready,
        activeDiscount: event.preset,
        errorMessage: null,
        statusMessage: 'Discount ${event.preset.label} live',
        lastActionAt: DateTime.now(),
      ),
    );
  }

  Future<void> _onDiscountStopped(
    OperatorDiscountStopped event,
    Emitter<OperatorState> emit,
  ) async {
    if (state.roomCode.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Set a room code before stopping a discount',
          statusMessage: 'Room code required',
        ),
      );
      return;
    }

    final success = await _repository.stopDiscount(roomCode: state.roomCode);
    if (!success) {
      emit(
        state.copyWith(
          phase: OperatorPhase.error,
          errorMessage: 'Unable to emit STOP_DISCOUNT',
          statusMessage: 'Stop discount failed',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: OperatorPhase.ready,
        activeDiscount: null,
        errorMessage: null,
        statusMessage: 'Discount stopped',
        lastActionAt: DateTime.now(),
      ),
    );
  }

  void _onConnectionStatusChanged(
    OperatorConnectionStatusChanged event,
    Emitter<OperatorState> emit,
  ) {
    final isConnected = event.status == SocketConnectionStatus.connected;
    final isReconnecting = event.status == SocketConnectionStatus.reconnecting;

    emit(
      state.copyWith(
        connectionStatus: event.status,
        phase: state.phase == OperatorPhase.initial
            ? OperatorPhase.ready
            : state.phase,
        statusMessage: isReconnecting
            ? 'Reconnecting control link'
            : isConnected
            ? (state.errorMessage == null ? state.statusMessage : 'Connected')
            : 'Socket disconnected',
      ),
    );
  }

  void _onSyncLost(OperatorSyncLost event, Emitter<OperatorState> emit) {
    emit(
      state.copyWith(
        phase: OperatorPhase.error,
        errorMessage: event.message,
        statusMessage: event.message,
      ),
    );
  }

  String _extractMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return fallback;
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    try {
      _repository.offSocketEvent('ROOM_SYNC_LOST');
      _repository.offSocketEvent('OPERATOR_SYNC_LOST');
      _repository.offSocketEvent('ROOM_ERROR');
    } catch (_) {}

    return super.close();
  }
}
