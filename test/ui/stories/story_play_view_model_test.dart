import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/stories/story_play_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

Story storyWith(String id) => starterStories.firstWhere((s) => s.id == id);

final forest = storyWith('forest_colours');

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  StoryPlayViewModel build({
    Story? story,
    List<String>? resumePath,
    Set<String> found = const {},
    ProgressRepository? repository,
  }) => StoryPlayViewModel(
    story: story ?? forest,
    voice: voice,
    progressRepository: repository ?? progress,
    resumePath: resumePath,
    foundEndingIds: found,
  );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  test('opens on the intro, and Buddy reads it', () async {
    final vm = build()..narrateOpening();
    await pumpEventQueue();

    expect(vm.phase, StoryPhase.intro);
    expect(tts.spoken.single, forest.intro);
    vm.dispose();
  });

  test('begin shows the first scene and reads it', () async {
    final vm = build()..begin();
    await pumpEventQueue();

    expect(vm.phase, StoryPhase.scene);
    expect(vm.scene.id, forest.startSceneId);
    expect(vm.sceneNumber, 1);
    expect(vm.consequence, isNull);
    expect(tts.spoken.last, vm.scene.text);
    vm.dispose();
  });

  test('a choice moves to its scene and explains what happened', () async {
    final vm = build()..begin();
    vm.choose('climb_oak');
    await pumpEventQueue();

    expect(vm.scene.id, 'dusty_crystal');
    expect(vm.path, ['grey_morning', 'dusty_crystal']);
    expect(vm.consequence, contains('climbed all the way up'));
    expect(tts.spoken.last, startsWith(vm.consequence!));
    expect(tts.spoken.last, contains(vm.scene.text));
    vm.dispose();
  });

  test('different choices lead to different scenes', () {
    final a = build()..begin();
    final b = build()..begin();
    a.choose('climb_oak');
    b.choose('follow_stream');

    expect(a.scene.id, isNot(b.scene.id));
    a.dispose();
    b.dispose();
  });

  test('unknown choices, and choices from other scenes, are ignored', () {
    final vm = build()..begin();
    vm.choose('not_a_choice');
    vm.choose('ask_wind'); // belongs to a later scene

    expect(vm.path, ['grey_morning']);
    vm.dispose();
  });

  test('choosing does nothing on the intro or at an ending', () {
    final vm = build();
    vm.choose('climb_oak');
    expect(vm.phase, StoryPhase.intro);

    vm
      ..begin()
      ..choose('follow_stream')
      ..choose('make_mist');
    expect(vm.atEnding, isTrue);
    final ended = vm.path;
    vm.choose('make_mist');
    expect(vm.path, ended);
    vm.dispose();
  });

  test(
    'reaching an ending records it as new and reads the discovery',
    () async {
      final vm = build()..begin();
      vm
        ..choose('follow_stream')
        ..choose('make_mist');
      await vm.saved;
      await pumpEventQueue();

      expect(vm.atEnding, isTrue);
      expect(vm.scene.ending!.id, 'mist');
      expect(vm.isNewEnding, isTrue);
      expect(vm.foundEndingIds, {'mist'});
      expect(tts.spoken.last, contains('The end.'));
      expect(tts.spoken.last, contains(vm.scene.ending!.discovery));

      final saved = await progress.load();
      expect(saved.completedStoryIds, {forest.id});
      expect(saved.storyEndings[forest.id], {'mist'});
      expect(saved.storyBookmarks, isEmpty);
      vm.dispose();
    },
  );

  test('an ending found before is not called new', () {
    final vm = build(found: {'mist'})..begin();
    vm
      ..choose('follow_stream')
      ..choose('make_mist');

    expect(vm.isNewEnding, isFalse);
    vm.dispose();
  });

  test('every choice saves a bookmark of the path so far', () async {
    final vm = build()..begin();
    vm.choose('climb_oak');
    await vm.saved;

    final saved = await progress.load();
    expect(saved.storyBookmarks[forest.id], ['grey_morning', 'dusty_crystal']);
    expect(vm.saveStatus, StorySaveStatus.saved);
    vm.dispose();
  });

  test('resuming opens at the saved scene and reads it', () async {
    final vm = build(resumePath: ['grey_morning', 'dusty_crystal']);
    vm.narrateOpening();
    await pumpEventQueue();

    expect(vm.phase, StoryPhase.scene);
    expect(vm.resumed, isTrue);
    expect(vm.onResumedPage, isTrue);
    expect(vm.scene.id, 'dusty_crystal');
    expect(tts.spoken.single, vm.scene.text);

    vm.choose('ask_wind');
    expect(vm.onResumedPage, isFalse);
    expect(vm.path, ['grey_morning', 'dusty_crystal', 'whoosh']);
    vm.dispose();
  });

  test('a saved path that does not fit the story starts from the intro', () {
    for (final bad in [
      <String>[],
      ['dusty_crystal'], // wrong start
      ['grey_morning', 'whoosh'], // not a real choice
      ['grey_morning', 'dusty_crystal', 'grey_morning'], // loop
      ['grey_morning', 'ghost'],
    ]) {
      final vm = build(resumePath: bad);
      expect(vm.phase, StoryPhase.intro, reason: bad.join(' > '));
      expect(vm.resumed, isFalse);
      vm.dispose();
    }
  });

  test(
    'restart goes back to the first scene and keeps found endings',
    () async {
      final vm = build()..begin();
      vm
        ..choose('follow_stream')
        ..choose('make_mist')
        ..restart();
      await vm.saved;

      expect(vm.scene.id, forest.startSceneId);
      expect(vm.consequence, isNull);
      expect(vm.foundEndingIds, {'mist'});
      expect((await progress.load()).storyBookmarks[forest.id], [
        forest.startSceneId,
      ]);
      vm.dispose();
    },
  );

  test('replaying can find a different ending; both are kept', () async {
    final vm = build()..begin();
    vm
      ..choose('follow_stream')
      ..choose('make_mist')
      ..restart()
      ..choose('climb_oak')
      ..choose('ask_robins')
      ..choose('turn_crystal');
    await vm.saved;

    expect(vm.scene.ending!.id, 'sunrise');
    expect(vm.isNewEnding, isTrue);
    expect(vm.foundEndingIds, {'mist', 'sunrise'});
    expect((await progress.load()).storyEndings[forest.id], {
      'mist',
      'sunrise',
    });
    vm.dispose();
  });

  test('every ending of every story can be reached by choosing', () async {
    for (final story in starterStories) {
      final reached = <String>{};
      void explore(List<String> choiceIds) {
        final vm = build(story: story)..begin();
        for (final id in choiceIds) {
          vm.choose(id);
        }
        if (vm.atEnding) {
          reached.add(vm.scene.ending!.id);
        } else {
          for (final c in vm.scene.choices) {
            explore([...choiceIds, c.id]);
          }
        }
        vm.dispose();
      }

      explore([]);
      expect(reached, {for (final e in story.endings) e.id}, reason: story.id);
    }
  });

  test('read the choices aloud, numbered as on screen', () async {
    final vm = build()..begin();
    vm.readChoices();
    await pumpEventQueue();

    expect(
      tts.spoken.last,
      'What should we do? '
      'Choice 1: Climb up to the Sun Crystal in the old oak. '
      'Choice 2: Follow the stream that still sparkles.',
    );
    vm.dispose();
  });

  test('hear again and read page repeat; stop silences Buddy', () async {
    tts.holdSpeech = true;
    final vm = build()..begin();
    await pumpEventQueue();
    expect(vm.isSpeaking, isTrue);

    await vm.stopSpeaking();
    expect(vm.isSpeaking, isFalse);

    vm.hearAgain();
    await pumpEventQueue();
    vm.readScene();
    await pumpEventQueue();
    expect(tts.spoken.where((s) => s == vm.scene.text), hasLength(3));
    tts.finishSpeaking();
    vm.dispose();
  });

  test(
    'a new page interrupts the last one, so speech never overlaps',
    () async {
      tts.holdSpeech = true;
      final vm = build()..begin();
      await pumpEventQueue();
      final stopsBefore = tts.stopCalls;

      vm.choose('climb_oak');
      await pumpEventQueue();

      expect(tts.stopCalls, greaterThan(stopsBefore));
      expect(tts.spoken.last, contains(vm.scene.text));
      tts.finishSpeaking();
      vm.dispose();
    },
  );

  test('leaving the story stops Buddy mid-sentence', () async {
    tts.holdSpeech = true;
    final vm = build()..begin();
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);

    vm.dispose();
    await pumpEventQueue();

    expect(tts.isSpeaking, isFalse);
  });

  test(
    'with the voice off, nothing is spoken but the story still works',
    () async {
      await voice.setMuted(true);
      final vm = build()..begin();
      vm.choose('follow_stream');
      await pumpEventQueue();

      expect(tts.spoken, isEmpty);
      expect(vm.scene.id, 'sparkling_stream');
      expect(vm.canSpeak, isFalse);
      vm.dispose();
    },
  );

  test('a save failure is reported but the story carries on', () async {
    final vm = build(
      repository: LocalProgressRepository(ReadOnlyKeyValueStore()),
    )..begin();
    vm.choose('climb_oak');
    await vm.saved;

    expect(vm.saveStatus, StorySaveStatus.failed);
    vm.choose('ask_wind');
    expect(vm.scene.id, 'whoosh');
    vm.dispose();
  });

  test('quick choices save in order, so the newest place wins', () async {
    final vm = build()..begin();
    vm
      ..choose('climb_oak')
      ..choose('ask_wind');
    await vm.saved;

    expect((await progress.load()).storyBookmarks[forest.id], [
      'grey_morning',
      'dusty_crystal',
      'whoosh',
    ]);
    vm.dispose();
  });
}
