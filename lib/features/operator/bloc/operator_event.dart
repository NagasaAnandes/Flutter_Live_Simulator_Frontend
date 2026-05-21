part of 'operator_bloc.dart';

abstract class OperatorEvent extends Equatable {
  const OperatorEvent();

  @override
  List<Object?> get props => [];
}

class LoadOperatorDataEvent extends OperatorEvent {
  const LoadOperatorDataEvent();
}

class UpdateOperatorStateEvent extends OperatorEvent {
  final Map<String, dynamic> data;

  const UpdateOperatorStateEvent(this.data);

  @override
  List<Object?> get props => [data];
}
