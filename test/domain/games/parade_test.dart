import 'dart:math';

import 'package:curious_buddy/domain/games/parade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ParadeGame game([int level = 1, int seed = 1]) =>
      ParadeGame(level: level, random: Random(seed));

  void finish(ParadeGame g) {
    for (final item in g.set.order) {
      g.tap(item);
    }
  }

  test('content passes every fairness check', () {
    expect(paradeProblems(), isEmpty);
  });

  test('the planets are in the right order', () {
    final sets = paradeLevels[3]!;
    expect(sets[0].order, [
      'Mercury',
      'Venus',
      'Earth',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
    ]);
    // The same eight planets appear in the size order.
    expect(sets[1].order.toSet(), sets[0].order.toSet());
  });

  test('things always start mixed up, and every thing is there', () {
    for (final level in paradeLevels.keys) {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(level, seed);
        do {
          expect(g.options, isNot(g.set.order));
          expect(g.options.toSet(), g.set.order.toSet());
          finish(g);
        } while (g.nextRound());
      }
    }
  });

  test('a game has no repeated sets', () {
    final g = game(3);
    final seen = {g.set.question};
    while (g.nextRound()) {
      seen.add(g.set.question);
    }
    expect(seen, hasLength(ParadeGame.rounds));
  });

  test('the next right thing goes in', () {
    final g = game();
    expect(g.tap(g.set.order.first), ParadeTap.right);
    expect(g.placed, 1);
    expect(g.isPlaced(g.set.order.first), isTrue);
    expect(g.tap(g.set.order.first), ParadeTap.ignored);
  });

  test('a wrong thing counts once, and stays out', () {
    final g = game();
    final wrong = g.set.order.last;
    expect(g.tap(wrong), ParadeTap.wrong);
    expect(g.tap(wrong), ParadeTap.ignored);
    expect(g.placed, 0);
    expect(g.mistakes, 1);
  });

  test('a mistake can be tried again later, when its turn comes', () {
    final g = game();
    final second = g.set.order[1];
    g.tap(second);
    g.tap(g.set.order.first);
    expect(g.tap(second), isNot(ParadeTap.ignored));
    expect(g.placed, 2);
  });

  test('the last thing finishes the set, and then nothing counts', () {
    final g = game();
    for (final item in g.set.order.take(g.set.order.length - 1)) {
      g.tap(item);
    }
    expect(g.tap(g.set.order.last), ParadeTap.finished);
    expect(g.isFinished, isTrue);
    expect(g.tap(g.set.order.first), ParadeTap.ignored);
  });

  test('things from other sets are ignored', () {
    expect(game().tap('Banana'), ParadeTap.ignored);
  });

  test('three sets make a level', () {
    final g = game();
    expect(g.nextRound(), isTrue);
    expect(g.nextRound(), isTrue);
    expect(g.nextRound(), isFalse);
  });

  test('stars follow the wrong picks, and never fall below one', () {
    for (final (wrong, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (4, 1)]) {
      final g = game(3);
      final items = g.set.order.reversed.take(wrong).toList();
      items.forEach(g.tap);
      expect(g.stars, stars);
    }
  });
}
