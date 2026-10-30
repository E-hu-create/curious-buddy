import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/games/dino.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../quiz/widgets/quiz_widgets.dart';
import 'dino_play_screen.dart';
import 'how_to_play.dart';
import 'widgets/dino_art.dart';
import 'widgets/game_world.dart';

/// Dino Discovery: the places to explore, and the way to the Field Guide.
class DinoHubScreen extends StatefulWidget {
  const DinoHubScreen({
    super.key,
    required this.progressRepository,
    required this.voice,
    this.random,
  });

  final ProgressRepository progressRepository;
  final BuddyVoice voice;
  final Random? random;

  static const title = 'Dino Discovery';
  static const welcome =
      'Grab your backpack! Explore each place, follow the clues and fill your '
      'Field Guide.';
  static const errorMessage =
      "Buddy couldn't open Dino Discovery. Please try again.";
  static const retryLabel = 'Try again';

  static String exploreLabel(DinoPlace place) => 'Explore ${place.name}';
  static String lockedLabel(DinoPlace previous) =>
      'Explore ${previous.name} first';
  static String guideLabel(int found, int total) =>
      'Field Guide: $found of $total found';

  @override
  State<DinoHubScreen> createState() => _DinoHubScreenState();
}

class _DinoHubScreenState extends State<DinoHubScreen> {
  Map<String, int> _best = const {};
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final progress = await widget.progressRepository.load();
      if (!mounted) return;
      setState(() {
        _best = progress.gameBest;
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

  Future<void> _explore(DinoPlace place) async {
    var current = place;
    while (mounted) {
      final next = await Navigator.of(context).push<DinoPlace>(
        MaterialPageRoute(
          settings: RouteSettings(name: '/dino/${current.id}'),
          builder: (_) => DinoPlayScreen(
            place: current,
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

  Future<void> _openGuide() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/dino/field-guide'),
      builder: (_) => FieldGuideScreen(
        found: DinoRules.foundIn(_best),
        voice: widget.voice,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GameWorld(
      title: DinoHubScreen.title,
      children: [
        Row(
          children: [
            const Buddy(height: 96, mood: BuddyMood.excited),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DinoHubScreen.welcome,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppColors.white,
                semanticsLabel: 'Opening Dino Discovery',
              ),
            ),
          )
        else if (_failed) ...[
          Text(
            DinoHubScreen.errorMessage,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: PlayButton(
              label: DinoHubScreen.retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: () => unawaited(_load()),
            ),
          ),
        ] else ...[
          PlayButton(
            label: DinoHubScreen.guideLabel(
              DinoRules.foundIn(_best).length,
              DinoCreature.values.length,
            ),
            icon: Icons.menu_book_rounded,
            onPressed: () => unawaited(_openGuide()),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => unawaited(
              showHowToPlay(
                context,
                guide: HowToPlay.dino,
                voice: widget.voice,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.ink,
            ),
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text(HowToPlaySheet.buttonTooltip),
          ),
          for (final place in DinoPlace.values) ...[
            const SizedBox(height: 14),
            _PlaceCard(
              place: place,
              open: DinoRules.isOpen(place, _best),
              stars: _best[place.id] ?? 0,
              onExplore: () => unawaited(_explore(place)),
            ),
          ],
        ],
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.open,
    required this.stars,
    required this.onExplore,
  });

  final DinoPlace place;
  final bool open;
  final int stars;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.white),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          DinoScene(place: place),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(place.name, style: textTheme.titleLarge),
              ),
              QuizStars(stars: stars, size: 20),
            ],
          ),
          Text(place.era, style: textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (open)
            PlayButton(
              label: DinoHubScreen.exploreLabel(place),
              icon: Icons.explore_rounded,
              onPressed: onExplore,
            )
          else
            Text(
              DinoHubScreen.lockedLabel(DinoPlace.values[place.index - 1]),
              style: textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

/// Every creature, filled in as the child finds them.
class FieldGuideScreen extends StatefulWidget {
  const FieldGuideScreen({super.key, required this.found, required this.voice});

  final Set<DinoCreature> found;
  final BuddyVoice voice;

  static const title = 'Field Guide';
  static const hearLabel = 'Hear about it';

  static String ateLabel(DinoDiet diet) => 'Ate: ${diet.label}';
  static String lockedLabel(DinoPlace place) =>
      'Explore ${place.name} to find this one.';

  @override
  State<FieldGuideScreen> createState() => _FieldGuideScreenState();
}

class _FieldGuideScreenState extends State<FieldGuideScreen> {
  @override
  void dispose() {
    // Leaving the guide always silences Buddy.
    widget.voice.stop().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                FieldGuideScreen.title,
                style: textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            for (final creature in DinoCreature.values) ...[
              widget.found.contains(creature)
                  ? _FoundEntry(creature: creature, voice: widget.voice)
                  : _HiddenEntry(creature: creature),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _FoundEntry extends StatelessWidget {
  const _FoundEntry({required this.creature, required this.voice});

  final DinoCreature creature;
  final BuddyVoice voice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.leafTint, depth: 3),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Center(child: DinoArt(creature: creature, width: 200)),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(creature.name, style: textTheme.titleLarge),
          ),
          Text(creature.sayIt, style: textTheme.bodyMedium),
          if (!creature.isDinosaur)
            Text(DinoPlayScreen.notDinosaur, style: textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            FieldGuideScreen.ateLabel(creature.diet),
            style: textTheme.bodyMedium,
          ),
          Text(creature.size, style: textTheme.bodyMedium),
          Text(creature.place.era, style: textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(creature.fact, style: textTheme.bodyLarge),
          if (voice.canSpeak) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  unawaited(voice.say(creature.guideLine, requested: true)),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text(FieldGuideScreen.hearLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _HiddenEntry extends StatelessWidget {
  const _HiddenEntry({required this.creature});

  final DinoCreature creature;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: AppShapes.sticker(AppColors.white, depth: 3),
    child: Row(
      children: [
        DinoArt(creature: creature, width: 96, hidden: true),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            FieldGuideScreen.lockedLabel(creature.place),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
