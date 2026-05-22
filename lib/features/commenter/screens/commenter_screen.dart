// Commenter Screen
//
// Responsibility:
// - Display commenter interface
// - Coordinate commenter UI elements
// - Handle commenter interactions

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/commenter_bloc.dart';
import '../widgets/comment_category_grid.dart';
import '../widgets/commenter_status_bar.dart';

class CommenterScreen extends StatelessWidget {
  const CommenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: SafeArea(
        child: BlocSelector<CommenterBloc, CommenterState, CommenterReady?>(
          selector: (state) => state is CommenterReady ? state : null,
          builder: (context, state) {
            final roomCode = state?.roomCode ?? 'ROOM-1001';

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF08111E),
                    Color(0xFF0C1320),
                    Color(0xFF04070D),
                  ],
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: _Header(roomCode: roomCode),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: CommenterStatusBar(
                        onReconnect: () {
                          context.read<CommenterBloc>().add(
                            const CommenterReconnectRequested(),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: _SectionCard(
                        title: 'Audience reactions',
                        subtitle:
                            'Tap predefined categories to stress-test the recorder overlay stream.',
                        child: CommentCategoryGrid(
                          onCategorySelected: (category) {
                            context.read<CommenterBloc>().add(
                              CommentCategoryTriggered(category),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: _BurstStrip(
                        onRunBurst: () {
                          context.read<CommenterBloc>().add(
                            const CommentBurstRequested(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.04, end: 0);
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String roomCode;

  const _Header({required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Commenter Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Controlled audience simulator for live commerce bursts.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _RoomBadge(roomCode: roomCode),
      ],
    );
  }
}

class _RoomBadge extends StatelessWidget {
  final String roomCode;

  const _RoomBadge({required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROOM',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roomCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1522).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BurstStrip extends StatelessWidget {
  final VoidCallback onRunBurst;

  const _BurstStrip({required this.onRunBurst});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111826).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Realtime burst test',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cycles all predefined categories with a compact 120ms cadence.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onRunBurst,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Run Burst'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
