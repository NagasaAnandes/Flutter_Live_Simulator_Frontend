part of 'operator_bloc.dart';

abstract class OperatorState extends Equatable {
  const OperatorState();

  @override
  List<Object?> get props => [];
}

class OperatorInitial extends OperatorState {
  const OperatorInitial();
}

class OperatorLoading extends OperatorState {
  const OperatorLoading();
}

class OperatorReady extends OperatorState {
  const OperatorReady();
}

class OperatorError extends OperatorState {
  final String message;

  const OperatorError(this.message);

  @override
  List<Object?> get props => [message];
}
