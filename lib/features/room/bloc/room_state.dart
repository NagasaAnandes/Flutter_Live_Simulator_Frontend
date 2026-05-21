part of 'room_bloc.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class RoomLoading extends RoomState {
  const RoomLoading();
}

class RoomConnected extends RoomState {
  final RoomData roomData;
  final ConnectionStatus connectionStatus;
  final bool isReconnecting;

  const RoomConnected({
    required this.roomData,
    required this.connectionStatus,
    this.isReconnecting = false,
  });

  @override
  List<Object?> get props => [roomData, connectionStatus, isReconnecting];
}

class RoomReconnecting extends RoomState {
  final RoomData? lastKnown;

  const RoomReconnecting({this.lastKnown});

  @override
  List<Object?> get props => [lastKnown];
}

class RoomErrorState extends RoomState {
  final RoomError error;

  const RoomErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
