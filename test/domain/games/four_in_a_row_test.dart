import 'dart:math';

import 'package:curious_buddy/domain/games/four_in_a_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FourGame game([int level = 1, int seed = 1]) =>
      FourGame(level: level, random: Random(seed));

  /// Places counters directly, to set up a position.
  void set(FourGame g, int row, int column, FourPlayer player) =>
      g.board[FourGame.cellOf(row, column)] = player;

  test('counters fall to the lowest free space', () {
    final g = game()..play(3);
    expect(g.board[FourGame.cellOf(5, 3)], FourPlayer.child);
    g.play(3);
    expect(g.board[FourGame.cellOf(4, 3)], FourPlayer.child);
    expect(g.freeIn(3), 4);
  });

  test('a full column takes no more', () {
    final g = game();
    for (var i = 0; i < FourGame.rows; i++) {
      set(g, i, 0, i.isEven ? FourPlayer.buddy : FourPlayer.child);
    }
    expect(g.canPlay(0), isFalse);
    expect(g.play(0), isFalse);
    expect(g.play(-1), isFalse);
    expect(g.play(7), isFalse);
  });

  test('four in a line wins, in every direction', () {
    for (final cells in [
      [(5, 0), (5, 1), (5, 2)],
      [(5, 0), (4, 0), (3, 0)],
    ]) {
      final g = game();
      for (final (row, column) in cells) {
        set(g, row, column, FourPlayer.child);
      }
      g.play(cells.first.$1 == cells.last.$1 ? 3 : 0);
      expect(g.result, FourResult.childWon);
      expect(g.winningCells, hasLength(4));
      expect(g.stars, 3);
    }

    final rising = game();
    for (final (column, height) in [(0, 1), (1, 2), (2, 3), (3, 3)]) {
      for (var h = 0; h < height; h++) {
        set(rising, 5 - h, column, FourPlayer.buddy);
      }
    }
    for (final (row, column) in [(5, 0), (4, 1), (3, 2)]) {
      set(rising, row, column, FourPlayer.child);
    }
    rising.play(3);
    expect(rising.result, FourResult.childWon);

    final falling = game();
    for (final (column, height) in [(6, 1), (5, 2), (4, 3), (3, 3)]) {
      for (var h = 0; h < height; h++) {
        set(falling, 5 - h, column, FourPlayer.buddy);
      }
    }
    for (final (row, column) in [(5, 6), (4, 5), (3, 4)]) {
      set(falling, row, column, FourPlayer.child);
    }
    falling.play(3);
    expect(falling.result, FourResult.childWon);
  });

  test('a loss still earns a star, and a full board is a draw', () {
    final lost = game(2);
    for (final column in [0, 1, 2]) {
      set(lost, 5, column, FourPlayer.buddy);
    }
    lost.buddyPlays();
    expect(lost.result, FourResult.buddyWon);
    expect(lost.stars, 1);

    // Pairs that shift on each row, which never line up four.
    final drawn = game();
    for (var i = 1; i < drawn.board.length; i++) {
      final row = i ~/ FourGame.columns;
      final column = i % FourGame.columns;
      drawn.board[i] = (column % 4 < 2) == row.isEven
          ? FourPlayer.child
          : FourPlayer.buddy;
    }
    expect(drawn.play(0), isTrue);
    expect(drawn.result, FourResult.draw);
    expect(drawn.stars, 2);
  });

  test('Explorer and Expert take a win when there is one', () {
    for (final level in [2, 3]) {
      final g = game(level);
      for (final column in [1, 2, 3]) {
        set(g, 5, column, FourPlayer.buddy);
        set(g, 4, column, FourPlayer.child);
      }
      g.buddyPlays();
      expect(g.result, FourResult.buddyWon);
    }
  });

  test('Explorer and Expert block a win', () {
    for (final level in [2, 3]) {
      for (var seed = 0; seed < 10; seed++) {
        final g = game(level, seed);
        for (final column in [4, 5, 6]) {
          set(g, 5, column, FourPlayer.child);
        }
        g.buddyPlays();
        expect(g.board[FourGame.cellOf(5, 3)], FourPlayer.buddy);
      }
    }
  });

  test('every level plays only legal moves, to a finish', () {
    for (final level in [1, 2, 3]) {
      for (var seed = 0; seed < 6; seed++) {
        final g = game(level, seed);
        final child = Random(seed);
        for (var i = 0; i < 50 && !g.isOver; i++) {
          final open = [
            for (var c = 0; c < FourGame.columns; c++)
              if (g.canPlay(c)) c,
          ];
          g.play(open[child.nextInt(open.length)]);
          final filled = g.board.where((p) => p != null).length;
          if (!g.isOver) {
            g.buddyPlays();
            expect(g.board.where((p) => p != null), hasLength(filled + 1));
          }
        }
        expect(g.isOver, isTrue);
      }
    }
  });

  test('Expert beats random play nearly every time', () {
    var wins = 0;
    for (var seed = 0; seed < 8; seed++) {
      final g = game(3, seed);
      final child = Random(seed);
      while (!g.isOver) {
        final open = [
          for (var c = 0; c < FourGame.columns; c++)
            if (g.canPlay(c)) c,
        ];
        g.play(open[child.nextInt(open.length)]);
        g.buddyPlays();
      }
      if (g.result == FourResult.buddyWon) wins++;
    }
    expect(wins, greaterThanOrEqualTo(7));
  });

  test('Expert moves quickly enough for a phone', () {
    final g = game(3)..play(3);
    final watch = Stopwatch()..start();
    g.buddyPlays();
    expect(watch.elapsedMilliseconds, lessThan(1500));
  });
}
