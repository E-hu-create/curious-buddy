import 'package:flutter/material.dart';

import '../ui/core/themes/app_theme.dart';
import '../ui/core/widgets/placeholder_screen.dart';
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
        Routes.home: (_) => const PlaceholderScreen(
          title: 'Curious Buddy',
          message: 'Foundation build. Adventures are on the way!',
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
