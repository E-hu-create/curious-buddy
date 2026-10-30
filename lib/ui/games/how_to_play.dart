import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/games/games.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';

class HowToStep {
  const HowToStep(this.icon, this.text);

  final IconData icon;
  final String text;
}

/// The instructions for one game, in short steps a child can follow.
class HowToPlay {
  const HowToPlay({required this.game, required this.steps, this.tip});

  final String game;
  final List<HowToStep> steps;
  final String? tip;

  /// What Buddy reads out.
  String get spoken => [
    'How to play $game.',
    for (final (i, step) in steps.indexed) 'Step ${i + 1}. ${step.text}',
    ?tip,
  ].join(' ');

  static const noClock = 'There is no clock, so take your time.';

  static const memory = HowToPlay(
    game: 'Memory Match',
    tip: noClock,
    steps: [
      HowToStep(Icons.touch_app_rounded, 'Tap a card to turn it over.'),
      HowToStep(
        Icons.join_inner_rounded,
        'Tap another card. If the two match, you found a pair!',
      ),
      HowToStep(
        Icons.psychology_rounded,
        "If they don't match, remember where they are, then tap again.",
      ),
      HowToStep(
        Icons.star_rounded,
        'Find every pair. Fewer moves earn more stars.',
      ),
    ],
  );

  static const pattern = HowToPlay(
    game: 'Pattern Power',
    tip: noClock,
    steps: [
      HowToStep(
        Icons.visibility_rounded,
        'Look at the row of shapes or numbers.',
      ),
      HowToStep(
        Icons.psychology_rounded,
        'Work out the rule. What repeats, or how does it change?',
      ),
      HowToStep(Icons.touch_app_rounded, 'Tap the one that comes next.'),
      HowToStep(
        Icons.star_rounded,
        'Get at least 3 of the 5 patterns right to earn a star.',
      ),
    ],
  );

  static const spot = HowToPlay(
    game: 'Spot the Change',
    tip: noClock,
    steps: [
      HowToStep(Icons.visibility_rounded, 'Look closely at the first picture.'),
      HowToStep(
        Icons.compare_rounded,
        'Now look at the second picture. Some things have changed.',
      ),
      HowToStep(
        Icons.touch_app_rounded,
        'Tap each change in the second picture.',
      ),
      HowToStep(
        Icons.star_rounded,
        'Find them all. Fewer wrong taps earn more stars.',
      ),
    ],
  );

  static const maze = HowToPlay(
    game: 'Treasure Maze',
    tip: noClock,
    steps: [
      HowToStep(
        Icons.gamepad_rounded,
        'Tap an arrow, or swipe on the maze, to move Buddy.',
      ),
      HowToStep(
        Icons.directions_run_rounded,
        'Buddy keeps running until a wall, a turning or a gem.',
      ),
      HowToStep(
        Icons.diamond_rounded,
        'Collect the gems. All of them earns 3 stars.',
      ),
      HowToStep(Icons.flag_rounded, 'Reach the treasure chest to finish.'),
    ],
  );

  static const robot = HowToPlay(
    game: 'Code the Robot',
    tip: noClock,
    steps: [
      HowToStep(
        Icons.flag_rounded,
        'Find the robot and the green flag. Plan a way around the rocks.',
      ),
      HowToStep(
        Icons.gamepad_rounded,
        'Tap arrows to write your code, one step at a time.',
      ),
      HowToStep(
        Icons.play_arrow_rounded,
        'Press Go. The robot follows your code exactly.',
      ),
      HowToStep(
        Icons.build_rounded,
        'Something wrong? Your code stays there, so fix it and try again.',
      ),
      HowToStep(
        Icons.repeat_rounded,
        'On Expert, Twice makes your last step happen two times.',
      ),
    ],
  );

  static const words = HowToPlay(
    game: 'Word Builder',
    tip: noClock,
    steps: [
      HowToStep(
        Icons.lightbulb_rounded,
        'Read the clue. What could the word be?',
      ),
      HowToStep(
        Icons.touch_app_rounded,
        'Tap the letters in order to spell the word.',
      ),
      HowToStep(
        Icons.undo_rounded,
        'Change your mind? Tap a letter in the word to send it back.',
      ),
      HowToStep(
        Icons.tips_and_updates_rounded,
        'Stuck? Tap Hint and Buddy fills in the next letter.',
      ),
      HowToStep(
        Icons.star_rounded,
        'Spell all 5 words. Fewer hints and mistakes earn more stars.',
      ),
    ],
  );

  static const sounds = HowToPlay(
    game: "What's That Sound?",
    tip: noClock,
    steps: [
      HowToStep(
        Icons.volume_up_rounded,
        'Tap Play sound. Listen as many times as you like.',
      ),
      HowToStep(
        Icons.touch_app_rounded,
        'Tap the picture of what you think made the sound.',
      ),
      HowToStep(
        Icons.lightbulb_rounded,
        "Can't tell, or can't hear it? Tap Read a clue.",
      ),
      HowToStep(
        Icons.star_rounded,
        'Finish all 5 sounds. Fewer wrong picks earn more stars.',
      ),
    ],
  );

  static const four = HowToPlay(
    game: 'Four in a Row',
    tip: noClock,
    steps: [
      HowToStep(
        Icons.touch_app_rounded,
        'Tap a column to drop your star counter in.',
      ),
      HowToStep(
        Icons.swap_horiz_rounded,
        'Buddy takes a turn next, then it is your go again.',
      ),
      HowToStep(
        Icons.flag_rounded,
        'Get four in a line: across, up or on a slant.',
      ),
      HowToStep(
        Icons.shield_rounded,
        'Watch out! Block Buddy from getting four first.',
      ),
      HowToStep(
        Icons.star_rounded,
        'A win earns 3 stars, a draw 2, and playing to the end 1.',
      ),
    ],
  );

  static const dino = HowToPlay(
    game: 'Dino Discovery',
    tip: noClock,
    steps: [
      HowToStep(Icons.search_rounded, 'Tap a yellow search spot in the scene.'),
      HowToStep(
        Icons.menu_book_rounded,
        'Read the clue, then look closely at the three pictures.',
      ),
      HowToStep(
        Icons.touch_app_rounded,
        'Tap the creature that matches. Wrong pick? You get another clue.',
      ),
      HowToStep(
        Icons.flag_rounded,
        'Find all three, then finish the mission to earn stars.',
      ),
      HowToStep(
        Icons.auto_stories_rounded,
        'Finishing a place adds its creatures to your Field Guide.',
      ),
    ],
  );

  static const quickCreate = HowToPlay(
    game: 'Quick Create',
    tip: 'There is no score, so draw it your way!',
    steps: [
      HowToStep(
        Icons.lightbulb_rounded,
        'Read the drawing idea. Tap New idea if you want another.',
      ),
      HowToStep(Icons.brush_rounded, 'Tap Start drawing.'),
      HowToStep(Icons.palette_rounded, 'Draw the idea any way you like.'),
    ],
  );

  static HowToPlay of(GameKind kind) => switch (kind) {
    GameKind.memory => memory,
    GameKind.pattern => pattern,
    GameKind.spot => spot,
    GameKind.maze => maze,
    GameKind.robot => robot,
    GameKind.words => words,
    GameKind.sounds => sounds,
    GameKind.four => four,
  };
}

/// Shows the instructions while Buddy reads them. [buttonLabel] closes them.
Future<void> showHowToPlay(
  BuildContext context, {
  required HowToPlay guide,
  required BuddyVoice voice,
  String buttonLabel = HowToPlaySheet.gotItLabel,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.paper,
    builder: (_) =>
        HowToPlaySheet(guide: guide, voice: voice, buttonLabel: buttonLabel),
  );
  await voice.stop();
}

class HowToPlaySheet extends StatefulWidget {
  const HowToPlaySheet({
    super.key,
    required this.guide,
    required this.voice,
    required this.buttonLabel,
  });

  final HowToPlay guide;
  final BuddyVoice voice;
  final String buttonLabel;

  static const buttonTooltip = 'How to play';
  static const gotItLabel = 'Got it';
  static const letsPlayLabel = "Let's play!";
  static const hearLabel = 'Hear it again';

  static String titleOf(HowToPlay guide) => 'How to play ${guide.game}';

  @override
  State<HowToPlaySheet> createState() => _HowToPlaySheetState();
}

class _HowToPlaySheetState extends State<HowToPlaySheet> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.voice.say(widget.guide.spoken));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final guide = widget.guide;
    final tip = guide.tip;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              const Buddy(
                height: 72,
                mood: BuddyMood.excited,
                waveOnAppear: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    HowToPlaySheet.titleOf(guide),
                    style: textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (i, step) in guide.steps.indexed) ...[
            _StepRow(number: i + 1, step: step),
            const SizedBox(height: 8),
          ],
          if (tip != null) ...[
            const SizedBox(height: 4),
            Text(tip, style: textTheme.titleMedium),
          ],
          const SizedBox(height: 14),
          if (widget.voice.canSpeak) ...[
            OutlinedButton.icon(
              onPressed: () =>
                  unawaited(widget.voice.say(guide.spoken, requested: true)),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text(HowToPlaySheet.hearLabel),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(widget.buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.step});

  final int number;
  final HowToStep step;

  static const _colors = [
    AppColors.sunTint,
    AppColors.leafTint,
    AppColors.brandBlueTint,
    AppColors.grapeTint,
    AppColors.coralTint,
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Step $number. ${step.text}',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: AppShapes.sticker(
        _colors[(number - 1) % _colors.length],
        depth: 2,
        radius: 14,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.ink,
            child: Text(
              '$number',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(width: 10),
          Icon(step.icon, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    ),
  );
}
