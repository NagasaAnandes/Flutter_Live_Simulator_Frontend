import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/socket/socket_service.dart';
import '../bloc/commenter_bloc.dart';

class CommenterStatusBar extends StatelessWidget {
  final VoidCallback onReconnect;

  const CommenterStatusBar({super.key, required this.onReconnect});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CommenterBloc, CommenterState, _StatusViewModel>(
      selector: (state) {
        if (state is! CommenterReady) {
          return const _StatusViewModel(
            roomCode: 'ROOM-1001',
            socketLabel: 'Idle',
            statusText: 'Initializing',
            detailText: 'Preparing commenter device',
            burstText: '0/0',
            showReconnect: false,
          );
        }

        return _StatusViewModel(
          roomCode: state.roomCode,
          socketLabel: _socketLabel(state.socketStatus),
          statusText: state.statusText,
          detailText: state.detailText,
          burstText: state.burstTotal == 0
              ? '0/0'
              : '${state.burstProgress}/${state.burstTotal}',
          showReconnect: state.socketStatus != SocketConnectionStatus.connected,
        );
      },
      builder: (context, viewModel) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111826).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusChip(
                    label: 'ROOM',
                    value: viewModel.roomCode,
                    accent: const Color(0xFF60A5FA),
                  ),
                  const SizedBox(width: 10),
                  _StatusChip(
                    label: 'SOCKET',
                    value: viewModel.socketLabel,
                    accent: viewModel.showReconnect
                        ? const Color(0xFFF97316)
                        : const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 10),
                  _StatusChip(
                    label: 'BURST',
                    value: viewModel.burstText,
                    accent: const Color(0xFFF4D35E),
                  ),
                  const Spacer(),
                  if (viewModel.showReconnect)
                    TextButton(
                      onPressed: onReconnect,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                      ),
                      child: const Text('Reconnect'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                viewModel.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.detailText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _socketLabel(SocketConnectionStatus status) {
    switch (status) {
      case SocketConnectionStatus.connected:
        return 'Connected';
      case SocketConnectionStatus.reconnecting:
        return 'Reconnecting';
      case SocketConnectionStatus.connecting:
        return 'Connecting';
      case SocketConnectionStatus.disconnected:
        return 'Disconnected';
      case SocketConnectionStatus.error:
        return 'Error';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusViewModel extends Equatable {
  final String roomCode;
  final String socketLabel;
  final String statusText;
  final String detailText;
  final String burstText;
  final bool showReconnect;

  const _StatusViewModel({
    required this.roomCode,
    required this.socketLabel,
    required this.statusText,
    required this.detailText,
    required this.burstText,
    required this.showReconnect,
  });

  @override
  List<Object?> get props => [
    roomCode,
    socketLabel,
    statusText,
    detailText,
    burstText,
    showReconnect,
  ];
}
