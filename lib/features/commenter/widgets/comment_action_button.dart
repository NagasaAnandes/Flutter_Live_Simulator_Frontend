import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/socket/socket_service.dart';
import '../bloc/commenter_bloc.dart';

class CommentActionButton extends StatelessWidget {
  final CommentCategory category;
  final VoidCallback onPressed;

  const CommentActionButton({
    super.key,
    required this.category,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CommenterBloc, CommenterState, _ActionButtonViewModel>(
      selector: (state) {
        if (state is! CommenterReady) {
          return _ActionButtonViewModel.disabled(category);
        }

        final isCoolingDown = state.isCategoryCoolingDown(category);
        final remaining = state.cooldownRemaining(category);

        return _ActionButtonViewModel(
          category: category,
          enabled: state.isConnected && !state.emitInFlight && !isCoolingDown,
          socketStatus: state.socketStatus,
          isCoolingDown: isCoolingDown,
          remaining: remaining,
          lastTriggered: state.lastCategory == category,
          isBursting: state.burstInProgress,
        );
      },
      builder: (context, viewModel) {
        final baseColor = _categoryColor(category);
        final backgroundColor = viewModel.enabled
            ? baseColor.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.04);
        final borderColor = viewModel.enabled
            ? baseColor.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.08);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: viewModel.enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: viewModel.enabled
                    ? [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.16),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.isCoolingDown
                              ? 'Cooldown ${_formatDuration(viewModel.remaining)}'
                              : category.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.66),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(viewModel: viewModel, color: baseColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _categoryColor(CommentCategory category) {
    switch (category) {
      case CommentCategory.price:
        return const Color(0xFFF4D35E);
      case CommentCategory.hype:
        return const Color(0xFF55D6BE);
      case CommentCategory.discount:
        return const Color(0xFF8B5CF6);
      case CommentCategory.stock:
        return const Color(0xFF38BDF8);
      case CommentCategory.cod:
        return const Color(0xFFF97316);
      case CommentCategory.checkout:
        return const Color(0xFF22C55E);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) {
      return '0ms';
    }

    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }

    return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';
  }
}

class _StatusPill extends StatelessWidget {
  final _ActionButtonViewModel viewModel;
  final Color color;

  const _StatusPill({required this.viewModel, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = viewModel.isCoolingDown
        ? 'WAIT'
        : viewModel.enabled
        ? 'GO'
        : viewModel.isBursting
        ? 'BURST'
        : 'LOCK';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: viewModel.enabled ? 0.22 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: viewModel.enabled ? color : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _ActionButtonViewModel extends Equatable {
  final CommentCategory category;
  final bool enabled;
  final SocketConnectionStatus socketStatus;
  final bool isCoolingDown;
  final Duration remaining;
  final bool lastTriggered;
  final bool isBursting;

  const _ActionButtonViewModel({
    required this.category,
    required this.enabled,
    required this.socketStatus,
    required this.isCoolingDown,
    required this.remaining,
    required this.lastTriggered,
    required this.isBursting,
  });

  factory _ActionButtonViewModel.disabled(CommentCategory category) {
    return _ActionButtonViewModel(
      category: category,
      enabled: false,
      socketStatus: SocketConnectionStatus.disconnected,
      isCoolingDown: false,
      remaining: Duration.zero,
      lastTriggered: false,
      isBursting: false,
    );
  }

  @override
  List<Object?> get props => [
    category,
    enabled,
    socketStatus,
    isCoolingDown,
    remaining.inMilliseconds,
    lastTriggered,
    isBursting,
  ];
}
