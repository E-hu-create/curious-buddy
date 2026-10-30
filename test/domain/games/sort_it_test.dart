import 'dart:math';

import 'package:curious_buddy/domain/games/sort_it.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SortGame game([int level = 1, int seed = 1]) =>
      SortGame(level: level, random: Random(seed));

  /// A group the current item doesn't belong to.
  int wrongGroup(SortGame g) => g.item.group == 0 ? 1 : 0;

  test('content passes every fairness check', () {
    expect(sortProblems(), isEmpty);
  });

  test('every game has the right number of different things', () {
    for (final level in sortLevels.keys) {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(level, seed);
        expect(g.items, hasLength(SortGame.itemCount));
        expect(g.items.map((i) => i.name).toSet(), hasLength(g.items.length));
      }
    }
  });

  test('Expert has three groups, and the others two', () {
    for (final (level, groups) in [(1, 2), (2, 2), (3, 3)]) {
      for (final set in sortLevels[level]!) {
        expect(set.groups, hasLength(groups));
      }
    }
  });

  test('a game can bring up either set', () {
    final seen = {
      for (var seed = 0; seed < 30; seed++) game(1, seed).set.question,
    };
    expect(seen, hasLength(sortLevels[1]!.length));
  });

  test('the right group moves on and fills up', () {
    final g = game();
    final first = g.item;
    expect(g.pick(first.group), SortResult.right);
    expect(g.counts[first.group], 1);
    expect(g.lastSorted, first);
    expect(g.index, 1);
  });

  test('a wrong group counts once and keeps the item', () {
    final g = game();
    final first = g.item;
    final wrong = wrongGroup(g);
    expect(g.pick(wrong), SortResult.wrong);
    expect(g.pick(wrong), SortResult.ignored);
    expect(g.mistakes, 1);
    expect(g.item, first);
  });

  test('sorting everything wins, and then nothing else counts', () {
    final g = game();
    for (var i = 0; i < SortGame.itemCount - 1; i++) {
      expect(g.pick(g.item.group), SortResult.right);
    }
    expect(g.pick(g.item.group), SortResult.won);
    expect(g.counts.reduce((a, b) => a + b), SortGame.itemCount);
  });

  test('groups that do not exist are ignored', () {
    expect(game().pick(-1), SortResult.ignored);
    expect(game().pick(5), SortResult.ignored);
  });

  test('stars follow the wrong picks, and never fall below one', () {
    for (final (wrong, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (5, 1)]) {
      final g = game();
      for (var i = 0; i < wrong; i++) {
        g.pick(wrongGroup(g));
        g.pick(g.item.group);
      }
      expect(g.stars, stars);
    }
  });
}
