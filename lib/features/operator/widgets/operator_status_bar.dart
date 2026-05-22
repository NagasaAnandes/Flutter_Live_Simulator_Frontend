import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/socket/socket_service.dart';
import '../bloc/operator_bloc.dart';

class OperatorStatusBar extends StatelessWidget {
  const OperatorStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OperatorBloc, OperatorState, _StatusBarData>(
      selector: (state) => _StatusBarData(
        roomCode: state.roomCode,
        connectionStatus: state.connectionStatus,
        overlayStateLabel: state.overlayStateLabel,
        statusMessage: state.statusMessage,
      ),
      builder: (context, data) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(
                label: 'ROOM',
                value: data.roomCode.isEmpty ? 'UNSET' : data.roomCode,
              ),
              _StatusChip(
                label: 'SOCKET',
                value: data.connectionStatus.name.toUpperCase(),
                accent: _connectionColor(data.connectionStatus),
              ),
              _StatusChip(label: 'OVERLAY', value: data.overlayStateLabel),
              _StatusChip(label: 'STATE', value: data.statusMessage),
            ],
          ),
        );
      },
    );
  }

  Color _connectionColor(SocketConnectionStatus status) {
    switch (status) {
      case SocketConnectionStatus.connected:
        return const Color(0xFF10B981);
      case SocketConnectionStatus.connecting:
      case SocketConnectionStatus.reconnecting:
        return const Color(0xFFF59E0B);
      case SocketConnectionStatus.disconnected:
      case SocketConnectionStatus.error:
        return const Color(0xFFEF4444);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;

  const _StatusChip({required this.label, required this.value, this.accent});

  @override
  Widget build(BuildContext context) {
    final chipColor = accent ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor.withAlpha(77)),
      ),
      child: Text(
        '$label  $value',
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatusBarData extends Equatable {
  final String roomCode;
  final SocketConnectionStatus connectionStatus;
  final String overlayStateLabel;
  final String statusMessage;

  const _StatusBarData({
    required this.roomCode,
    required this.connectionStatus,
    required this.overlayStateLabel,
    required this.statusMessage,
  });

  @override
  List<Object?> get props => [
    roomCode,
    connectionStatus,
    overlayStateLabel,
    statusMessage,
  ];
}
