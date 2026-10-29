import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/voice/buddy_listener.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/voice/educational_response_provider.dart';
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
    required this.responseProvider,
    required this.voice,
    required this.listener,
  });

  final ProgressRepository progressRepository;
  final EducationalResponseProvider responseProvider;
  final BuddyVoice voice;
  final BuddyListener listener;

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
    voice: widget.voice,
  );
  late final BuddyChatViewModel _chat = BuddyChatViewModel(
    responder: widget.responseProvider,
    voice: widget.voice,
    greeting: HomeViewModel.greeting,
  );
  late final TalkViewModel _talk = TalkViewModel(listener: widget.listener);
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

  void _open(String route) => Navigator.of(context).pushNamed(route);

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
                      _Header(onGrownUps: () => _open(Routes.parentZone)),
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
                        draft: _talk.draft,
                        draftId: _talk.draftId,
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 24),
                        ExplorerLog(
                          missionsSolved: progress.completedMissionIds.length,
                          storiesFinished: progress.completedStoryIds.length,
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

class _Header extends StatelessWidget {
  const _Header({required this.onGrownUps});

  final VoidCallback onGrownUps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Curious Buddy',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onGrownUps,
          icon: const Icon(Icons.lock_rounded, size: 20),
          label: const Text('Grown-ups'),
        ),
      ],
    );
  }
}
