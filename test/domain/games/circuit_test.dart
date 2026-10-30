import 'dart:math';

import 'package:curious_buddy/domain/games/circuit.dart';
import 'package:curious_buddy/domain/games/maze.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps the route's pieces until the bulb lights.
void fix(CircuitGame g) {
  final puzzle = g.puzzle;
  for (final entry in puzzle.route.entries) {
    final taps = puzzle.tiles[entry.key].tapsToJoin(entry.value);
    for (var i = 0; i < taps; i++) {
      g.tap(entry.key);
    }
  }
}

void main() {
  CircuitGame game([int level = 1, int seed = 1]) =>
      CircuitGame(level: level, random: Random(seed));

  group('pieces', () {
    test('turn a quarter clockwise', () {
      final corner = CircuitTile(straight: false);
      expect(corner.openings, {MazeDirection.up, MazeDirection.right});
      corner.turns++;
      expect(corner.openings, {MazeDirection.right, MazeDirection.down});
      corner.turns++;
      expect(corner.openings, {MazeDirection.down, MazeDirection.left});
    });

    test('a straight piece has two positions', () {
      final wire = CircuitTile(straight: true);
      expect(wire.tapsToJoin({MazeDirection.up, MazeDirection.down}), 0);
      expect(wire.tapsToJoin({MazeDirection.left, MazeDirection.right}), 1);
    });
  });

  group('circuits', () {
    test('never start lit, and can always be fixed', () {
      for (final level in [1, 2, 3]) {
        for (var seed = 0; seed < 60; seed++) {
          final g = game(level, seed);
          expect(g.puzzle.isLit, isFalse);
          fix(g);
          expect(g.puzzle.isLit, isTrue, reason: 'level $level seed $seed');
        }
      }
    });

    test('routes wander instead of running straight across', () {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(3, seed);
        expect(g.puzzle.route.length, greaterThanOrEqualTo(7));
      }
    });

    test('nothing is lit unless the battery side is joined', () {
      for (var seed = 0; seed < 30; seed++) {
        final p = game(2, seed).puzzle;
        final first = p.tiles[p.sourceRow * p.size];
        if (!first.openings.contains(MazeDirection.left)) {
          expect(p.lit, isEmpty);
        } else {
          expect(p.lit, contains(p.sourceRow * p.size));
        }
      }
    });

    test('the bulb needs its own side joined too', () {
      final g = game();
      fix(g);
      final p = g.puzzle;
      p.tiles[p.bulbCell].turns++;
      expect(p.isLit, isFalse);
    });
  });

  group('playing', () {
    test('a tap turns a piece and counts', () {
      final g = game();
      final tile = g.puzzle.tiles[0];
      final before = tile.turns;
      g.tap(0);
      expect(tile.turns, before + 1);
      expect(g.taps, 1);
    });

    test('a lit circuit stops taking taps', () {
      final g = game();
      fix(g);
      final taps = g.taps;
      expect(g.tap(0), CircuitResult.ignored);
      expect(g.taps, taps);
    });

    test('out-of-range taps are ignored', () {
      expect(game().tap(-1), CircuitResult.ignored);
      expect(game().tap(99), CircuitResult.ignored);
    });

    test('three circuits make a level', () {
      final g = game();
      expect(g.nextRound(), isTrue);
      expect(g.nextRound(), isTrue);
      expect(g.nextRound(), isFalse);
      expect(g.round, CircuitGame.rounds - 1);
    });

    test('there is a fact for every round', () {
      expect(CircuitGame.facts, hasLength(CircuitGame.rounds));
    });
  });

  group('stars', () {
    test('a tidy game earns three', () {
      final g = game();
      do {
        fix(g);
      } while (g.nextRound());
      expect(g.stars, 3);
    });

    test('many extra taps lower them, but never below one', () {
      final messy = game(3, 2);
      for (var i = 0; i < 40; i++) {
        messy.tap(24 - i % 3);
      }
      expect(messy.stars, 1);
    });
  });
}
