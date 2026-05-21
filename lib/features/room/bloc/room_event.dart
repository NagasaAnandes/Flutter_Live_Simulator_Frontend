part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class JoinRoomEvent extends RoomEvent {
  final String roomId;

  const JoinRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LeaveRoomEvent extends RoomEvent {
  const LeaveRoomEvent();
}

class UpdateRoomEvent extends RoomEvent {
  final Map<String, dynamic> data;

  const UpdateRoomEvent(this.data);

  @override
  List<Object?> get props => [data];
}
