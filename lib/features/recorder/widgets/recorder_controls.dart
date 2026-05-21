import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';

class RecorderControls extends StatelessWidget {
  const RecorderControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BlocSelector<RecorderCubit, RecorderState, bool>(
                selector: (state) =>
                    state is RecorderReady ? state.overlaysVisible : false,
                builder: (context, overlaysVisible) {
                  return FloatingActionButton.small(
                    onPressed: () =>
                        context.read<RecorderCubit>().toggleOverlays(),
                    child: Icon(
                      overlaysVisible ? Icons.layers : Icons.layers_clear,
                    ),
                  );
                },
              ),
              FloatingActionButton.small(
                onPressed: () => context.read<RecorderCubit>().switchCamera(),
                child: const Icon(Icons.cameraswitch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
