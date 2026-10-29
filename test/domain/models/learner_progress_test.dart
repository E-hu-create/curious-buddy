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
}
