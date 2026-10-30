import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/games/dino.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/motion.dart';
import 'dino_view_model.dart';
import 'widgets/dino_art.dart';
import 'widgets/game_parts.dart';

/// Runs one expedition. Pops with the next place on "Next place".
class DinoPlayScreen extends StatefulWidget {
  const DinoPlayScreen({
    super.key,
    required this.place,
    required this.voice,
    required this.progressRepository,
    this.random,
  });

  final DinoPlace place;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  /// Injected in tests for a predictable game.
  final Random? random;

  static const searchHint = 'Tap a search spot to look for clues.';
  static const whoIsIt = 'Who is it?';
  static const clueTitle = 'Clue';
  static const keepExploring = 'Keep exploring';
  static const startMission = 'Start the mission';
  static const nextQuestion = 'Next';
  static const seeStars = 'See my stars';
  static const notDinosaur = 'Not a dinosaur!';
  static const guideTitle = 'In your Field Guide';
  static const backLabel = 'Back to Dino Discovery';
  static const tryAgain = 'Not quite. Try again!';

  static String foundLabel(int found, int total) => '$found of $total found';
  static String nextPlaceLabel(DinoPlace place) => 'Next place: ${place.name}';
  static String missionLabel(int n, int total) => 'Mission: $n of $total';
  static String spotLabel(int n) => 'Search spot $n';
  static String wrongLabel(DinoCreature creature) =>
      "That's ${creature.name}. Here is another clue.";

  @override
  State<DinoPlayScreen> createState() => _DinoPlayScreenState();
}

class _DinoPlayScreenState extends State<DinoPlayScreen> {
  late final DinoViewModel _vm = DinoViewModel(
    place: widget.place,
    voice: widget.voice,
    progressRepository: widget.progressRepository,
    random: widget.random,
  );

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
  Widget build(BuildContext context) {
    final place = widget.place;
    final next = place.index + 1 < DinoPlace.values.length
        ? DinoPlace.values[place.index + 1]
        : null;
    return GameShell(
      vm: _vm,
      nextButton: next == null ? null : DinoPlayScreen.nextPlaceLabel(next),
      nextResult: next,
      backButton: DinoPlayScreen.backLabel,
      finishExtra: _GuideStrip(place: place),
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => PageSwap(
          pageKey: _pageKey,
          child: switch (_vm.expedition.stage) {
            DinoStage.explore => _Explore(vm: _vm),
            DinoStage.identify => _Identify(vm: _vm),
            DinoStage.discovered => _Discovered(vm: _vm),
            DinoStage.mission => _Mission(vm: _vm),
            DinoStage.done => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  String get _pageKey {
    final e = _vm.expedition;
    return '${e.stage.name}-${e.current?.name}-${e.taskIndex}';
  }
}

/// Where each creature waits in its scene.
List<Alignment> _spotsOf(DinoPlace place) => switch (place) {
  DinoPlace.fernForest => const [
    Alignment(-0.7, 0.75),
    Alignment(0.05, 0.3),
    Alignment(0.75, 0.8),
  ],
  DinoPlace.openPlains => const [
    Alignment(-0.7, 0.7),
    Alignment(0.05, 0.9),
    Alignment(0.75, 0.45),
  ],
  DinoPlace.ancientSea => const [
    Alignment(0.6, -0.8),
    Alignment(-0.6, 0.15),
    Alignment(0.45, 0.7),
  ],
};

class _Explore extends StatelessWidget {
  const _Explore({required this.vm});

  final DinoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final place = vm.place;
    final expedition = vm.expedition;
    final spots = _spotsOf(place);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(place.intro, style: textTheme.bodyLarge),
        const SizedBox(height: 10),
        Container(
          decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 16),
          child: LayoutBuilder(
            builder: (context, constraints) => DinoScene(
              place: place,
              children: [
                for (final (i, creature) in place.creatures.indexed)
                  Align(
                    alignment: spots[i],
                    child: expedition.found.contains(creature)
                        ? PopIn(
                            child: DinoArt(
                              creature: creature,
                              width: constraints.maxWidth * 0.36,
                            ),
                          )
                        : _SearchSpot(
                            number: i + 1,
                            onTap: () => vm.look(creature),
                          ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          DinoPlayScreen.foundLabel(
            expedition.found.length,
            place.creatures.length,
          ),
          style: textTheme.titleMedium,
        ),
        Text(DinoPlayScreen.searchHint, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _SearchSpot extends StatelessWidget {
  const _SearchSpot({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: DinoPlayScreen.spotLabel(number),
    excludeSemantics: true,
    child: StickerPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: AppTheme.minTouchTarget,
            height: AppTheme.minTouchTarget,
            decoration: AppShapes.sticker(
              AppColors.sun,
              depth: 2,
              radius: AppTheme.minTouchTarget / 2,
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.ink),
          ),
        ),
      ),
    ),
  );
}

/// Three pictures to pick from. A wrong pick stays visible but can't be
/// picked again.
class _Options extends StatelessWidget {
  const _Options({required this.vm, this.locked = false});

  final DinoViewModel vm;

  /// Whether the question is already answered.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final expedition = vm.expedition;
    final answer = locked ? expedition.task.answer : null;
    return Row(
      crossAxisAlignment: .start,
      children: [
        for (final (i, creature) in expedition.options.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _OptionCard(
              creature: creature,
              color: creature == answer
                  ? AppColors.leafTint
                  : expedition.wrongPicks.contains(creature)
                  ? AppColors.coralTint
                  : AppColors.white,
              onTap: locked || expedition.wrongPicks.contains(creature)
                  ? null
                  : () => vm.pick(creature),
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.creature,
    required this.color,
    required this.onTap,
  });

  final DinoCreature creature;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: creature.name,
    excludeSemantics: true,
    child: StickerPress(
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            decoration: AppShapes.sticker(color, depth: 3, radius: 14),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  DinoArt(creature: creature, width: constraints.maxWidth),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      creature.name,
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

class _Identify extends StatelessWidget {
  const _Identify({required this.vm});

  final DinoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wrong = vm.lastWrong;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          header: true,
          child: Text(DinoPlayScreen.whoIsIt, style: textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.sticker(
              AppColors.sunTint,
              depth: 3,
              radius: 18,
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                if (wrong != null) ...[
                  Text(
                    DinoPlayScreen.wrongLabel(wrong),
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(DinoPlayScreen.clueTitle, style: textTheme.titleSmall),
                Text(vm.expedition.clue, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Options(vm: vm),
      ],
    );
  }
}

class _Discovered extends StatelessWidget {
  const _Discovered({required this.vm});

  final DinoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final creature = vm.expedition.current!;
    final allFound = vm.expedition.found.length == vm.place.creatures.length;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppShapes.sticker(AppColors.leafTint, depth: 3),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Center(
                child: PopIn(child: DinoArt(creature: creature, width: 220)),
              ),
              const SizedBox(height: 8),
              Semantics(
                header: true,
                child: Text(creature.name, style: textTheme.titleLarge),
              ),
              Text(creature.sayIt, style: textTheme.bodyMedium),
              if (!creature.isDinosaur)
                Text(DinoPlayScreen.notDinosaur, style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(creature.fact, style: textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => unawaited(vm.carryOn()),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(
            allFound
                ? DinoPlayScreen.startMission
                : DinoPlayScreen.keepExploring,
          ),
        ),
      ],
    );
  }
}

class _Mission extends StatelessWidget {
  const _Mission({required this.vm});

  final DinoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final expedition = vm.expedition;
    final solved = expedition.taskSolved;
    final total = vm.place.mission.length;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          DinoPlayScreen.missionLabel(expedition.taskIndex + 1, total),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Semantics(
          header: true,
          child: Text(expedition.task.prompt, style: textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        _Options(vm: vm, locked: solved),
        const SizedBox(height: 12),
        if (solved) ...[
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppShapes.sticker(
                AppColors.leafTint,
                depth: 3,
                radius: 18,
              ),
              child: Text(
                expedition.task.explanation,
                style: textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => unawaited(vm.carryOn()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              expedition.taskIndex + 1 < total
                  ? DinoPlayScreen.nextQuestion
                  : DinoPlayScreen.seeStars,
            ),
          ),
        ] else if (vm.lastWrong != null)
          Semantics(
            liveRegion: true,
            child: Text(DinoPlayScreen.tryAgain, style: textTheme.bodyLarge),
          ),
      ],
    );
  }
}

/// The finish panel's reminder of who joined the Field Guide.
class _GuideStrip extends StatelessWidget {
  const _GuideStrip({required this.place});

  final DinoPlace place;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.white, depth: 3, radius: 16),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(DinoPlayScreen.guideTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final creature in place.creatures)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => DinoArt(
                      creature: creature,
                      width: constraints.maxWidth,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
