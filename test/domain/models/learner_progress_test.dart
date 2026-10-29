import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearnerProgress.tryFromJson', () {
    test('round-trips through toJson', () {
      const progress = LearnerProgress(
        completedMissionIds: {'ocean_1', 'space-2'},
        completedStoryIds: {'dragon'},
      );

      expect(LearnerProgress.tryFromJson(progress.toJson()), progress);
    });

    test('rejects non-map input', () {
      expect(LearnerProgress.tryFromJson(null), isNull);
      expect(LearnerProgress.tryFromJson('text'), isNull);
      expect(LearnerProgress.tryFromJson(<Object?>[]), isNull);
    });

    test('rejects missing, invalid and future schema versions', () {
      expect(LearnerProgress.tryFromJson(<String, Object?>{}), isNull);
      expect(LearnerProgress.tryFromJson({'schemaVersion': 'one'}), isNull);
      expect(LearnerProgress.tryFromJson({'schemaVersion': 0}), isNull);
      expect(
        LearnerProgress.tryFromJson({
          'schemaVersion': LearnerProgress.schemaVersion + 1,
        }),
        isNull,
      );
    });

    test('drops malformed ids but keeps valid ones', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 1,
        'completedMissionIds': [
          'ok_1',
          42,
          null,
          '',
          'Has Spaces',
          'x' * (LearnerProgress.maxIdLength + 1),
        ],
        'completedStoryIds': 'not-a-list',
      });

      expect(progress, isNotNull);
      expect(progress!.completedMissionIds, {'ok_1'});
      expect(progress.completedStoryIds, isEmpty);
    });
  });

  group('mission scores (schema 2)', () {
    test('round-trips best points', () {
      const progress = LearnerProgress(
        completedMissionIds: {'moon'},
        missionBestPoints: {'moon': 120},
      );

      expect(LearnerProgress.tryFromJson(progress.toJson()), progress);
    });

    test('reads version 1 data (no scores) without losing missions', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 1,
        'completedMissionIds': ['moon'],
      });

      expect(progress!.completedMissionIds, {'moon'});
      expect(progress.missionBestPoints, isEmpty);
    });

    test('drops malformed scores but keeps valid ones', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 2,
        'missionBestPoints': {
          'ok': 50,
          'negative': -5,
          'huge': LearnerProgress.maxPoints + 1,
          'text': 'lots',
          'Bad Id': 10,
        },
      });

      expect(progress!.missionBestPoints, {'ok': 50});
    });

    test('withMissionResult records completion and keeps the best score', () {
      final first = LearnerProgress.empty.withMissionResult('moon', 100);
      final worse = first.withMissionResult('moon', 60);
      final better = worse.withMissionResult('moon', 140);

      expect(first.completedMissionIds, {'moon'});
      expect(worse.missionBestPoints['moon'], 100);
      expect(better.missionBestPoints['moon'], 140);
    });

    test('total points add each mission best', () {
      final progress = LearnerProgress.empty
          .withMissionResult('a', 100)
          .withMissionResult('b', 50)
          .withMissionResult('a', 80);

      expect(progress.totalMissionPoints, 150);
    });
  });
}
