import 'package:flutter/material.dart';

import '../ui/core/themes/app_theme.dart';
import '../ui/core/widgets/buddy/buddy.dart';
import '../ui/core/widgets/placeholder_screen.dart';
import '../ui/home/home_destination.dart';
import '../ui/home/home_screen.dart';
import 'app_dependencies.dart';
import 'routes.dart';

/// Root widget: theme, navigation and the composition root.
///
/// Nothing here may touch the microphone, speech engines or storage at
/// launch. Voice input is only ever started by an explicit child action.
class CuriousBuddyApp extends StatelessWidget {
  const CuriousBuddyApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curious Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => HomeScreen(
          progressRepository: dependencies.progressRepository,
          textToSpeech: dependencies.textToSpeech,
        ),
        for (final destination in HomeDestination.values)
          destination.route: (_) => PlaceholderScreen(
            title: destination.title,
            message: destination.comingSoonMessage,
          ),
        // Placeholder only. The real Parent Zone must sit behind a parent
        // gate (docs/CHILD_SAFETY.md) before it shows any settings or data.
        Routes.parentZone: (_) => const PlaceholderScreen(
          title: 'Parent Zone',
          message:
              'Settings for grown-ups will live here, behind a parent check.',
          mood: BuddyMood.cheerful,
        ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PlaceholderScreen(
          title: 'Oops!',
          message: 'We could not find that page.',
        ),
      ),
    );
  }
}
