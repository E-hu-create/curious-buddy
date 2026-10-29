import 'package:flutter/material.dart';

import '../domain/voice/buddy_voice.dart';
import '../ui/core/themes/app_theme.dart';
import '../ui/core/widgets/buddy/buddy.dart';
import '../ui/core/widgets/placeholder_screen.dart';
import '../ui/home/home_destination.dart';
import '../ui/home/home_screen.dart';
import 'app_dependencies.dart';
import 'routes.dart';
import 'voice_navigator_observer.dart';

/// Root widget: theme, navigation and the composition root.
///
/// Owns the single [BuddyVoice] and makes sure speech stops when the user
/// navigates, when the app is hidden, and when it closes. Nothing here may
/// touch the microphone.
class CuriousBuddyApp extends StatefulWidget {
  const CuriousBuddyApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<CuriousBuddyApp> createState() => _CuriousBuddyAppState();
}

class _CuriousBuddyAppState extends State<CuriousBuddyApp> {
  late final BuddyVoice _voice = BuddyVoice(
    textToSpeech: widget.dependencies.textToSpeech,
    settings: widget.dependencies.settingsStore,
  );
  late final VoiceNavigatorObserver _voiceObserver = VoiceNavigatorObserver(
    _voice,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      // Covers calls, the app switcher, the screen turning off, and leaving
      // the app.
      onInactive: _stopVoice,
      onHide: _stopVoice,
    );
  }

  void _stopVoice() => _voice.stop().ignore();

  @override
  void dispose() {
    _lifecycle.dispose();
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return MaterialApp(
      title: 'Curious Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorObservers: [_voiceObserver],
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => HomeScreen(
          progressRepository: dependencies.progressRepository,
          voice: _voice,
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
          mood: BuddyMood.thoughtful,
        ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PlaceholderScreen(
          title: 'Oops!',
          message: 'We could not find that page.',
          mood: BuddyMood.surprised,
        ),
      ),
    );
  }
}
