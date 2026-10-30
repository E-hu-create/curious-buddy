import 'dart:math';

import 'package:curious_buddy/domain/games/sound_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SoundQuiz quiz([int level = 1, int seed = 1]) =>
      SoundQuiz(level: level, random: Random(seed));

  test('content passes every fairness check', () {
    expect(soundProblems(), isEmpty);
  });

  test('every round offers the right answer and two others', () {
    for (final level in SoundQuiz.levels.keys) {
      for (var seed = 0; seed < 20; seed++) {
        final q = quiz(level, seed);
        do {
          expect(q.options, hasLength(SoundQuiz.optionCount));
          expect(q.options.toSet(), hasLength(SoundQuiz.optionCount));
          expect(q.options, contains(q.sound));
        } while (q.nextRound());
      }
    }
  });

  test('easier levels stay within their own sounds', () {
    final q = quiz();
    do {
      expect(SoundQuiz.levels[1], containsAll(q.options));
    } while (q.nextRound());
  });

  test('each sound plays once in a level', () {
    final q = quiz(2);
    final heard = {q.sound};
    while (q.nextRound()) {
      heard.add(q.sound);
    }
    expect(heard, SoundQuiz.levels[2]!.toSet());
  });

  test('a wrong pick stays visible and can only count once', () {
    final q = quiz();
    final wrong = q.options.firstWhere((o) => o != q.sound);
    expect(q.pick(wrong), SoundPick.wrong);
    expect(q.pick(wrong), SoundPick.ignored);
    expect(q.mistakes, 1);
    expect(q.isSolved, isFalse);
  });

  test('a right pick solves the round and locks it', () {
    final q = quiz();
    expect(q.pick(q.sound), SoundPick.right);
    expect(q.isSolved, isTrue);
    expect(q.pick(q.options.first), SoundPick.ignored);
  });

  test('sounds not on offer are ignored', () {
    final q = quiz();
    final outside = GameSound.values.firstWhere((s) => !q.options.contains(s));
    expect(q.pick(outside), SoundPick.ignored);
  });

  test('stars follow the wrong picks, and never fall below one', () {
    for (final (wrong, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (5, 1)]) {
      final q = quiz();
      var left = wrong;
      do {
        for (final option in q.options) {
          if (left > 0 && option != q.sound) {
            q.pick(option);
            left--;
          }
        }
        q.pick(q.sound);
      } while (q.nextRound());
      expect(q.mistakes, wrong);
      expect(q.stars, stars);
    }
  });
}
