import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/stories/story.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../missions/widgets/stage_widgets.dart';
import 'story_play_view_model.dart';
import 'widgets/story_picture.dart';
import 'widgets/story_widgets.dart';

/// Reading one story: intro, then a page per scene until an ending. Buddy
/// narrates, and stops when the child leaves (dispose and the navigator
/// observer both stop speech). All text stays on screen, so the story
/// works with the voice off.
class StoryPlayScreen extends StatefulWidget {
  const StoryPlayScreen({
    super.key,
    required this.story,
    required this.voice,
    required this.progressRepository,
    this.resumePath,
    this.foundEndingIds = const {},
  });

  final Story story;
  final BuddyVoice voice;
  final ProgressRepository progressRepository;

  /// Where to carry on from, if the child chose Continue.
  final List<String>? resumePath;
  final Set<String> foundEndingIds;

  static const beginLabel = 'Begin the story';
  static const whatNext = 'What should we do?';
  static const readChoicesLabel = 'Read the choices';
  static const readPageTooltip = 'Read this page aloud';
  static const theEnd = 'The End';
  static const newEnding = 'New ending!';
  static const foundBefore = 'You found this ending before';
  static const discoveredLabel = 'You discovered';
  static const tryAnotherLabel = 'Try a different path';
  static const backLabel = 'Back to stories';
  static const welcomeBack = 'Welcome back! Here is where you stopped.';
  static const saveFailed =
      "The story carries on, but your place couldn't be saved this time.";

  static String pageLabel(int page) => 'Page $page';
  static String endingsLabel(int found, int total) =>
      'You have found $found of $total endings.';

  @override
  State<StoryPlayScreen> createState() => _StoryPlayScreenState();
}

class _StoryPlayScreenState extends State<StoryPlayScreen> {
  late final StoryPlayViewModel _vm = StoryPlayViewModel(
    story: widget.story,
    voice: widget.voice,
    progressRepository: widget.progressRepository,
    resumePath: widget.resumePath,
    foundEndingIds: widget.foundEndingIds,
  );
  final _scroll = ScrollController();
  late final _colours = storyColours(widget.story.cover);

  @override
  void initState() {
    super.initState();
    // Narrate once the page is on screen (after the route push settles).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateOpening();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Run a page change, then show the new page from the top.
  void _turnPage(VoidCallback change) {
    change();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.story.title,
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
                child: switch (_vm.phase) {
                  StoryPhase.intro => _intro(context),
                  StoryPhase.scene => _scene(context),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buddyRow(BuddyMood mood) => Row(
    children: [
      Buddy(height: 84, mood: mood, waveOnAppear: false),
      const SizedBox(width: 12),
      Expanded(
        child: MissionVoiceBar(
          canSpeak: _vm.canSpeak,
          isSpeaking: _vm.isSpeaking,
          onHearAgain: _vm.lastSpoken == null ? null : _vm.hearAgain,
          onStop: () => unawaited(_vm.stopSpeaking()),
        ),
      ),
    ],
  );

  // ------------------------------------------------------------- intro

  Widget _intro(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final story = widget.story;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        StoryPicture(picture: story.cover, height: 200),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(story.title, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        _buddyRow(BuddyMood.happy),
        const SizedBox(height: 12),
        Text(story.intro, style: textTheme.bodyLarge),
        const SizedBox(height: 12),
        Text(
          StoryPlayScreen.endingsLabel(
            _vm.foundEndingIds.length,
            _vm.totalEndings,
          ),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _turnPage(_vm.begin),
          icon: const Icon(Icons.auto_stories_rounded),
          label: const Text(StoryPlayScreen.beginLabel),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- scene

  Widget _scene(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scene = _vm.scene;
    final consequence = _vm.consequence;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          StoryPlayScreen.pageLabel(_vm.sceneNumber),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        StoryPicture(picture: scene.picture),
        if (_vm.onResumedPage) ...[
          const SizedBox(height: 12),
          _note(
            Icons.bookmark_rounded,
            StoryPlayScreen.welcomeBack,
            AppColors.sunTint,
          ),
        ],
        if (consequence != null) ...[
          const SizedBox(height: 12),
          _note(Icons.east_rounded, consequence, _colours.tint),
        ],
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(scene.title, style: textTheme.headlineSmall),
              ),
            ),
            if (_vm.canSpeak)
              IconButton(
                tooltip: StoryPlayScreen.readPageTooltip,
                onPressed: _vm.readScene,
                icon: const Icon(Icons.volume_up_rounded),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buddyRow(scene.isEnding ? BuddyMood.excited : BuddyMood.thoughtful),
        const SizedBox(height: 12),
        Text(scene.text, style: textTheme.bodyLarge?.copyWith(height: 1.45)),
        const SizedBox(height: 20),
        if (scene.ending case final ending?)
          ..._ending(context, ending)
        else
          ..._choices(context, scene),
        if (_vm.saveStatus == StorySaveStatus.failed) ...[
          const SizedBox(height: 12),
          Text(StoryPlayScreen.saveFailed, style: textTheme.bodyMedium),
        ],
      ],
    );
  }

  Widget _note(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.ink, width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, color: AppColors.ink),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );

  List<Widget> _choices(BuildContext context, StoryScene scene) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(StoryPlayScreen.whatNext, style: textTheme.titleLarge),
          if (_vm.canSpeak)
            TextButton.icon(
              onPressed: _vm.readChoices,
              icon: const Icon(Icons.record_voice_over_rounded),
              label: const Text(StoryPlayScreen.readChoicesLabel),
            ),
        ],
      ),
      const SizedBox(height: 8),
      for (final (i, choice) in scene.choices.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StoryChoiceCard(
            number: i + 1,
            text: choice.text,
            accent: _colours.accent,
            tint: _colours.tint,
            onTap: () => _turnPage(() => _vm.choose(choice.id)),
          ),
        ),
    ];
  }

  List<Widget> _ending(BuildContext context, StoryEnding ending) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: AppShapes.sticker(_colours.tint, depth: 4),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                StoryPlayScreen.theEnd,
                style: textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(ending.title, style: textTheme.titleLarge),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: StoryTag(
                icon: _vm.isNewEnding
                    ? Icons.auto_awesome_rounded
                    : Icons.check_circle_rounded,
                label: _vm.isNewEnding
                    ? StoryPlayScreen.newEnding
                    : StoryPlayScreen.foundBefore,
                color: _vm.isNewEnding ? AppColors.sunTint : AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(StoryPlayScreen.discoveredLabel, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(ending.discovery, style: textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              StoryPlayScreen.endingsLabel(
                _vm.foundEndingIds.length,
                _vm.totalEndings,
              ),
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: () => _turnPage(_vm.restart),
        icon: const Icon(Icons.alt_route_rounded),
        label: const Text(StoryPlayScreen.tryAnotherLabel),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text(StoryPlayScreen.backLabel),
      ),
    ];
  }
}
