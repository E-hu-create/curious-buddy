import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/missions/mission.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import 'mission_play_screen.dart';
import 'missions_view_model.dart';
import 'widgets/mission_cover.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({
    super.key,
    required this.missionRepository,
    required this.progressRepository,
    required this.voice,
  });

  final MissionRepository missionRepository;
  final ProgressRepository progressRepository;
  final BuddyVoice voice;

  static const title = 'Mystery Missions';
  static const welcome =
      'Welcome, detective! Pick a case. Inspect every clue, and ask me for a '
      'hint whenever you need one.';
  static const emptyMessage =
      'No missions are ready right now. Check back soon!';
  static const errorMessage =
      "Buddy couldn't open the case files. Please try again.";
  static const retryLabel = 'Try again';
  static const newLabel = 'New case';
  static const solvedLabel = 'Solved';
  static const playLabel = 'Play';
  static const replayLabel = 'Play again';

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  late final MissionsViewModel _vm = MissionsViewModel(
    missionRepository: widget.missionRepository,
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

  Future<void> _play(Mission mission) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/missions/${mission.id}'),
        builder: (_) => MissionPlayScreen(
          mission: mission,
          voice: widget.voice,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    // Show any new score or badge.
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
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        MissionsScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Buddy(height: 96, mood: BuddyMood.curious),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            MissionsScreen.welcome,
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
      case MissionsStatus.loading:
        return const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading missions',
              ),
            ),
          ),
        ];
      case MissionsStatus.empty:
        return [Text(MissionsScreen.emptyMessage, style: textTheme.bodyLarge)];
      case MissionsStatus.error:
        return [
          Text(MissionsScreen.errorMessage, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => unawaited(_vm.load()),
              child: const Text(MissionsScreen.retryLabel),
            ),
          ),
        ];
      case MissionsStatus.ready:
        return [
          _TrophyShelf(
            points: _vm.totalPoints,
            solved: _vm.solvedCount,
            total: _vm.summaries.length,
            badges: _vm.badges,
          ),
          const SizedBox(height: 20),
          for (final summary in _vm.summaries)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _MissionCard(
                summary: summary,
                onPlay: () => unawaited(_play(summary.mission)),
              ),
            ),
        ];
    }
  }
}

class _TrophyShelf extends StatelessWidget {
  const _TrophyShelf({
    required this.points,
    required this.solved,
    required this.total,
    required this.badges,
  });

  final int points;
  final int solved;
  final int total;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(AppColors.sunTint, depth: 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Stat(icon: Icons.star_rounded, label: '$points points'),
              _Stat(
                icon: Icons.task_alt_rounded,
                label: '$solved of $total cases solved',
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in badges)
                  Chip(
                    avatar: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.ink,
                    ),
                    label: Text(badge),
                    labelStyle: textTheme.labelLarge?.copyWith(
                      color: AppColors.ink,
                    ),
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: .min,
    children: [
      Icon(icon, color: AppColors.ink),
      const SizedBox(width: 6),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
    ],
  );
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.summary, required this.onPlay});

  final MissionSummary summary;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mission = summary.mission;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppShapes.sticker(AppColors.white),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          MissionCover(art: mission.art),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusTag(solved: summary.solved),
              if (summary.solved)
                Text(
                  'Best: ${summary.bestPoints} of ${summary.maxPoints} points',
                  style: textTheme.bodyMedium,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(mission.title, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(mission.tagline, style: textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('${mission.stages.length} steps', style: textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onPlay,
            icon: Icon(
              summary.solved ? Icons.replay_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(
              summary.solved
                  ? MissionsScreen.replayLabel
                  : MissionsScreen.playLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.solved});

  final bool solved;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: solved ? AppColors.leafTint : AppColors.sunTint,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.ink, width: 1.5),
    ),
    child: Row(
      mainAxisSize: .min,
      children: [
        Icon(
          solved ? Icons.check_circle_rounded : Icons.search_rounded,
          size: 18,
          color: AppColors.ink,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            solved ? MissionsScreen.solvedLabel : MissionsScreen.newLabel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    ),
  );
}
