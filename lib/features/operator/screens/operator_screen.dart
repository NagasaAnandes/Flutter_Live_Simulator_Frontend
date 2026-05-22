import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/operator_bloc.dart';
import '../models/operator_product.dart';
import '../widgets/operator_discount_panel.dart';
import '../widgets/operator_product_grid.dart';
import '../widgets/operator_status_bar.dart';

class OperatorScreen extends StatelessWidget {
  const OperatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1020), Color(0xFF0F172A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OperatorStatusBar(),
                const SizedBox(height: 12),
                BlocSelector<OperatorBloc, OperatorState, String?>(
                  selector: (state) => state.errorMessage,
                  builder: (context, errorMessage) {
                    if (errorMessage == null) {
                      return const SizedBox.shrink();
                    }

                    return _ErrorBanner(message: errorMessage);
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wideLayout = constraints.maxWidth >= 960;

                      final productGrid = Expanded(
                        child:
                            BlocSelector<
                              OperatorBloc,
                              OperatorState,
                              _GridData
                            >(
                              selector: (state) => _GridData(
                                products: state.products,
                                selectedProductId: state.activeProduct?.id,
                              ),
                              builder: (context, data) {
                                return OperatorProductGrid(
                                  products: data.products,
                                  selectedProductId: data.selectedProductId,
                                  onProductTap: (product) {
                                    context.read<OperatorBloc>().add(
                                      OperatorProductSelected(product: product),
                                    );
                                  },
                                );
                              },
                            ),
                      );

                      final controlPanel = SizedBox(
                        width: wideLayout ? 320 : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BlocSelector<
                              OperatorBloc,
                              OperatorState,
                              _SelectionData
                            >(
                              selector: (state) => _SelectionData(
                                activeProduct: state.activeProduct,
                                activeDiscount: state.activeDiscount,
                                statusMessage: state.statusMessage,
                                phase: state.phase,
                              ),
                              builder: (context, data) {
                                return _SelectionCard(data: data);
                              },
                            ),
                            const SizedBox(height: 12),
                            OperatorDiscountPanel(
                              onPresetSelected: (preset) {
                                context.read<OperatorBloc>().add(
                                  OperatorDiscountTriggered(preset: preset),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.read<OperatorBloc>().add(
                                        const OperatorProductCleared(),
                                      );
                                    },
                                    child: const Text('Clear Product'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.read<OperatorBloc>().add(
                                        const OperatorDiscountStopped(),
                                      );
                                    },
                                    child: const Text('Stop Discount'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (wideLayout) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            productGrid,
                            const SizedBox(width: 12),
                            controlPanel,
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          productGrid,
                          const SizedBox(height: 12),
                          controlPanel,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x33EF4444),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withAlpha(120)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final _SelectionData data;

  const _SelectionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final product = data.activeProduct;
    final discount = data.activeDiscount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Control',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _DetailLine(
            label: 'Product',
            value: product == null ? 'None active' : product.name,
          ),
          const SizedBox(height: 8),
          _DetailLine(
            label: 'Discount',
            value: discount == null ? 'None active' : discount.label,
          ),
          const SizedBox(height: 8),
          _DetailLine(label: 'State', value: data.phase.name.toUpperCase()),
          const SizedBox(height: 8),
          _DetailLine(label: 'Status', value: data.statusMessage),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GridData extends Equatable {
  final List<OperatorProduct> products;
  final String? selectedProductId;

  const _GridData({required this.products, required this.selectedProductId});

  @override
  List<Object?> get props => [products, selectedProductId];
}

class _SelectionData extends Equatable {
  final OperatorProduct? activeProduct;
  final OperatorDiscountPreset? activeDiscount;
  final String statusMessage;
  final OperatorPhase phase;

  const _SelectionData({
    required this.activeProduct,
    required this.activeDiscount,
    required this.statusMessage,
    required this.phase,
  });

  @override
  List<Object?> get props => [
    activeProduct,
    activeDiscount,
    statusMessage,
    phase,
  ];
}
