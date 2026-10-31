import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/stories/world_stories.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import 'stories_view_model.dart';
import 'story_maker_screen.dart';
import 'story_play_screen.dart';
import 'widgets/story_picture.dart';
import 'widgets/story_widgets.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({
    super.key,
    required this.storyRepository,
    required this.progressRepository,
    required this.voice,
  });

  final StoryRepository storyRepository;
  final ProgressRepository progressRepository;
  final BuddyVoice voice;

  static const title = 'Living Stories';
  static const welcome =
      'Pick a story, and I will read it to you. You choose what happens '
      'next, and every choice leads somewhere new.';
  static const emptyMessage =
      'No stories are ready right now. Check back soon!';
  static const errorMessage =
      "Buddy couldn't open the story books. Please try again.";
  static const retryLabel = 'Try again';
  static const startLabel = 'Start the story';
  static const continueLabel = 'Continue the story';
  static const startAgainLabel = 'Start again';
  static const anotherEndingLabel = 'Find another ending';
  static const allFoundLabel = 'Read it again';
  static const newLabel = 'New story';
  static const inProgressLabel = 'Reading';
  static const makerTitle = 'Story Maker';
  static const makerText =
      'Make a brand-new story: pick a hero, a place and a mystery.';
  static const makerLabel = 'Make a new story';
  static const newestHeading = 'New: stories from around the world';
  static const olderHeading = 'More stories';

  static String endingsLabel(int found, int total) =>
      '$found of $total endings found';

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late final StoriesViewModel _vm = StoriesViewModel(
    storyRepository: widget.storyRepository,
    progressRepository: widget.progressRepository,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _open(StorySummary summary, {required bool resume}) async {
    final story = summary.story;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/stories/${story.id}'),
        builder: (_) => StoryPlayScreen(
          story: story,
          voice: widget.voice,
          progressRepository: widget.progressRepository,
          resumePath: resume ? summary.bookmark : null,
          foundEndingIds: summary.foundEndingIds,
        ),
      ),
    );
    // Show new endings and where the child stopped.
    await _vm.load();
  }

  Future<void> _openMaker() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/stories/maker'),
      builder: (_) => StoryMakerScreen(
        voice: widget.voice,
        progressRepository: widget.progressRepository,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SingleChildScrollView(
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
                        StoriesScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Buddy(height: 96, mood: BuddyMood.happy),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            StoriesScreen.welcome,
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._body(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (_vm.status) {
      case StoriesStatus.loading:
        return const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading stories',
              ),
            ),
          ),
        ];
      case StoriesStatus.empty:
        return [Text(StoriesScreen.emptyMessage, style: textTheme.bodyLarge)];
      case StoriesStatus.error:
        return [
          Text(StoriesScreen.errorMessage, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => unawaited(_vm.load()),
              child: const Text(StoriesScreen.retryLabel),
            ),
          ),
        ];
      case StoriesStatus.ready:
        return [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.sticker(AppColors.grapeTint, depth: 4),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    StoriesScreen.endingsLabel(
                      _vm.endingsFound,
                      _vm.totalEndings,
                    ),
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.sticker(AppColors.sunTint, depth: 4),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_fix_high_rounded,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          StoriesScreen.makerTitle,
                          style: textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(StoriesScreen.makerText, style: textTheme.bodyLarge),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => unawaited(_openMaker()),
                  icon: const Icon(Icons.auto_fix_high_rounded),
                  label: const Text(StoriesScreen.makerLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // The newest stories come first, under their own heading, so
          // they are easy to find.
          for (final (heading, newest) in [
            (StoriesScreen.newestHeading, true),
            (StoriesScreen.olderHeading, false),
          ])
            if (_vm.summaries.any(
              (s) => worldStories.contains(s.story) == newest,
            )) ...[
              Semantics(
                header: true,
                child: Text(heading, style: textTheme.titleLarge),
              ),
              const SizedBox(height: 10),
              for (final summary in _vm.summaries.where(
                (s) => worldStories.contains(s.story) == newest,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _StoryCard(
                    summary: summary,
                    onOpen: ({required resume}) =>
                        unawaited(_open(summary, resume: resume)),
                  ),
                ),
            ],
        ];
    }
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.summary, required this.onOpen});

  final StorySummary summary;
  final void Function({required bool resume}) onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final story = summary.story;
    final colours = storyColours(story.cover);
    final found = summary.foundEndings;
    final allFound = found.length == summary.totalEndings;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.white),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          StoryPicture(picture: story.cover, height: 160),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (summary.canContinue)
                StoryTag(
                  icon: Icons.bookmark_rounded,
                  label: StoriesScreen.inProgressLabel,
                  color: AppColors.sunTint,
                )
              else if (!summary.finished)
                StoryTag(
                  icon: Icons.auto_awesome_rounded,
                  label: StoriesScreen.newLabel,
                  color: colours.tint,
                ),
              Text(
                StoriesScreen.endingsLabel(found.length, summary.totalEndings),
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(story.title, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(story.tagline, style: textTheme.bodyLarge),
          if (found.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ending in found)
                  StoryTag(
                    icon: Icons.star_rounded,
                    label: ending.title,
                    color: colours.tint,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (summary.canContinue) ...[
            FilledButton.icon(
              onPressed: () => onOpen(resume: true),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(StoriesScreen.continueLabel),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => onOpen(resume: false),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text(StoriesScreen.startAgainLabel),
            ),
          ] else
            FilledButton.icon(
              onPressed: () => onOpen(resume: false),
              icon: Icon(
                summary.finished
                    ? Icons.alt_route_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                !summary.finished
                    ? StoriesScreen.startLabel
                    : allFound
                    ? StoriesScreen.allFoundLabel
                    : StoriesScreen.anotherEndingLabel,
              ),
            ),
        ],
      ),
    );
  }
}
