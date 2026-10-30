import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/missions/mission.dart';
import '../../domain/missions/mission_rules.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import 'mission_play_view_model.dart';
import 'widgets/mission_cover.dart';
import 'widgets/stage_widgets.dart';

/// Playing one mission: intro → stages → completion. Buddy narrates, and
/// stops when the child leaves (dispose and the navigator observer both
/// stop speech).
class MissionPlayScreen extends StatefulWidget {
  const MissionPlayScreen({
    super.key,
    required this.mission,
    required this.voice,
    required this.progressRepository,
  });

  final Mission mission;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  static const startLabel = 'Start investigating';
  static const answerLabel = 'Your answer';
  static const pickAllLabel = 'Your answer (pick all that fit)';
  static const checkLabel = 'Check my answer';
  static const nextLabel = 'Next step';
  static const finishLabel = 'Solve the case!';
  static const noMoreHints = 'No more hints. You can do it!';
  static const playAgainLabel = 'Play again';
  static const backLabel = 'Back to missions';
  static const caseSolved = 'Case solved!';
  static const saveFailed =
      "Your result is shown, but it couldn't be saved this time.";

  static String hintLabel(int next, int total) =>
      'Get a hint ($next of $total)';
  static String stepLabel(int step, int total) => 'Step $step of $total';

  @override
  State<MissionPlayScreen> createState() => _MissionPlayScreenState();
}

class _MissionPlayScreenState extends State<MissionPlayScreen> {
  late final MissionPlayViewModel _vm = MissionPlayViewModel(
    mission: widget.mission,
    voice: widget.voice,
    progressRepository: widget.progressRepository,
  );
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Narrate once the page is on screen (after the route push settles).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateIntro();
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
    return CelebrationOverlay(
      listenable: _vm,
      celebrationKey: () =>
          _vm.phase == MissionPhase.complete ? 'solved' : null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mission.title,
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
                    pageKey: '${_vm.phase.name}${_vm.stageIndex}',
                    child: switch (_vm.phase) {
                      MissionPhase.intro => _intro(context),
                      MissionPhase.stage => _stage(context),
                      MissionPhase.complete => _complete(context),
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

  Widget _voiceBar() => MissionVoiceBar(
    canSpeak: _vm.canSpeak,
    isSpeaking: _vm.isSpeaking,
    onHearAgain: _vm.lastSpoken == null ? null : _vm.hearAgain,
    onStop: () => unawaited(_vm.stopSpeaking()),
  );

  Widget _buddyRow(BuddyMood mood) => Row(
    children: [
      Buddy(height: 84, mood: mood, waveOnAppear: false),
      const SizedBox(width: 12),
      Expanded(child: _voiceBar()),
    ],
  );

  // ------------------------------------------------------------- intro

  Widget _intro(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mission = widget.mission;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        MissionCover(art: mission.art, height: 180),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(mission.title, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        _buddyRow(BuddyMood.curious),
        const SizedBox(height: 12),
        Text(mission.intro, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppShapes.sticker(
            AppColors.sunTint,
            depth: 3,
            radius: 18,
          ),
          child: Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Text(mission.objective, style: textTheme.titleMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _vm.start,
          icon: const Icon(Icons.search_rounded),
          label: const Text(MissionPlayScreen.startLabel),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- stage

  Widget _stage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stage = _vm.stage;
    final feedback = _vm.feedback;
    final step = _vm.stageIndex + 1;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          MissionPlayScreen.stepLabel(step, _vm.stageCount),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_vm.stageIndex + (_vm.isSolved ? 1 : 0)) / _vm.stageCount,
            minHeight: 10,
            color: AppColors.leaf,
            backgroundColor: AppColors.leafTint,
            semanticsLabel: 'Mission progress',
          ),
        ),
        const SizedBox(height: 12),
        _buddyRow(
          feedback == null
              ? BuddyMood.thoughtful
              : feedback.correct
              ? BuddyMood.happy
              : BuddyMood.curious,
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
                  child: Text(stage.prompt, style: textTheme.titleMedium),
                ),
              ),
              if (_vm.canSpeak)
                IconButton(
                  tooltip: 'Read the question aloud',
                  onPressed: _vm.readPrompt,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
            ],
          ),
        ),
        if (stage.clues.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Clues', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final clue in stage.clues)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClueCard(
                clue: clue,
                inspected: _vm.inspectedClues.contains(clue.id),
                onInspect: () => _vm.inspectClue(clue.id),
                onRead: () => _vm.readClue(clue.id),
                canSpeak: _vm.canSpeak,
              ),
            ),
        ],
        const SizedBox(height: 16),
        if (stage is! OrderStage) ...[
          Text(
            stage is MultiSelectStage
                ? MissionPlayScreen.pickAllLabel
                : MissionPlayScreen.answerLabel,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
        ],
        _challenge(stage),
        const SizedBox(height: 16),
        ..._hints(textTheme),
        if (feedback != null) ...[
          const SizedBox(height: 12),
          FeedbackPanel(
            result: feedback,
            explanation: feedback.correct && stage is ChoiceStage
                ? stage.explanation
                : null,
          ),
        ],
        const SizedBox(height: 16),
        if (_vm.isSolved)
          FilledButton.icon(
            onPressed: () {
              unawaited(_vm.next());
              _toTop();
            },
            icon: Icon(
              _vm.isLastStage
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              _vm.isLastStage
                  ? MissionPlayScreen.finishLabel
                  : MissionPlayScreen.nextLabel,
            ),
          )
        else
          FilledButton.icon(
            onPressed: _vm.canCheck ? _vm.check : null,
            icon: const Icon(Icons.check_rounded),
            label: const Text(MissionPlayScreen.checkLabel),
          ),
      ],
    );
  }

  Widget _challenge(MissionStage stage) {
    final locked = _vm.isSolved;
    return switch (stage) {
      ChoiceStage(:final choices) => Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final choice in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceTile(
                text: choice.text,
                selected:
                    _vm.selectedChoice == choice.id ||
                    (locked && choice.correct),
                onTap: locked ? null : () => _vm.pickChoice(choice.id),
              ),
            ),
        ],
      ),
      MultiSelectStage(:final choices) => Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final choice in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceTile(
                text: choice.text,
                multi: true,
                selected: _vm.selectedChoices.contains(choice.id),
                onTap: locked ? null : () => _vm.toggleChoice(choice.id),
              ),
            ),
        ],
      ),
      OrderStage(:final pieces) => OrderBuilder(
        total: pieces.length,
        placed: _vm.placedPieces,
        remaining: _vm.remainingPieces,
        onPlace: _vm.placePiece,
        onRemove: _vm.removePlacedPiece,
        onClear: _vm.clearOrder,
        enabled: !locked,
      ),
    };
  }

  List<Widget> _hints(TextTheme textTheme) {
    final total = _vm.stage.hints.length;
    return [
      for (final (i, hint) in _vm.visibleHints.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sunTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hint ${i + 1}: $hint',
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      if (!_vm.isSolved)
        Align(
          alignment: Alignment.centerLeft,
          child: _vm.hasMoreHints
              ? OutlinedButton.icon(
                  onPressed: _vm.showHint,
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: Text(
                    MissionPlayScreen.hintLabel(_vm.hintsShown + 1, total),
                  ),
                )
              : Text(
                  MissionPlayScreen.noMoreHints,
                  style: textTheme.bodyMedium,
                ),
        ),
    ];
  }

  // ---------------------------------------------------------- complete

  Widget _complete(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final score = _vm.score!;
    final mission = widget.mission;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Center(child: Buddy(height: 140, mood: BuddyMood.excited)),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            MissionPlayScreen.caseSolved,
            textAlign: .center,
            style: textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        _BadgeCard(
          badge: mission.badge,
          points: score.total,
          max: _vm.maxPoints,
        ),
        const SizedBox(height: 16),
        _voiceBar(),
        const SizedBox(height: 12),
        Text(mission.solution, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        _ScoreBreakdown(score: score),
        if (_vm.saveStatus == SaveStatus.failed) ...[
          const SizedBox(height: 12),
          Text(MissionPlayScreen.saveFailed, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            _vm.replay();
            _toTop();
          },
          icon: const Icon(Icons.replay_rounded),
          label: const Text(MissionPlayScreen.playAgainLabel),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.map_rounded),
          label: const Text(MissionPlayScreen.backLabel),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.points,
    required this.max,
  });

  final String badge;
  final int points;
  final int max;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShapes.sticker(AppColors.sunTint),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.sun,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.ink,
                width: AppShapes.outlineWidth,
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 38,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text('Badge earned', style: textTheme.bodyMedium),
                Text(badge, style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('$points of $max points', style: textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.score});

  final MissionScore score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget row(String label, int points) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
          Text('+$points', style: textTheme.titleMedium),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 18),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text('How you earned your points', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          row('Solving the case', score.completion),
          row('Steps solved', score.stagesSolved),
          row('Careful reasoning (right first time)', score.firstTryBonus),
          row('Clues inspected', score.cluesInspected),
          const Divider(),
          row('Total', score.total),
          const SizedBox(height: 4),
          Text(
            'Hints never cost points. Asking for help is what good '
            'detectives do!',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
