import 'dart:math';

import 'package:curious_buddy/domain/games/maze.dart';
import 'package:curious_buddy/domain/games/robot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('puzzles', () {
    test('can always be solved within the limit', () {
      for (final level in [1, 2, 3]) {
        for (var seed = 0; seed < 60; seed++) {
          final p = RobotPuzzle.make(level, Random(seed));
          expect(p.trace(p.solution).ending, RobotEnding.goal);
          expect(p.solution.length, lessThanOrEqualTo(p.limit));
          expect(p.rocks, isNot(contains(p.start)));
          expect(p.rocks, isNot(contains(p.goal)));
          expect(p.start, isNot(p.goal));
        }
      }
    });

    test('are worth solving: the flag is never right next door', () {
      for (var seed = 0; seed < 60; seed++) {
        final p = RobotPuzzle.make(1, Random(seed));
        final moves = p.solution.fold(0, (sum, s) => sum + s.times);
        expect(moves, greaterThanOrEqualTo(p.size));
      }
    });

    test('only the top level folds moves into repeats', () {
      for (var seed = 0; seed < 30; seed++) {
        expect(
          RobotPuzzle.make(2, Random(seed)).solution.every((s) => s.times == 1),
          isTrue,
        );
      }
      expect(
        List.generate(
          30,
          (seed) => RobotPuzzle.make(3, Random(seed)),
        ).any((p) => p.solution.any((s) => s.times == 2)),
        isTrue,
      );
    });
  });

  group('running code', () {
    final puzzle = RobotPuzzle.make(2, Random(1));

    MazeDirection edgeDirection() {
      final row = puzzle.start ~/ puzzle.size;
      final column = puzzle.start % puzzle.size;
      if (row == 0) return MazeDirection.up;
      if (row == puzzle.size - 1) return MazeDirection.down;
      if (column == 0) return MazeDirection.left;
      return MazeDirection.right;
    }

    test('code that stops early says so', () {
      expect(puzzle.trace(const []).ending, RobotEnding.short);
    });

    test('walking off the grid stops the robot', () {
      final steps = List.filled(puzzle.size + 1, RobotStep(edgeDirection()));
      final ending = puzzle.trace(steps).ending;
      expect(ending, isNot(RobotEnding.short));
      expect(ending, isNot(RobotEnding.goal));
    });

    test('every cell is tied to the line that caused it', () {
      final trace = puzzle.trace(puzzle.solution);
      expect(trace.stepOfCell, hasLength(trace.cells.length));
      expect(trace.cells.last, puzzle.goal);
      expect(trace.stepOfCell.last, puzzle.solution.length - 1);
    });

    test('a repeated line moves two cells', () {
      final p = RobotPuzzle.make(3, Random(1));
      final trace = p.trace(p.solution);
      expect(
        trace.cells,
        hasLength(p.solution.fold<int>(0, (sum, s) => sum + s.times)),
      );
    });
  });

  group('writing code', () {
    RobotGame game([int level = 1]) =>
        RobotGame(level: level, random: Random(1));

    test('add, undo and clear', () {
      final g = game()
        ..add(MazeDirection.up)
        ..add(MazeDirection.left)
        ..undo();
      expect(g.code.single.direction, MazeDirection.up);
      g.clear();
      expect(g.code, isEmpty);
      g.undo(); // nothing to undo is fine
    });

    test('code cannot grow past the limit', () {
      final g = game();
      for (var i = 0; i < g.puzzle.limit; i++) {
        expect(g.add(MazeDirection.up), isTrue);
      }
      expect(g.isFull, isTrue);
      expect(g.add(MazeDirection.up), isFalse);
      expect(g.code, hasLength(g.puzzle.limit));
    });

    test('repeat works only where it is taught', () {
      final low = game()..add(MazeDirection.up);
      expect(low.toggleRepeat(), isFalse);

      final top = game(3);
      expect(top.toggleRepeat(), isFalse, reason: 'nothing to repeat');
      top.add(MazeDirection.up);
      expect(top.toggleRepeat(), isTrue);
      expect(top.code.single.times, 2);
      expect(top.code.single.label, 'up twice');
      top.toggleRepeat();
      expect(top.code.single.times, 1);
    });

    test('a failed run keeps the code and costs a star', () {
      final g = game()..add(MazeDirection.up);
      g.run();
      expect(g.code, hasLength(1));
      expect(g.failedRuns, 1);
      expect(g.stars, 2);
    });

    test('stars follow the failed runs, and never fall below one', () {
      for (final (fails, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (9, 1)]) {
        final g = game();
        for (var i = 0; i < fails; i++) {
          g.run();
        }
        expect(g.stars, stars);
      }
    });

    test('the level ends after its rounds', () {
      final g = game();
      final first = g.puzzle;
      g.add(MazeDirection.up);
      expect(g.nextRound(), isTrue);
      expect(g.puzzle, isNot(same(first)));
      expect(g.code, isEmpty);
      expect(g.nextRound(), isTrue);
      expect(g.nextRound(), isFalse);
      expect(g.round, RobotGame.rounds - 1);
    });
  });
}
