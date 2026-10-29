import 'package:flutter/foundation.dart';

import '../../domain/missions/mission.dart';
import '../../domain/missions/mission_content.dart';
import '../../domain/missions/mission_rules.dart';

/// Where missions come from. Today: the reviewed starter missions bundled
/// in the app (offline). Kept behind an interface so more can be added
/// later without changing screens.
abstract interface class MissionRepository {
  /// Only valid, playable missions. Invalid ones are left out (and logged)
  /// rather than shown broken.
  Future<List<Mission>> loadMissions();
}

class BundledMissionRepository implements MissionRepository {
  BundledMissionRepository({this.missions = starterMissions});

  final List<Mission> missions;

  @override
  Future<List<Mission>> loadMissions() async {
    final ids = <String>{};
    return [
      for (final mission in missions)
        if (_isPlayable(mission, ids)) mission,
    ];
  }

  static bool _isPlayable(Mission mission, Set<String> seenIds) {
    final problems = MissionValidator.problems(mission);
    if (!seenIds.add(mission.id)) problems.add('duplicate id ${mission.id}');
    if (problems.isEmpty) return true;
    debugPrint('Missions: skipping invalid mission: ${problems.join('; ')}');
    return false;
  }
}
