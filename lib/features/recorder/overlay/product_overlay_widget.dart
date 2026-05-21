import 'package:flutter/material.dart';

class ProductOverlayWidget extends StatelessWidget {
  const ProductOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          child: Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Name', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 6),
                  Text('\$49.99', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
