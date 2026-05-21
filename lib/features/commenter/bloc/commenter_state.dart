part of 'commenter_bloc.dart';

abstract class CommenterState extends Equatable {
  const CommenterState();

  @override
  List<Object?> get props => [];
}

class CommenterInitial extends CommenterState {
  const CommenterInitial();
}

class CommenterLoading extends CommenterState {
  const CommenterLoading();
}

class CommenterReady extends CommenterState {
  const CommenterReady();
}

class CommentSent extends CommenterState {
  const CommentSent();
}

class CommenterError extends CommenterState {
  final String message;

  const CommenterError(this.message);

  @override
  List<Object?> get props => [message];
}
