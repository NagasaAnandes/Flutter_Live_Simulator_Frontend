import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';
import 'comment_overlay_queue.dart';
import 'discount_overlay_widget.dart';
import 'product_overlay_widget.dart';

class OverlayStack extends StatelessWidget {
  const OverlayStack({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RecorderCubit, RecorderState, bool>(
      selector: (state) =>
          state is RecorderReady ? state.overlaysVisible : false,
      builder: (context, overlaysVisible) {
        if (!overlaysVisible) {
          return const SizedBox.shrink();
        }

        return const RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductOverlayWidget(),
              DiscountOverlayWidget(),
              CommentOverlayQueue(),
            ],
          ),
        );
      },
    );
  }
}
