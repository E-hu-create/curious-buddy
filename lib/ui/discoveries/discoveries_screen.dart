import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/discoveries/discovery_journal.dart';
import '../../domain/stories/story.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../creative/widgets/creative_art.dart';
import '../missions/widgets/stage_widgets.dart';
import '../quiz/widgets/quiz_widgets.dart';
import 'discoveries_view_model.dart';

/// The child's explorer journal, worked out from what is already saved.
class DiscoveriesScreen extends StatefulWidget {
  const DiscoveriesScreen({
    super.key,
    required this.progressRepository,
    required this.missionRepository,
    required this.storyRepository,
    required this.quizRepository,
    required this.creationsRepository,
    required this.voice,
  });

  final ProgressRepository progressRepository;
  final MissionRepository missionRepository;
  final StoryRepository storyRepository;
  final QuizRepository quizRepository;
  final CreationsRepository creationsRepository;
  final BuddyVoice voice;

  static const title = 'My Discoveries';
  static const nextTitle = 'Your next adventure';
  static const badgesTitle = 'Mission badges';
  static const storiesTitle = 'Story discoveries';
  static const quizTitle = 'Quiz stars';
  static const creationsTitle = 'Recent creations';
  static const noCreations = 'Nothing yet. Your creations will appear here.';
  static const openCreative = 'Open Creative Island';
  static const notYet = 'Not earned yet';
  static const noEndings = 'No endings found yet.';
  static const topRank = 'You have reached the top rank. Amazing!';
  static const partialNote =
      "Buddy couldn't find part of your journal just now, so it is hidden "
      'for the moment. Nothing has been lost.';
  static const errorMessage =
      "Buddy couldn't open your journal. Please try again.";
  static const retryLabel = 'Try again';

  static String rankLine(int more, String next) =>
      '$more more to become a $next!';
  static String moreEndings(int n) =>
      '$n more ${n == 1 ? 'ending' : 'endings'} to find';
  static String readTooltip(String title) => 'Read "$title" aloud';
  static String goLabel(AdventureKind kind) => switch (kind) {
    AdventureKind.mission => 'Go to Mystery Missions',
    AdventureKind.story => 'Go to Living Stories',
    AdventureKind.quiz => 'Go to Quiz Time',
    AdventureKind.creative => 'Go to Creative Island',
  };

  static String routeFor(AdventureKind kind) => switch (kind) {
    AdventureKind.mission => Routes.missions,
    AdventureKind.story => Routes.stories,
    AdventureKind.quiz => Routes.quiz,
    AdventureKind.creative => Routes.creative,
  };

  @override
  State<DiscoveriesScreen> createState() => _DiscoveriesScreenState();
}

class _DiscoveriesScreenState extends State<DiscoveriesScreen> {
  late final DiscoveriesViewModel _vm = DiscoveriesViewModel(
    progressRepository: widget.progressRepository,
    missionRepository: widget.missionRepository,
    storyRepository: widget.storyRepository,
    quizRepository: widget.quizRepository,
    creationsRepository: widget.creationsRepository,
    voice: widget.voice,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    await _vm.load();
    if (mounted) _vm.narrateSummary();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _go(String route) async {
    await Navigator.of(context).pushNamed(route);
    // Show whatever was just done.
    await _vm.load();
  }

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
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        DiscoveriesScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
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
    final journal = _vm.journal;
    if (_vm.status == DiscoveriesStatus.loading) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading your journal',
            ),
          ),
        ),
      ];
    }
    if (_vm.status == DiscoveriesStatus.error || journal == null) {
      return [
        Text(DiscoveriesScreen.errorMessage, style: textTheme.bodyLarge),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () => unawaited(_open()),
            child: const Text(DiscoveriesScreen.retryLabel),
          ),
        ),
      ];
    }
    return [
      _SummaryCard(vm: _vm, journal: journal),
      if (_vm.isPartial) ...[
        const SizedBox(height: 12),
        Text(DiscoveriesScreen.partialNote, style: textTheme.bodyMedium),
      ],
      const SizedBox(height: 16),
      _NextCard(
        next: journal.next,
        onGo: () =>
            unawaited(_go(DiscoveriesScreen.routeFor(journal.next.kind))),
      ),
      if (journal.badges case final badges?) ...[
        const SizedBox(height: 20),
        _heading(textTheme, DiscoveriesScreen.badgesTitle),
        for (final b in badges) _BadgeRow(entry: b),
      ],
      if (journal.stories case final stories?) ...[
        const SizedBox(height: 20),
        _heading(textTheme, DiscoveriesScreen.storiesTitle),
        for (final s in stories)
          _StoryCard(
            entry: s,
            canSpeak: _vm.canSpeak,
            onRead: (e) =>
                _vm.readDiscovery(s.story.title, e.title, e.discovery),
          ),
      ],
      if (journal.quizzes case final quizzes?) ...[
        const SizedBox(height: 20),
        _heading(textTheme, DiscoveriesScreen.quizTitle),
        for (final q in quizzes) _QuizRow(entry: q),
      ],
      if (journal.creations != null) ...[
        const SizedBox(height: 20),
        _heading(textTheme, DiscoveriesScreen.creationsTitle),
        _creations(textTheme),
      ],
    ];
  }

  Widget _heading(TextTheme textTheme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(text, style: textTheme.titleLarge),
    ),
  );

  Widget _creations(TextTheme textTheme) => Column(
    crossAxisAlignment: .stretch,
    children: [
      if (_vm.recentCreations.isEmpty)
        Text(DiscoveriesScreen.noCreations, style: textTheme.bodyLarge)
      else
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            const columns = 2;
            final width = (constraints.maxWidth - gap) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final c in _vm.recentCreations)
                  Container(
                    width: width,
                    padding: const EdgeInsets.all(6),
                    decoration: AppShapes.sticker(
                      AppColors.white,
                      depth: 3,
                      radius: 16,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CreationPicture(creation: c),
                    ),
                  ),
              ],
            );
          },
        ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => unawaited(_go(Routes.creative)),
        icon: const Icon(Icons.palette_rounded),
        label: const Text(DiscoveriesScreen.openCreative),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.vm, required this.journal});

  final DiscoveriesViewModel vm;
  final DiscoveryJournal journal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final next = journal.rank.next;
    final more = journal.toNextRank;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.coralTint),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Buddy(
                height: 84,
                mood: journal.isEmpty ? BuddyMood.curious : BuddyMood.excited,
                waveOnAppear: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(journal.rank.title, style: textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      next != null && more != null
                          ? DiscoveriesScreen.rankLine(more, next.title)
                          : DiscoveriesScreen.topRank,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(journal.summary, style: textTheme.bodyLarge),
          const SizedBox(height: 10),
          MissionVoiceBar(
            canSpeak: vm.canSpeak,
            isSpeaking: vm.isSpeaking,
            onHearAgain: vm.lastSpoken == null ? null : vm.hearAgain,
            onStop: () => unawaited(vm.stopSpeaking()),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Total(
                icon: Icons.search_rounded,
                label: _count(journal.casesSolved, 'case', 'cases'),
              ),
              _Total(
                icon: Icons.auto_stories_rounded,
                label: _count(journal.endingsFound, 'ending', 'endings'),
              ),
              _Total(
                icon: Icons.star_rounded,
                label: _count(journal.quizStars, 'star', 'stars'),
              ),
              _Total(
                icon: Icons.palette_rounded,
                label: _count(journal.creationCount, 'creation', 'creations'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _count(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';
}

class _Total extends StatelessWidget {
  const _Total({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.ink, width: 1.5),
    ),
    child: Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 18, color: AppColors.ink),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ],
    ),
  );
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.next, required this.onGo});

  final NextAdventure next;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.sunTint),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              DiscoveriesScreen.nextTitle,
              style: textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          Text(next.text, style: textTheme.bodyLarge),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onGo,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(DiscoveriesScreen.goLabel(next.kind)),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.entry});

  final BadgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final earned = entry.earned;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? AppColors.sunTint : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            earned ? Icons.workspace_premium_rounded : Icons.lock_rounded,
            color: earned ? AppColors.ink : AppColors.inkSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  earned ? entry.mission.badge : entry.mission.title,
                  style: textTheme.titleMedium,
                ),
                Text(
                  earned ? entry.mission.title : DiscoveriesScreen.notYet,
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.entry,
    required this.canSpeak,
    required this.onRead,
  });

  final StoryDiscoveries entry;
  final bool canSpeak;
  final ValueChanged<StoryEnding> onRead;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(entry.story.title, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          if (entry.found.isEmpty)
            Text(DiscoveriesScreen.noEndings, style: textTheme.bodyMedium),
          for (final e in entry.found)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          e.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(e.discovery, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  if (canSpeak)
                    IconButton(
                      tooltip: DiscoveriesScreen.readTooltip(e.title),
                      onPressed: () => onRead(e),
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                ],
              ),
            ),
          if (entry.remaining > 0)
            Text(
              DiscoveriesScreen.moreEndings(entry.remaining),
              style: textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _QuizRow extends StatelessWidget {
  const _QuizRow({required this.entry});

  final TopicStars entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          QuizTopicBadge(topicId: entry.topic.id, size: 40),
          const SizedBox(width: 10),
          // Wraps at large text sizes instead of overflowing.
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(entry.topic.title, style: textTheme.titleMedium),
                Row(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      '${entry.stars} of ${entry.maxStars}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded, color: AppColors.ink),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
