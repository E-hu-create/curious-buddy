import 'package:flutter/material.dart';

import 'buddy/buddy.dart';

/// Buddy with a short message. Used for features that are not built yet and
/// for unknown routes.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.mood = BuddyMood.curious,
  });

  final String title;
  final String message;
  final BuddyMood mood;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canGoHome = Navigator.of(context).canPop();
    return Scaffold(
      appBar: canGoHome ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: .min,
                children: [
                  Buddy(height: 150, mood: mood),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: .center,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: .center, style: textTheme.bodyLarge),
                  if (canGoHome) ...[
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Back to Home'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
