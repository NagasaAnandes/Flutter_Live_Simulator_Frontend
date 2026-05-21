/// Room BLoC
///
/// Responsibility:
/// - Orchestrate room feature state management
/// - Handle socket synchronization for room data
/// - Manage room lifecycle (join, leave, update)
/// - Coordinate with socket service
///
/// Feature-oriented: manages all room-related realtime state

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(const RoomInitial()) {
    on<RoomEvent>((event, emit) {
      // TODO: Implement event handlers
    });
  }
}
