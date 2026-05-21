part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class CreateRoomRequested extends RoomEvent {
  const CreateRoomRequested();
}

class JoinRoomRequested extends RoomEvent {
  final String roomCode;
  final ParticipantRole role;

  const JoinRoomRequested({required this.roomCode, required this.role});

  @override
  List<Object?> get props => [roomCode, role];
}

class RoomCreatedReceived extends RoomEvent {
  final RoomData roomData;

  const RoomCreatedReceived(this.roomData);

  @override
  List<Object?> get props => [roomData];
}

class RoomJoinedReceived extends RoomEvent {
  final RoomData roomData;
  final String participantId;
  final ParticipantRole role;

  const RoomJoinedReceived({
    required this.roomData,
    required this.participantId,
    required this.role,
  });

  @override
  List<Object?> get props => [roomData, participantId, role];
}

class RoomUpdatedReceived extends RoomEvent {
  final RoomData roomData;

  const RoomUpdatedReceived(this.roomData);

  @override
  List<Object?> get props => [roomData];
}

class RoomErrorReceived extends RoomEvent {
  final RoomError error;

  const RoomErrorReceived(this.error);

  @override
  List<Object?> get props => [error];
}

class ReconnectRoomRequested extends RoomEvent {
  const ReconnectRoomRequested();
}

class LeaveRoomRequested extends RoomEvent {
  const LeaveRoomRequested();
}

class SocketConnectedReceived extends RoomEvent {
  const SocketConnectedReceived();
}

class SocketDisconnectedReceived extends RoomEvent {
  const SocketDisconnectedReceived();
}

class SocketConnectingReceived extends RoomEvent {
  const SocketConnectingReceived();
}

class SocketReconnectingReceived extends RoomEvent {
  const SocketReconnectingReceived();
}
