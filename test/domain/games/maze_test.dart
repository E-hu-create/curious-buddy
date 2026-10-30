import 'dart:math';

import 'package:curious_buddy/domain/games/maze.dart';
import 'package:flutter_test/flutter_test.dart';

/// The first direction of the only route from Buddy to [target].
MazeDirection towards(MazeGame g, int target) {
  final from = <int, (int, MazeDirection)>{};
  final queue = [g.cell];
  for (var i = 0; i < queue.length; i++) {
    final here = queue[i];
    for (final d in g.openings[here]) {
      final next = here + d.rowStep * g.size + d.columnStep;
      if (next == g.cell || from.containsKey(next)) continue;
      from[next] = (here, d);
      queue.add(next);
    }
  }
  var at = target;
  while (from[at]!.$1 != g.cell) {
    at = from[at]!.$1;
  }
  return from[at]!.$2;
}

/// Walks to [target], which may take several moves.
void walkTo(MazeGame g, int target) {
  for (var i = 0; i < 200 && g.cell != target; i++) {
    expect(g.go(towards(g, target)), isNot(MazeMove.blocked));
  }
  expect(g.cell, target);
}

void main() {
  MazeGame game(int level, [int seed = 1]) {
    final (size, gems) = MazeGame.sizeFor(level);
    return MazeGame(size: size, gems: gems, random: Random(seed));
  }

  group('making a maze', () {
    test('every cell can be reached, by exactly one route', () {
      for (final level in [1, 2, 3]) {
        for (var seed = 0; seed < 30; seed++) {
          final g = game(level, seed);
          final cells = g.size * g.size;
          final passages =
              g.openings.fold(0, (sum, open) => sum + open.length) ~/ 2;
          expect(passages, cells - 1);

          final seen = {MazeGame.start};
          final queue = [MazeGame.start];
          for (var i = 0; i < queue.length; i++) {
            for (final d in g.openings[queue[i]]) {
              final next = queue[i] + d.rowStep * g.size + d.columnStep;
              if (seen.add(next)) queue.add(next);
            }
          }
          expect(seen, hasLength(cells));
        }
      }
    });

    test('passages match from both sides and stay inside', () {
      final g = game(3);
      for (var i = 0; i < g.openings.length; i++) {
        final row = i ~/ g.size;
        final column = i % g.size;
        for (final d in g.openings[i]) {
          final r = row + d.rowStep;
          final c = column + d.columnStep;
          expect(r, inInclusiveRange(0, g.size - 1));
          expect(c, inInclusiveRange(0, g.size - 1));
          expect(g.openings[r * g.size + c], contains(d.opposite));
        }
      }
    });

    test('gems and the treasure sit on their own cells', () {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(2, seed);
        expect(g.gems, hasLength(3));
        expect(g.gems, isNot(contains(g.treasure)));
        expect(g.gems, isNot(contains(MazeGame.start)));
        expect(g.treasure, isNot(MazeGame.start));
      }
    });

    test('each game is a new maze, and levels get bigger', () {
      expect(game(1, 1).openings, isNot(game(1, 2).openings));
      expect(MazeGame.sizeFor(1).$1, lessThan(MazeGame.sizeFor(2).$1));
      expect(MazeGame.sizeFor(2).$1, lessThan(MazeGame.sizeFor(3).$1));
    });
  });

  group('moving', () {
    test('a wall blocks, and costs nothing', () {
      final g = game(1);
      expect(g.go(MazeDirection.up), MazeMove.blocked);
      expect(g.go(MazeDirection.left), MazeMove.blocked);
      expect(g.cell, MazeGame.start);
    });

    test('Buddy runs on along a straight corridor', () {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(3, seed);
        final direction = g.openings[g.cell].first;
        g.go(direction);
        // Stopped because something made it worth stopping.
        expect(
          g.gems.contains(g.cell) ||
              g.isWon ||
              g.openings[g.cell].length != 2 ||
              !g.openings[g.cell].contains(direction),
          isTrue,
        );
      }
    });

    test('a gem stops Buddy and is collected once', () {
      final g = game(2);
      final gem = g.gems.first;
      walkTo(g, gem);
      expect(g.collected, {gem});
      expect(g.stars, greaterThanOrEqualTo(1));
    });

    test('nothing moves after the treasure', () {
      final g = game(1);
      walkTo(g, g.treasure);
      expect(g.isWon, isTrue);
      expect(g.go(MazeDirection.up), MazeMove.ignored);
    });
  });

  group('stars', () {
    test('collecting every gem on the way earns three', () {
      final g = game(3);
      g.gems.toList().forEach((gem) => walkTo(g, gem));
      walkTo(g, g.treasure);
      expect(g.isWon, isTrue);
      expect(g.stars, 3);
    });

    test('the sums hold with exact counts', () {
      final g = game(3);
      expect(g.stars, 1);
      g.collected.addAll(g.gems.take(2));
      expect(g.stars, 2);
      g.collected.addAll(g.gems);
      expect(g.stars, 3);
    });
  });
}
