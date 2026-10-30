import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/buddy/buddy.dart';
import '../../missions/widgets/stage_widgets.dart';
import '../creative_view_models.dart';

/// Buddy with Hear again / Stop talking.
class CreativeBuddyRow extends StatelessWidget {
  const CreativeBuddyRow({super.key, required this.vm, this.mood});

  final CreativeActivityViewModel vm;
  final BuddyMood? mood;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Buddy(
        height: 72,
        mood:
            mood ??
            (vm.saveStatus == CreationSaveStatus.saved
                ? BuddyMood.excited
                : BuddyMood.happy),
        waveOnAppear: false,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: MissionVoiceBar(
          canSpeak: vm.canSpeak,
          isSpeaking: vm.isSpeaking,
          onHearAgain: vm.lastSpoken == null ? null : vm.hearAgain,
          onStop: () => unawaited(vm.stopSpeaking()),
        ),
      ),
    ],
  );
}

/// A choice button: filled when selected, outlined otherwise.
class CreativeOption extends StatelessWidget {
  const CreativeOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.swatch,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Shown as a coloured dot before the label (colour choices).
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    final dot = swatch;
    final child = Row(
      mainAxisSize: .min,
      children: [
        if (dot != null) ...[
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(child: Text(label)),
      ],
    );
    return Semantics(
      selected: selected,
      child: selected
          ? FilledButton(onPressed: onTap, child: child)
          : OutlinedButton(onPressed: onTap, child: child),
    );
  }
}

/// A labelled group of options.
class CreativeOptionGroup extends StatelessWidget {
  const CreativeOptionGroup({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: children),
    ],
  );
}

/// Shown after saving, or when saving could not happen.
class CreativeSaveNote extends StatelessWidget {
  const CreativeSaveNote({
    super.key,
    required this.status,
    required this.onAnother,
    required this.anotherLabel,
  });

  final CreationSaveStatus status;
  final VoidCallback onAnother;
  final String anotherLabel;

  static const savedTitle = 'Saved to My Creations!';
  static const fullText = CreativeActivityViewModel.fullLine;
  static const failedText =
      "Buddy couldn't save it this time. Please try again.";
  static const backLabel = 'Back to Creative Island';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (Color color, IconData icon, String text) = switch (status) {
      CreationSaveStatus.saved => (
        AppColors.leafTint,
        Icons.check_circle_rounded,
        savedTitle,
      ),
      CreationSaveStatus.full => (
        AppColors.sunTint,
        Icons.inventory_2_rounded,
        fullText,
      ),
      _ => (AppColors.coralTint, Icons.error_outline_rounded, failedText),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppShapes.sticker(color, depth: 3, radius: 18),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.ink),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: textTheme.titleMedium)),
              ],
            ),
            if (status == CreationSaveStatus.saved) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAnother,
                icon: const Icon(Icons.add_rounded),
                label: Text(anotherLabel),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(backLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
