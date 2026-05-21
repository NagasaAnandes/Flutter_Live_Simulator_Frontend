/// Room Feature Models
///
/// Responsibility:
/// - Define data structures for room feature
/// - Ensure type safety for room state
/// - Bridge socket events to UI state

import 'package:equatable/equatable.dart';
import '../../../shared/enums/enums.dart';

/// Participant in a room
class Participant extends Equatable {
  final String participantId;
  final ParticipantRole role;
  final bool isConnected;
  final DateTime joinedAt;

  const Participant({
    required this.participantId,
    required this.role,
    required this.isConnected,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [participantId, role, isConnected, joinedAt];

  Participant copyWith({
    String? participantId,
    ParticipantRole? role,
    bool? isConnected,
    DateTime? joinedAt,
  }) {
    return Participant(
      participantId: participantId ?? this.participantId,
      role: role ?? this.role,
      isConnected: isConnected ?? this.isConnected,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// Room snapshot - represents current state of a room session
class RoomData extends Equatable {
  final String roomId;
  final String roomCode;
  final List<Participant> participants;
  final RoomStatus status;
  final DateTime createdAt;
  final String? createdBy;

  const RoomData({
    required this.roomId,
    required this.roomCode,
    required this.participants,
    required this.status,
    required this.createdAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
    roomId,
    roomCode,
    participants,
    status,
    createdAt,
    createdBy,
  ];

  RoomData copyWith({
    String? roomId,
    String? roomCode,
    List<Participant>? participants,
    RoomStatus? status,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RoomData(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Get participant by role
  Participant? getParticipantByRole(ParticipantRole role) {
    try {
      return participants.firstWhere((p) => p.role == role);
    } catch (e) {
      return null;
    }
  }

  /// Check if role is already taken
  bool isRoleTaken(ParticipantRole role) {
    return getParticipantByRole(role) != null;
  }

  /// Get connected participants count
  int getConnectedCount() {
    return participants.where((p) => p.isConnected).length;
  }
}

/// Room error types
class RoomError extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const RoomError({required this.message, this.code, this.stackTrace});

  @override
  List<Object?> get props => [message, code, stackTrace];

  factory RoomError.roomNotFound() =>
      const RoomError(message: 'Room not found', code: 'ROOM_NOT_FOUND');

  factory RoomError.roleTaken() => const RoomError(
    message: 'This role is already taken',
    code: 'ROLE_TAKEN',
  );

  factory RoomError.invalidRoomCode() =>
      const RoomError(message: 'Invalid room code', code: 'INVALID_ROOM_CODE');

  factory RoomError.connectionError() =>
      const RoomError(message: 'Connection error', code: 'CONNECTION_ERROR');

  factory RoomError.socketDisconnected() => const RoomError(
    message: 'Socket disconnected',
    code: 'SOCKET_DISCONNECTED',
  );
}
