/// Recorder Widgets
///
/// Responsibility:
/// - Provide reusable widgets for recorder feature
/// - Handle recording UI components

import 'package:flutter/material.dart';

class RecorderControls extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPause;

  const RecorderControls({
    Key? key,
    required this.onStart,
    required this.onStop,
    required this.onPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: onStart, child: const Text('Start')),
        ElevatedButton(onPressed: onPause, child: const Text('Pause')),
        ElevatedButton(onPressed: onStop, child: const Text('Stop')),
      ],
    );
  }
}
