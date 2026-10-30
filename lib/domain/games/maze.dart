import 'dart:math';

/// Treasure Maze: guide Buddy along the corridors, collect gems and reach the
/// chest. Pure logic: no Flutter, no storage. A new maze is made every game;
/// nothing is timed, and bumping a wall costs nothing.

enum MazeDirection {
  up('up', -1, 0),
  right('right', 0, 1),
  down('down', 1, 0),
  left('left', 0, -1);

  const MazeDirection(this.label, this.rowStep, this.columnStep);

  final String label;
  final int rowStep;
  final int columnStep;

  MazeDirection get opposite => values[(index + 2) % 4];
}

enum MazeMove { ignored, blocked, moved, gem, won }

class MazeGame {
  MazeGame({required this.size, required int gems, required Random random})
    : openings = List.generate(size * size, (_) => <MazeDirection>{}) {
    _carve(random);
    treasure = _farthestFromStart();
    _placeGems(gems, random);
  }

  static (int size, int gems) sizeFor(int level) => switch (level) {
    1 => (5, 2),
    2 => (7, 3),
    _ => (9, 4),
  };

  /// Cells along each side.
  final int size;

  /// For each cell, row by row, the directions with no wall.
  final List<Set<MazeDirection>> openings;

  static const start = 0;
  late final int treasure;
  final Set<int> gems = {};
  final Set<int> collected = {};

  /// Buddy's cell.
  int get cell => _cell;
  int _cell = start;

  int get row => _cell ~/ size;
  int get column => _cell % size;

  bool get isWon => _cell == treasure;

  /// All the gems earn three stars and half of them two. Reaching the
  /// treasure always earns at least one.
  int get stars {
    if (collected.length == gems.length) return 3;
    if (collected.length * 2 >= gems.length) return 2;
    return 1;
  }

  /// Moves until something interesting: a wall, a turning, a gem or the
  /// treasure.
  MazeMove go(MazeDirection direction) {
    if (isWon) return MazeMove.ignored;
    if (!openings[_cell].contains(direction)) return MazeMove.blocked;
    do {
      _cell = _step(_cell, direction)!;
      if (isWon) return MazeMove.won;
      if (gems.contains(_cell) && collected.add(_cell)) return MazeMove.gem;
    } while (openings[_cell].contains(direction) &&
        openings[_cell].length == 2);
    return MazeMove.moved;
  }

  int? _step(int from, MazeDirection direction) {
    final row = from ~/ size + direction.rowStep;
    final column = from % size + direction.columnStep;
    if (row < 0 || row >= size || column < 0 || column >= size) return null;
    return row * size + column;
  }

  /// Digs corridors by wandering from the start and backing up at dead ends,
  /// so every cell can be reached by exactly one route.
  void _carve(Random random) {
    final visited = {start};
    final trail = [start];
    while (trail.isNotEmpty) {
      final here = trail.last;
      final choices = [
        for (final direction in MazeDirection.values)
          if (_step(here, direction) case final next?
              when !visited.contains(next))
            (direction, next),
      ];
      if (choices.isEmpty) {
        trail.removeLast();
        continue;
      }
      final (direction, next) = choices[random.nextInt(choices.length)];
      openings[here].add(direction);
      openings[next].add(direction.opposite);
      visited.add(next);
      trail.add(next);
    }
  }

  int _farthestFromStart() {
    final distance = {start: 0};
    final queue = [start];
    for (var i = 0; i < queue.length; i++) {
      for (final direction in openings[queue[i]]) {
        final next = _step(queue[i], direction)!;
        if (distance.containsKey(next)) continue;
        distance[next] = distance[queue[i]]! + 1;
        queue.add(next);
      }
    }
    return queue.last;
  }

  /// Dead ends come first, so finding a gem means exploring.
  void _placeGems(int count, Random random) {
    final cells = [
      for (var i = 0; i < size * size; i++)
        if (i != start && i != treasure) i,
    ]..shuffle(random);
    cells.sort((a, b) => openings[a].length.compareTo(openings[b].length));
    gems.addAll(cells.take(count));
  }
}
