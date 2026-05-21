/// Commenter Widgets
///
/// Responsibility:
/// - Provide reusable widgets for commenter feature
/// - Handle comment-specific UI components

import 'package:flutter/material.dart';

class CommentInput extends StatelessWidget {
  final ValueChanged<String> onSubmit;

  const CommentInput({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onSubmitted: onSubmit,
        decoration: InputDecoration(
          hintText: 'Enter comment...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final List<String> comments;

  const CommentList({Key? key, required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) => ListTile(title: Text(comments[index])),
    );
  }
}
