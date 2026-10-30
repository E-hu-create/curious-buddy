import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/games/game_content.dart';
import '../../domain/games/games.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../creative/drawing_screen.dart';
import '../quiz/widgets/quiz_widgets.dart';
import 'game_play_screen.dart';

/// The way into every game.
class GameZoneScreen extends StatelessWidget {
  const GameZoneScreen({super.key});

  static const title = 'Game Zone';
  static const welcome = 'Ready to play? Pick a game!';
  static const arenaTitle = "Buddy's Challenge Arena";
  static const arenaText = 'Quick games for your memory, logic and eyes.';
  static const arenaLabel = 'Enter the Arena';
  static const comingSoon = 'Coming soon';
  static const dinoTitle = 'Dino Discovery';
  static const soundTitle = "What's That Sound?";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Buddy(height: 96, mood: BuddyMood.excited),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(welcome, style: textTheme.bodyLarge),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppShapes.sticker(AppColors.brandBlueTint),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(arenaTitle, style: textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(arenaText, style: textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => unawaited(
                            Navigator.of(context).pushNamed(Routes.arena),
                          ),
                          icon: const Icon(Icons.sports_esports_rounded),
                          label: const Text(arenaLabel),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _ComingSoon(title: dinoTitle),
                  const SizedBox(height: 10),
                  const _ComingSoon(title: soundTitle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: AppColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(title, style: textTheme.titleMedium),
                Text(GameZoneScreen.comingSoon, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Buddy's Challenge Arena: the games, their levels, and Quick Create.
class ArenaScreen extends StatefulWidget {
  const ArenaScreen({
    super.key,
    required this.progressRepository,
    required this.creationsRepository,
    required this.voice,
    this.random,
  });

  final ProgressRepository progressRepository;
  final CreationsRepository creationsRepository;
  final BuddyVoice voice;
  final Random? random;

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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      ArenaScreen.title,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Opening the Arena',
                        ),
                      ),
                    )
                  else if (_failed) ...[
                    Text(ArenaScreen.errorMessage, style: textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () => unawaited(_load()),
                        child: const Text(ArenaScreen.retryLabel),
                      ),
                    ),
                  ] else ...[
                    for (final kind in GameKind.values) ...[
                      _GameCard(
                        kind: kind,
                        best: _best,
                        onPlay: (level) => unawaited(_play(level)),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _quickCreate(textTheme),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
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
  });

  final GameKind kind;
  final Map<String, int> best;
  final ValueChanged<GameLevel> onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final levels = ArenaRules.levelsOf(kind);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.white),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Semantics(
            header: true,
            child: Text(kind.title, style: textTheme.titleLarge),
          ),
          Text(kind.tagline, style: textTheme.bodyMedium),
          const SizedBox(height: 10),
          for (final (i, level) in levels.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: _LevelRow(
                level: level,
                open: ArenaRules.isOpen(level, best),
                stars: best[level.id] ?? 0,
                previousName: i == 0 ? '' : levels[i - 1].name,
                onPlay: () => onPlay(level),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(level.name, style: textTheme.titleMedium),
            QuizStars(stars: stars, size: 20),
          ],
        ),
        if (open)
          OutlinedButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Play ${level.name}'),
          )
        else
          Text(
            ArenaScreen.lockedLabel(previousName),
            style: textTheme.bodyMedium,
          ),
      ],
    );
  }
}
