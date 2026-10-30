import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import 'buddy/buddy_painter.dart';

/// The Curious Buddy logo: Buddy on a golden sun, with the name, on the night
/// sky of the app icon. It never wears the child's outfit, so it stays the
/// same everywhere.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const name = 'Curious Buddy';
  static const _sunSize = 58.0;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(color: AppColors.white);
    return Semantics(
      header: true,
      label: name,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 18, 6),
        decoration: AppShapes.sticker(AppColors.arcade, depth: 4, radius: 40),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _sunSize,
                height: _sunSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.sun,
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  size: const Size(
                    _sunSize *
                        0.82 *
                        BuddyPainter.gridWidth /
                        BuddyPainter.gridHeight,
                    _sunSize * 0.82,
                  ),
                  painter: const BuddyPainter(mood: BuddyMood.happy),
                ),
              ),
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Curious '),
                    TextSpan(
                      text: 'Buddy',
                      style: style?.copyWith(color: AppColors.sun),
                    ),
                  ],
                ),
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
