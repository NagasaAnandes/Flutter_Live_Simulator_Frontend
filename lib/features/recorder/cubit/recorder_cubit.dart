/// Recorder Cubit
///
/// Responsibility:
/// - Manage recorder local UI state
/// - Handle recording status changes
/// - Not responsible for socket sync (RoomBloc handles that)
///
/// Cubit for simple local state management

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'recorder_state.dart';

class RecorderCubit extends Cubit<RecorderState> {
  RecorderCubit() : super(const RecorderInitial());

  void startRecording() {
    // TODO: Implement
  }

  void stopRecording() {
    // TODO: Implement
  }

  void pauseRecording() {
    // TODO: Implement
  }
}
