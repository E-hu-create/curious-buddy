import 'package:flutter/material.dart';

import '../../../domain/discoveries/discovery_journal.dart';
import '../../../domain/games/dino.dart';
import '../../../domain/games/games.dart';
import '../../../domain/missions/more_missions.dart';
import '../../../domain/quiz/more_quiz_topics.dart';
import '../../../domain/stories/more_stories.dart';
import '../../core/themes/app_colors.dart';
import '../parent_zone_view_model.dart';
import 'parent_section.dart';

/// How far a child has come across the whole app, for a grown-up to see at a
/// glance. It is worked out from saved progress, so it adds nothing to what
/// is stored, and it never compares a child with anyone else.
class ProgressOverviewSection extends StatelessWidget {
  const ProgressOverviewSection({super.key, required this.vm});

  final ParentZoneViewModel vm;

  static const title = 'Progress at a glance';
  static const intro =
      'How far your child has come so far. Nothing here is timed or compared '
      'with anyone else.';
  static const loadError = "Curious Buddy couldn't read its progress just now.";
  static const missions = 'Mystery Missions solved';
  static const stories = 'Story endings found';
  static const quiz = 'Quiz Time stars';
  static const games = 'Game Zone stars';
  static const guide = 'Field Guide creatures';
  static const creationsLabel = 'Drawings and creatures made';
  static const nextTitle = 'A good next step';

  static String ofLabel(int done, int total) => '$done of $total';

  @override
  Widget build(BuildContext context) {
    final summary = vm.summary;
    return ParentSection(
      icon: Icons.insights_rounded,
      title: title,
      color: AppColors.leafTint,
      children: [
        if (vm.status == SummaryStatus.error)
          const ParentNote(loadError)
        else if (summary == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                semanticsLabel: 'Reading progress',
              ),
            ),
          )
        else
          ..._rows(summary),
      ],
    );
  }

  List<Widget> _rows(ActivitySummary summary) {
    final progress = summary.progress;
    final creations = summary.drawings + summary.creatures;
    final journal = DiscoveryJournal.build(
      progress: progress,
      missions: allMissions,
      stories: allStories,
      topics: allQuizTopics,
      creations: creations,
    );
    final endings = allStories.fold(0, (sum, s) => sum + s.endings.length);
    final quizMax = allQuizTopics.fold(
      0,
      (sum, t) => sum + t.levels.length * ArenaRules.maxStars,
    );
    return [
      const ParentNote(intro),
      _ProgressRow(
        label: missions,
        done: journal.casesSolved,
        total: allMissions.length,
      ),
      _ProgressRow(label: stories, done: journal.endingsFound, total: endings),
      _ProgressRow(label: quiz, done: journal.quizStars, total: quizMax),
      _ProgressRow(
        label: games,
        done: journal.gameStars,
        total: ArenaRules.allStars,
      ),
      _ProgressRow(
        label: guide,
        done: DinoRules.foundIn(progress.gameBest).length,
        total: DinoCreature.values.length,
      ),
      ParentFactLine(label: creationsLabel, value: '$creations'),
      const SizedBox(height: 14),
      ParentNote(nextTitle, bold: true),
      ParentNote(journal.next.text),
    ];
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.done,
    required this.total,
  });

  final String label;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: ${ProgressOverviewSection.ofLabel(done, total)}',
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ParentFactLine(
            label: label,
            value: ProgressOverviewSection.ofLabel(done, total),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 10,
              color: AppColors.buddyTealDeep,
              backgroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

/// A label and value on one line, wrapping if the text is large.
class ParentFactLine extends StatelessWidget {
  const ParentFactLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: 8),
        Text(value, style: textTheme.titleSmall),
      ],
    );
  }
}

/// Quick links to each part of the Parent Zone.
class ParentJumpBar extends StatelessWidget {
  const ParentJumpBar({super.key, required this.links});

  /// Each link's words, and what it does.
  final List<(String, VoidCallback)> links;

  static const title = 'Jump to';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (label, onTap) in links)
            OutlinedButton(onPressed: onTap, child: Text(label)),
        ],
      ),
    ],
  );
}
