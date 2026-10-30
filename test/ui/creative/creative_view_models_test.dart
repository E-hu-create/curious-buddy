import 'dart:math';

import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/creative/creative_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalCreationsRepository repository;

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
    repository = LocalCreationsRepository(store);
  });

  tearDown(() => voice.dispose());

  DrawingViewModel drawing([CreationsRepository? r]) =>
      DrawingViewModel(voice: voice, creationsRepository: r ?? repository);

  CreatureViewModel creature({CreationsRepository? r, int seed = 1}) =>
      CreatureViewModel(
        voice: voice,
        creationsRepository: r ?? repository,
        random: Random(seed),
      );

  void line(DrawingViewModel vm, {int y = 100}) {
    vm
      ..startStroke(DrawPoint(100, y))
      ..extendStroke(DrawPoint(200, y))
      ..extendStroke(DrawPoint(300, y))
      ..endStroke();
  }

  Future<void> fillShelf() async {
    for (var i = 0; i < CreativeLimits.maxCreations; i++) {
      await repository.add((id) => Drawing(id: id, strokes: const []));
    }
  }

  group('DrawingViewModel', () {
    test('a stroke keeps its points, colour and size', () {
      final vm = drawing()
        ..pickColor(4)
        ..pickSize(2);
      line(vm);

      expect(vm.strokes, hasLength(1));
      final stroke = vm.strokes.single;
      expect(stroke.colorIndex, 4);
      expect(stroke.sizeIndex, 2);
      expect(stroke.eraser, isFalse);
      expect(stroke.points, const [
        DrawPoint(100, 100),
        DrawPoint(200, 100),
        DrawPoint(300, 100),
      ]);
      expect(vm.active, isNull);
      vm.dispose();
    });

    test('tiny finger moves are dropped to keep drawings small', () {
      final vm = drawing()
        ..startStroke(const DrawPoint(100, 100))
        ..extendStroke(const DrawPoint(102, 101))
        ..extendStroke(const DrawPoint(103, 103))
        ..extendStroke(const DrawPoint(120, 100))
        ..endStroke();

      expect(vm.strokes.single.points, hasLength(2));
      vm.dispose();
    });

    test('points are kept inside the canvas', () {
      final vm = drawing()
        ..startStroke(const DrawPoint(-50, 5000))
        ..endStroke();

      expect(vm.strokes.single.points.single, const DrawPoint(0, 1000));
      vm.dispose();
    });

    test('a single tap makes a dot', () {
      final vm = drawing()
        ..startStroke(const DrawPoint(500, 500))
        ..endStroke();

      expect(vm.strokes.single.points, hasLength(1));
      expect(vm.hasDrawing, isTrue);
      vm.dispose();
    });

    test('invalid colours and sizes are ignored', () {
      final vm = drawing()
        ..pickColor(1)
        ..pickColor(99)
        ..pickColor(-1)
        ..pickSize(1)
        ..pickSize(99);

      expect(vm.colorIndex, 1);
      expect(vm.sizeIndex, 1);
      vm.dispose();
    });

    test('the eraser marks strokes; picking a colour turns it off', () {
      final vm = drawing()..toggleEraser();
      line(vm);
      expect(vm.strokes.single.eraser, isTrue);

      vm.pickColor(2);
      expect(vm.eraser, isFalse);
      vm.dispose();
    });

    test('undo removes the last stroke; clear removes them all', () {
      final vm = drawing();
      line(vm);
      line(vm, y: 200);
      line(vm, y: 300);

      vm.undo();
      expect(vm.strokes, hasLength(2));
      vm.clear();
      expect(vm.strokes, isEmpty);
      vm.undo(); // nothing left: harmless
      expect(vm.strokes, isEmpty);
      vm.dispose();
    });

    test('only eraser marks is not a drawing worth saving', () {
      final vm = drawing()..toggleEraser();
      line(vm);

      expect(vm.canSave, isFalse);
      vm.dispose();
    });

    test('the point cap stops the stroke and tells the child', () async {
      final vm = drawing()..startStroke(const DrawPoint(0, 0));
      for (var i = 0; i < CreativeLimits.maxPointsPerDrawing + 10; i++) {
        // Zigzag, so every point is far enough from the last.
        vm.extendStroke(DrawPoint(i.isEven ? 900 : 0, 0));
      }
      await pumpEventQueue();

      expect(vm.pointCount, CreativeLimits.maxPointsPerDrawing);
      expect(vm.pointsFull, isTrue);
      expect(vm.active, isNull);
      expect(tts.spoken.last, DrawingViewModel.pointsFullLine);

      vm.startStroke(const DrawPoint(5, 5));
      expect(vm.active, isNull, reason: 'no more lines');
      vm.undo();
      expect(vm.pointsFull, isFalse, reason: 'undo makes room');
      vm.dispose();
    });

    test('saving adds it to the shelf and locks the picture', () async {
      final vm = drawing();
      line(vm);
      await vm.save();
      await pumpEventQueue();

      expect(vm.saveStatus, CreationSaveStatus.saved);
      expect(tts.spoken.last, CreativeActivityViewModel.savedLine);
      final shelf = await repository.load();
      expect(shelf.drawings, 1);
      expect((shelf.items.single as Drawing).strokes, hasLength(1));

      expect(vm.canSave, isFalse);
      vm.startStroke(const DrawPoint(9, 9));
      expect(vm.active, isNull);
      await vm.save();
      expect((await repository.load()).items, hasLength(1), reason: 'once');
      vm.dispose();
    });

    test('Draw another starts with a clean canvas', () async {
      final vm = drawing();
      line(vm);
      await vm.save();
      vm.startAgain();

      expect(vm.strokes, isEmpty);
      expect(vm.saveStatus, CreationSaveStatus.notSaved);
      vm.dispose();
    });

    test('a full shelf is explained, and the drawing is kept', () async {
      await fillShelf();
      final vm = drawing();
      line(vm);
      await vm.save();

      expect(vm.saveStatus, CreationSaveStatus.full);
      expect(vm.strokes, hasLength(1));
      expect(vm.canSave, isTrue);
      vm.dispose();
    });

    test('a storage failure is reported, and the drawing is kept', () async {
      final vm = drawing(LocalCreationsRepository(ReadOnlyKeyValueStore()));
      line(vm);
      await vm.save();

      expect(vm.saveStatus, CreationSaveStatus.failed);
      expect(vm.strokes, hasLength(1));
      vm.dispose();
    });
  });

  group('CreatureViewModel', () {
    test('starts with a colourful creature and a listed name', () {
      final vm = creature();

      expect(creatureNames, contains(vm.creature.name));
      expect(vm.creature.colorIndex, greaterThan(0), reason: 'not outline ink');
      vm.dispose();
    });

    test('every choice changes the creature', () {
      final vm = creature()
        ..setBody(CreatureBody.tall)
        ..setColor(5)
        ..setEyes(CreatureEyes.sleepy)
        ..setMouth(CreatureMouth.tongue)
        ..setExtra(CreatureExtra.horns)
        ..setPattern(CreaturePattern.stripes);

      final c = vm.creature;
      expect(c.body, CreatureBody.tall);
      expect(c.colorIndex, 5);
      expect(c.eyes, CreatureEyes.sleepy);
      expect(c.mouth, CreatureMouth.tongue);
      expect(c.extra, CreatureExtra.horns);
      expect(c.pattern, CreaturePattern.stripes);
      vm.dispose();
    });

    test('an invalid colour is ignored', () {
      final vm = creature()..setColor(2);
      vm.setColor(99);
      expect(vm.creature.colorIndex, 2);
      vm.dispose();
    });

    test('Buddy shares a real fact when a part changes', () async {
      final vm = creature()..setExtra(CreatureExtra.wings);
      await pumpEventQueue();

      expect(tts.spoken.last, contains('Bats are the only mammals'));
      vm.dispose();
    });

    test('Surprise me keeps the name and picks new parts', () {
      final vm = creature();
      final name = vm.creature.name;
      final seen = <String>{};
      for (var i = 0; i < 10; i++) {
        vm.surprise();
        final c = vm.creature;
        seen.add('${c.body}${c.colorIndex}${c.eyes}${c.extra}');
        expect(c.name, name);
      }
      expect(seen.length, greaterThan(1));
      vm.dispose();
    });

    test('New name always gives a different listed name', () async {
      final vm = creature();
      for (var i = 0; i < 20; i++) {
        final before = vm.creature.name;
        vm.newName();
        expect(vm.creature.name, isNot(before));
        expect(creatureNames, contains(vm.creature.name));
      }
      await pumpEventQueue();
      expect(tts.spoken.last, 'Hello, ${vm.creature.name}!');
      vm.dispose();
    });

    test('saving adds it to the shelf with a real id', () async {
      final vm = creature()..setExtra(CreatureExtra.antennae);
      await vm.save();

      final saved = (await repository.load()).items.single as Creature;
      expect(saved.id, 'c1');
      expect(saved.name, vm.creature.name);
      expect(saved.extra, CreatureExtra.antennae);
      vm.dispose();
    });

    test('Make another starts a new creature; a saved one is locked', () async {
      final vm = creature();
      await vm.save();
      final saved = vm.creature;

      vm.setExtra(CreatureExtra.wings);
      expect(identical(vm.creature, saved), isTrue, reason: 'locked');

      vm.startAgain();
      expect(vm.saveStatus, CreationSaveStatus.notSaved);
      expect(identical(vm.creature, saved), isFalse);
      vm.dispose();
    });

    test('a full shelf is explained; changing a part allows a retry', () async {
      await fillShelf();
      final vm = creature();
      await vm.save();
      expect(vm.saveStatus, CreationSaveStatus.full);

      vm.setBody(CreatureBody.wide);
      expect(vm.saveStatus, CreationSaveStatus.notSaved);
      vm.dispose();
    });
  });

  group('voice', () {
    test('Buddy reads the intro; Hear again repeats it', () async {
      final vm = drawing()..narrateIntro();
      await pumpEventQueue();
      expect(tts.spoken.single, vm.introLine);

      vm.hearAgain();
      await pumpEventQueue();
      expect(tts.spoken, hasLength(2));
      vm.dispose();
    });

    test('automatic reading off: quiet, but Hear again still works', () async {
      await voice.setAutoRead(false);
      final vm = creature()..narrateIntro();
      await pumpEventQueue();
      expect(tts.spoken, isEmpty);

      vm.hearAgain();
      await pumpEventQueue();
      expect(tts.spoken, hasLength(1));
      vm.dispose();
    });

    test('with the voice off, everything still works', () async {
      await voice.setMuted(true);
      final vm = drawing();
      line(vm);
      await vm.save();

      expect(tts.spoken, isEmpty);
      expect(vm.saveStatus, CreationSaveStatus.saved);
      vm.dispose();
    });

    test('leaving an activity stops Buddy mid-sentence', () async {
      tts.holdSpeech = true;
      final vm = creature()..narrateIntro();
      await pumpEventQueue();
      expect(tts.isSpeaking, isTrue);

      vm.dispose();
      await pumpEventQueue();
      expect(tts.isSpeaking, isFalse);
    });
  });

  group('CreativeHubViewModel', () {
    test('loads the shelf, newest first', () async {
      final a = await repository.add(
        (id) => Drawing(id: id, strokes: const []),
      );
      final b = await repository.add(
        (id) => Drawing(id: id, strokes: const []),
      );
      final vm = CreativeHubViewModel(creationsRepository: repository);
      await vm.load();

      expect(vm.status, CreativeStatus.ready);
      expect([for (final c in vm.newestFirst) c.id], [b.id, a.id]);
      vm.dispose();
    });

    test('remove takes one creation off the shelf', () async {
      final a = await repository.add(
        (id) => Drawing(id: id, strokes: const []),
      );
      final vm = CreativeHubViewModel(creationsRepository: repository);
      await vm.load();

      expect(await vm.remove(a.id), isTrue);
      expect(vm.shelf.items, isEmpty);
      vm.dispose();
    });

    test('a storage error shows an error, not an empty shelf', () async {
      final vm = CreativeHubViewModel(
        creationsRepository: LocalCreationsRepository(FailingKeyValueStore()),
      );
      await vm.load();

      expect(vm.status, CreativeStatus.error);
      vm.dispose();
    });
  });
}
