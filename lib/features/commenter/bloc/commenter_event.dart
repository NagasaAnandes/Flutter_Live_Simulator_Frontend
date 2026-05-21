part of 'commenter_bloc.dart';

abstract class CommenterEvent extends Equatable {
  const CommenterEvent();

  @override
  List<Object?> get props => [];
}

class SendCommentEvent extends CommenterEvent {
  final String message;

  const SendCommentEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadCommentsEvent extends CommenterEvent {
  const LoadCommentsEvent();
}
