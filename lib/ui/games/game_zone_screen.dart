import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/games/dino.dart';
import '../../domain/games/game_content.dart';
import '../../domain/games/games.dart';
import '../../domain/games/maze.dart';
import '../../domain/games/sound_game.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import '../creative/drawing_screen.dart';
import '../quiz/widgets/quiz_widgets.dart';
import 'game_play_screen.dart';
import 'how_to_play.dart';
import 'widgets/dino_art.dart';
import 'widgets/game_world.dart';
import 'widgets/maze_art.dart';
import 'widgets/picture_art.dart';
import 'widgets/robot_art.dart';
import 'widgets/sound_art.dart';

/// The way into every game.
class GameZoneScreen extends StatefulWidget {
  const GameZoneScreen({super.key, required this.progressRepository});

  final ProgressRepository progressRepository;

  static const title = 'Game Zone';
  static const welcome = 'Ready to play? Pick a game!';
  static const arenaTitle = "Buddy's Challenge Arena";
  static const arenaText = 'Quick games for your memory, logic and eyes.';
  static const arenaLabel = 'Enter the Arena';
  static const dinoTitle = 'Dino Discovery';
  static const dinoText =
      'Explore prehistoric places and name their creatures.';
  static const dinoLabel = 'Start exploring';
  static const mazeLabel = 'Find the treasure';
  static const robotLabel = 'Start coding';
  static const wordsLabel = 'Build a word';
  static const soundsLabel = 'Start listening';
  static const fourLabel = 'Beat Buddy';
  static const numberLabel = 'Start popping';

  static String starsLabel(int stars, int all) => '$stars of $all stars';
  static String nextRankLabel(int stars, GameRank next) =>
      '${next.stars - stars} more to ${next.label}';

  @override
  State<GameZoneScreen> createState() => _GameZoneScreenState();
}

class _GameZoneScreenState extends State<GameZoneScreen> {
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final progress = await widget.progressRepository.load();
      if (!mounted) return;
      setState(() => _stars = ArenaRules.totalStars(progress.gameBest));
    } on Exception {
      // The games still open; each explains the problem itself.
    }
  }

  Future<void> _open(String route) async {
    await Navigator.of(context).pushNamed(route);
    await _load();
  }

  @override
  Widget build(BuildContext context) => GameWorld(
    title: GameZoneScreen.title,
    children: [
      Row(
        children: [
          const Buddy(height: 96, mood: BuddyMood.excited),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              GameZoneScreen.welcome,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _Scoreboard(stars: _stars),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.leafTint,
        art: const _DinoTileArt(),
        title: GameZoneScreen.dinoTitle,
        text: GameZoneScreen.dinoText,
        button: PlayButton(
          label: GameZoneScreen.dinoLabel,
          icon: Icons.explore_rounded,
          onPressed: () => unawaited(_open(Routes.dino)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.sunTint,
        art: const _MazeTileArt(),
        title: GameKind.maze.title,
        text: GameKind.maze.tagline,
        button: PlayButton(
          label: GameZoneScreen.mazeLabel,
          icon: Icons.diamond_rounded,
          onPressed: () => unawaited(_open(Routes.maze)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.grapeTint,
        art: const _RobotTileArt(),
        title: GameKind.robot.title,
        text: GameKind.robot.tagline,
        button: PlayButton(
          label: GameZoneScreen.robotLabel,
          icon: Icons.smart_toy_rounded,
          onPressed: () => unawaited(_open(Routes.robot)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.coralTint,
        art: const _WordTileArt(),
        title: GameKind.words.title,
        text: GameKind.words.tagline,
        button: PlayButton(
          label: GameZoneScreen.wordsLabel,
          icon: Icons.abc_rounded,
          onPressed: () => unawaited(_open(Routes.words)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.leafTint,
        art: const _FourTileArt(),
        title: GameKind.four.title,
        text: GameKind.four.tagline,
        button: PlayButton(
          label: GameZoneScreen.fourLabel,
          icon: Icons.grid_on_rounded,
          onPressed: () => unawaited(_open(Routes.four)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.coralTint,
        art: const _NumberTileArt(),
        title: GameKind.number.title,
        text: GameKind.number.tagline,
        button: PlayButton(
          label: GameZoneScreen.numberLabel,
          icon: Icons.bubble_chart_rounded,
          onPressed: () => unawaited(_open(Routes.number)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.brandBlueTint,
        art: const _ArenaTileArt(),
        title: GameZoneScreen.arenaTitle,
        text: GameZoneScreen.arenaText,
        button: PlayButton(
          label: GameZoneScreen.arenaLabel,
          icon: Icons.sports_esports_rounded,
          onPressed: () => unawaited(_open(Routes.arena)),
        ),
      ),
      const SizedBox(height: 16),
      _GameTile(
        color: AppColors.grapeTint,
        art: const _SoundTileArt(),
        title: GameKind.sounds.title,
        text: GameKind.sounds.tagline,
        button: PlayButton(
          label: GameZoneScreen.soundsLabel,
          icon: Icons.hearing_rounded,
          onPressed: () => unawaited(_open(Routes.sounds)),
        ),
      ),
    ],
  );
}

/// The player's stars and rank. Nothing here can go down.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rank = GameRank.of(stars);
    final next = rank.next;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.sunTint, depth: 3),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 40,
            color: AppColors.ink,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(rank.label, style: textTheme.titleLarge),
                Text(
                  GameZoneScreen.starsLabel(stars, ArenaRules.allStars),
                  style: textTheme.bodyMedium,
                ),
                if (next != null)
                  Text(
                    GameZoneScreen.nextRankLabel(stars, next),
                    style: textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.color,
    required this.art,
    required this.title,
    required this.text,
    required this.button,
  });

  final Color color;
  final Widget art;
  final String title;
  final String text;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopIn(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: AppShapes.sticker(color),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            art,
            const SizedBox(height: 10),
            Semantics(
              header: true,
              child: Text(title, style: textTheme.titleLarge),
            ),
            const SizedBox(height: 2),
            Text(text, style: textTheme.bodyLarge),
            const SizedBox(height: 10),
            button,
          ],
        ),
      ),
    );
  }
}

class _DinoTileArt extends StatelessWidget {
  const _DinoTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (context, constraints) => DinoScene(
        place: DinoPlace.openPlains,
        children: [
          Align(
            alignment: const Alignment(-0.85, 0.8),
            child: DinoArt(
              creature: DinoCreature.triceratops,
              width: constraints.maxWidth * 0.42,
            ),
          ),
          Align(
            alignment: const Alignment(0.9, 0.75),
            child: DinoArt(
              creature: DinoCreature.tyrannosaurus,
              width: constraints.maxWidth * 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}

/// A small maze, the same every time.
class _MazeTileArt extends StatelessWidget {
  const _MazeTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 170,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MazeArt(game: MazeGame(size: 5, gems: 2, random: Random(7))),
            const Align(
              alignment: Alignment.topLeft,
              child: Buddy(height: 28, waveOnAppear: false),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The robot and a line of code.
class _RobotTileArt extends StatelessWidget {
  const _RobotTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grape,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Row(
          children: [
            const RobotFigure(size: 110),
            const SizedBox(width: 14),
            for (final icon in const [
              Icons.arrow_forward_rounded,
              Icons.arrow_upward_rounded,
              Icons.flag_rounded,
            ])
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(left: 6),
                decoration: AppShapes.sticker(
                  AppColors.sun,
                  depth: 3,
                  radius: 14,
                ),
                child: Icon(icon, color: AppColors.ink, size: 32),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Letter tiles falling into place.
class _WordTileArt extends StatelessWidget {
  const _WordTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Row(
          children: [
            for (final (letter, turn) in const [
              ('W', -0.12),
              ('O', 0.08),
              ('R', -0.06),
              ('D', 0.12),
              ('S', -0.1),
            ])
              Transform.rotate(
                angle: turn,
                child: Container(
                  width: 62,
                  height: 62,
                  margin: const EdgeInsets.all(3),
                  alignment: Alignment.center,
                  decoration: AppShapes.sticker(
                    AppColors.sun,
                    depth: 3,
                    radius: 12,
                  ),
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// A speaker, and some of the things that make sounds.
class _SoundTileArt extends StatelessWidget {
  const _SoundTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.buddyTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, size: 84, color: AppColors.ink),
            for (final sound in const [
              GameSound.rooster,
              GameSound.thunder,
              GameSound.train,
            ])
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: AppShapes.sticker(
                  AppColors.white,
                  depth: 3,
                  radius: 14,
                ),
                child: SoundArt(sound: sound, size: 72),
              ),
          ],
        ),
      ),
    ),
  );
}

/// A winning line of stars on the board.
class _FourTileArt extends StatelessWidget {
  const _FourTileArt();

  static const _rows = [
    [null, null, null, null, null],
    [null, false, null, null, null],
    [false, false, true, null, false],
    [true, true, true, true, false],
  ];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.brandBlueDeep,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Column(
          children: [
            for (final row in _rows)
              Row(
                children: [
                  for (final star in row)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (star) {
                          null => AppColors.brandBlueTint,
                          true => AppColors.coral,
                          false => AppColors.buddyTeal,
                        },
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: star == true
                          ? const Icon(
                              Icons.star_rounded,
                              color: AppColors.white,
                              size: 28,
                            )
                          : null,
                    ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

/// Bubbles of sums, floating up.
class _NumberTileArt extends StatelessWidget {
  const _NumberTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Row(
          children: [
            for (final (sum, lift) in const [
              ('6 × 6', 14.0),
              ('9 + 3', -14.0),
              ('8 − 2', 14.0),
            ])
              Transform.translate(
                offset: Offset(0, lift),
                child: Container(
                  width: 96,
                  height: 96,
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.4, -0.5),
                      colors: [AppColors.white, AppColors.brandBlueTint],
                    ),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Text(
                    sum,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// A fan of game cards.
class _ArenaTileArt extends StatelessWidget {
  const _ArenaTileArt();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        child: Row(
          children: [
            for (final (picture, turn) in const [
              (GamePicture.rocket, -0.14),
              (GamePicture.owl, 0.0),
              (GamePicture.planet, 0.14),
            ])
              Transform.rotate(
                angle: turn,
                child: Container(
                  width: 84,
                  height: 104,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: AppShapes.sticker(
                    AppColors.white,
                    depth: 3,
                    radius: 12,
                  ),
                  child: PictureArt(picture: picture, size: 64),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Buddy's Challenge Arena: the games, their levels, and Quick Create.
class ArenaScreen extends StatefulWidget {
  const ArenaScreen({
    super.key,
    required this.progressRepository,
    required this.creationsRepository,
    required this.voice,
    this.random,
    this.only,
  });

  final ProgressRepository progressRepository;
  final CreationsRepository creationsRepository;
  final BuddyVoice voice;
  final Random? random;

  /// Shows just this game's levels, for a game with its own Game Zone tile.
  final GameKind? only;

  static const title = GameZoneScreen.arenaTitle;
  static const quickTitle = 'Quick Create';
  static const quickText = 'A fun idea to draw. There is no score: just enjoy!';
  static const newIdea = 'New idea';
  static const startDrawing = 'Start drawing';
  static const shelfFull =
      'Your shelf is full. Remove a creation on Creative Island first.';
  static const errorMessage =
      "Buddy couldn't open the Arena. Please try again.";
  static const retryLabel = 'Try again';

  static String lockedLabel(String previous) => 'Earn a star in $previous';
  static String playLabel(GameLevel level) => 'Play ${level.name}';
  static String starsValue(int stars) =>
      '$stars ${stars == 1 ? 'star' : 'stars'}';

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  late final Random _random = widget.random ?? Random();
  Map<String, int> _best = const {};
  bool _shelfFull = false;
  bool _loading = true;
  bool _failed = false;
  late String _idea =
      quickCreateIdeas[_random.nextInt(quickCreateIdeas.length)];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final progress = await widget.progressRepository.load();
      final shelf = await widget.creationsRepository.load();
      if (!mounted) return;
      setState(() {
        _best = progress.gameBest;
        _shelfFull = shelf.isFull;
        _loading = false;
        _failed = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _newIdea() {
    setState(() {
      final others = quickCreateIdeas.where((i) => i != _idea).toList();
      _idea = others[_random.nextInt(others.length)];
    });
  }

  Future<void> _play(GameLevel level) async {
    var current = level;
    while (mounted) {
      final next = await Navigator.of(context).push<GameLevel>(
        MaterialPageRoute(
          settings: RouteSettings(name: '/arena/${current.id}'),
          builder: (_) => GamePlayScreen(
            level: current,
            voice: widget.voice,
            progressRepository: widget.progressRepository,
            random: widget.random,
          ),
        ),
      );
      await _load();
      if (next == null || !mounted) return;
      current = next;
    }
  }

  Future<void> _draw() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/arena/quick-create'),
        builder: (_) => DrawingScreen(
          voice: widget.voice,
          creationsRepository: widget.creationsRepository,
          prompt: _idea,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final only = widget.only;
    return GameWorld(
      title: only?.title ?? ArenaScreen.title,
      children: [
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppColors.white,
                semanticsLabel: 'Opening the Arena',
              ),
            ),
          )
        else if (_failed) ...[
          Text(
            ArenaScreen.errorMessage,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: PlayButton(
              label: ArenaScreen.retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: () => unawaited(_load()),
            ),
          ),
        ] else ...[
          for (final kind in only == null ? GameKind.arena : [only]) ...[
            _GameCard(
              kind: kind,
              best: _best,
              onPlay: (level) => unawaited(_play(level)),
              onHowTo: () => unawaited(
                showHowToPlay(
                  context,
                  guide: HowToPlay.of(kind),
                  voice: widget.voice,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (only == null) _quickCreate(textTheme),
        ],
      ],
    );
  }

  Widget _quickCreate(TextTheme textTheme) => Container(
    padding: const EdgeInsets.all(14),
    decoration: AppShapes.sticker(AppColors.leafTint),
    child: Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(ArenaScreen.quickTitle, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(ArenaScreen.quickText, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => unawaited(
              showHowToPlay(
                context,
                guide: HowToPlay.quickCreate,
                voice: widget.voice,
              ),
            ),
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text(HowToPlaySheet.buttonTooltip),
          ),
        ),
        const SizedBox(height: 10),
        Text(_idea, style: textTheme.titleMedium),
        const SizedBox(height: 10),
        if (_shelfFull) ...[
          Text(ArenaScreen.shelfFull, style: textTheme.bodyMedium),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _shelfFull ? null : () => unawaited(_draw()),
              icon: const Icon(Icons.brush_rounded),
              label: const Text(ArenaScreen.startDrawing),
            ),
            OutlinedButton.icon(
              onPressed: _newIdea,
              icon: const Icon(Icons.casino_rounded),
              label: const Text(ArenaScreen.newIdea),
            ),
          ],
        ),
      ],
    ),
  );
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.kind,
    required this.best,
    required this.onPlay,
    required this.onHowTo,
  });

  final GameKind kind;
  final Map<String, int> best;
  final ValueChanged<GameLevel> onPlay;
  final VoidCallback onHowTo;

  static const _colors = {
    GameKind.memory: AppColors.grapeTint,
    GameKind.pattern: AppColors.sunTint,
    GameKind.spot: AppColors.leafTint,
    GameKind.maze: AppColors.sunTint,
    GameKind.robot: AppColors.grapeTint,
    GameKind.words: AppColors.coralTint,
    GameKind.sounds: AppColors.grapeTint,
    GameKind.four: AppColors.brandBlueTint,
    GameKind.number: AppColors.coralTint,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final levels = ArenaRules.levelsOf(kind);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(_colors[kind]!),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Semantics(
            header: true,
            child: Text(kind.title, style: textTheme.titleLarge),
          ),
          Text(kind.tagline, style: textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: .start,
            children: [
              for (final (i, level) in levels.indexed)
                Expanded(
                  child: _LevelNode(
                    level: level,
                    open: ArenaRules.isOpen(level, best),
                    stars: best[level.id] ?? 0,
                    previousName: i == 0 ? '' : levels[i - 1].name,
                    onPlay: () => onPlay(level),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onHowTo,
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text(HowToPlaySheet.buttonTooltip),
          ),
        ],
      ),
    );
  }
}

/// One stop on a game's level map: a big numbered button, or a lock.
class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.open,
    required this.stars,
    required this.previousName,
    required this.onPlay,
  });

  final GameLevel level;
  final bool open;
  final int stars;
  final String previousName;
  final VoidCallback onPlay;

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: open,
      label: open
          ? ArenaScreen.playLabel(level)
          : ArenaScreen.lockedLabel(previousName),
      value: open ? ArenaScreen.starsValue(stars) : null,
      excludeSemantics: true,
      child: StickerPress(
        enabled: open,
        child: InkWell(
          onTap: open ? onPlay : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: _size,
                  height: _size,
                  alignment: Alignment.center,
                  decoration: AppShapes.sticker(
                    open ? AppColors.sun : AppColors.white,
                    depth: 3,
                    radius: _size / 2,
                  ),
                  child: open
                      ? Text('${level.number}', style: textTheme.titleLarge)
                      : const Icon(
                          Icons.lock_rounded,
                          color: AppColors.inkSoft,
                        ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(level.name, style: textTheme.titleSmall),
                ),
                const SizedBox(height: 2),
                QuizStars(stars: stars, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
