import 'package:flutter/foundation.dart';

import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/missions/mission.dart';
import '../../domain/missions/mission_rules.dart';
import '../../domain/models/learner_progress.dart';

enum MissionsStatus { loading, ready, empty, error }

/// A mission card's data: the mission and how the child has done.
class MissionSummary {
  const MissionSummary({
    required this.mission,
    required this.solved,
    required this.bestPoints,
    required this.maxPoints,
  });

  final Mission mission;
  final bool solved;
  final int bestPoints;
  final int maxPoints;
}

class MissionsViewModel extends ChangeNotifier {
  MissionsViewModel({
    required MissionRepository missionRepository,
    required ProgressRepository progressRepository,
  }) : _missions = missionRepository,
       _progress = progressRepository;

  final MissionRepository _missions;
  final ProgressRepository _progress;
  bool _disposed = false;

  MissionsStatus get status => _status;
  MissionsStatus _status = MissionsStatus.loading;

  List<MissionSummary> get summaries => _summaries;
  List<MissionSummary> _summaries = const [];

  int get totalPoints => _progressData.totalMissionPoints;
  int get solvedCount => _summaries.where((s) => s.solved).length;
  List<String> get badges => [
    for (final s in _summaries)
      if (s.solved) s.mission.badge,
  ];

  LearnerProgress _progressData = LearnerProgress.empty;

  /// Loads missions and progress. Safe to call again (e.g. after a mission).
  Future<void> load() async {
    List<Mission> missions;
    try {
      missions = await _missions.loadMissions();
    } on Exception {
      _status = MissionsStatus.error;
      _notify();
      return;
    }
    try {
      _progressData = await _progress.load();
    } on Exception {
      // Missions still work; scores just are not shown this time.
      _progressData = LearnerProgress.empty;
    }
    _summaries = [
      for (final mission in missions)
        MissionSummary(
          mission: mission,
          solved: _progressData.completedMissionIds.contains(mission.id),
          bestPoints: _progressData.missionBestPoints[mission.id] ?? 0,
          maxPoints: MissionScore.maxFor(mission),
        ),
    ];
    _status = missions.isEmpty ? MissionsStatus.empty : MissionsStatus.ready;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
