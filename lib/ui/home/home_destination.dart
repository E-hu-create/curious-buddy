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
    icon: Icons.travel_explore_rounded,
    color: AppColors.sun,
    tint: AppColors.sunTint,
  ),
  stories(
    route: Routes.stories,
    title: 'Living Stories',
    subtitle: 'Stories that change with your choices',
    icon: Icons.auto_stories_rounded,
    color: AppColors.grape,
    tint: AppColors.grapeTint,
  ),
  quiz(
    route: Routes.quiz,
    title: 'Quiz Time',
    subtitle: 'Test what you know and earn stars',
    icon: Icons.quiz_rounded,
    color: AppColors.brandBlue,
    tint: AppColors.brandBlueTint,
  ),
  creative(
    route: Routes.creative,
    title: 'Creative Island',
    subtitle: 'Build, draw and invent',
    icon: Icons.palette_rounded,
    color: AppColors.leaf,
    tint: AppColors.leafTint,
  ),
  discoveries(
    route: Routes.discoveries,
    title: 'My Discoveries',
    subtitle: 'See everything you have explored',
    icon: Icons.emoji_events_rounded,
    color: AppColors.coral,
    tint: AppColors.coralTint,
  ),
  wardrobe(
    route: Routes.wardrobe,
    title: "Buddy's Wardrobe",
    subtitle: 'Dress up Buddy with what you earn',
    icon: Icons.checkroom_rounded,
    color: AppColors.buddyTealLight,
    tint: AppColors.buddyBelly,
  );

  const HomeDestination({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String route;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color tint;
}
