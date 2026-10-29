import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../core/themes/app_colors.dart';

/// The child-facing places reachable from Home, in display order.
///
/// Text is kept short and plain so it reads well aloud when narration is
/// added.
enum HomeDestination {
  missions(
    route: Routes.missions,
    title: 'Mystery Missions',
    subtitle: 'Follow clues and crack puzzles',
    comingSoonMessage:
        'Buddy is still hiding the clues. Mystery Missions are coming soon!',
    icon: Icons.travel_explore_rounded,
    color: AppColors.sun,
    tint: AppColors.sunTint,
  ),
  stories(
    route: Routes.stories,
    title: 'Living Stories',
    subtitle: 'Stories that change with your choices',
    comingSoonMessage:
        'The storytellers are still writing. Living Stories are coming soon!',
    icon: Icons.auto_stories_rounded,
    color: AppColors.grape,
    tint: AppColors.grapeTint,
  ),
  quiz(
    route: Routes.quiz,
    title: 'Quiz Time',
    subtitle: 'Test what you know and earn stars',
    comingSoonMessage: 'Quiz Time is getting ready. Check back soon!',
    icon: Icons.quiz_rounded,
    color: AppColors.brandBlue,
    tint: AppColors.brandBlueTint,
  ),
  creative(
    route: Routes.creative,
    title: 'Creative Island',
    subtitle: 'Build, draw and invent',
    comingSoonMessage:
        'The island workshop is still being built. Creative Island is coming soon!',
    icon: Icons.palette_rounded,
    color: AppColors.leaf,
    tint: AppColors.leafTint,
  ),
  discoveries(
    route: Routes.discoveries,
    title: 'My Discoveries',
    subtitle: 'See everything you have explored',
    comingSoonMessage:
        'Your discovery journal is still being made. Check back soon!',
    icon: Icons.emoji_events_rounded,
    color: AppColors.coral,
    tint: AppColors.coralTint,
  );

  const HomeDestination({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.comingSoonMessage,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String route;
  final String title;
  final String subtitle;
  final String comingSoonMessage;
  final IconData icon;
  final Color color;
  final Color tint;
}
