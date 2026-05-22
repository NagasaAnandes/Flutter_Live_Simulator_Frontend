import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/overlay_models.dart';
import '../cubit/recorder_cubit.dart';

class DiscountOverlayWidget extends StatelessWidget {
  const DiscountOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RecorderCubit, RecorderState, DiscountOverlay?>(
      selector: (state) => state is RecorderReady ? state.activeDiscount : null,
      builder: (context, discount) {
        if (discount == null) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(220),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (discount.discountPercentage > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\$${discount.discountPercentage.toStringAsFixed(0)} OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
