import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';

class RecorderStatusBar extends StatelessWidget {
  const RecorderStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: RepaintBoundary(
            child: BlocSelector<RecorderCubit, RecorderState, String>(
              selector: (state) {
                if (state is RecorderLoading) {
                  return 'Loading camera...';
                }
                if (state is RecorderError) {
                  return 'Error: ${state.message}';
                }
                if (state is RecorderReady) {
                  final lens =
                      state.activeCamera?.lensDirection
                          .toString()
                          .split('.')
                          .last ??
                      'unknown';
                  return '${state.statusText} • $lens';
                }
                return 'Initializing';
              },
              builder: (context, text) => _StatusPill(text: text),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;

  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
