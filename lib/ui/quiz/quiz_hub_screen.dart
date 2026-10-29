import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../domain/quiz/quiz.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import 'quiz_hub_view_model.dart';
import 'quiz_play_screen.dart';
import 'widgets/quiz_widgets.dart';

class QuizHubScreen extends StatefulWidget {
  const QuizHubScreen({
    super.key,
    required this.quizRepository,
    required this.progressRepository,
    required this.voice,
  });

  final QuizRepository quizRepository;
  final ProgressRepository progressRepository;
  final BuddyVoice voice;

  static const title = 'Quiz Time';
  static const welcome =
      'Pick a topic and a level. Each level has five questions. Get three '
      'right to open the next level!';
  static const emptyMessage =
      'No quizzes are ready right now. Check back soon!';
  static const errorMessage =
      "Buddy couldn't find the quiz cards. Please try again.";
  static const retryLabel = 'Try again';
  static const playLabel = 'Play';
  static const replayLabel = 'Play again';

  static String starsLabel(int stars, int max) => '$stars of $max stars';
  static String lockedLabel(String previous) =>
      'Get 3 right in $previous to open';
  static String bestLabel(int best, int total) => 'Best: $best of $total';

  @override
  State<QuizHubScreen> createState() => _QuizHubScreenState();
}

class _QuizHubScreenState extends State<QuizHubScreen> {
  late final QuizHubViewModel _vm = QuizHubViewModel(
    quizRepository: widget.quizRepository,
    progressRepository: widget.progressRepository,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _play(QuizTopic topic, QuizLevel level) async {
    var current = level;
    // "Next level" on the summary swaps to the next level's round.
    while (mounted) {
      final next = await Navigator.of(context).push<QuizLevel>(
        MaterialPageRoute(
          settings: RouteSettings(name: '/quiz/${current.id}'),
          builder: (_) => QuizPlayScreen(
            topic: topic,
            level: current,
            voice: widget.voice,
            progressRepository: widget.progressRepository,
            best: _vm.best,
          ),
        ),
      );
      // Show new stars and newly opened levels.
      await _vm.load();
      if (next == null || !mounted) return;
      current = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        QuizHubScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Buddy(height: 96, mood: BuddyMood.excited),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            QuizHubScreen.welcome,
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._body(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (_vm.status) {
      case QuizHubStatus.loading:
        return const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading quizzes',
              ),
            ),
          ),
        ];
      case QuizHubStatus.empty:
        return [Text(QuizHubScreen.emptyMessage, style: textTheme.bodyLarge)];
      case QuizHubStatus.error:
        return [
          Text(QuizHubScreen.errorMessage, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => unawaited(_vm.load()),
              child: const Text(QuizHubScreen.retryLabel),
            ),
          ),
        ];
      case QuizHubStatus.ready:
        return [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.sticker(AppColors.sunTint, depth: 4),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    QuizHubScreen.starsLabel(_vm.stars, _vm.maxStars),
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final summary in _vm.topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _TopicCard(
                summary: summary,
                onPlay: (level) => unawaited(_play(summary.topic, level)),
              ),
            ),
        ];
    }
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.summary, required this.onPlay});

  final QuizTopicSummary summary;
  final ValueChanged<QuizLevel> onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topic = summary.topic;
    final style = quizTopicStyle(topic.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(style.tint),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              QuizTopicBadge(topicId: topic.id),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(topic.title, style: textTheme.titleLarge),
                    ),
                    Text(topic.tagline, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (i, level) in summary.levels.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: _LevelRow(
                summary: level,
                previousName: i == 0
                    ? null
                    : quizLevelName(summary.levels[i - 1].level.difficulty),
                onPlay: () => onPlay(level.level),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.summary,
    required this.previousName,
    required this.onPlay,
  });

  final QuizLevelSummary summary;
  final String? previousName;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = quizLevelName(summary.level.difficulty);
    final best = summary.best;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(name, style: textTheme.titleMedium),
              QuizStars(stars: summary.stars),
              if (best != null)
                Text(
                  QuizHubScreen.bestLabel(best, summary.total),
                  style: textTheme.bodyMedium,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (summary.unlocked)
            FilledButton.icon(
              onPressed: onPlay,
              icon: Icon(
                best == null ? Icons.play_arrow_rounded : Icons.replay_rounded,
              ),
              label: Text(
                '${best == null ? QuizHubScreen.playLabel : QuizHubScreen.replayLabel}'
                ' $name',
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    QuizHubScreen.lockedLabel(previousName ?? ''),
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
