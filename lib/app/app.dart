import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/games/games.dart';
import '../domain/parent/parent_gate.dart';
import '../domain/settings/display_settings.dart';
import '../domain/voice/buddy_listener.dart';
import '../domain/voice/buddy_voice.dart';
import '../domain/wardrobe/buddy_wardrobe.dart';
import '../ui/core/themes/app_theme.dart';
import '../ui/core/widgets/buddy/buddy.dart';
import '../ui/core/widgets/buddy/buddy_look_scope.dart';
import '../ui/core/widgets/placeholder_screen.dart';
import '../ui/creative/creative_hub_screen.dart';
import '../ui/discoveries/discoveries_screen.dart';
import '../ui/games/dino_hub_screen.dart';
import '../ui/games/game_zone_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/missions/missions_screen.dart';
import '../ui/parent_zone/parent_zone_screen.dart';
import '../ui/quiz/quiz_hub_screen.dart';
import '../ui/stories/stories_screen.dart';
import '../ui/wardrobe/wardrobe_screen.dart';
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
    sounds: widget.dependencies.soundEffects,
  );
  late final BuddyListener _listener = BuddyListener(
    recognizer: widget.dependencies.speechRecognition,
    settings: widget.dependencies.settingsStore,
    voice: _voice,
  );
  late final DisplaySettings _display = DisplaySettings(
    settings: widget.dependencies.settingsStore,
  );

  late final BuddyWardrobe _wardrobe = BuddyWardrobe(
    progressRepository: widget.dependencies.progressRepository,
  );

  /// Kept for the whole session so its pause after wrong answers cannot be
  /// skipped by leaving and reopening the Parent Zone.
  final ParentGate _parentGate = ParentGate();
  late final VoiceNavigatorObserver _voiceObserver = VoiceNavigatorObserver(
    _voice,
    _listener,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Load saved settings now, so screens never show a default before the
    // saved choice (e.g. the Parent Zone switches).
    unawaited(_voice.ready);
    unawaited(_listener.ready);
    unawaited(_display.ready);
    unawaited(_wardrobe.load());
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
    _display.dispose();
    _wardrobe.dispose();
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
      // The grown-up "calmer animations" setting adds to the phone's own.
      builder: (context, child) => ListenableBuilder(
        listenable: _display,
        builder: (context, _) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              disableAnimations:
                  media.disableAnimations || _display.reduceMotion,
            ),
            child: BuddyLookScope(wardrobe: _wardrobe, child: child!),
          );
        },
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => HomeScreen(
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          responseProvider: dependencies.responseProvider,
          voice: _voice,
          listener: _listener,
        ),
        Routes.missions: (_) => MissionsScreen(
          missionRepository: dependencies.missionRepository,
          progressRepository: dependencies.progressRepository,
          voice: _voice,
        ),
        Routes.stories: (_) => StoriesScreen(
          storyRepository: dependencies.storyRepository,
          progressRepository: dependencies.progressRepository,
          voice: _voice,
        ),
        Routes.games: (_) =>
            GameZoneScreen(progressRepository: dependencies.progressRepository),
        Routes.arena: (_) => ArenaScreen(
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.maze: (_) => ArenaScreen(
          only: GameKind.maze,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.robot: (_) => ArenaScreen(
          only: GameKind.robot,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.words: (_) => ArenaScreen(
          only: GameKind.words,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.sounds: (_) => ArenaScreen(
          only: GameKind.sounds,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.four: (_) => ArenaScreen(
          only: GameKind.four,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.number: (_) => ArenaScreen(
          only: GameKind.number,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.sort: (_) => ArenaScreen(
          only: GameKind.sort,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.circuit: (_) => ArenaScreen(
          only: GameKind.circuit,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.sudoku: (_) => ArenaScreen(
          only: GameKind.sudoku,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.dino: (_) => DinoHubScreen(
          progressRepository: dependencies.progressRepository,
          voice: _voice,
        ),
        Routes.wardrobe: (_) => WardrobeScreen(
          progressRepository: dependencies.progressRepository,
          missionRepository: dependencies.missionRepository,
          storyRepository: dependencies.storyRepository,
          quizRepository: dependencies.quizRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
          wardrobe: _wardrobe,
        ),
        Routes.discoveries: (_) => DiscoveriesScreen(
          progressRepository: dependencies.progressRepository,
          missionRepository: dependencies.missionRepository,
          storyRepository: dependencies.storyRepository,
          quizRepository: dependencies.quizRepository,
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        Routes.creative: (_) => CreativeHubScreen(
          creationsRepository: dependencies.creationsRepository,
          voice: _voice,
        ),
        // Reached from Home and from Buddy's "Let's play a quiz" answer.
        Routes.quiz: (_) => QuizHubScreen(
          quizRepository: dependencies.quizRepository,
          progressRepository: dependencies.progressRepository,
          voice: _voice,
        ),
        // Behind a parent check.
        Routes.parentZone: (_) => ParentZoneScreen(
          gate: _parentGate,
          voice: _voice,
          listener: _listener,
          display: _display,
          progressRepository: dependencies.progressRepository,
          creationsRepository: dependencies.creationsRepository,
          wardrobe: _wardrobe,
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
