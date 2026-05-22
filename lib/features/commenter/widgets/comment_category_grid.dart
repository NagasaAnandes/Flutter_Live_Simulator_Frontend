import 'package:flutter/material.dart';

import '../bloc/commenter_bloc.dart';
import 'comment_action_button.dart';

class CommentCategoryGrid extends StatelessWidget {
  final ValueChanged<CommentCategory> onCategorySelected;

  const CommentCategoryGrid({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.7,
          children: CommentCategory.values
              .map(
                (category) => CommentActionButton(
                  category: category,
                  onPressed: () => onCategorySelected(category),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
