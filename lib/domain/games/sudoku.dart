import 'dart:math';

import 'games.dart';

/// Picture Sudoku: fill the grid so each picture appears once in every row,
/// column and box. Pure logic: no Flutter, no storage. Nothing is timed, and
/// a picture that doesn't fit is simply not placed.

/// Why a picture can't go in a square.
enum SudokuClash { row, column, box, other }

enum SudokuMove { ignored, clash, placed, solved }

class SudokuPuzzle {
  SudokuPuzzle({
    required this.boxRows,
    required this.boxColumns,
    required int blanks,
    required Random random,
  }) : size = boxRows * boxColumns {
    solution = _solvedGrid(random);
    board = [...solution];
    _clearSquares(blanks, random);
    given = {
      for (var i = 0; i < board.length; i++)
        if (board[i] != null) i,
    };
  }

  final int boxRows;
  final int boxColumns;

  /// Squares along each side, and how many different pictures there are.
  final int size;

  late final List<int> solution;

  /// The grid so far: a picture number, or null for an empty square.
  late final List<int?> board;

  /// Squares filled in from the start.
  late final Set<int> given;

  bool get isSolved => !board.contains(null);

  int? get firstEmpty {
    final index = board.indexOf(null);
    return index < 0 ? null : index;
  }

  /// Why [value] can't go in [cell], or null if it belongs there.
  SudokuClash? clashAt(int cell, int value) {
    if (solution[cell] == value) return null;
    final row = cell ~/ size;
    final column = cell % size;
    if ([
      for (var c = 0; c < size; c++) board[row * size + c],
    ].contains(value)) {
      return SudokuClash.row;
    }
    if ([
      for (var r = 0; r < size; r++) board[r * size + column],
    ].contains(value)) {
      return SudokuClash.column;
    }
    if (_boxOf(cell).any((other) => board[other] == value)) {
      return SudokuClash.box;
    }
    return SudokuClash.other;
  }

  /// The number of answers, stopping at [limit]. A fair puzzle has one.
  int countSolutions({int limit = 2}) => _count([...board], limit);

  int _count(List<int?> grid, int limit) {
    final cell = grid.indexOf(null);
    if (cell < 0) return 1;
    var found = 0;
    for (var value = 0; value < size && found < limit; value++) {
      if (_fits(grid, cell, value)) {
        grid[cell] = value;
        found += _count(grid, limit - found);
        grid[cell] = null;
      }
    }
    return found;
  }

  bool _fits(List<int?> grid, int cell, int value) {
    final row = cell ~/ size;
    final column = cell % size;
    for (var i = 0; i < size; i++) {
      if (grid[row * size + i] == value) return false;
      if (grid[i * size + column] == value) return false;
    }
    return !_boxOf(cell).any((other) => grid[other] == value);
  }

  Iterable<int> _boxOf(int cell) sync* {
    final top = cell ~/ size ~/ boxRows * boxRows;
    final left = cell % size ~/ boxColumns * boxColumns;
    for (var r = 0; r < boxRows; r++) {
      for (var c = 0; c < boxColumns; c++) {
        yield (top + r) * size + left + c;
      }
    }
  }

  /// A known solved pattern, shuffled in ways that keep it valid.
  List<int> _solvedGrid(Random random) {
    List<int> shuffledLines(int groups, int groupSize) {
      final order = List.generate(groups, (g) => g)..shuffle(random);
      return [
        for (final group in order)
          ...(List.generate(groupSize, (i) => group * groupSize + i)
            ..shuffle(random)),
      ];
    }

    final rows = shuffledLines(boxColumns, boxRows);
    final columns = shuffledLines(boxRows, boxColumns);
    final pictures = List.generate(size, (i) => i)..shuffle(random);
    return [
      for (final r in rows)
        for (final c in columns)
          pictures[(boxColumns * (r % boxRows) + r ~/ boxRows + c) % size],
    ];
  }

  /// Empties squares one by one, keeping only those that leave one answer.
  void _clearSquares(int blanks, Random random) {
    final cells = List.generate(board.length, (i) => i)..shuffle(random);
    var cleared = 0;
    for (final cell in cells) {
      if (cleared == blanks) return;
      final value = board[cell];
      board[cell] = null;
      if (countSolutions() == 1) {
        cleared++;
      } else {
        board[cell] = value;
      }
    }
  }
}

/// The puzzles of one level.
class SudokuGame {
  SudokuGame({required this.level, required Random random}) : _random = random {
    _deal();
  }

  static const rounds = 2;

  final int level;
  final Random _random;

  SudokuPuzzle get puzzle => _puzzle;
  late SudokuPuzzle _puzzle;

  /// The picture for each number on the board.
  List<GamePicture> get pictures => _pictures;
  late List<GamePicture> _pictures;

  int get round => _round;
  int _round = 0;

  int get mistakes => _mistakes;
  int _mistakes = 0;

  /// Fewer clashes earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 2) return 2;
    return 1;
  }

  /// Puts picture [value] in [cell], if it belongs there.
  SudokuMove place(int cell, int value) {
    if (cell < 0 || cell >= _puzzle.board.length) return SudokuMove.ignored;
    if (_puzzle.given.contains(cell) || _puzzle.board[cell] != null) {
      return SudokuMove.ignored;
    }
    if (_puzzle.clashAt(cell, value) != null) {
      _mistakes++;
      return SudokuMove.clash;
    }
    _puzzle.board[cell] = value;
    return _puzzle.isSolved ? SudokuMove.solved : SudokuMove.placed;
  }

  /// Moves on. Returns false when there are no more puzzles.
  bool nextRound() {
    if (_round + 1 >= rounds) return false;
    _round++;
    _deal();
    return true;
  }

  void _deal() {
    final (boxRows, boxColumns, blanks) = switch (level) {
      1 => (2, 2, 6),
      2 => (2, 2, 10),
      _ => (2, 3, 16),
    };
    _puzzle = SudokuPuzzle(
      boxRows: boxRows,
      boxColumns: boxColumns,
      blanks: blanks,
      random: _random,
    );
    _pictures = ([
      ...GamePicture.values,
    ]..shuffle(_random)).take(_puzzle.size).toList();
  }
}
