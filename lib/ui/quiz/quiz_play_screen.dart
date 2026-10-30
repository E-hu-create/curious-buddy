import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/quiz/quiz.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import '../missions/widgets/stage_widgets.dart';
import 'quiz_play_view_model.dart';
import 'widgets/quiz_widgets.dart';

/// One round: five questions, then a summary. Pops with the next level when
/// the child taps "Next level", so Quiz Time can open it.
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.topic,
    required this.level,
    required this.voice,
    required this.progressRepository,
    this.best = const {},
  });

  final QuizTopic topic;
  final QuizLevel level;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;
  final Map<String, int> best;

  static const readQuestionTooltip = 'Read the question aloud';
  static const readAnswersLabel = 'Read the answers';
  static const nextLabel = 'Next question';
  static const finishLabel = 'See my score';
  static const playAgainLabel = 'Play again';
  static const nextLevelLabel = 'Next level';
  static const backLabel = 'Back to Quiz Time';
  static const summaryTitle = 'Quiz complete!';
  static const yourAnswers = 'Your answers';
  static const newBest = 'New best score!';
  static const unlockedNext = 'You opened the next level!';
  static const saveFailed =
      "Your score is shown, but it couldn't be saved this time.";

  static String questionLabel(int n, int total) => 'Question $n of $total';
  static String scoreLabel(int correct, int total) =>
      'You got $correct out of $total';
  static String keepGoing(String level) =>
      'Get 3 right to open the next level. You can play $level again '
      'any time.';

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late final QuizPlayViewModel _vm = QuizPlayViewModel(
    topic: widget.topic,
    level: widget.level,
    voice: widget.voice,
    progressRepository: widget.progressRepository,
    best: widget.best,
  );
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateQuestion();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final levelName = quizLevelName(widget.level.difficulty);
    return CelebrationOverlay(
      listenable: _vm,
      celebrationKey: () =>
          _vm.phase == QuizPhase.summary && _vm.stars == 3 ? 'perfect' : null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.topic.title}: $levelName',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: PageSwap(
                    pageKey: _vm.phase == QuizPhase.summary
                        ? 'summary'
                        : 'question${_vm.index}',
                    child: switch (_vm.phase) {
                      QuizPhase.question => _question(context),
                      QuizPhase.summary => _summary(context),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Buddy hops when [hopKey] is given, once per key.
  Widget _buddyRow(BuddyMood mood, {Object? hopKey}) => Row(
    children: [
      Buddy(
        key: hopKey == null ? null : ValueKey(hopKey),
        height: 84,
        mood: mood,
        waveOnAppear: hopKey != null,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: MissionVoiceBar(
          canSpeak: _vm.canSpeak,
          isSpeaking: _vm.isSpeaking,
          onHearAgain: _vm.lastSpoken == null ? null : _vm.hearAgain,
          onStop: () => unawaited(_vm.stopSpeaking()),
        ),
      ),
    ],
  );

  // ----------------------------------------------------------- question

  Widget _question(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = _vm.question;
    final picked = _vm.pickedId;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          QuizPlayScreen.questionLabel(_vm.index + 1, _vm.total),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_vm.index + (_vm.hasPicked ? 1 : 0)) / _vm.total,
            minHeight: 10,
            color: AppColors.brandBlue,
            backgroundColor: AppColors.brandBlueTint,
            semanticsLabel: 'Quiz progress',
          ),
        ),
        const SizedBox(height: 12),
        _buddyRow(
          !_vm.hasPicked
              ? BuddyMood.curious
              : _vm.pickedCorrect
              ? BuddyMood.happy
              : BuddyMood.thoughtful,
          hopKey: _vm.hasPicked && _vm.pickedCorrect ? q.id : null,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 18),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(q.prompt, style: textTheme.titleLarge),
                ),
              ),
              if (_vm.canSpeak)
                IconButton(
                  tooltip: QuizPlayScreen.readQuestionTooltip,
                  onPressed: _vm.readQuestion,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
            ],
          ),
        ),
        if (_vm.canSpeak) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _vm.readAnswers,
              icon: const Icon(Icons.record_voice_over_rounded),
              label: const Text(QuizPlayScreen.readAnswersLabel),
            ),
          ),
        ] else
          const SizedBox(height: 12),
        for (final (i, option) in _vm.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QuizAnswerTile(
              key: ValueKey('${q.id}-${option.id}'),
              letter: QuizPlayViewModel.letters[i],
              text: option.text,
              state: _stateFor(option, picked, q),
              onTap: picked == null ? () => _vm.pick(option.id) : null,
            ),
          ),
        if (picked != null) ...[
          const SizedBox(height: 6),
          QuizResultPanel(
            correct: _vm.pickedCorrect,
            answer: q.answer.text,
            explanation: q.explanation,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              unawaited(_vm.next());
              _toTop();
            },
            icon: Icon(
              _vm.isLast
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              _vm.isLast
                  ? QuizPlayScreen.finishLabel
                  : QuizPlayScreen.nextLabel,
            ),
          ),
        ],
      ],
    );
  }

  static QuizAnswerState _stateFor(
    QuizOption option,
    String? picked,
    QuizQuestion q,
  ) {
    if (picked == null) return QuizAnswerState.idle;
    if (option.id == picked) {
      return option.id == q.answerId
          ? QuizAnswerState.right
          : QuizAnswerState.wrong;
    }
    if (option.id == q.answerId) return QuizAnswerState.revealed;
    return QuizAnswerState.dimmed;
  }

  // ------------------------------------------------------------ summary

  Widget _summary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final levelName = quizLevelName(widget.level.difficulty);
    final next = _vm.nextLevel;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Center(
          child: Buddy(
            height: 130,
            mood: _vm.passed ? BuddyMood.excited : BuddyMood.happy,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppShapes.sticker(AppColors.sunTint, depth: 4),
          child: Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  QuizPlayScreen.summaryTitle,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                QuizPlayScreen.scoreLabel(_vm.correctCount, _vm.total),
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              QuizStars(stars: _vm.stars, size: 36, animate: true),
              const SizedBox(height: 8),
              Text(
                _vm.summaryMessage(),
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (_vm.isNewBest && _vm.previousBest != null) ...[
                const SizedBox(height: 6),
                Text(
                  QuizPlayScreen.newBest,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              if (!_vm.passed && next != null) ...[
                const SizedBox(height: 6),
                Text(
                  QuizPlayScreen.keepGoing(levelName),
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        if (_vm.saveStatus == QuizSaveStatus.failed) ...[
          const SizedBox(height: 12),
          Text(QuizPlayScreen.saveFailed, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        if (next != null && _vm.nextUnlocked) ...[
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(next),
            icon: const Icon(Icons.arrow_upward_rounded),
            label: Text(
              '${QuizPlayScreen.nextLevelLabel}: '
              '${quizLevelName(next.difficulty)}',
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: () {
            _vm.replay();
            _toTop();
          },
          icon: const Icon(Icons.replay_rounded),
          label: const Text(QuizPlayScreen.playAgainLabel),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text(QuizPlayScreen.backLabel),
        ),
        const SizedBox(height: 20),
        Text(QuizPlayScreen.yourAnswers, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final (i, record) in _vm.records.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerReview(number: i + 1, record: record),
          ),
      ],
    );
  }
}

class _AnswerReview extends StatelessWidget {
  const _AnswerReview({required this.number, required this.record});

  final int number;
  final QuizAnswerRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = record.question;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record.correct ? AppColors.leafTint : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(
                record.correct
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: AppColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$number. ${q.prompt}',
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record.correct
                ? 'You said: ${record.picked.text}. Right!'
                : 'You said: ${record.picked.text}. '
                      'The answer: ${q.answer.text}.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
