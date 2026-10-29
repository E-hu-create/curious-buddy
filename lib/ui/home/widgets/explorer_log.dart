import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// A small summary of saved progress.
class ExplorerLog extends StatelessWidget {
  const ExplorerLog({
    super.key,
    required this.missionsSolved,
    required this.storiesFinished,
    this.points = 0,
  });

  final int missionsSolved;
  final int storiesFinished;

  /// Total best mission points. Shown once there are any.
  final int points;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Stat(
          icon: Icons.star_rounded,
          color: AppColors.sun,
          label: _count(missionsSolved, 'mission solved', 'missions solved'),
        ),
        _Stat(
          icon: Icons.menu_book_rounded,
          color: AppColors.grape,
          label: _count(storiesFinished, 'story finished', 'stories finished'),
        ),
        if (points > 0)
          _Stat(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.leaf,
            label: _count(points, 'point', 'points'),
          ),
      ],
    );
  }

  static String _count(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 999),
      child: Row(
        mainAxisSize: .min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
