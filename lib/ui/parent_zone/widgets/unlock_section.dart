import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/access/access_controller.dart';
import '../../core/themes/app_colors.dart';
import 'parent_section.dart';

/// "Full app": the one-time purchase, only ever shown to grown-ups.
class UnlockSection extends StatefulWidget {
  const UnlockSection({super.key, required this.access});

  final AccessController access;

  static const title = 'Full app';
  static const testBuild =
      'This is a test version, so everything is already open. In the '
      'version from Google Play, you can unlock the full app here.';
  static const unlockedNote =
      'The full app is unlocked on this phone. Thank you for supporting '
      'Curious Buddy!';
  static const freeNote =
      'Free for everyone: Buddy\'s answers, 3 stories, Story Maker, '
      '3 missions, the starter level of every quiz, 5 games and Creative '
      'Island. Unlocking adds every story, mission, quiz level and game, '
      'and everything added later.';
  static const promise =
      'One payment, kept for good. No subscriptions, no ads, nothing your '
      'child can buy. Google Play handles the payment and may ask for your '
      'account password.';
  static const unlockLabel = 'Unlock the full app';
  static const restoreLabel = 'Restore an earlier purchase';
  static const priceUnknown = 'The price is shown by Google Play.';
  static String priceLabel(String price) => 'Price: $price, paid once.';

  static const working = 'Talking to Google Play...';
  static const pending =
      'The payment is waiting to go through. The full app unlocks as soon '
      'as it does, even if you close Curious Buddy.';
  static const cancelled = 'No problem. Nothing was bought.';
  static const failed =
      'Google Play could not finish that. Nothing was charged by Curious '
      'Buddy. Please try again later.';
  static const notFound =
      'No earlier purchase was found for the Google account on this phone.';
  static const storeUnavailable =
      "Google Play can't be reached right now. Check the internet "
      'connection, then try again.';

  @override
  State<UnlockSection> createState() => _UnlockSectionState();
}

class _UnlockSectionState extends State<UnlockSection> {
  AccessController get _access => widget.access;

  @override
  void initState() {
    super.initState();
    if (_access.locksOn && !_access.unlocked) unawaited(_access.loadPrice());
  }

  String? _statusText(UnlockStatus status) => switch (status) {
    UnlockStatus.idle => null,
    UnlockStatus.working => UnlockSection.working,
    UnlockStatus.pending => UnlockSection.pending,
    UnlockStatus.cancelled => UnlockSection.cancelled,
    UnlockStatus.failed => UnlockSection.failed,
    UnlockStatus.notFound => UnlockSection.notFound,
    UnlockStatus.storeUnavailable => UnlockSection.storeUnavailable,
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _access,
    builder: (context, _) {
      final busy = _access.status == UnlockStatus.working;
      final status = _statusText(_access.status);
      final price = _access.price;
      return ParentSection(
        icon: Icons.lock_open_rounded,
        title: UnlockSection.title,
        color: _access.unlocked ? AppColors.leafTint : AppColors.white,
        children: [
          if (!_access.locksOn)
            const ParentNote(UnlockSection.testBuild)
          else if (_access.unlocked)
            const ParentNote(UnlockSection.unlockedNote, bold: true)
          else ...[
            const ParentNote(UnlockSection.freeNote),
            const ParentNote(UnlockSection.promise),
            ParentNote(
              price == null
                  ? UnlockSection.priceUnknown
                  : UnlockSection.priceLabel(price),
              bold: true,
            ),
            if (status != null) ParentNote(status, bold: true),
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: busy ? null : () => unawaited(_access.buy()),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text(UnlockSection.unlockLabel),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: busy ? null : () => unawaited(_access.restore()),
              icon: const Icon(Icons.restore_rounded),
              label: const Text(UnlockSection.restoreLabel),
            ),
          ],
        ],
      );
    },
  );
}
