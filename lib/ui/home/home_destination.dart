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
    tint: AppColors.sunTint,
  ),
  stories(
    route: Routes.stories,
    title: 'Living Stories',
    subtitle: 'Stories that change with your choices',
    tint: AppColors.grapeTint,
  ),
  storyMaker(
    route: Routes.storyMaker,
    title: 'Story Maker',
    subtitle: 'Make a brand-new story of your own',
    tint: AppColors.sunTint,
  ),
  quiz(
    route: Routes.quiz,
    title: 'Quiz Time',
    subtitle: 'Test what you know and earn stars',
    tint: AppColors.brandBlueTint,
  ),
  games(
    route: Routes.games,
    title: 'Game Zone',
    subtitle: 'Quick games and challenges',
    tint: AppColors.coralTint,
  ),
  creative(
    route: Routes.creative,
    title: 'Creative Island',
    subtitle: 'Build, draw and invent',
    tint: AppColors.leafTint,
  ),
  discoveries(
    route: Routes.discoveries,
    title: 'My Discoveries',
    subtitle: 'See everything you have explored',
    tint: AppColors.coralTint,
  ),
  wardrobe(
    route: Routes.wardrobe,
    title: "Buddy's Wardrobe",
    subtitle: 'Dress up Buddy with what you earn',
    tint: AppColors.buddyBelly,
  );

  const HomeDestination({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  final String route;
  final String title;
  final String subtitle;
  final Color tint;
}
