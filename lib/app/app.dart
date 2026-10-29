import 'package:flutter/material.dart';

import '../domain/voice/buddy_listener.dart';
import '../domain/voice/buddy_voice.dart';
import '../ui/core/themes/app_theme.dart';
import '../ui/core/widgets/buddy/buddy.dart';
import '../ui/core/widgets/placeholder_screen.dart';
import '../ui/home/home_destination.dart';
import '../ui/home/home_screen.dart';
import '../ui/missions/missions_screen.dart';
import '../ui/parent_zone/parent_zone_screen.dart';
import 'app_dependencies.dart';
import 'routes.dart';
import 'voice_navigator_observer.dart';

/// Root widget: theme, navigation and the composition root.
///
/// Owns the single [BuddyVoice] and [BuddyListener] and makes sure speech and
/// listening stop when the user navigates, when the app is interrupted or
/// hidden, and when it closes.
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
  late final BuddyListener _listener = BuddyListener(
    recognizer: widget.dependencies.speechRecognition,
    settings: widget.dependencies.settingsStore,
    voice: _voice,
  );
  late final VoiceNavigatorObserver _voiceObserver = VoiceNavigatorObserver(
    _voice,
    _listener,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      // Covers calls, the app switcher, the screen turning off, and leaving
      // the app.
      onInactive: _stopVoiceAndListening,
      onHide: _stopVoiceAndListening,
    );
  }

  void _stopVoiceAndListening() {
    _listener.cancel().ignore();
    _voice.stop().ignore();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _listener.dispose();
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
          responseProvider: dependencies.responseProvider,
          voice: _voice,
          listener: _listener,
        ),
        Routes.missions: (_) => MissionsScreen(
          missionRepository: dependencies.missionRepository,
          progressRepository: dependencies.progressRepository,
          voice: _voice,
        ),
        // Destinations not built yet still show a "coming soon" page.
        for (final destination in HomeDestination.values)
          if (destination.route != Routes.missions)
            destination.route: (_) => PlaceholderScreen(
              title: destination.title,
              message: destination.comingSoonMessage,
            ),
        // Placeholder: reached from Buddy's "Let's play a quiz" answer.
        Routes.quiz: (_) => const PlaceholderScreen(
          title: 'Quiz Time',
          message:
              'Buddy is still writing the questions. Quizzes are coming '
              'soon!',
          mood: BuddyMood.excited,
        ),
        // Behind a parent check. Only the voice-recognition setting so far.
        Routes.parentZone: (_) => ParentZoneScreen(listener: _listener),
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
