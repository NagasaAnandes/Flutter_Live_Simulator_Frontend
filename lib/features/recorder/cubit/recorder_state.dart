part of 'recorder_cubit.dart';

abstract class RecorderState extends Equatable {
  const RecorderState();

  @override
  List<Object?> get props => [];
}

class RecorderInitial extends RecorderState {
  const RecorderInitial();
}

class RecorderReady extends RecorderState {
  const RecorderReady();
}

class RecorderRecording extends RecorderState {
  final Duration elapsed;

  const RecorderRecording(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

class RecorderPaused extends RecorderState {
  final Duration elapsed;

  const RecorderPaused(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

class RecorderError extends RecorderState {
  final String message;

  const RecorderError(this.message);

  @override
  List<Object?> get props => [message];
}
