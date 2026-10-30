import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/creative/creation_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

Creature _creature(String id) => Creature(
  id: id,
  name: creatureNames.first,
  body: CreatureBody.blob,
  colorIndex: 2,
  eyes: CreatureEyes.round,
  mouth: CreatureMouth.smile,
  extra: CreatureExtra.none,
  pattern: CreaturePattern.none,
);

Drawing _drawing(String id) => Drawing(
  id: id,
  strokes: const [
    Stroke(colorIndex: 4, sizeIndex: 1, points: [DrawPoint(1, 2)]),
  ],
);

void main() {
  late InMemoryKeyValueStore store;
  late LocalCreationsRepository repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = LocalCreationsRepository(store);
  });

  test('starts empty', () async {
    expect((await repository.load()).items, isEmpty);
  });

  test('adds creations with new ids, and keeps them', () async {
    final first = await repository.add(_drawing);
    final second = await repository.add(_creature);

    expect(first.id, 'c1');
    expect(second.id, 'c2');
    final shelf = await LocalCreationsRepository(store).load();
    expect([for (final i in shelf.items) i.id], ['c1', 'c2']);
    expect(shelf.drawings, 1);
    expect(shelf.creatures, 1);
  });

  test('removing one keeps the others; ids are never reused', () async {
    await repository.add(_drawing);
    await repository.add(_creature);
    await repository.remove('c1');

    final shelf = await repository.load();
    expect([for (final i in shelf.items) i.id], ['c2']);
    expect((await repository.add(_drawing)).id, 'c3');
  });

  test('a full shelf refuses new creations', () async {
    for (var i = 0; i < CreativeLimits.maxCreations; i++) {
      await repository.add(_creature);
    }

    expect(
      () => repository.add(_drawing),
      throwsA(isA<CreationsFullException>()),
    );
    expect(
      (await repository.load()).items,
      hasLength(CreativeLimits.maxCreations),
    );
  });

  test('unreadable data is backed up, not lost', () async {
    await store.write(LocalCreationsRepository.storageKey, '{broken');

    expect(await repository.load(), isA<CreationShelf>());
    expect((await repository.load()).items, isEmpty);
    expect(
      await store.read(LocalCreationsRepository.corruptBackupKey),
      '{broken',
    );
    expect(await repository.hasCorruptBackup(), isTrue);
  });

  test('clear deletes creations and the backup, and nothing else', () async {
    await repository.add(_drawing);
    await store.write(LocalCreationsRepository.corruptBackupKey, 'old');
    await store.write('progress', 'kept');

    await repository.clear();

    expect(await store.read(LocalCreationsRepository.storageKey), isNull);
    expect(await store.read(LocalCreationsRepository.corruptBackupKey), isNull);
    expect(await store.read('progress'), 'kept');
    expect((await LocalCreationsRepository(store).load()).items, isEmpty);
  });

  test('storage errors propagate instead of looking like an empty shelf', () {
    final failing = LocalCreationsRepository(FailingKeyValueStore());
    expect(failing.load(), throwsA(isA<FileSystemLikeException>()));
  });
}
