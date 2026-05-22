part of 'operator_bloc.dart';

abstract class OperatorEvent extends Equatable {
  const OperatorEvent();

  @override
  List<Object?> get props => [];
}

class OperatorStarted extends OperatorEvent {
  final String roomCode;

  const OperatorStarted({required this.roomCode});

  @override
  List<Object?> get props => [roomCode];
}

class OperatorRoomCodeUpdated extends OperatorEvent {
  final String roomCode;

  const OperatorRoomCodeUpdated({required this.roomCode});

  @override
  List<Object?> get props => [roomCode];
}

class OperatorProductSelected extends OperatorEvent {
  final OperatorProduct product;

  const OperatorProductSelected({required this.product});

  @override
  List<Object?> get props => [product];
}

class OperatorProductCleared extends OperatorEvent {
  const OperatorProductCleared();
}

class OperatorDiscountTriggered extends OperatorEvent {
  final OperatorDiscountPreset preset;

  const OperatorDiscountTriggered({required this.preset});

  @override
  List<Object?> get props => [preset];
}

class OperatorDiscountStopped extends OperatorEvent {
  const OperatorDiscountStopped();
}

class OperatorConnectionStatusChanged extends OperatorEvent {
  final SocketConnectionStatus status;

  const OperatorConnectionStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class OperatorSyncLost extends OperatorEvent {
  final String message;

  const OperatorSyncLost(this.message);

  @override
  List<Object?> get props => [message];
}
