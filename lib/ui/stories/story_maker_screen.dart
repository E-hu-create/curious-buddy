import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/stories/story_maker.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import 'story_play_screen.dart';

/// Story Maker: the child picks a hero, a place and a mystery, or lets Buddy
/// pick, and gets a brand-new story to play. Made stories are not saved.
class StoryMakerScreen extends StatefulWidget {
  const StoryMakerScreen({
    super.key,
    required this.voice,
    required this.progressRepository,
    this.random,
  });

  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  /// Injected in tests for a predictable surprise.
  final Random? random;

  static const title = 'Story Maker';
  static const welcome =
      'Pick a hero, a place and a mystery, and Buddy will make a brand-new '
      'story just for you!';
  static const heroTitle = '1. Choose a hero';
  static const placeTitle = '2. Choose a place';
  static const mysteryTitle = '3. Choose a mystery';
  static const surpriseLabel = 'Surprise me!';
  static const makeLabel = 'Make my story';
  static const notSaved =
      'Made stories are just for now. Make as many as you like!';

  static String countLabel(int count) =>
      'There are $count different stories to make.';

  @override
  State<StoryMakerScreen> createState() => _StoryMakerScreenState();
}

class _StoryMakerScreenState extends State<StoryMakerScreen> {
  late final Random _random = widget.random ?? Random();
  late MakerHero _hero = StoryMaker.heroes.first;
  late MakerPlace _place = StoryMaker.places.first;
  late MakerMystery _mystery = StoryMaker.mysteries.first;

  void _surprise() {
    final (hero, place, mystery) = StoryMaker.surprise(_random);
    setState(() {
      _hero = hero;
      _place = place;
      _mystery = mystery;
    });
  }

  Future<void> _make() async {
    final story = StoryMaker.make(_hero, _place, _mystery);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/stories/maker/${story.id}'),
        builder: (_) => StoryPlayScreen(
          story: story,
          voice: widget.voice,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
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
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      StoryMakerScreen.title,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Buddy(height: 88, mood: BuddyMood.excited),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          StoryMakerScreen.welcome,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _surprise,
                    icon: const Icon(Icons.casino_rounded),
                    label: const Text(StoryMakerScreen.surpriseLabel),
                  ),
                  const SizedBox(height: 16),
                  _Picker<MakerHero>(
                    title: StoryMakerScreen.heroTitle,
                    color: AppColors.sunTint,
                    options: StoryMaker.heroes,
                    selected: _hero,
                    label: (hero) => hero.intro,
                    onPick: (hero) => setState(() => _hero = hero),
                  ),
                  const SizedBox(height: 14),
                  _Picker<MakerPlace>(
                    title: StoryMakerScreen.placeTitle,
                    color: AppColors.leafTint,
                    options: StoryMaker.places,
                    selected: _place,
                    label: (place) => _capitalised(place.name),
                    onPick: (place) => setState(() => _place = place),
                  ),
                  const SizedBox(height: 14),
                  _Picker<MakerMystery>(
                    title: StoryMakerScreen.mysteryTitle,
                    color: AppColors.grapeTint,
                    options: StoryMaker.mysteries,
                    selected: _mystery,
                    label: (mystery) => _capitalised(mystery.title),
                    onPick: (mystery) => setState(() => _mystery = mystery),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => unawaited(_make()),
                    icon: const Icon(Icons.auto_stories_rounded),
                    label: const Text(StoryMakerScreen.makeLabel),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    StoryMakerScreen.countLabel(StoryMaker.combinations),
                    style: textTheme.bodyMedium,
                  ),
                  Text(StoryMakerScreen.notSaved, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _capitalised(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// One row of choices. The chosen one is highlighted and marked as selected
/// for screen readers.
class _Picker<T> extends StatelessWidget {
  const _Picker({
    required this.title,
    required this.color,
    required this.options,
    required this.selected,
    required this.label,
    required this.onPick,
  });

  final String title;
  final Color color;
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(color, depth: 3),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                Semantics(
                  button: true,
                  selected: option == selected,
                  label: label(option),
                  excludeSemantics: true,
                  child: OutlinedButton.icon(
                    onPressed: () => onPick(option),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: option == selected
                          ? AppColors.sun
                          : AppColors.white,
                    ),
                    icon: Icon(
                      option == selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                    ),
                    label: Text(label(option)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
