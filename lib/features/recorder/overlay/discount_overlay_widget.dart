import 'package:flutter/material.dart';

class DiscountOverlayWidget extends StatelessWidget {
  const DiscountOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(217),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('20% OFF', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
