import 'dart:math';

import 'package:curious_buddy/domain/games/sudoku.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SudokuGame game([int level = 1, int seed = 1]) =>
      SudokuGame(level: level, random: Random(seed));

  /// Whether every row, column and box holds each picture once.
  void expectValid(SudokuPuzzle p) {
    final n = p.size;
    final all = List.generate(n, (i) => i).toSet();
    for (var i = 0; i < n; i++) {
      expect({for (var c = 0; c < n; c++) p.solution[i * n + c]}, all);
      expect({for (var r = 0; r < n; r++) p.solution[r * n + i]}, all);
    }
    for (var top = 0; top < n; top += p.boxRows) {
      for (var left = 0; left < n; left += p.boxColumns) {
        expect({
          for (var r = 0; r < p.boxRows; r++)
            for (var c = 0; c < p.boxColumns; c++)
              p.solution[(top + r) * n + left + c],
        }, all);
      }
    }
  }

  group('puzzles', () {
    test('are valid and have exactly one answer', () {
      for (final level in [1, 2, 3]) {
        for (var seed = 0; seed < 30; seed++) {
          final p = game(level, seed).puzzle;
          expectValid(p);
          expect(p.countSolutions(), 1, reason: 'level $level seed $seed');
        }
      }
    });

    test('get bigger and emptier with each level', () {
      int empties(int level) =>
          game(level).puzzle.board.where((v) => v == null).length;
      expect(game().puzzle.size, 4);
      expect(game(3).puzzle.size, 6);
      expect(empties(1), lessThan(empties(2)));
      expect(empties(2), lessThan(empties(3)));
    });

    test('squares from the start match the answer', () {
      final p = game(3).puzzle;
      for (final cell in p.given) {
        expect(p.board[cell], p.solution[cell]);
      }
    });
  });

  group('placing', () {
    int empty(SudokuGame g) => g.puzzle.firstEmpty!;

    test('the right picture goes in', () {
      final g = game();
      final cell = empty(g);
      expect(g.place(cell, g.puzzle.solution[cell]), SudokuMove.placed);
      expect(g.puzzle.board[cell], g.puzzle.solution[cell]);
    });

    test('a wrong picture stays out and counts', () {
      final g = game();
      final cell = empty(g);
      final wrong = (g.puzzle.solution[cell] + 1) % g.puzzle.size;
      expect(g.place(cell, wrong), SudokuMove.clash);
      expect(g.puzzle.board[cell], isNull);
      expect(g.mistakes, 1);
    });

    test('a clash names what it clashes with', () {
      for (var seed = 0; seed < 40; seed++) {
        final p = game(2, seed).puzzle;
        final cell = p.firstEmpty!;
        final n = p.size;
        final row = cell ~/ n;
        final inRow = [
          for (var c = 0; c < n; c++) p.board[row * n + c],
        ].whereType<int>().where((v) => v != p.solution[cell]);
        if (inRow.isNotEmpty) {
          expect(p.clashAt(cell, inRow.first), SudokuClash.row);
        }
      }
    });

    test('given and filled squares cannot change', () {
      final g = game();
      final cell = empty(g);
      g.place(cell, g.puzzle.solution[cell]);
      expect(g.place(cell, 0), SudokuMove.ignored);
      expect(g.place(g.puzzle.given.first, 0), SudokuMove.ignored);
      expect(g.place(-1, 0), SudokuMove.ignored);
    });

    test('the last square solves it, and levels have two puzzles', () {
      final g = game();
      var last = SudokuMove.ignored;
      while (!g.puzzle.isSolved) {
        final cell = empty(g);
        last = g.place(cell, g.puzzle.solution[cell]);
      }
      expect(last, SudokuMove.solved);
      expect(g.nextRound(), isTrue);
      expect(g.nextRound(), isFalse);
    });

    test('each puzzle has enough different pictures', () {
      for (final level in [1, 3]) {
        final g = game(level);
        expect(g.pictures.toSet(), hasLength(g.puzzle.size));
      }
    });

    test('stars follow the clashes, and never fall below one', () {
      for (final (wrong, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (6, 1)]) {
        final g = game();
        final cell = empty(g);
        final value = (g.puzzle.solution[cell] + 1) % g.puzzle.size;
        for (var i = 0; i < wrong; i++) {
          g.place(cell, value);
        }
        expect(g.stars, stars);
      }
    });
  });
}
