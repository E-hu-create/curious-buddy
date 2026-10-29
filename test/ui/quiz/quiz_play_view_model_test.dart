import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

final space = starterQuizTopics.first;
final starter = space.levels[0];
final explorer = space.levels[1];

/// Answers the current question right, or wrong, by id.
void answer(QuizPlayViewModel vm, {required bool right}) {
  final q = vm.question;
  vm.pick(
    right ? q.answerId : q.options.firstWhere((o) => o.id != q.answerId).id,
  );
}

/// Plays a whole round with [rightCount] right answers first.
Future<void> playRound(QuizPlayViewModel vm, int rightCount) async {
  for (var i = 0; i < vm.total; i++) {
    answer(vm, right: i < rightCount);
    await vm.next();
  }
}

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  QuizPlayViewModel build({
    QuizLevel? level,
    Map<String, int> best = const {},
    ProgressRepository? repository,
    int seed = 1,
  }) => QuizPlayViewModel(
    topic: space,
    level: level ?? starter,
    voice: voice,
    progressRepository: repository ?? progress,
    best: best,
    random: Random(seed),
  );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  test('starts on question 1 and reads it with its answers', () async {
    final vm = build()..narrateQuestion();
    await pumpEventQueue();

    expect(vm.phase, QuizPhase.question);
    expect(vm.index, 0);
    expect(vm.total, 5);
    final spoken = tts.spoken.single;
    expect(spoken, startsWith('Question 1 of 5. ${vm.question.prompt}'));
    for (final (i, o) in vm.options.indexed) {
      expect(spoken, contains('${QuizPlayViewModel.letters[i]}: ${o.text}.'));
    }
    vm.dispose();
  });

  test('answers are shuffled but keep every option', () {
    final vm = build();
    for (var i = 0; i < vm.total; i++) {
      final q = starter.questions[i];
      expect(vm.options.toSet(), q.options.toSet());
      answer(vm, right: true);
      vm.next();
    }
    vm.dispose();
  });

  test('a shuffle never keeps the written order', () {
    for (var seed = 0; seed < 20; seed++) {
      final vm = build(seed: seed);
      expect(vm.options, isNot(orderedEquals(vm.question.options)));
      vm.dispose();
    }
  });

  test('a right answer is confirmed and explained', () async {
    final vm = build();
    answer(vm, right: true);
    await pumpEventQueue();

    expect(vm.hasPicked, isTrue);
    expect(vm.pickedCorrect, isTrue);
    expect(tts.spoken.last, "That's right! ${vm.question.explanation}");
    vm.dispose();
  });

  test('a wrong answer names the right one and explains', () async {
    final vm = build();
    answer(vm, right: false);
    await pumpEventQueue();

    expect(vm.pickedCorrect, isFalse);
    expect(
      tts.spoken.last,
      'Not quite. The answer is ${vm.question.answer.text}. '
      '${vm.question.explanation}',
    );
    vm.dispose();
  });

  test('only the first pick counts, and unknown answers are ignored', () {
    final vm = build();
    vm.pick('not_an_option');
    expect(vm.hasPicked, isFalse);

    answer(vm, right: false);
    final first = vm.pickedId;
    vm.pick(vm.question.answerId);
    expect(vm.pickedId, first);
    expect(vm.pickedCorrect, isFalse);
    vm.dispose();
  });

  test('cannot move on before answering', () async {
    final vm = build();
    await vm.next();
    expect(vm.index, 0);
    vm.dispose();
  });

  test('next reads the next question', () async {
    final vm = build();
    answer(vm, right: true);
    await vm.next();
    await pumpEventQueue();

    expect(vm.index, 1);
    expect(vm.hasPicked, isFalse);
    expect(tts.spoken.last, startsWith('Question 2 of 5.'));
    vm.dispose();
  });

  for (final (right, stars, passed) in [
    (5, 3, true),
    (4, 2, true),
    (3, 1, true),
    (2, 0, false),
    (0, 0, false),
  ]) {
    test('$right of 5 right: $stars stars, passed: $passed', () async {
      final vm = build();
      await playRound(vm, right);

      expect(vm.phase, QuizPhase.summary);
      expect(vm.correctCount, right);
      expect(vm.stars, stars);
      expect(vm.passed, passed);
      expect(vm.records, hasLength(5));
      expect(vm.records.where((r) => r.correct), hasLength(right));
      await pumpEventQueue();
      expect(tts.spoken.last, startsWith('You got $right out of 5.'));
      vm.dispose();
    });
  }

  test('a finished round is saved; replays never lower the best', () async {
    final vm = build();
    await playRound(vm, 4);
    expect(vm.saveStatus, QuizSaveStatus.saved);
    expect((await progress.load()).quizBest, {starter.id: 4});

    vm.replay();
    await playRound(vm, 2);
    expect((await progress.load()).quizBest, {starter.id: 4});
    expect(vm.isNewBest, isFalse);

    vm.replay();
    await playRound(vm, 5);
    expect((await progress.load()).quizBest, {starter.id: 5});
    expect(vm.isNewBest, isTrue);
    vm.dispose();
  });

  test('passing opens the next level, and says so once', () async {
    final vm = build();
    expect(vm.nextUnlocked, isFalse);

    await playRound(vm, 3);
    expect(vm.nextUnlocked, isTrue);
    expect(vm.justUnlockedNext, isTrue);
    await pumpEventQueue();
    expect(tts.spoken.last, contains('You opened the next level!'));

    vm.replay();
    await playRound(vm, 5);
    expect(vm.justUnlockedNext, isFalse, reason: 'already open');
    vm.dispose();
  });

  test('not passing keeps the next level closed', () async {
    final vm = build();
    await playRound(vm, 2);

    expect(vm.nextUnlocked, isFalse);
    expect(vm.nextLevel, explorer);
    vm.dispose();
  });

  test('the last level has no next level', () async {
    final vm = build(
      level: space.levels[2],
      best: {starter.id: 5, explorer.id: 5},
    );
    await playRound(vm, 5);

    expect(vm.nextLevel, isNull);
    expect(vm.nextUnlocked, isFalse);
    vm.dispose();
  });

  test('play again starts fresh', () async {
    final vm = build();
    await playRound(vm, 5);
    vm.replay();

    expect(vm.phase, QuizPhase.question);
    expect(vm.index, 0);
    expect(vm.hasPicked, isFalse);
    expect(vm.records, isEmpty);
    expect(vm.saveStatus, QuizSaveStatus.notSaved);
    vm.dispose();
  });

  test('a failed save is reported, and the score still shows', () async {
    final vm = build(
      repository: LocalProgressRepository(ReadOnlyKeyValueStore()),
    );
    await playRound(vm, 4);

    expect(vm.saveStatus, QuizSaveStatus.failed);
    expect(vm.correctCount, 4);
    vm.dispose();
  });

  test('read the question and the answers on request', () async {
    final vm = build();
    vm.readQuestion();
    await pumpEventQueue();
    expect(tts.spoken.last, vm.question.prompt);

    vm.readAnswers();
    await pumpEventQueue();
    expect(tts.spoken.last, QuizPlayViewModel.answersNarration(vm.options));
    vm.dispose();
  });

  test('with automatic reading off, Buddy only reads when asked', () async {
    await voice.setAutoRead(false);
    final vm = build()..narrateQuestion();
    answer(vm, right: true);
    await pumpEventQueue();
    expect(tts.spoken, isEmpty);
    expect(vm.lastSpoken, isNotNull, reason: 'Hear again still works');

    vm.hearAgain();
    await pumpEventQueue();
    expect(tts.spoken, hasLength(1));
    vm.dispose();
  });

  test('with the voice off, the quiz still works', () async {
    await voice.setMuted(true);
    final vm = build();
    await playRound(vm, 5);

    expect(tts.spoken, isEmpty);
    expect(vm.correctCount, 5);
    vm.dispose();
  });

  test('leaving the quiz stops Buddy mid-sentence', () async {
    tts.holdSpeech = true;
    final vm = build()..narrateQuestion();
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);

    vm.dispose();
    await pumpEventQueue();
    expect(tts.isSpeaking, isFalse);
  });
}
