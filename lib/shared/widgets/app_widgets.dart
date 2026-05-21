/// Shared Widgets
///
/// Responsibility:
/// - Provide reusable UI components
/// - Maintain consistent visual patterns
/// - Reduce duplication across features

import 'package:flutter/material.dart';

/// Placeholder for custom app bar widget
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const AppAppBar({Key? key, required this.title, this.actions, this.leading})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions, leading: leading);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Placeholder for loading widget
class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: 16), Text(message!)],
        ],
      ),
    );
  }
}

/// Placeholder for error widget
class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppError({Key? key, required this.message, this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
