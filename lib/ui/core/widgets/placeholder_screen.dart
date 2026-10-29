import 'package:flutter/material.dart';

/// Temporary screen used until real feature screens exist.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(title, style: textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(message, textAlign: .center, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
