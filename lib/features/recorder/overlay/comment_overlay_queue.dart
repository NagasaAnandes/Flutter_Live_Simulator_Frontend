import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';
import 'comment_overlay_widget.dart';

class CommentOverlayQueue extends StatelessWidget {
  const CommentOverlayQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RecorderCubit, RecorderState, List<CommentOverlayItem>>(
      selector: (state) => state is RecorderReady ? state.comments : const [],
      builder: (context, comments) {
        if (comments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: comments
                    .map((comment) => CommentOverlayWidget(text: comment.text))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
