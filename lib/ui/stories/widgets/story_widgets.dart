import 'package:flutter/material.dart';

import '../../../domain/stories/story.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/motion.dart';

/// Each story's own colour, so the three feel like different books.
({Color accent, Color tint}) storyColours(ScenePicture cover) =>
    switch (cover) {
      ScenePicture.forestGrey ||
      ScenePicture.forestOak ||
      ScenePicture.forestStream ||
      ScenePicture.forestRainbow => (
        accent: AppColors.leaf,
        tint: AppColors.leafTint,
      ),
      ScenePicture.lumaCamp ||
      ScenePicture.lumaRidge ||
      ScenePicture.lumaCrater ||
      ScenePicture.lumaSignal => (
        accent: AppColors.grape,
        tint: AppColors.grapeTint,
      ),
      ScenePicture.inventorShed ||
      ScenePicture.inventorWorkshop ||
      ScenePicture.inventorHill ||
      ScenePicture.inventorGarden => (
        accent: AppColors.coral,
        tint: AppColors.coralTint,
      ),
    };

/// One choice, shown as a numbered storybook card.
class StoryChoiceCard extends StatelessWidget {
  const StoryChoiceCard({
    super.key,
    required this.number,
    required this.text,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  final int number;
  final String text;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Choice $number: $text',
      excludeSemantics: true,
      child: StickerPress(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              decoration: AppShapes.sticker(tint, depth: 3, radius: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTheme.minTouchTarget + 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                        ),
                        child: Text(
                          '$number',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text, style: textTheme.titleMedium)),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.ink,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small rounded label, e.g. "New ending!".
class StoryTag extends StatelessWidget {
  const StoryTag({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.ink, width: 1.5),
    ),
    child: Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 18, color: AppColors.ink),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    ),
  );
}
