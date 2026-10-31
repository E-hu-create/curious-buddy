import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/voice/buddy_listener.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/voice/educational_response_provider.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/buddy/buddy.dart';
import 'buddy_action_routes.dart';
import 'buddy_chat_view_model.dart';
import 'home_destination.dart';
import 'home_view_model.dart';
import 'talk_view_model.dart';
import 'widgets/ask_buddy_panel.dart';
import 'widgets/buddy_greeting.dart';
import 'widgets/destination_grid.dart';
import 'widgets/explorer_log.dart';

/// Home is built around Buddy: his bubble and controls first, then ways to
/// ask him something, then the learning worlds.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.progressRepository,
    this.creationsRepository,
    required this.responseProvider,
    required this.voice,
    required this.listener,
  });

  final ProgressRepository progressRepository;
  final CreationsRepository? creationsRepository;
  final EducationalResponseProvider responseProvider;
  final BuddyVoice voice;
  final BuddyListener listener;

  static const grownUpsLabel = 'Grown-ups';
  static const grownUpsHelp = 'Progress, settings and privacy';
  static const micTitle = 'Can Buddy use the microphone?';
  static const micMessage =
      'Buddy needs the microphone to hear your question. '
      'Your phone will ask if that is okay. A grown-up may need to help.\n\n'
      'Buddy only listens after you tap Talk, and the app does not save '
      'what you say.';
  static const micOkLabel = 'OK';
  static const micNotNowLabel = 'Not now';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _home = HomeViewModel(
    progressRepository: widget.progressRepository,
    creationsRepository: widget.creationsRepository,
    voice: widget.voice,
  );
  late final BuddyChatViewModel _chat = BuddyChatViewModel(
    responder: widget.responseProvider,
    voice: widget.voice,
    greeting: HomeViewModel.greeting,
  );
  late final TalkViewModel _talk = TalkViewModel(
    listener: widget.listener,
    onHeard: (words) => unawaited(_chat.ask(words)),
  );
  late final Listenable _changes = Listenable.merge([_home, _chat, _talk]);

  @override
  void initState() {
    super.initState();
    unawaited(_home.load());
  }

  @override
  void dispose() {
    _talk.dispose();
    _chat.dispose();
    _home.dispose();
    super.dispose();
  }

  BuddyMood get _mood {
    if (_talk.isListening) return BuddyMood.curious;
    if (_chat.hadError) return BuddyMood.surprised;
    return switch (_chat.activity) {
      BuddyActivity.thinking => BuddyMood.thoughtful,
      BuddyActivity.speaking => BuddyMood.happy,
      BuddyActivity.idle => switch (_chat.response?.kind) {
        ResponseKind.fallback => BuddyMood.curious,
        ResponseKind.safety => BuddyMood.thoughtful,
        ResponseKind.answer || null => BuddyMood.happy,
      },
    };
  }

  /// Opens a screen; when the child comes back, refresh progress so new
  /// mission results show up on Home.
  void _open(String route) {
    unawaited(
      Navigator.of(
        context,
      ).pushNamed(route).then((_) => _home.refreshProgress()),
    );
  }

  /// Tap-to-talk: explain first, and only then let Android ask for the
  /// microphone. Nothing is listened to before the child taps Talk.
  Future<void> _startTalking() async {
    final step = await _talk.prepare();
    if (!mounted) return;
    switch (step) {
      case TalkStep.unavailable:
        return;
      case TalkStep.ready:
        await _talk.listen();
      case TalkStep.needsPermission:
        final agreed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(HomeScreen.micTitle),
            content: const Text(HomeScreen.micMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(HomeScreen.micNotNowLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(HomeScreen.micOkLabel),
              ),
            ],
          ),
        );
        if (agreed == true && mounted) await _talk.requestPermissionAndListen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListenableBuilder(
                listenable: _changes,
                builder: (context, _) {
                  final progress = _home.progress;
                  final action = _chat.response?.action;
                  return Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      const AppLogo(),
                      const SizedBox(height: 20),
                      BuddyGreeting(
                        text: _chat.message,
                        mood: _mood,
                        status: _talk.isListening
                            ? BuddyStatus.listening
                            : switch (_chat.activity) {
                                BuddyActivity.thinking => BuddyStatus.thinking,
                                BuddyActivity.speaking => BuddyStatus.talking,
                                BuddyActivity.idle => null,
                              },
                        youAsked: _chat.youAsked,
                        questionHidden: _chat.questionHidden,
                        actionLabel: _chat.response?.actionLabel,
                        onAction: action == null
                            ? null
                            : () => _open(routeForAction(action)),
                        voiceStatus: _home.voiceStatus,
                        isMuted: _home.isMuted,
                        isSpeaking: _chat.activity == BuddyActivity.speaking,
                        // Never talk over a child who is speaking.
                        onReplay: _talk.isListening
                            ? null
                            : () => unawaited(_chat.replay()),
                        onStop: () => unawaited(_chat.stopSpeaking()),
                        onToggleMuted: () => unawaited(_home.toggleMuted()),
                      ),
                      const SizedBox(height: 20),
                      AskBuddyPanel(
                        enabled: _chat.canAsk,
                        suggestions: _chat.suggestions,
                        onAsk: (question) {
                          _talk.clearNotice();
                          unawaited(_chat.ask(question));
                        },
                        onTalk: () => unawaited(_startTalking()),
                        onFinishListening: () => unawaited(_talk.finish()),
                        onCancelListening: () => unawaited(_talk.cancel()),
                        isListening: _talk.isListening,
                        liveWords: _talk.liveWords,
                        notice: _talk.notice,
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 24),
                        ExplorerLog(
                          missionsSolved: progress.completedMissionIds.length,
                          storiesFinished: progress.completedStoryIds.length,
                          points: progress.totalMissionPoints,
                          quizLevels: progress.quizBest.length,
                          creations: _home.creations,
                        ),
                      ],
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        child: Text(
                          'Pick an adventure',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DestinationGrid(
                        destinations: HomeDestination.values,
                        onSelected: (destination) => _open(destination.route),
                      ),
                      const SizedBox(height: 28),
                      _GrownUpsCard(onTap: () => _open(Routes.parentZone)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The way into the Parent Zone. It sits below everything a child plays
/// with, so it is easy for a grown-up to find and out of the way in play.
class _GrownUpsCard extends StatelessWidget {
  const _GrownUpsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: HomeScreen.grownUpsLabel,
      hint: HomeScreen.grownUpsHelp,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShapes.radius),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.sticker(AppColors.white, depth: 3),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.arcade,
                  child: Icon(Icons.lock_rounded, color: AppColors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        HomeScreen.grownUpsLabel,
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        HomeScreen.grownUpsHelp,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
