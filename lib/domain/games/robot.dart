import 'dart:math';

import 'maze.dart';

/// Code the Robot: plan a line of steps, press Go, and watch the robot follow
/// them to the flag. Pure logic: no Flutter, no storage. A run that goes wrong
/// keeps the code, so the child can find the mistake and fix it.

/// One line of the child's code.
class RobotStep {
  const RobotStep(this.direction, {this.times = 1});

  final MazeDirection direction;

  /// 2 when the step repeats, on the levels that allow it.
  final int times;

  String get label => times == 1 ? direction.label : '${direction.label} twice';
}

enum RobotEnding { goal, rock, edge, short }

/// What happened when the code ran.
class RobotTrace {
  const RobotTrace({
    required this.cells,
    required this.stepOfCell,
    required this.ending,
  });

  /// Each cell the robot moved to, in order.
  final List<int> cells;

  /// For each of [cells], the line of code that moved it there.
  final List<int> stepOfCell;
  final RobotEnding ending;
}

class RobotPuzzle {
  RobotPuzzle._({
    required this.size,
    required this.start,
    required this.goal,
    required this.rocks,
    required this.limit,
    required this.solution,
  });

  /// A new puzzle that can always be solved within [limit] lines.
  factory RobotPuzzle.make(int level, Random random) {
    final (size, rockCount) = _sizeFor(level);
    final allowRepeat = level >= RobotGame.repeatFromLevel;
    while (true) {
      final cells = List.generate(size * size, (i) => i)..shuffle(random);
      final start = cells[0];
      final goal = cells[1];
      final rocks = cells.skip(2).take(rockCount).toSet();
      final route = _route(size, start, goal, rocks);
      if (route == null || route.length < size) continue;
      final solution = allowRepeat
          ? _withRepeats(route)
          : [for (final d in route) RobotStep(d)];
      return RobotPuzzle._(
        size: size,
        start: start,
        goal: goal,
        rocks: rocks,
        limit: solution.length + 2,
        solution: solution,
      );
    }
  }

  static (int size, int rocks) _sizeFor(int level) => switch (level) {
    1 => (4, 2),
    2 => (5, 5),
    _ => (6, 8),
  };

  final int size;
  final int start;
  final int goal;
  final Set<int> rocks;

  /// The most lines of code allowed.
  final int limit;

  /// One way to solve it.
  final List<RobotStep> solution;

  /// Runs [code] from the start, stopping at the flag or the first problem.
  RobotTrace trace(List<RobotStep> code) {
    final cells = <int>[];
    final stepOfCell = <int>[];
    var cell = start;
    for (final (line, step) in code.indexed) {
      for (var i = 0; i < step.times; i++) {
        final next = _next(size, cell, step.direction);
        if (next == null) {
          return RobotTrace(
            cells: cells,
            stepOfCell: stepOfCell,
            ending: RobotEnding.edge,
          );
        }
        if (rocks.contains(next)) {
          return RobotTrace(
            cells: cells,
            stepOfCell: stepOfCell,
            ending: RobotEnding.rock,
          );
        }
        cell = next;
        cells.add(cell);
        stepOfCell.add(line);
        if (cell == goal) {
          return RobotTrace(
            cells: cells,
            stepOfCell: stepOfCell,
            ending: RobotEnding.goal,
          );
        }
      }
    }
    return RobotTrace(
      cells: cells,
      stepOfCell: stepOfCell,
      ending: RobotEnding.short,
    );
  }

  static int? _next(int size, int from, MazeDirection direction) {
    final row = from ~/ size + direction.rowStep;
    final column = from % size + direction.columnStep;
    if (row < 0 || row >= size || column < 0 || column >= size) return null;
    return row * size + column;
  }

  /// The shortest way from [start] to [goal], or null if rocks block it.
  static List<MazeDirection>? _route(
    int size,
    int start,
    int goal,
    Set<int> rocks,
  ) {
    final cameFrom = <int, (int, MazeDirection)>{};
    final queue = [start];
    for (var i = 0; i < queue.length; i++) {
      final here = queue[i];
      if (here == goal) break;
      for (final direction in MazeDirection.values) {
        final next = _next(size, here, direction);
        if (next == null || next == start) continue;
        if (rocks.contains(next) || cameFrom.containsKey(next)) continue;
        cameFrom[next] = (here, direction);
        queue.add(next);
      }
    }
    if (!cameFrom.containsKey(goal)) return null;
    final route = <MazeDirection>[];
    for (var at = goal; at != start; at = cameFrom[at]!.$1) {
      route.insert(0, cameFrom[at]!.$2);
    }
    return route;
  }

  /// Folds pairs of matching moves into one repeated line.
  static List<RobotStep> _withRepeats(List<MazeDirection> route) {
    final steps = <RobotStep>[];
    for (var i = 0; i < route.length; i++) {
      final twice = i + 1 < route.length && route[i + 1] == route[i];
      steps.add(RobotStep(route[i], times: twice ? 2 : 1));
      if (twice) i++;
    }
    return steps;
  }
}

/// The puzzles of one level, and the code being written.
class RobotGame {
  RobotGame({required this.level, required Random random}) : _random = random {
    _puzzle = RobotPuzzle.make(level, _random);
  }

  static const rounds = 3;

  /// The first level with the repeat button.
  static const repeatFromLevel = 3;

  final int level;
  final Random _random;

  RobotPuzzle get puzzle => _puzzle;
  late RobotPuzzle _puzzle;

  int get round => _round;
  int _round = 0;

  final List<RobotStep> code = [];

  bool get allowRepeat => level >= repeatFromLevel;
  bool get isFull => code.length >= _puzzle.limit;

  int get failedRuns => _failedRuns;
  int _failedRuns = 0;

  /// Fewer runs that go wrong earn more stars. Finishing always earns one.
  int get stars {
    if (_failedRuns == 0) return 3;
    if (_failedRuns <= 2) return 2;
    return 1;
  }

  bool add(MazeDirection direction) {
    if (isFull) return false;
    code.add(RobotStep(direction));
    return true;
  }

  /// Makes the last line repeat, or stop repeating.
  bool toggleRepeat() {
    if (!allowRepeat || code.isEmpty) return false;
    final last = code.last;
    code.last = RobotStep(last.direction, times: last.times == 1 ? 2 : 1);
    return true;
  }

  void undo() {
    if (code.isNotEmpty) code.removeLast();
  }

  void clear() => code.clear();

  RobotTrace run() {
    final trace = _puzzle.trace(code);
    if (trace.ending != RobotEnding.goal) _failedRuns++;
    return trace;
  }

  /// Moves to the next puzzle. Returns false when there are no more.
  bool nextRound() {
    if (_round + 1 >= rounds) return false;
    _round++;
    code.clear();
    _puzzle = RobotPuzzle.make(level, _random);
    return true;
  }
}
