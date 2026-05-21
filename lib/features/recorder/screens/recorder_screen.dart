import 'package:flutter/material.dart';

import '../overlay/overlay_stack.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/recorder_controls.dart';
import '../widgets/recorder_status_bar.dart';

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreviewWidget(),
            OverlayStack(),
            RecorderStatusBar(),
            RecorderControls(),
          ],
        ),
      ),
    );
  }
}
