/// Overlay Widgets
///
/// Responsibility:
/// - Provide reusable overlay widgets
/// - Handle overlay display components

import 'package:flutter/material.dart';

class ProductOverlayWidget extends StatelessWidget {
  final String productName;
  final double price;

  const ProductOverlayWidget({
    Key? key,
    required this.productName,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(productName), Text('\$$price')],
      ),
    );
  }
}

class DiscountOverlayWidget extends StatelessWidget {
  final String title;
  final double percentage;

  const DiscountOverlayWidget({
    Key? key,
    required this.title,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(title), Text('$percentage% OFF')],
      ),
    );
  }
}
