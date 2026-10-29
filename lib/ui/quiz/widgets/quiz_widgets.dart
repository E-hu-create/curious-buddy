import 'package:flutter/material.dart';

import '../../../domain/quiz/quiz.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// Each topic's icon and colour, in the app's sticker style.
({IconData icon, Color color, Color tint}) quizTopicStyle(String topicId) =>
    switch (topicId) {
      'space' => (
        icon: Icons.rocket_launch_rounded,
        color: AppColors.grape,
        tint: AppColors.grapeTint,
      ),
      'animals' => (
        icon: Icons.pets_rounded,
        color: AppColors.sun,
        tint: AppColors.sunTint,
      ),
      'body' => (
        icon: Icons.favorite_rounded,
        color: AppColors.coral,
        tint: AppColors.coralTint,
      ),
      'earth' => (
        icon: Icons.public_rounded,
        color: AppColors.leaf,
        tint: AppColors.leafTint,
      ),
      _ => (
        icon: Icons.quiz_rounded,
        color: AppColors.brandBlue,
        tint: AppColors.brandBlueTint,
      ),
    };

String quizLevelName(QuizDifficulty difficulty) => switch (difficulty) {
  QuizDifficulty.starter => 'Starter',
  QuizDifficulty.explorer => 'Explorer',
  QuizDifficulty.expert => 'Expert',
};

/// A round icon sticker for a topic.
class QuizTopicBadge extends StatelessWidget {
  const QuizTopicBadge({super.key, required this.topicId, this.size = 56});

  final String topicId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = quizTopicStyle(topicId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2.5),
      ),
      child: Icon(style.icon, color: AppColors.ink, size: size * 0.5),
    );
  }
}

/// 0 to 3 stars, read out as "2 of 3 stars".
class QuizStars extends StatelessWidget {
  const QuizStars({super.key, required this.stars, this.size = 24});

  final int stars;
  final double size;

  static String label(int stars) => '$stars of 3 stars';

  @override
  Widget build(BuildContext context) => Semantics(
    label: label(stars),
    excludeSemantics: true,
    child: Row(
      mainAxisSize: .min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < stars ? AppColors.backpackShade : AppColors.inkSoft,
          ),
      ],
    ),
  );
}

enum QuizAnswerState { idle, right, wrong, revealed, dimmed }

/// One answer, with its letter. After the pick it shows right or wrong,
/// in words and with an icon, not only by colour.
class QuizAnswerTile extends StatelessWidget {
  const QuizAnswerTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final QuizAnswerState state;
  final VoidCallback? onTap;

  static const rightTag = 'Right answer';
  static const yourAnswerTag = 'Your answer';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (Color fill, IconData? icon, String? tag) = switch (state) {
      QuizAnswerState.idle => (AppColors.white, null, null),
      QuizAnswerState.right => (
        AppColors.leafTint,
        Icons.check_circle_rounded,
        rightTag,
      ),
      QuizAnswerState.wrong => (
        AppColors.coralTint,
        Icons.cancel_rounded,
        yourAnswerTag,
      ),
      QuizAnswerState.revealed => (
        AppColors.leafTint,
        Icons.check_circle_rounded,
        rightTag,
      ),
      QuizAnswerState.dimmed => (AppColors.paper, null, null),
    };
    final emphasis =
        state == QuizAnswerState.right ||
        state == QuizAnswerState.wrong ||
        state == QuizAnswerState.revealed;
    return Semantics(
      button: onTap != null,
      label: ['Answer $letter: $text', ?tag].join(', '),
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppTheme.minTouchTarget + 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.ink,
                width: emphasis ? 3 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Text(
                    letter,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(text, style: textTheme.titleMedium),
                      if (tag != null)
                        Text(
                          tag,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: AppColors.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Right or wrong, with the explanation, after each answer.
class QuizResultPanel extends StatelessWidget {
  const QuizResultPanel({
    super.key,
    required this.correct,
    required this.answer,
    required this.explanation,
  });

  final bool correct;
  final String answer;
  final String explanation;

  static const rightTitle = "That's right!";
  static const wrongTitle = 'Not quite.';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppShapes.sticker(
          correct ? AppColors.leafTint : AppColors.sunTint,
          depth: 3,
          radius: 18,
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Icon(
                  correct
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correct ? rightTitle : '$wrongTitle The answer is $answer.',
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(explanation, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
