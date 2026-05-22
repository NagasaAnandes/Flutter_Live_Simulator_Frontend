/// Room BLoC
///
/// Responsibility:
/// - Orchestrate room feature state management
/// - Handle socket synchronization for room data
/// - Manage room lifecycle (join, leave, update)
/// - Coordinate with socket service
///
/// Feature-oriented: manages all room-related realtime state

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/dependency_injection/injection.dart';
import '../../../core/socket/socket_service.dart';
import '../../room/models/room_models.dart';
import '../../../shared/enums/enums.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final SocketService _socketService = getIt<SocketService>();

  StreamSubscription<SocketConnectionStatus>? _socketStatusSub;
  bool _listenersAttached = false;

  RoomData? _currentRoom;
  String? _participantId;
  ParticipantRole? _participantRole;

  RoomBloc() : super(const RoomInitial()) {
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<JoinRoomRequested>(_onJoinRoomRequested);
    on<RoomCreatedReceived>(_onRoomCreatedReceived);
    on<RoomJoinedReceived>(_onRoomJoinedReceived);
    on<RoomUpdatedReceived>(_onRoomUpdatedReceived);
    on<RoomErrorReceived>(_onRoomErrorReceived);
    on<ReconnectRoomRequested>(_onReconnectRequested);
    on<SocketConnectedReceived>(
      (event, emit) => _onSocketStatusChanged(ConnectionStatus.connected, emit),
    );
    on<SocketDisconnectedReceived>(
      (event, emit) =>
          _onSocketStatusChanged(ConnectionStatus.disconnected, emit),
    );
    on<SocketConnectingReceived>(
      (event, emit) =>
          _onSocketStatusChanged(ConnectionStatus.connecting, emit),
    );
    on<SocketReconnectingReceived>(
      (event, emit) =>
          _onSocketStatusChanged(ConnectionStatus.connecting, emit),
    );

    // subscribe to socket connection status stream
    _socketStatusSub = _socketService.connectionStatusStream.listen((status) {
      switch (status) {
        case SocketConnectionStatus.connected:
          add(const SocketConnectedReceived());
          break;
        case SocketConnectionStatus.disconnected:
          add(const SocketDisconnectedReceived());
          break;
        case SocketConnectionStatus.connecting:
          add(const SocketConnectingReceived());
          break;
        case SocketConnectionStatus.reconnecting:
          add(const SocketReconnectingReceived());
          break;
        case SocketConnectionStatus.error:
          add(const SocketDisconnectedReceived());
          break;
      }
    });

    // attach socket listeners once
    _attachSocketListeners();
  }

  // Attach socket event listeners, safe-guarded against double attachment
  void _attachSocketListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    _socketService.on('ROOM_CREATED', (data) {
      try {
        final room = _parseRoomData(data);
        add(RoomCreatedReceived(room));
      } catch (e) {
        add(
          RoomErrorReceived(
            RoomError(message: 'Invalid ROOM_CREATED payload: $e'),
          ),
        );
      }
    });

    _socketService.on('ROOM_JOINED', (data) {
      try {
        final room = _parseRoomData(data['room']);
        final participantId = data['participantId']?.toString() ?? '';
        final roleStr = data['role']?.toString() ?? '';
        final role = _parseRole(roleStr) ?? ParticipantRole.commenter;
        add(
          RoomJoinedReceived(
            roomData: room,
            participantId: participantId,
            role: role,
          ),
        );
      } catch (e) {
        add(
          RoomErrorReceived(
            RoomError(message: 'Invalid ROOM_JOINED payload: $e'),
          ),
        );
      }
    });

    _socketService.on('ROOM_UPDATED', (data) {
      try {
        final room = _parseRoomData(data);
        add(RoomUpdatedReceived(room));
      } catch (e) {
        add(
          RoomErrorReceived(
            RoomError(message: 'Invalid ROOM_UPDATED payload: $e'),
          ),
        );
      }
    });

    _socketService.on('ROOM_ERROR', (data) {
      try {
        final message = data?['message']?.toString() ?? 'Unknown room error';
        final code = data?['code']?.toString();
        add(RoomErrorReceived(RoomError(message: message, code: code)));
      } catch (e) {
        add(RoomErrorReceived(RoomError(message: 'ROOM_ERROR: $e')));
      }
    });
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomLoading());
    try {
      // Emit CREATE_ROOM to server. Server should respond with ROOM_CREATED
      _socketService.emit('CREATE_ROOM', {
        'meta': {'source': 'client'},
      });
    } catch (e) {
      emit(RoomErrorState(RoomError(message: 'Failed to create room: $e')));
    }
  }

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomLoading());
    try {
      final roleStr = event.role.toString().split('.').last;
      _socketService.emit('JOIN_ROOM', {
        'roomCode': event.roomCode,
        'role': roleStr,
      });
    } catch (e) {
      emit(RoomErrorState(RoomError(message: 'Failed to join room: $e')));
    }
  }

  void _onRoomCreatedReceived(
    RoomCreatedReceived event,
    Emitter<RoomState> emit,
  ) {
    _currentRoom = event.roomData;
    // No participant yet until server assigns one to creator
    emit(
      RoomConnected(
        roomData: event.roomData,
        connectionStatus: ConnectionStatus.connected,
      ),
    );
  }

  void _onRoomJoinedReceived(
    RoomJoinedReceived event,
    Emitter<RoomState> emit,
  ) {
    _currentRoom = event.roomData;
    _participantId = event.participantId;
    _participantRole = event.role;
    emit(
      RoomConnected(
        roomData: event.roomData,
        connectionStatus: ConnectionStatus.connected,
      ),
    );
  }

  void _onRoomUpdatedReceived(
    RoomUpdatedReceived event,
    Emitter<RoomState> emit,
  ) {
    _currentRoom = event.roomData;
    emit(
      RoomConnected(
        roomData: event.roomData,
        connectionStatus: _socketService.isConnected
            ? ConnectionStatus.connected
            : ConnectionStatus.disconnected,
      ),
    );
  }

  void _onRoomErrorReceived(RoomErrorReceived event, Emitter<RoomState> emit) {
    emit(RoomErrorState(event.error));
  }

  Future<void> _onReconnectRequested(
    ReconnectRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    // Attempt to rejoin room automatically when socket reconnects
    if (_currentRoom == null || _participantRole == null) {
      return;
    }

    emit(RoomReconnecting(lastKnown: _currentRoom));

    try {
      final payload = {
        'roomCode': _currentRoom!.roomCode,
        'participantId': _participantId,
        'role': _participantRole.toString().split('.').last,
      };

      // Prefer a dedicated reconnect event if server supports it
      _socketService.emit('RECONNECT_ROOM', payload);

      // Fallback: emit JOIN_ROOM in case server expects it
      _socketService.emit('JOIN_ROOM', payload);
    } catch (e) {
      add(RoomErrorReceived(RoomError(message: 'Reconnect failed: $e')));
    }
  }

  void _onSocketStatusChanged(
    ConnectionStatus status,
    Emitter<RoomState> emit,
  ) {
    if (_currentRoom != null) {
      if (status == ConnectionStatus.connected) {
        // trigger rejoin flow
        add(const ReconnectRoomRequested());
      }
      // emit updated state reflecting connection status
      emit(RoomConnected(roomData: _currentRoom!, connectionStatus: status));
    } else {
      if (status == ConnectionStatus.disconnected) {
        emit(const RoomInitial());
      }
    }
  }

  ParticipantRole? _parseRole(String roleStr) {
    try {
      final key = roleStr.split('.').last.toLowerCase();
      switch (key) {
        case 'recorder':
          return ParticipantRole.recorder;
        case 'operator':
          return ParticipantRole.operator;
        case 'commenter':
          return ParticipantRole.commenter;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  RoomData _parseRoomData(dynamic data) {
    // Defensive parsing from JSON-like map
    final roomId = data['roomId']?.toString() ?? data['id']?.toString() ?? '';
    final roomCode =
        data['roomCode']?.toString() ?? data['code']?.toString() ?? '';
    final statusStr = data['status']?.toString() ?? 'waiting';
    final createdAtStr = data['createdAt']?.toString();
    final createdBy = data['createdBy']?.toString();

    final status = RoomStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusStr,
      orElse: () => RoomStatus.waiting,
    );

    DateTime createdAt;
    try {
      createdAt = createdAtStr != null
          ? DateTime.parse(createdAtStr)
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    final participantsRaw = data['participants'] as List<dynamic>? ?? [];
    final participants = participantsRaw.map<Participant>((p) {
      final pid = p['participantId']?.toString() ?? p['id']?.toString() ?? '';
      final role =
          _parseRole(p['role']?.toString() ?? '') ?? ParticipantRole.commenter;
      final isConnected = p['isConnected'] == true || p['connected'] == true;
      DateTime joinedAt;
      try {
        joinedAt = p['joinedAt'] != null
            ? DateTime.parse(p['joinedAt'])
            : DateTime.now();
      } catch (_) {
        joinedAt = DateTime.now();
      }
      return Participant(
        participantId: pid,
        role: role,
        isConnected: isConnected,
        joinedAt: joinedAt,
      );
    }).toList();

    return RoomData(
      roomId: roomId,
      roomCode: roomCode,
      participants: participants,
      status: status,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  @override
  Future<void> close() async {
    _socketStatusSub?.cancel();
    // remove only the room listeners to avoid clearing global listeners
    try {
      _socketService.off('ROOM_CREATED');
      _socketService.off('ROOM_JOINED');
      _socketService.off('ROOM_UPDATED');
      _socketService.off('ROOM_ERROR');
    } catch (_) {}
    return super.close();
  }
}
