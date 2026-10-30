import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/games/games.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/motion.dart';
import 'game_view_models.dart';
import 'widgets/game_parts.dart';

/// The next level of [level], if any.
GameLevel? _nextOf(GameLevel level) => level.number < ArenaRules.levelsPerGame
    ? GameLevel(level.kind, level.number + 1)
    : null;

/// Runs one Arena level. Pops with the next level on "Next level".
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({
    super.key,
    required this.level,
    required this.voice,
    required this.progressRepository,
    this.random,
  });

  final GameLevel level;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  /// Injected in tests for a predictable game.
  final Random? random;

  static const nextQuestion = 'Next';
  static const seeStars = 'See my stars';
  static const whatNext = 'What comes next?';
  static const firstPicture = 'First picture';
  static const secondPicture = 'Second picture: tap what changed';
  static const missNote = "That one didn't change. Keep looking!";

  static String movesLabel(int moves) =>
      '$moves ${moves == 1 ? 'move' : 'moves'}';
  static String leftLabel(int left) =>
      '$left ${left == 1 ? 'change' : 'changes'} left to find';
  static String questionLabel(int n, int total) => 'Pattern $n of $total';

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late final GamePlayViewModel _vm = switch (widget.level.kind) {
    GameKind.memory => MemoryViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.pattern => PatternViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
    ),
    GameKind.spot => SpotViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateIntro();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameShell(
    vm: _vm,
    nextLevel: _nextOf(widget.level),
    child: ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => switch (_vm) {
        final MemoryViewModel vm => _MemoryBoard(vm: vm),
        final PatternViewModel vm => _PatternBoard(vm: vm),
        final SpotViewModel vm => _SpotBoard(vm: vm),
        _ => const SizedBox.shrink(),
      },
    ),
  );
}

// -------------------------------------------------------------- Memory Match

class _MemoryBoard extends StatelessWidget {
  const _MemoryBoard({required this.vm});

  final MemoryViewModel vm;

  @override
  Widget build(BuildContext context) {
    final game = vm.game;
    final columns = game.cards.length <= 6 ? 3 : 4;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.movesLabel(game.moves),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < game.cards.length; i++)
                  SizedBox(
                    width: size,
                    height: size,
                    child: _MemoryCard(
                      number: i + 1,
                      token: game.cards[i],
                      faceUp: game.isFaceUp(i),
                      matched: game.matched.contains(i),
                      onTap: () => vm.flip(i),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.number,
    required this.token,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  final int number;
  final GameToken token;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: !faceUp,
    label:
        'Card $number, ${faceUp ? token.label : 'face down'}'
        '${matched ? ', matched' : ''}',
    excludeSemantics: true,
    child: StickerPress(
      enabled: !faceUp,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: AppMotion.isCalm(context)
                ? Duration.zero
                : AppMotion.quick,
            alignment: Alignment.center,
            decoration: AppShapes.sticker(
              matched
                  ? AppColors.leafTint
                  : faceUp
                  ? AppColors.white
                  : AppColors.grapeTint,
              depth: 3,
              radius: 16,
            ),
            child: faceUp
                ? FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.6,
                    child: FittedBox(child: TokenView(token: token)),
                  )
                : const Icon(Icons.question_mark_rounded, color: AppColors.ink),
          ),
        ),
      ),
    ),
  );
}

// ------------------------------------------------------------- Pattern Power

class _PatternBoard extends StatelessWidget {
  const _PatternBoard({required this.vm});

  final PatternViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final round = vm.round;
    final picked = vm.picked;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.questionLabel(vm.index + 1, vm.total),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 18),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final token in round.shown)
                TokenView(token: token, size: 36),
              const Icon(
                Icons.help_outline_rounded,
                size: 36,
                color: AppColors.ink,
                semanticLabel: 'What comes next?',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(GamePlayScreen.whatNext, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final option in round.options)
              Semantics(
                button: picked == null,
                label: option.label,
                excludeSemantics: true,
                child: StickerPress(
                  enabled: picked == null,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: picked == null ? () => vm.pick(option) : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: AppShapes.sticker(
                          picked != null && option == round.answer
                              ? AppColors.leafTint
                              : option == picked
                              ? AppColors.coralTint
                              : AppColors.white,
                          depth: 3,
                          radius: 16,
                        ),
                        child: SizedBox(
                          width: 76,
                          height: 76,
                          child: Center(child: TokenView(token: option)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (picked != null) ...[
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppShapes.sticker(
                vm.pickedRight ? AppColors.leafTint : AppColors.sunTint,
                depth: 3,
                radius: 18,
              ),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    vm.pickedRight
                        ? "That's right!"
                        : 'Not quite. The answer is ${round.answer.label}.',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(round.explanation, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => unawaited(vm.next()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              vm.index + 1 < vm.total
                  ? GamePlayScreen.nextQuestion
                  : GamePlayScreen.seeStars,
            ),
          ),
        ],
      ],
    );
  }
}

// ----------------------------------------------------------- Spot the Change

class _SpotBoard extends StatelessWidget {
  const _SpotBoard({required this.vm});

  final SpotViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(GamePlayScreen.leftLabel(game.left), style: textTheme.titleMedium),
        const SizedBox(height: 10),
        Text(GamePlayScreen.firstPicture, style: textTheme.titleSmall),
        const SizedBox(height: 6),
        _SpotGrid(game: game, tokens: game.first),
        const SizedBox(height: 14),
        Text(GamePlayScreen.secondPicture, style: textTheme.titleSmall),
        const SizedBox(height: 6),
        _SpotGrid(
          game: game,
          tokens: game.second,
          found: game.found,
          onTap: vm.tap,
        ),
        if (vm.lastMiss != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(GamePlayScreen.missNote, style: textTheme.bodyLarge),
          ),
        ],
      ],
    );
  }
}

class _SpotGrid extends StatelessWidget {
  const _SpotGrid({
    required this.game,
    required this.tokens,
    this.found = const {},
    this.onTap,
  });

  final SpotGame game;
  final List<GameToken> tokens;
  final Set<int> found;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 16),
      child: Column(
        children: [
          for (var row = 0; row < game.rows; row++)
            Row(
              children: [
                for (var column = 0; column < game.columns; column++)
                  Expanded(
                    child: _tile(row * game.columns + column, row, column, tap),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tile(int index, int row, int column, ValueChanged<int>? tap) {
    final isFound = found.contains(index);
    return Semantics(
      button: tap != null && !isFound,
      label:
          'Row ${row + 1}, column ${column + 1}: ${tokens[index].label}'
          '${isFound ? ', found' : ''}',
      excludeSemantics: true,
      child: InkWell(
        onTap: tap == null ? null : () => tap(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: AppTheme.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFound ? AppColors.leafTint : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TokenView(token: tokens[index], size: 34),
        ),
      ),
    );
  }
}
