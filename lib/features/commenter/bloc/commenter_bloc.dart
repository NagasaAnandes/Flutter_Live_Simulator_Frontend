// Commenter BLoC
//
// Responsibility:
// - Manage commenter feature state
// - Handle comment synchronization
// - Coordinate with socket service

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/log/logger.dart';
import '../../../core/socket/socket_service.dart';
import '../repository/commenter_repository.dart';

part 'commenter_event.dart';
part 'commenter_state.dart';

class CommenterBloc extends Bloc<CommenterEvent, CommenterState> {
  final CommenterRepository _repository;
  StreamSubscription<SocketConnectionStatus>? _connectionSubscription;
  final Map<CommentCategory, Timer> _cooldownTimers = {};
  bool _disposed = false;

  CommenterBloc({required CommenterRepository repository})
    : _repository = repository,
      super(const CommenterInitial()) {
    on<CommenterStarted>(_onStarted);
    on<CommentCategoryTriggered>(_onCategoryTriggered);
    on<CommentBurstRequested>(_onBurstRequested);
    on<CommenterReconnectRequested>(_onReconnectRequested);
    on<_CommenterSocketStatusChanged>(_onSocketStatusChanged);
    on<_CommenterCooldownExpired>(_onCooldownExpired);

    _connectionSubscription = _repository.connectionStatusStream.listen((
      status,
    ) {
      if (!_disposed && !isClosed) {
        add(_CommenterSocketStatusChanged(status));
      }
    });
  }

  Future<void> _onStarted(
    CommenterStarted event,
    Emitter<CommenterState> emit,
  ) async {
    final roomCode = event.roomCode.trim().isEmpty
        ? 'ROOM-1001'
        : event.roomCode.trim();

    emit(
      CommenterReady(
        roomCode: roomCode,
        socketStatus: _repository.connectionStatus,
        statusText: _statusTextFor(
          socketStatus: _repository.connectionStatus,
          burstInProgress: false,
          cooldownCount: 0,
          emitInFlight: false,
        ),
        detailText: _detailTextFor(
          socketStatus: _repository.connectionStatus,
          roomCode: roomCode,
        ),
      ),
    );
  }

  Future<void> _onCategoryTriggered(
    CommentCategoryTriggered event,
    Emitter<CommenterState> emit,
  ) async {
    final current = state;
    if (current is! CommenterReady || _disposed) {
      return;
    }

    if (current.roomCode.trim().isEmpty) {
      emit(
        current.copyWith(
          statusText: 'Room code required',
          detailText: 'Set a room code before triggering comments',
        ),
      );
      return;
    }

    if (current.emitInFlight) {
      emit(
        current.copyWith(
          statusText: 'Sending comment',
          detailText: 'Waiting for the current emit to settle',
        ),
      );
      return;
    }

    if (!current.isConnected) {
      emit(
        current.copyWith(
          statusText: _connectionLabel(current.socketStatus),
          detailText: 'Reconnect to resume comment emits',
        ),
      );
      return;
    }

    if (current.isCategoryCoolingDown(event.category)) {
      final remaining = current.cooldownRemaining(event.category);
      emit(
        current.copyWith(
          statusText: 'Cooldown active',
          detailText:
              '${event.category.label} available in ${_formatDuration(remaining)}',
        ),
      );
      return;
    }

    final updatedCooldowns = Map<CommentCategory, DateTime>.from(
      current.cooldownUntil,
    )..[event.category] = DateTime.now().add(const Duration(milliseconds: 500));

    emit(
      current.copyWith(
        emitInFlight: true,
        lastCategory: event.category,
        cooldownUntil: updatedCooldowns,
        statusText: 'Triggering ${event.category.label}',
        detailText: 'Sending controlled audience reaction',
      ),
    );

    final success = await _repository.triggerComment(
      roomCode: current.roomCode,
      category: event.category.socketValue,
    );

    final latest = state;
    if (latest is! CommenterReady || _disposed) {
      return;
    }

    if (!success) {
      final revertedCooldowns = Map<CommentCategory, DateTime>.from(
        latest.cooldownUntil,
      )..remove(event.category);

      emit(
        latest.copyWith(
          emitInFlight: false,
          cooldownUntil: revertedCooldowns,
          statusText: 'Emit failed',
          detailText: 'Unable to send ${event.category.label}',
        ),
      );
      return;
    }

    emit(
      latest.copyWith(
        emitInFlight: false,
        statusText: '${event.category.label} sent',
        detailText: 'Recorder overlay sync pending',
      ),
    );

    _scheduleCooldownExpiry(event.category);
  }

  Future<void> _onBurstRequested(
    CommentBurstRequested event,
    Emitter<CommenterState> emit,
  ) async {
    final current = state;
    if (current is! CommenterReady || _disposed) {
      return;
    }

    if (current.burstInProgress) {
      emit(
        current.copyWith(
          detailText: 'Burst test already running',
          statusText: 'Burst locked',
        ),
      );
      return;
    }

    final sequence = CommentCategory.values;
    emit(
      current.copyWith(
        burstInProgress: true,
        burstProgress: 0,
        burstTotal: sequence.length,
        statusText: 'Burst test running',
        detailText: 'Cycling predefined audience reactions',
      ),
    );

    for (var index = 0; index < sequence.length; index++) {
      if (_disposed || isClosed) {
        return;
      }

      add(CommentCategoryTriggered(sequence[index]));

      await Future<void>.delayed(const Duration(milliseconds: 120));

      final updated = state;
      if (updated is CommenterReady && !_disposed) {
        emit(
          updated.copyWith(
            burstInProgress: true,
            burstProgress: index + 1,
            burstTotal: sequence.length,
            statusText: 'Burst test running',
            detailText: 'Sent ${index + 1}/${sequence.length} triggers',
          ),
        );
      }
    }

    final latest = state;
    if (latest is CommenterReady && !_disposed) {
      emit(
        latest.copyWith(
          burstInProgress: false,
          burstProgress: 0,
          burstTotal: 0,
          statusText: _statusTextFor(
            socketStatus: latest.socketStatus,
            burstInProgress: false,
            cooldownCount: latest.cooldownUntil.length,
            emitInFlight: latest.emitInFlight,
          ),
          detailText: _detailTextFor(
            socketStatus: latest.socketStatus,
            roomCode: latest.roomCode,
            burstFinished: true,
          ),
        ),
      );
    }
  }

  Future<void> _onReconnectRequested(
    CommenterReconnectRequested event,
    Emitter<CommenterState> emit,
  ) async {
    final current = state;
    if (current is! CommenterReady || _disposed) {
      return;
    }

    emit(
      current.copyWith(
        statusText: 'Reconnecting',
        detailText: 'Restoring the live socket link',
      ),
    );

    await _repository.reconnect();
  }

  void _onSocketStatusChanged(
    _CommenterSocketStatusChanged event,
    Emitter<CommenterState> emit,
  ) {
    final current = state;
    if (current is! CommenterReady || _disposed) {
      return;
    }

    final next = current.copyWith(socketStatus: event.status);
    emit(
      next.copyWith(
        statusText: _statusTextFor(
          socketStatus: event.status,
          burstInProgress: next.burstInProgress,
          cooldownCount: next.cooldownUntil.length,
          emitInFlight: next.emitInFlight,
        ),
        detailText: _detailTextFor(
          socketStatus: event.status,
          roomCode: next.roomCode,
          burstFinished: false,
        ),
      ),
    );
  }

  void _onCooldownExpired(
    _CommenterCooldownExpired event,
    Emitter<CommenterState> emit,
  ) {
    final current = state;
    if (current is! CommenterReady || _disposed) {
      return;
    }

    if (!current.cooldownUntil.containsKey(event.category)) {
      return;
    }

    final cooldowns = Map<CommentCategory, DateTime>.from(current.cooldownUntil)
      ..remove(event.category);

    emit(
      current.copyWith(
        cooldownUntil: cooldowns,
        statusText: _statusTextFor(
          socketStatus: current.socketStatus,
          burstInProgress: current.burstInProgress,
          cooldownCount: cooldowns.length,
          emitInFlight: current.emitInFlight,
        ),
        detailText: _detailTextFor(
          socketStatus: current.socketStatus,
          roomCode: current.roomCode,
        ),
      ),
    );
  }

  void _scheduleCooldownExpiry(CommentCategory category) {
    _cooldownTimers[category]?.cancel();
    _cooldownTimers[category] = Timer(const Duration(milliseconds: 500), () {
      if (_disposed || isClosed) {
        return;
      }

      add(_CommenterCooldownExpired(category));
    });
  }

  String _statusTextFor({
    required SocketConnectionStatus socketStatus,
    required bool burstInProgress,
    required int cooldownCount,
    required bool emitInFlight,
  }) {
    if (burstInProgress) {
      return 'Burst test running';
    }

    if (emitInFlight) {
      return 'Sending comment';
    }

    if (socketStatus == SocketConnectionStatus.reconnecting) {
      return 'Reconnecting control link';
    }

    if (socketStatus == SocketConnectionStatus.disconnected ||
        socketStatus == SocketConnectionStatus.error) {
      return 'Socket disconnected';
    }

    if (cooldownCount > 0) {
      return 'Cooldown active';
    }

    return 'Ready';
  }

  String _detailTextFor({
    required SocketConnectionStatus socketStatus,
    required String roomCode,
    bool burstFinished = false,
  }) {
    switch (socketStatus) {
      case SocketConnectionStatus.connected:
        return burstFinished
            ? 'Burst test complete for $roomCode'
            : 'Audience reactions are live in $roomCode';
      case SocketConnectionStatus.reconnecting:
        return 'Socket reconnecting for $roomCode';
      case SocketConnectionStatus.connecting:
        return 'Connecting to live room $roomCode';
      case SocketConnectionStatus.disconnected:
        return 'Reconnect to resume comment emits';
      case SocketConnectionStatus.error:
        return 'Socket error detected for $roomCode';
    }
  }

  String _connectionLabel(SocketConnectionStatus status) {
    switch (status) {
      case SocketConnectionStatus.connected:
        return 'Ready';
      case SocketConnectionStatus.reconnecting:
        return 'Reconnecting control link';
      case SocketConnectionStatus.connecting:
        return 'Connecting...';
      case SocketConnectionStatus.disconnected:
        return 'Socket disconnected';
      case SocketConnectionStatus.error:
        return 'Socket error';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) {
      return '0ms';
    }

    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }

    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}s';
  }

  @override
  Future<void> close() async {
    _disposed = true;
    for (final timer in _cooldownTimers.values) {
      timer.cancel();
    }
    _cooldownTimers.clear();

    await _connectionSubscription?.cancel();

    AppLogger.i('[Commenter] Closing commenter bloc');
    return super.close();
  }
}
