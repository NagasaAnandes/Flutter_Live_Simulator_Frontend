import 'package:flutter/material.dart';

import '../models/operator_product.dart';
import 'operator_product_card.dart';

class OperatorProductGrid extends StatelessWidget {
  final List<OperatorProduct> products;
  final String? selectedProductId;
  final ValueChanged<OperatorProduct> onProductTap;

  const OperatorProductGrid({
    super.key,
    required this.products,
    required this.selectedProductId,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 198,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return OperatorProductCard(
          product: product,
          isSelected: selectedProductId == product.id,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
