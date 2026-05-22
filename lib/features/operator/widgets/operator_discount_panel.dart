import 'package:flutter/material.dart';

import '../bloc/operator_bloc.dart';

class OperatorDiscountPanel extends StatelessWidget {
  final ValueChanged<OperatorDiscountPreset> onPresetSelected;

  const OperatorDiscountPanel({super.key, required this.onPresetSelected});

  @override
  Widget build(BuildContext context) {
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
            'Discount Trigger',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OperatorDiscountPreset.values
                .map(
                  (preset) => FilledButton.tonal(
                    onPressed: () => onPresetSelected(preset),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: Text(preset.label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
