import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/missions/mission_rules.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/missions/mission_play_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

/// Answers the current stage correctly, the way a child would on screen.
void solveCurrentStage(MissionPlayViewModel vm) {
  switch (vm.stage) {
    case ChoiceStage(:final choices):
      vm.pickChoice(choices.firstWhere((c) => c.correct).id);
    case MultiSelectStage(:final choices):
      // Untick anything wrong, tick everything right.
      for (final c in choices) {
        if (c.correct != vm.selectedChoices.contains(c.id)) {
          vm.toggleChoice(c.id);
        }
      }
    case OrderStage(:final pieces):
      vm.clearOrder(); // "Start over"
      for (final p in pieces) {
        vm.placePiece(p.id);
      }
  }
  vm.check();
}

/// Answers the current stage wrongly once.
void answerWrongly(MissionPlayViewModel vm) {
  switch (vm.stage) {
    case ChoiceStage(:final choices):
      vm.pickChoice(choices.firstWhere((c) => !c.correct).id);
    case MultiSelectStage(:final choices):
      vm.toggleChoice(choices.firstWhere((c) => !c.correct).id);
    case OrderStage(:final pieces):
      for (final p in pieces.reversed) {
        vm.placePiece(p.id);
      }
  }
  vm.check();
}

Mission missionWith(String id) => starterMissions.firstWhere((m) => m.id == id);

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  MissionPlayViewModel build([String id = 'missing_moonstone']) =>
      MissionPlayViewModel(
        mission: missionWith(id),
        voice: voice,
        progressRepository: progress,
      );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  test('opens on the intro, and Buddy narrates the scene', () async {
    final vm = build();
    vm.narrateIntro();
    await pumpEventQueue();

    expect(vm.phase, MissionPhase.intro);
    expect(tts.spoken.single, contains('Starlight Museum'));
    vm.dispose();
  });

  test('start goes to step 1 and reads the question', () async {
    final vm = build()..start();
    await pumpEventQueue();

    expect(vm.phase, MissionPhase.stage);
    expect(vm.stageIndex, 0);
    expect(tts.spoken.last, vm.stage.prompt);
    vm.dispose();
  });

  test('clues start hidden; inspecting reveals and counts them', () {
    final vm = build()..start();

    expect(vm.inspectedClues, isEmpty);
    vm.inspectClue('glass');
    vm.inspectClue('glass'); // twice counts once
    vm.inspectClue('not_a_clue');

    expect(vm.inspectedClues, {'glass'});
    vm.dispose();
  });

  test('a clue can only be read aloud once inspected', () async {
    final vm = build()..start();
    await pumpEventQueue();
    final before = tts.spoken.length;

    vm.readClue('lock');
    await pumpEventQueue();
    expect(tts.spoken.length, before);

    vm
      ..inspectClue('lock')
      ..readClue('lock');
    await pumpEventQueue();
    expect(tts.spoken.last, contains('silver key'));
    vm.dispose();
  });

  test('hints come one at a time and stop at the last', () async {
    final vm = build()..start();
    final total = vm.stage.hints.length;

    for (var i = 1; i <= total; i++) {
      vm.showHint();
      expect(vm.visibleHints, hasLength(i));
    }
    expect(vm.hasMoreHints, isFalse);
    vm.showHint();
    expect(vm.visibleHints, hasLength(total));
    await pumpEventQueue();
    expect(tts.spoken.last, contains(vm.stage.hints.last));
    vm.dispose();
  });

  test('Check is only possible once an answer is chosen', () {
    final vm = build()..start();

    expect(vm.canCheck, isFalse);
    vm.pickChoice('used_key');
    expect(vm.canCheck, isTrue);
    vm.dispose();
  });

  test(
    'a wrong answer explains why, nudges to inspect, and allows retry',
    () async {
      final vm = build()..start();
      answerWrongly(vm);
      await pumpEventQueue();

      expect(vm.feedback!.correct, isFalse);
      expect(vm.isSolved, isFalse);
      expect(vm.selectedChoice, isNull, reason: 'free to pick again');
      expect(tts.spoken.last, contains('Have you inspected every clue?'));

      solveCurrentStage(vm);
      expect(vm.isSolved, isTrue);
      vm.dispose();
    },
  );

  test('a correct answer locks the step and Buddy explains it', () async {
    final vm = build()..start();
    solveCurrentStage(vm);
    await pumpEventQueue();

    expect(vm.isSolved, isTrue);
    expect(vm.canCheck, isFalse);
    expect(tts.spoken.last, contains(vm.stage.explanation));
    vm.pickChoice('broke_glass');
    expect(vm.selectedChoice, 'used_key', reason: 'locked after solving');
    vm.dispose();
  });

  test('Next is only possible after solving, and moves on', () async {
    final vm = build()..start();

    await vm.next();
    expect(vm.stageIndex, 0);

    solveCurrentStage(vm);
    await vm.next();
    expect(vm.stageIndex, 1);
    expect(vm.feedback, isNull);
    vm.dispose();
  });

  test('order steps: place, take back, start over', () {
    final vm = build('wilting_garden')..start();
    solveCurrentStage(vm);
    vm.next();
    solveCurrentStage(vm);
    vm.next();
    final stage = vm.stage as OrderStage;

    vm
      ..placePiece(stage.pieces[0].id)
      ..placePiece(stage.pieces[1].id);
    expect(vm.placedPieces, hasLength(2));
    expect(vm.remainingPieces, hasLength(stage.pieces.length - 2));

    vm.removePlacedPiece(stage.pieces[0].id);
    expect(vm.placedPieces.single, stage.pieces[1]);

    vm.clearOrder();
    expect(vm.placedPieces, isEmpty);
    vm.dispose();
  });

  test('pieces are never shown already in the right order', () {
    for (final mission in starterMissions) {
      for (final stage in mission.stages.whereType<OrderStage>()) {
        final shown = MissionPlayViewModel.shuffled(stage.pieces);
        expect(shown, isNot(stage.pieces), reason: stage.id);
        expect(shown.toSet(), stage.pieces.toSet());
      }
    }
  });

  for (final mission in starterMissions) {
    test('${mission.title} can be finished, scored and saved', () async {
      final vm = build(mission.id)..start();
      for (var i = 0; i < mission.stages.length; i++) {
        for (final clue in vm.stage.clues) {
          vm.inspectClue(clue.id);
        }
        solveCurrentStage(vm);
        await vm.next();
      }

      expect(vm.phase, MissionPhase.complete);
      expect(vm.score!.total, MissionScore.maxFor(mission));
      expect(vm.saveStatus, SaveStatus.saved);
      final saved = await progress.load();
      expect(saved.completedMissionIds, {mission.id});
      expect(saved.missionBestPoints[mission.id], vm.score!.total);
      await pumpEventQueue();
      expect(tts.spoken.last, contains('Case solved!'));
      vm.dispose();
    });
  }

  test('a mission can be finished even with mistakes and every hint', () async {
    final vm = build()..start();
    for (var i = 0; i < vm.stageCount; i++) {
      while (vm.hasMoreHints) {
        vm.showHint();
      }
      answerWrongly(vm);
      solveCurrentStage(vm);
      await vm.next();
    }

    expect(vm.phase, MissionPhase.complete);
    expect(vm.score!.firstTryBonus, 0);
    expect(vm.score!.completion, MissionScore.completionPoints);
    vm.dispose();
  });

  test('replay starts fresh and keeps the best saved score', () async {
    final vm = build()..start();
    for (var i = 0; i < vm.stageCount; i++) {
      for (final clue in vm.stage.clues) {
        vm.inspectClue(clue.id);
      }
      solveCurrentStage(vm);
      await vm.next();
    }
    final best = vm.score!.total;

    vm.replay();
    expect(vm.phase, MissionPhase.intro);
    expect(vm.score, isNull);

    vm.start();
    for (var i = 0; i < vm.stageCount; i++) {
      answerWrongly(vm);
      solveCurrentStage(vm);
      await vm.next();
    }
    expect(vm.score!.total, lessThan(best));
    expect((await progress.load()).missionBestPoints[vm.mission.id], best);
    vm.dispose();
  });

  test('a failed save still shows the result', () async {
    final vm = MissionPlayViewModel(
      mission: missionWith('mixed_up_signals'),
      voice: voice,
      progressRepository: LocalProgressRepository(FailingKeyValueStore()),
    )..start();
    for (var i = 0; i < vm.stageCount; i++) {
      solveCurrentStage(vm);
      await vm.next();
    }

    expect(vm.phase, MissionPhase.complete);
    expect(vm.saveStatus, SaveStatus.failed);
    vm.dispose();
  });

  test('Hear again repeats the last line; Stop silences Buddy', () async {
    tts.holdSpeech = true;
    final vm = build();
    vm.narrateIntro();
    await pumpEventQueue();
    expect(vm.isSpeaking, isTrue);

    await vm.stopSpeaking();
    expect(tts.isSpeaking, isFalse);

    vm.hearAgain();
    await pumpEventQueue();
    expect(tts.spoken, hasLength(2));
    expect(tts.spoken.last, tts.spoken.first);
    vm.dispose();
  });

  test('leaving the mission (dispose) stops Buddy talking', () async {
    tts.holdSpeech = true;
    final vm = build();
    vm.narrateIntro();
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);

    vm.dispose();
    await pumpEventQueue();

    expect(tts.isSpeaking, isFalse);
  });

  test('voice off: everything works, nothing is spoken', () async {
    await voice.setMuted(true);
    final vm = build();
    vm.narrateIntro();
    vm.start();
    solveCurrentStage(vm);
    await pumpEventQueue();

    expect(vm.isSolved, isTrue);
    expect(tts.spoken, isEmpty);
    vm.dispose();
  });
}
