import 'dart:math';

import 'package:curious_buddy/domain/games/number_pop.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pops the rest of the current round's right bubbles.
PopResult clear(NumberPopGame g) {
  var result = PopResult.ignored;
  final round = g.round;
  for (var i = 0; i < g.bubbles.length && g.round == round; i++) {
    if (g.bubbles[i].value == g.target && !g.popped.contains(i)) {
      result = g.tap(i);
      if (result == PopResult.won) return result;
    }
  }
  return result;
}

void main() {
  NumberPopGame game([int level = 1, int seed = 1]) =>
      NumberPopGame(level: level, random: Random(seed));

  group('sums', () {
    test('work out correctly, and read aloud', () {
      expect(const BubbleSum(3, SumOperator.plus, 4).value, 7);
      expect(const BubbleSum(9, SumOperator.minus, 4).value, 5);
      expect(const BubbleSum(6, SumOperator.times, 7).value, 42);
      expect(const BubbleSum(6, SumOperator.times, 7).text, '6 × 7');
      expect(const BubbleSum(6, SumOperator.times, 7).spoken, '6 times 7');
    });
  });

  group('rounds', () {
    test('always have the right mix of unique bubbles', () {
      for (final level in [1, 2, 3]) {
        for (var seed = 0; seed < 40; seed++) {
          final g = game(level, seed);
          while (true) {
            expect(g.bubbles, hasLength(NumberPopGame.bubbleCount));
            expect(
              g.bubbles.where((s) => s.value == g.target),
              hasLength(NumberPopGame.rightCount),
            );
            expect(
              g.bubbles.map((s) => s.text).toSet(),
              hasLength(NumberPopGame.bubbleCount),
            );
            if (clear(g) == PopResult.won) break;
          }
        }
      }
    });

    test('no sum goes below zero', () {
      for (var seed = 0; seed < 40; seed++) {
        expect(game(3, seed).bubbles.every((s) => s.value > 0), isTrue);
      }
    });

    test('Expert always has a times sum to find', () {
      for (var seed = 0; seed < 40; seed++) {
        final g = game(3, seed);
        expect(
          g.bubbles.any(
            (s) => s.value == g.target && s.operator == SumOperator.times,
          ),
          isTrue,
        );
      }
    });

    test('Starter is adding only', () {
      for (var seed = 0; seed < 20; seed++) {
        expect(
          game(1, seed).bubbles.every((s) => s.operator == SumOperator.plus),
          isTrue,
        );
      }
    });

    test('a game never repeats a target', () {
      final g = game(2);
      final targets = {g.target};
      while (clear(g) != PopResult.won) {
        targets.add(g.target);
      }
      expect(targets, hasLength(NumberPopGame.rounds));
    });
  });

  group('tapping', () {
    int wrongIndex(NumberPopGame g) =>
        g.bubbles.indexWhere((s) => s.value != g.target);
    int rightIndex(NumberPopGame g) =>
        g.bubbles.indexWhere((s) => s.value == g.target);

    test('a right bubble pops once', () {
      final g = game();
      final i = rightIndex(g);
      expect(g.tap(i), PopResult.popped);
      expect(g.left, 2);
      expect(g.tap(i), PopResult.ignored);
    });

    test('a wrong bubble counts once, and stays', () {
      final g = game();
      final i = wrongIndex(g);
      expect(g.tap(i), PopResult.wrong);
      expect(g.tap(i), PopResult.ignored);
      expect(g.mistakes, 1);
    });

    test('clearing a round moves on, and the last one wins', () {
      final g = game();
      for (var i = 0; i < NumberPopGame.rounds - 1; i++) {
        expect(clear(g), PopResult.cleared);
        expect(g.round, i + 1);
        expect(g.popped, isEmpty);
      }
      expect(clear(g), PopResult.won);
    });

    test('out-of-range taps are ignored', () {
      expect(game().tap(-1), PopResult.ignored);
      expect(game().tap(99), PopResult.ignored);
    });

    test('stars follow the wrong taps, and never fall below one', () {
      for (final (wrong, stars) in [(0, 3), (1, 2), (3, 2), (4, 1), (6, 1)]) {
        final g = game();
        for (var i = 0, n = 0; n < wrong; i++) {
          if (g.bubbles[i].value != g.target) {
            g.tap(i);
            n++;
          }
        }
        expect(g.stars, stars);
      }
    });
  });
}
