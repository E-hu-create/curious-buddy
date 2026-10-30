import 'package:curious_buddy/data/repositories/mission_repository.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:flutter_test/flutter_test.dart';

Mission _withId(Mission source, String id) => Mission(
  id: id,
  title: source.title,
  tagline: source.tagline,
  art: source.art,
  intro: source.intro,
  objective: source.objective,
  stages: source.stages,
  solution: source.solution,
  badge: source.badge,
);

void main() {
  test('loads every mission offline, none left out', () async {
    final missions = await BundledMissionRepository().loadMissions();

    expect(
      [for (final m in missions) m.id],
      [for (final m in allMissions) m.id],
    );
    expect(missions, hasLength(10));
  });

  test('leaves out invalid missions instead of showing them broken', () async {
    final broken = Mission(
      id: 'broken',
      title: 'Broken',
      tagline: 't',
      art: MissionArt.garden,
      intro: 'i',
      objective: 'o',
      stages: const [], // no stages: unplayable
      solution: 's',
      badge: 'b',
    );
    final missions = await BundledMissionRepository(
      missions: [starterMissions.first, broken],
    ).loadMissions();

    expect([for (final m in missions) m.id], ['missing_moonstone']);
  });

  test('leaves out duplicate ids', () async {
    final missions = await BundledMissionRepository(
      missions: [
        starterMissions.first,
        _withId(starterMissions[1], starterMissions.first.id),
      ],
    ).loadMissions();

    expect(missions, hasLength(1));
  });

  test('an empty catalogue loads as an empty list', () async {
    expect(
      await BundledMissionRepository(missions: []).loadMissions(),
      isEmpty,
    );
  });
}
