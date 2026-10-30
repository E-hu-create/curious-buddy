import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/games/games.dart';
import '../../domain/games/maze.dart';
import '../../domain/games/robot.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import 'game_view_models.dart';
import 'how_to_play.dart';
import 'widgets/game_parts.dart';
import 'widgets/maze_art.dart';
import 'widgets/robot_art.dart';

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
    this.autoGuide = true,
  });

  final GameLevel level;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  /// Injected in tests for a predictable game.
  final Random? random;

  /// Whether the instructions open by themselves on a first game.
  final bool autoGuide;

  static const nextQuestion = 'Next';
  static const seeStars = 'See my stars';
  static const whatNext = 'What comes next?';
  static const firstPicture = 'First picture';
  static const secondPicture = 'Second picture: tap what changed';
  static const missNote = "That one didn't change. Keep looking!";

  static const goLabel2 = 'Go!';
  static const undoLabel = 'Undo';
  static const clearLabel = 'Clear';
  static const twiceLabel = 'Twice';
  static const nextPuzzle = 'Next puzzle';

  static String puzzleLabel(int n, int total) => 'Puzzle $n of $total';
  static String linesLabel(int used, int limit) => 'Your code: $used of $limit';
  static String lineLabel(int n, RobotStep step) => 'Line $n: ${step.label}';
  static String gridLabel(RobotPuzzle puzzle, int cell) {
    String at(int i) =>
        'row ${i ~/ puzzle.size + 1} column ${i % puzzle.size + 1}';
    final rocks = puzzle.rocks.map(at).join(', ');
    return 'Robot at ${at(cell)}. Flag at ${at(puzzle.goal)}. Rocks at $rocks.';
  }

  static String gemsLabel(int found, int all) => 'Gems: $found of $all';
  static String goLabel(MazeDirection direction) => 'Go ${direction.label}';
  static String whereLabel(MazeGame game) {
    final ways = game.openings[game.cell].map((d) => d.label).join(', ');
    return 'Buddy is in row ${game.row + 1}, column ${game.column + 1}. '
        'Open ways: $ways.';
  }

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
    GameKind.maze => MazeViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.robot => RobotViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_begin()));
  }

  /// The first time a child plays this game, explain it before it starts.
  Future<void> _begin() async {
    if (widget.autoGuide && await _isFirstGame() && mounted) {
      await showHowToPlay(
        context,
        guide: HowToPlay.of(widget.level.kind),
        voice: widget.voice,
        buttonLabel: HowToPlaySheet.letsPlayLabel,
      );
    }
    if (mounted) _vm.narrateIntro();
  }

  Future<bool> _isFirstGame() async {
    try {
      final best = (await widget.progressRepository.load()).gameBest;
      return !ArenaRules.levelsOf(
        widget.level.kind,
      ).any((level) => best.containsKey(level.id));
    } on Exception {
      return false;
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextOf(widget.level);
    return GameShell(
      vm: _vm,
      nextButton: next == null ? null : '${GameShell.nextLabel}: ${next.name}',
      nextResult: next,
      onHowToPlay: () => unawaited(
        showHowToPlay(
          context,
          guide: HowToPlay.of(widget.level.kind),
          voice: widget.voice,
        ),
      ),
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => switch (_vm) {
          final MemoryViewModel vm => _MemoryBoard(vm: vm),
          final PatternViewModel vm => _PatternBoard(vm: vm),
          final SpotViewModel vm => _SpotBoard(vm: vm),
          final MazeViewModel vm => _MazeBoard(vm: vm),
          final RobotViewModel vm => _RobotBoard(vm: vm),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
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
                    widthFactor: 0.78,
                    heightFactor: 0.78,
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

// ------------------------------------------------------------- Treasure Maze

class _MazeBoard extends StatefulWidget {
  const _MazeBoard({required this.vm});

  final MazeViewModel vm;

  @override
  State<_MazeBoard> createState() => _MazeBoardState();
}

class _MazeBoardState extends State<_MazeBoard> {
  /// How far the current swipe has moved. Under this it counts as a slip.
  static const _swipeDistance = 16.0;
  Offset _swipe = Offset.zero;

  void _endSwipe() {
    final swipe = _swipe;
    _swipe = Offset.zero;
    if (swipe.distance < _swipeDistance) return;
    widget.vm.go(
      swipe.dx.abs() > swipe.dy.abs()
          ? (swipe.dx > 0 ? MazeDirection.right : MazeDirection.left)
          : (swipe.dy > 0 ? MazeDirection.down : MazeDirection.up),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final game = vm.game;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.gemsLabel(game.collected.length, game.gems.length),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: GamePlayScreen.whereLabel(game),
                liveRegion: true,
                excludeSemantics: true,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _swipe += d.delta,
                  onHorizontalDragEnd: (_) => _endSwipe(),
                  onVerticalDragUpdate: (d) => _swipe += d.delta,
                  onVerticalDragEnd: (_) => _endSwipe(),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: AppShapes.sticker(
                      AppColors.white,
                      depth: 3,
                      radius: 12,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cell = constraints.maxWidth / game.size;
                        return Stack(
                          children: [
                            Positioned.fill(child: MazeArt(game: game)),
                            AnimatedPositioned(
                              duration: AppMotion.isCalm(context)
                                  ? Duration.zero
                                  : AppMotion.quick,
                              curve: Curves.easeOut,
                              left: game.column * cell,
                              top: game.row * cell,
                              width: cell,
                              height: cell,
                              child: Padding(
                                padding: EdgeInsets.all(cell * 0.08),
                                child: FittedBox(
                                  child: Buddy(
                                    height: cell,
                                    waveOnAppear: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: _ArrowButton(vm: vm, direction: MazeDirection.up),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(vm: vm, direction: MazeDirection.left),
            const SizedBox(width: 6),
            _ArrowButton(vm: vm, direction: MazeDirection.down),
            const SizedBox(width: 6),
            _ArrowButton(vm: vm, direction: MazeDirection.right),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.vm, required this.direction});

  final MazeViewModel vm;
  final MazeDirection direction;

  @override
  Widget build(BuildContext context) => _SquareButton(
    label: GamePlayScreen.goLabel(direction),
    icon: _arrowOf(direction),
    onTap: () => vm.go(direction),
  );
}

IconData _arrowOf(MazeDirection direction) => switch (direction) {
  MazeDirection.up => Icons.arrow_upward_rounded,
  MazeDirection.right => Icons.arrow_forward_rounded,
  MazeDirection.down => Icons.arrow_downward_rounded,
  MazeDirection.left => Icons.arrow_back_rounded,
};

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.size = 68,
    this.color = AppColors.sun,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    excludeSemantics: true,
    child: StickerPress(
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: size,
            height: size,
            decoration: AppShapes.sticker(
              onTap == null ? AppColors.white : color,
              depth: 3,
              radius: 18,
            ),
            child: Icon(icon, size: size / 2, color: AppColors.ink),
          ),
        ),
      ),
    ),
  );
}

// ------------------------------------------------------------ Code the Robot

class _RobotBoard extends StatelessWidget {
  const _RobotBoard({required this.vm});

  final RobotViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    final puzzle = game.puzzle;
    final ending = vm.ending;
    final editable = vm.canEdit;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.puzzleLabel(game.round + 1, RobotGame.rounds),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: GamePlayScreen.gridLabel(puzzle, vm.cell),
                excludeSemantics: true,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: AppShapes.sticker(
                    AppColors.white,
                    depth: 3,
                    radius: 12,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cell = constraints.maxWidth / puzzle.size;
                      return Stack(
                        children: [
                          Positioned.fill(child: RobotGridArt(puzzle: puzzle)),
                          AnimatedPositioned(
                            duration: AppMotion.isCalm(context)
                                ? Duration.zero
                                : AppMotion.quick,
                            curve: Curves.easeInOut,
                            left: vm.cell % puzzle.size * cell,
                            top: vm.cell ~/ puzzle.size * cell,
                            width: cell,
                            height: cell,
                            child: Padding(
                              padding: EdgeInsets.all(cell * 0.1),
                              child: FittedBox(child: RobotFigure(size: cell)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          GamePlayScreen.linesLabel(game.code.length, puzzle.limit),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 14),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < puzzle.limit; i++)
                _CodeSlot(
                  number: i + 1,
                  step: i < game.code.length ? game.code[i] : null,
                  active: vm.activeLine == i,
                ),
            ],
          ),
        ),
        if (ending != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppShapes.sticker(
                vm.isSolved ? AppColors.leafTint : AppColors.sunTint,
                depth: 3,
                radius: 14,
              ),
              child: Text(
                RobotViewModel.noteFor(ending),
                style: textTheme.bodyLarge,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (vm.isSolved)
          FilledButton.icon(
            onPressed: () => unawaited(vm.next()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              game.round + 1 < RobotGame.rounds
                  ? GamePlayScreen.nextPuzzle
                  : GamePlayScreen.seeStars,
            ),
          )
        else ...[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final direction in const [
                MazeDirection.left,
                MazeDirection.up,
                MazeDirection.down,
                MazeDirection.right,
              ])
                _SquareButton(
                  label: GamePlayScreen.goLabel(direction),
                  icon: _arrowOf(direction),
                  size: 58,
                  onTap: editable && !game.isFull
                      ? () => vm.add(direction)
                      : null,
                ),
              if (game.allowRepeat)
                _SquareButton(
                  label: GamePlayScreen.twiceLabel,
                  icon: Icons.repeat_rounded,
                  size: 58,
                  color: AppColors.grapeTint,
                  onTap: editable && game.code.isNotEmpty
                      ? vm.toggleRepeat
                      : null,
                ),
              _SquareButton(
                label: GamePlayScreen.undoLabel,
                icon: Icons.undo_rounded,
                size: 58,
                color: AppColors.coralTint,
                onTap: editable && game.code.isNotEmpty ? vm.undo : null,
              ),
              _SquareButton(
                label: GamePlayScreen.clearLabel,
                icon: Icons.delete_outline_rounded,
                size: 58,
                color: AppColors.coralTint,
                onTap: editable && game.code.isNotEmpty ? vm.clear : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: editable && game.code.isNotEmpty
                ? () => unawaited(vm.run())
                : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(GamePlayScreen.goLabel2),
          ),
        ],
      ],
    );
  }
}

class _CodeSlot extends StatelessWidget {
  const _CodeSlot({
    required this.number,
    required this.step,
    required this.active,
  });

  final int number;
  final RobotStep? step;
  final bool active;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final step = this.step;
    return Semantics(
      label: step == null ? null : GamePlayScreen.lineLabel(number, step),
      excludeSemantics: true,
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.sun
              : step == null
              ? AppColors.paper
              : AppColors.brandBlueTint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: step == null ? AppColors.inkSoft : AppColors.ink,
            width: 1.5,
          ),
        ),
        child: step == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _arrowOf(step.direction),
                    size: step.times == 1 ? 24 : 18,
                    color: AppColors.ink,
                  ),
                  if (step.times == 2)
                    Icon(
                      _arrowOf(step.direction),
                      size: 18,
                      color: AppColors.ink,
                    ),
                ],
              ),
      ),
    );
  }
}
