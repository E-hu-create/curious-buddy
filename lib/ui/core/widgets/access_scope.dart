import 'package:flutter/material.dart';

import '../../../domain/access/access_controller.dart';
import '../themes/app_colors.dart';

/// Makes the [AccessController] available to every screen. Screens shown
/// without one (as in some tests) treat everything as unlocked.
class AccessScope extends InheritedNotifier<AccessController> {
  const AccessScope({
    super.key,
    required AccessController access,
    required super.child,
  }) : super(notifier: access);

  static AccessController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccessScope>()?.notifier;
}

/// Shown instead of a Play button on something that needs the full app.
/// Calm on purpose: no prices, countdowns or sales talk for children.
class AskGrownUpButton extends StatelessWidget {
  const AskGrownUpButton({super.key});

  static const label = 'Ask a grown-up';
  static const title = 'Part of the full app';
  static const message =
      'This one is part of the full Curious Buddy. A grown-up can unlock '
      'it in the Grown-ups area. There is lots more to explore for free!';
  static const okLabel = 'OK';

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_rounded, color: AppColors.ink),
        title: const Text(title),
        content: const Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(okLabel),
          ),
        ],
      ),
    ),
    icon: const Icon(Icons.lock_rounded),
    label: const Text(label),
  );
}
