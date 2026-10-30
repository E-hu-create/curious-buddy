import 'dart:math';

/// Four in a Row: drop counters in turn and try to line up four before Buddy
/// does. Pure logic: no Flutter, no storage. Nothing is timed.

enum FourPlayer { child, buddy }

enum FourResult { playing, childWon, buddyWon, draw }

class FourGame {
  FourGame({required this.level, required Random random}) : _random = random;

  static const rows = 6;
  static const columns = 7;
  static const _lookAhead = 4;
  static const _win = 100000;

  /// 1 plays anywhere, 2 takes wins and blocks, 3 looks ahead.
  final int level;
  final Random _random;

  /// Row by row from the top: who is in each space.
  final List<FourPlayer?> board = List.filled(rows * columns, null);

  FourResult get result => _result;
  FourResult _result = FourResult.playing;

  bool get isOver => _result != FourResult.playing;

  /// The four spaces that won, if any.
  Set<int> get winningCells => _winningCells;
  Set<int> _winningCells = const {};

  /// Buddy's latest column.
  int? get lastBuddyColumn => _lastBuddyColumn;
  int? _lastBuddyColumn;

  /// A win earns three stars, a draw two, and a game played to the end one.
  int get stars => switch (_result) {
    FourResult.childWon => 3,
    FourResult.draw => 2,
    _ => 1,
  };

  static int cellOf(int row, int column) => row * columns + column;

  bool canPlay(int column) =>
      !isOver &&
      column >= 0 &&
      column < columns &&
      board[cellOf(0, column)] == null;

  int freeIn(int column) => List.generate(
    rows,
    (row) => cellOf(row, column),
  ).where((cell) => board[cell] == null).length;

  /// The child drops a counter. Returns false if that column can't take one.
  bool play(int column) {
    if (!canPlay(column)) return false;
    _drop(board, column, FourPlayer.child);
    _update();
    return true;
  }

  /// Buddy takes a turn.
  void buddyPlays() {
    if (isOver) return;
    final column = _chooseColumn();
    _drop(board, column, FourPlayer.buddy);
    _lastBuddyColumn = column;
    _update();
  }

  void _update() {
    for (final player in FourPlayer.values) {
      final line = _lineOf(board, player);
      if (line != null) {
        _winningCells = line;
        _result = player == FourPlayer.child
            ? FourResult.childWon
            : FourResult.buddyWon;
        return;
      }
    }
    if (!board.contains(null)) _result = FourResult.draw;
  }

  int _chooseColumn() {
    final open = _openColumns(board)..shuffle(_random);
    if (level <= 1) return open.first;
    for (final player in const [FourPlayer.buddy, FourPlayer.child]) {
      for (final column in open) {
        final copy = [...board];
        _drop(copy, column, player);
        if (_lineOf(copy, player) != null) return column;
      }
    }
    if (level == 2) {
      // Nearer the middle is usually stronger.
      open.sort((a, b) => (a - 3).abs().compareTo((b - 3).abs()));
      return open.first;
    }
    var best = open.first;
    var bestScore = -_win * 10;
    for (final column in open) {
      final copy = [...board];
      _drop(copy, column, FourPlayer.buddy);
      final score = _search(copy, _lookAhead - 1, -_win * 10, _win * 10, false);
      if (score > bestScore) {
        bestScore = score;
        best = column;
      }
    }
    return best;
  }

  /// Looks ahead over both players' moves, skipping lines that can't matter.
  int _search(List<FourPlayer?> state, int depth, int low, int high, bool me) {
    if (_lineOf(state, FourPlayer.buddy) != null) return _win + depth;
    if (_lineOf(state, FourPlayer.child) != null) return -_win - depth;
    final open = _openColumns(state);
    if (open.isEmpty) return 0;
    if (depth == 0) return _score(state);
    var best = me ? -_win * 10 : _win * 10;
    for (final column in open) {
      final copy = [...state];
      _drop(copy, column, me ? FourPlayer.buddy : FourPlayer.child);
      final score = _search(copy, depth - 1, low, high, !me);
      if (me) {
        best = max(best, score);
        low = max(low, best);
      } else {
        best = min(best, score);
        high = min(high, best);
      }
      if (low >= high) break;
    }
    return best;
  }

  /// Open lines with more of Buddy's counters score higher.
  static int _score(List<FourPlayer?> state) {
    var total = 0;
    for (final line in _allLines) {
      final buddy = line.where((c) => state[c] == FourPlayer.buddy).length;
      final child = line.where((c) => state[c] == FourPlayer.child).length;
      if (child == 0) total += buddy * buddy;
      if (buddy == 0) total -= child * child;
    }
    return total;
  }

  static List<int> _openColumns(List<FourPlayer?> state) => [
    for (var column = 0; column < columns; column++)
      if (state[cellOf(0, column)] == null) column,
  ];

  static void _drop(List<FourPlayer?> state, int column, FourPlayer player) {
    for (var row = rows - 1; row >= 0; row--) {
      final cell = cellOf(row, column);
      if (state[cell] == null) {
        state[cell] = player;
        return;
      }
    }
  }

  static Set<int>? _lineOf(List<FourPlayer?> state, FourPlayer player) {
    for (final line in _allLines) {
      if (line.every((cell) => state[cell] == player)) return line.toSet();
    }
    return null;
  }

  /// Every straight run of four spaces on the board.
  static final List<List<int>> _allLines = [
    for (var row = 0; row < rows; row++)
      for (var column = 0; column < columns; column++)
        for (final (rowStep, columnStep) in const [
          (0, 1),
          (1, 0),
          (1, 1),
          (1, -1),
        ])
          if (_fits(row + rowStep * 3, column + columnStep * 3))
            [
              for (var i = 0; i < 4; i++)
                cellOf(row + rowStep * i, column + columnStep * i),
            ],
  ];

  static bool _fits(int row, int column) =>
      row >= 0 && row < rows && column >= 0 && column < columns;
}
