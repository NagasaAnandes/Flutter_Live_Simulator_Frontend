import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RecorderCubit, RecorderState, CameraController?>(
      selector: (state) => state is RecorderReady ? state.controller : null,
      builder: (context, controller) {
        if (controller == null || !controller.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return RepaintBoundary(child: CameraPreview(controller));
      },
    );
  }
}
