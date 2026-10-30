import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/games/four_in_a_row.dart';
import '../../domain/games/games.dart';
import '../../domain/games/maze.dart';
import '../../domain/games/number_pop.dart';
import '../../domain/games/robot.dart';
import '../../domain/games/sound_game.dart';
import '../../domain/games/words.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import 'game_view_models.dart';
import 'how_to_play.dart';
import 'widgets/game_parts.dart';
import 'widgets/game_world.dart';
import 'widgets/maze_art.dart';
import 'widgets/picture_art.dart';
import 'widgets/robot_art.dart';
import 'widgets/sound_art.dart';

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

  static const sortWrong = 'Not that group. Try again!';

  static String itemLabel(int n, int total) => 'Thing $n of $total';
  static String groupLabel(String group, int count) => '$group, $count sorted';

  static String roundLabel(int n, int total) => 'Round $n of $total';
  static String targetLabel(int target) => 'Make $target';
  static String toGoLabel(int left) => '$left to go';

  static const yourTurn = 'Your turn';
  static const buddyTurn = 'Buddy is thinking...';
  static const youAre = 'You are the stars. Buddy is the circles.';

  static String columnLabel(int n, int free) =>
      'Column $n, ${free == 0 ? 'full' : '$free free'}';
  static String buddyMoved(int column) =>
      'Buddy dropped in column ${column + 1}.';

  static const playSoundLabel = 'Play sound';
  static const clueLabel = 'Read a clue';
  static const nextSound = 'Next sound';
  static const soundsOffNote =
      'Sounds are turned off, so use the clue. A grown-up can turn them on in '
      'the Parent Zone.';

  static String soundLabel(int n, int total) => 'Sound $n of $total';
  static String notThisLabel(GameSound sound) => "It's not ${sound.title}.";

  static const hintLabel = 'Hint';
  static const nextWord = 'Next word';

  static String wordLabel(int n, int total) => 'Word $n of $total';
  static String slotLabel(int n, String? letter) =>
      'Space $n: ${letter ?? 'empty'}';
  static String tileLabel(String letter) => 'Letter $letter';

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
    GameKind.words => WordViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.sounds => SoundViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.four => FourViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.number => NumberViewModel(
      level: widget.level,
      voice: widget.voice,
      progressRepository: widget.progressRepository,
      random: widget.random,
    ),
    GameKind.sort => SortViewModel(
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
      finishExtra: switch (_vm) {
        final FourViewModel vm => _FourGrid(game: vm.game),
        _ => null,
      },
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
          final WordViewModel vm => _WordBoard(vm: vm),
          final SoundViewModel vm => _SoundBoard(vm: vm),
          final FourViewModel vm => _FourBoard(vm: vm),
          final NumberViewModel vm => _NumberBoard(vm: vm),
          final SortViewModel vm => _SortBoard(vm: vm),
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

// -------------------------------------------------------------- Word Builder

class _WordBoard extends StatelessWidget {
  const _WordBoard({required this.vm});

  final WordViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    final puzzle = game.puzzle;
    final picture = puzzle.picture;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.wordLabel(game.round + 1, WordGame.rounds),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppShapes.sticker(
            AppColors.sunTint,
            depth: 3,
            radius: 16,
          ),
          child: Row(
            children: [
              if (picture != null) ...[
                PictureArt(picture: picture, size: 72),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(puzzle.clue, style: textTheme.bodyLarge)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [
            for (var slot = 0; slot < game.slots.length; slot++)
              _letterSpace(slot),
          ],
        ),
        const SizedBox(height: 14),
        if (game.isSolved) ...[
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppShapes.sticker(
                AppColors.leafTint,
                depth: 3,
                radius: 14,
              ),
              child: Text(
                '$_rightNote ${puzzle.word.toLowerCase()}!',
                style: textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => unawaited(vm.next()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              game.round + 1 < WordGame.rounds
                  ? GamePlayScreen.nextWord
                  : GamePlayScreen.seeStars,
            ),
          ),
        ] else ...[
          if (game.isWrong) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                WordViewModel.wrongNote,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var tile = 0; tile < game.tiles.length; tile++)
                _LetterTile(
                  label: GamePlayScreen.tileLabel(game.tiles[tile]),
                  letter: game.isUsed(tile) ? null : game.tiles[tile],
                  color: AppColors.sun,
                  onTap: game.isUsed(tile) ? null : () => vm.tapTile(tile),
                ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: vm.hint,
            icon: const Icon(Icons.tips_and_updates_rounded),
            label: const Text(GamePlayScreen.hintLabel),
          ),
        ],
      ],
    );
  }

  static const _rightNote = 'Well done! You spelled';

  Widget _letterSpace(int slot) {
    final game = vm.game;
    final tile = game.slots[slot];
    final letter = tile == null ? null : game.tiles[tile];
    final locked = game.locked.contains(slot);
    return _LetterTile(
      label: GamePlayScreen.slotLabel(slot + 1, letter),
      letter: letter,
      color: game.isSolved
          ? AppColors.leafTint
          : game.isWrong
          ? AppColors.coralTint
          : locked
          ? AppColors.grapeTint
          : AppColors.white,
      onTap: letter == null || locked || game.isSolved
          ? null
          : () => vm.tapSlot(slot),
    );
  }
}

/// A square letter. With no letter it is an empty space.
class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.label,
    required this.letter,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String? letter;
  final Color color;
  final VoidCallback? onTap;

  static const _size = AppTheme.minTouchTarget + 2;

  @override
  Widget build(BuildContext context) {
    final letter = this.letter;
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: StickerPress(
        enabled: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: _size,
              height: _size,
              decoration: letter == null
                  ? BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inkSoft, width: 1.5),
                    )
                  : AppShapes.sticker(color, depth: 2, radius: 12),
              child: letter == null
                  ? null
                  : Center(
                      child: FittedBox(
                        child: Text(
                          letter,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------- What's That Sound?

class _SoundBoard extends StatelessWidget {
  const _SoundBoard({required this.vm});

  final SoundViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    final sound = game.sound;
    final solved = game.isSolved;
    final wrong = vm.lastWrong;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.soundLabel(game.round + 1, game.rounds),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (solved)
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppShapes.sticker(
                AppColors.leafTint,
                depth: 3,
                radius: 18,
              ),
              child: Column(
                children: [
                  PopIn(child: SoundArt(sound: sound, size: 110)),
                  const SizedBox(height: 8),
                  Text(sound.title, style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    sound.fact,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (vm.soundsOn)
            PlayButton(
              label: GamePlayScreen.playSoundLabel,
              icon: Icons.volume_up_rounded,
              onPressed: vm.playSound,
            )
          else
            Text(GamePlayScreen.soundsOffNote, style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          if (vm.isClueShowing)
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: AppShapes.sticker(
                  AppColors.sunTint,
                  depth: 3,
                  radius: 14,
                ),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    if (wrong != null)
                      Text(
                        GamePlayScreen.notThisLabel(wrong),
                        style: textTheme.bodyMedium,
                      ),
                    Text(sound.clue, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: vm.showClue,
              icon: const Icon(Icons.lightbulb_rounded),
              label: const Text(GamePlayScreen.clueLabel),
            ),
        ],
        const SizedBox(height: 12),
        if (solved)
          FilledButton.icon(
            onPressed: () => unawaited(vm.next()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              game.round + 1 < game.rounds
                  ? GamePlayScreen.nextSound
                  : GamePlayScreen.seeStars,
            ),
          )
        else
          Row(
            crossAxisAlignment: .start,
            children: [
              for (final (i, option) in game.options.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SoundOption(
                    sound: option,
                    tried: game.wrongPicks.contains(option),
                    onTap: () => vm.pick(option),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _SoundOption extends StatelessWidget {
  const _SoundOption({
    required this.sound,
    required this.tried,
    required this.onTap,
  });

  final GameSound sound;
  final bool tried;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: !tried,
    label: sound.title,
    excludeSemantics: true,
    child: StickerPress(
      enabled: !tried,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tried ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.all(8),
            decoration: AppShapes.sticker(
              tried ? AppColors.coralTint : AppColors.white,
              depth: 3,
              radius: 14,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  SoundArt(sound: sound, size: constraints.maxWidth),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      sound.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ------------------------------------------------------------- Four in a Row

class _FourBoard extends StatelessWidget {
  const _FourBoard({required this.vm});

  final FourViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final last = vm.game.lastBuddyColumn;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          vm.isBuddyThinking
              ? GamePlayScreen.buddyTurn
              : GamePlayScreen.yourTurn,
          style: textTheme.titleLarge,
        ),
        Text(GamePlayScreen.youAre, style: textTheme.bodyMedium),
        const SizedBox(height: 10),
        _FourGrid(
          game: vm.game,
          onColumn: vm.isBuddyThinking
              ? null
              : (column) => unawaited(vm.drop(column)),
        ),
        if (last != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              GamePlayScreen.buddyMoved(last),
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}

/// The board. With [onColumn], each column is a big button.
class _FourGrid extends StatelessWidget {
  const _FourGrid({required this.game, this.onColumn});

  final FourGame game;
  final ValueChanged<int>? onColumn;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: AppShapes.sticker(
          AppColors.brandBlueDeep,
          depth: 3,
          radius: 14,
        ),
        child: Row(
          children: [
            for (var column = 0; column < FourGame.columns; column++)
              Expanded(child: _column(column)),
          ],
        ),
      ),
    ),
  );

  Widget _column(int column) {
    final tap = onColumn;
    final cells = Column(
      children: [
        for (var row = 0; row < FourGame.rows; row++)
          AspectRatio(
            aspectRatio: 1,
            child: _FourCell(
              player: game.board[FourGame.cellOf(row, column)],
              winning: game.winningCells.contains(FourGame.cellOf(row, column)),
            ),
          ),
      ],
    );
    if (tap == null) return ExcludeSemantics(child: cells);
    return Semantics(
      button: true,
      enabled: game.canPlay(column),
      label: GamePlayScreen.columnLabel(column + 1, game.freeIn(column)),
      excludeSemantics: true,
      child: InkWell(
        onTap: game.canPlay(column) ? () => tap(column) : null,
        borderRadius: BorderRadius.circular(10),
        child: cells,
      ),
    );
  }
}

/// A space on the board. The two players differ by shape as well as colour.
class _FourCell extends StatelessWidget {
  const _FourCell({required this.player, required this.winning});

  final FourPlayer? player;
  final bool winning;

  @override
  Widget build(BuildContext context) {
    final player = this.player;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: AnimatedContainer(
        duration: AppMotion.isCalm(context) ? Duration.zero : AppMotion.quick,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: switch (player) {
            null => AppColors.brandBlueTint,
            FourPlayer.child => AppColors.coral,
            FourPlayer.buddy => AppColors.buddyTeal,
          },
          border: Border.all(
            color: winning ? AppColors.sun : AppColors.ink,
            width: winning ? 4 : 1.5,
          ),
        ),
        child: player == FourPlayer.child
            ? const FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.star_rounded, color: AppColors.white),
                ),
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------- Number Pop

class _NumberBoard extends StatelessWidget {
  const _NumberBoard({required this.vm});

  final NumberViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.roundLabel(game.round + 1, NumberPopGame.rounds),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: AppShapes.sticker(AppColors.sun, depth: 3, radius: 16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                GamePlayScreen.targetLabel(game.target),
                style: textTheme.headlineMedium,
              ),
              Text(
                GamePlayScreen.toGoLabel(game.left),
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: AppShapes.sticker(
            AppColors.brandBlue,
            depth: 3,
            radius: 18,
          ),
          child: Column(
            children: [
              for (var row = 0; row < 3; row++)
                Row(
                  children: [
                    for (var column = 0; column < 3; column++)
                      Expanded(
                        child: _Bubble(
                          key: ValueKey('${game.round}-${row * 3 + column}'),
                          sum: game.bubbles[row * 3 + column],
                          popped: game.popped.contains(row * 3 + column),
                          tried: game.tried.contains(row * 3 + column),
                          // A little unevenness, so it feels like bubbles.
                          lift: (row + column).isEven ? 0 : 8,
                          onTap: () => vm.tap(row * 3 + column),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.sum,
    required this.popped,
    required this.tried,
    required this.lift,
    required this.onTap,
  });

  final BubbleSum sum;
  final bool popped;
  final bool tried;
  final double lift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubble = AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 4 + lift, 4, 12 - lift),
        child: AnimatedScale(
          scale: popped ? 0 : 1,
          duration: AppMotion.isCalm(context) ? Duration.zero : AppMotion.quick,
          curve: Curves.easeInBack,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: popped || tried ? null : onTap,
              customBorder: const CircleBorder(),
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.5),
                    colors: tried
                        ? const [AppColors.white, AppColors.coralTint]
                        : const [AppColors.white, AppColors.brandBlueTint],
                  ),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Text(
                        sum.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (popped) return ExcludeSemantics(child: bubble);
    return Semantics(
      button: !tried,
      label: sum.spoken,
      excludeSemantics: true,
      child: bubble,
    );
  }
}

// ------------------------------------------------------------------ Sort It!

class _SortBoard extends StatelessWidget {
  const _SortBoard({required this.vm});

  final SortViewModel vm;

  static const _colors = [
    AppColors.leafTint,
    AppColors.brandBlueTint,
    AppColors.grapeTint,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = vm.game;
    final note = game.lastSorted?.note;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          GamePlayScreen.itemLabel(game.index + 1, game.items.length),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Semantics(
          header: true,
          child: Text(game.set.question, style: textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        PageSwap(
          pageKey: '${game.index}',
          child: Container(
            key: ValueKey(game.index),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            decoration: AppShapes.sticker(AppColors.sun, depth: 4),
            child: Text(
              game.item.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: .start,
          children: [
            for (final (i, group) in game.set.groups.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _SortGroup(
                  name: group,
                  count: game.counts[i],
                  color: _colors[i],
                  tried: game.tried.contains(i),
                  onTap: () => vm.pick(i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (vm.wasWrong)
          Semantics(
            liveRegion: true,
            child: Text(GamePlayScreen.sortWrong, style: textTheme.bodyLarge),
          )
        else if (note != null)
          Semantics(
            liveRegion: true,
            child: Text(note, style: textTheme.bodyLarge),
          ),
      ],
    );
  }
}

class _SortGroup extends StatelessWidget {
  const _SortGroup({
    required this.name,
    required this.count,
    required this.color,
    required this.tried,
    required this.onTap,
  });

  final String name;
  final int count;
  final Color color;
  final bool tried;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: !tried,
      label: GamePlayScreen.groupLabel(name, count),
      excludeSemantics: true,
      child: StickerPress(
        enabled: !tried,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tried ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              decoration: AppShapes.sticker(
                tried ? AppColors.coralTint : color,
                depth: 3,
                radius: 16,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    size: 34,
                    color: AppColors.ink,
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                    ),
                  ),
                  Text('$count', style: textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
