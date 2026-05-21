import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/room_bloc.dart';
import '../models/room_models.dart';
import '../../../shared/enums/enums.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  Widget _roleRow(String label, bool present) {
    return Row(
      children: [
        Icon(
          present ? Icons.check_circle : Icons.radio_button_unchecked,
          color: present ? Colors.greenAccent : Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state is RoomLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RoomErrorState) {
              return Center(child: Text('Error: ${state.error.message}'));
            }

            if (state is RoomConnected) {
              final room = state.roomData;
              final hasRecorder = room.isRoleTaken(ParticipantRole.recorder);
              final hasOperator = room.isRoleTaken(ParticipantRole.operator);
              final hasCommenter = room.isRoleTaken(ParticipantRole.commenter);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ROOM ${room.roomCode}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Participants',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _roleRow('Recorder', hasRecorder),
                          const SizedBox(height: 8),
                          _roleRow('Operator', hasOperator),
                          const SizedBox(height: 8),
                          _roleRow('Commenter', hasCommenter),
                          const SizedBox(height: 16),
                          Text(
                            'Connected: ${room.getConnectedCount()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Connection: ${state.connectionStatus.toString().split('.').last.toUpperCase()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (state.isReconnecting)
                        const Text(
                          'Reconnecting...',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                    ],
                  ),
                ],
              );
            }

            return const Center(child: Text('No room connected'));
          },
        ),
      ),
    );
  }
}
