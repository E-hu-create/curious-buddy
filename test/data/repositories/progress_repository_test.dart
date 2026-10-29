import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late InMemoryKeyValueStore store;
  late LocalProgressRepository repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = LocalProgressRepository(store);
  });

  test('returns empty progress when nothing is saved', () async {
    expect(await repository.load(), LearnerProgress.empty);
  });

  test('saves and reloads progress', () async {
    const progress = LearnerProgress(completedMissionIds: {'ocean_1'});

    await repository.save(progress);

    expect(await LocalProgressRepository(store).load(), progress);
  });

  for (final (name, raw) in [
    ('invalid JSON', '{not json'),
    ('wrong shape', '[1, 2, 3]'),
    ('future schema', '{"schemaVersion": 999}'),
  ]) {
    test('backs up unreadable data ($name) and recovers to empty', () async {
      await store.write(LocalProgressRepository.storageKey, raw);

      expect(await repository.load(), LearnerProgress.empty);
      expect(await store.read(LocalProgressRepository.corruptBackupKey), raw);
    });
  }

  test(
    'storage errors propagate instead of looking like no progress',
    () async {
      final failing = FailingKeyValueStore();

      await expectLater(
        LocalProgressRepository(failing).load(),
        throwsA(isA<FileSystemLikeException>()),
      );
      expect(failing.writes, 0);
    },
  );
}
