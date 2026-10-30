import 'dart:math';

import 'maze.dart';

/// Circuit Fixer: turn the wire pieces until electricity can flow from the
/// battery to the bulb. Pure logic: no Flutter, no storage. Nothing is timed,
/// and any path that reaches the bulb counts.

/// A wire piece. Each tap turns it a quarter clockwise.
class CircuitTile {
  CircuitTile({required this.straight, this.turns = 0});

  /// A straight wire, or a corner.
  final bool straight;
  int turns;

  Set<MazeDirection> get openings => openingsAt(turns);

  Set<MazeDirection> openingsAt(int turns) => {
    for (final side
        in straight
            ? const [MazeDirection.up, MazeDirection.down]
            : const [MazeDirection.up, MazeDirection.right])
      MazeDirection.values[(side.index + turns) % 4],
  };

  /// How many taps until it joins [sides].
  int tapsToJoin(Set<MazeDirection> sides) {
    for (var taps = 0; taps < 4; taps++) {
      final after = openingsAt(turns + taps);
      if (after.containsAll(sides) && sides.containsAll(after)) return taps;
    }
    throw ArgumentError('This piece cannot join $sides');
  }
}

class CircuitPuzzle {
  CircuitPuzzle({required this.size, required Random random}) {
    sourceRow = random.nextInt(size);
    bulbRow = random.nextInt(size);
    _route = _findRoute(random);
    tiles = [
      for (var i = 0; i < size * size; i++)
        CircuitTile(straight: random.nextBool()),
    ];
    for (final (i, cell) in _route.indexed) {
      final from = i == 0
          ? MazeDirection.left
          : _stepBetween(_route[i - 1], cell).opposite;
      final to = i == _route.length - 1
          ? MazeDirection.right
          : _stepBetween(cell, _route[i + 1]);
      tiles[cell] = CircuitTile(straight: from.opposite == to);
      _needed[cell] = {from, to};
    }
    for (final tile in tiles) {
      tile.turns = random.nextInt(4);
    }
    // Never start with the bulb already on.
    while (isLit) {
      tiles[_route[random.nextInt(_route.length)]].turns++;
    }
  }

  final int size;
  late final int sourceRow;
  late final int bulbRow;
  late final List<CircuitTile> tiles;
  late final List<int> _route;
  final Map<int, Set<MazeDirection>> _needed = {};

  int get _sourceCell => sourceRow * size;
  int get bulbCell => bulbRow * size + size - 1;

  /// The cells of one route to the bulb, and the sides each must join.
  Map<int, Set<MazeDirection>> get route => _needed;

  /// The fewest taps on the route, right now, to light the bulb that way.
  int get tapsNeeded => _needed.entries.fold(
    0,
    (sum, e) => sum + tiles[e.key].tapsToJoin(e.value),
  );

  /// Cells that electricity reaches from the battery.
  Set<int> get lit {
    if (!tiles[_sourceCell].openings.contains(MazeDirection.left)) return {};
    final reached = {_sourceCell};
    final queue = [_sourceCell];
    for (var i = 0; i < queue.length; i++) {
      final here = queue[i];
      for (final side in tiles[here].openings) {
        final next = _neighbour(here, side);
        if (next == null || reached.contains(next)) continue;
        if (!tiles[next].openings.contains(side.opposite)) continue;
        reached.add(next);
        queue.add(next);
      }
    }
    return reached;
  }

  bool get isLit =>
      lit.contains(bulbCell) &&
      tiles[bulbCell].openings.contains(MazeDirection.right);

  int? _neighbour(int cell, MazeDirection side) {
    final row = cell ~/ size + side.rowStep;
    final column = cell % size + side.columnStep;
    if (row < 0 || row >= size || column < 0 || column >= size) return null;
    return row * size + column;
  }

  MazeDirection _stepBetween(int from, int to) =>
      MazeDirection.values.firstWhere((d) => _neighbour(from, d) == to);

  /// A wandering path across the board, so the answer is never just a line.
  List<int> _findRoute(Random random) {
    final target = bulbRow * size + size - 1;
    while (true) {
      final path = [sourceRow * size];
      if (_walk(path, target, random) && path.length >= size + size ~/ 2) {
        return path;
      }
    }
  }

  bool _walk(List<int> path, int target, Random random) {
    final here = path.last;
    if (here == target) return true;
    final sides = [...MazeDirection.values]..shuffle(random);
    for (final side in sides) {
      final next = _neighbour(here, side);
      if (next == null || path.contains(next)) continue;
      path.add(next);
      if (_walk(path, target, random)) return true;
      path.removeLast();
    }
    return false;
  }
}

enum CircuitResult { ignored, turned, lit }

/// The circuits of one level.
class CircuitGame {
  CircuitGame({required this.level, required Random random})
    : _random = random {
    _deal();
  }

  static const rounds = 3;
  static const _generous = 2;

  static int sizeFor(int level) => switch (level) {
    1 => 3,
    2 => 4,
    _ => 5,
  };

  /// One for each round.
  static const facts = [
    'Electricity only flows when the circuit makes a complete path.',
    'A battery pushes electricity around the circuit.',
    'Copper is used in wires because electricity flows through it easily.',
  ];

  final int level;
  final Random _random;

  CircuitPuzzle get puzzle => _puzzle;
  late CircuitPuzzle _puzzle;

  int get round => _round;
  int _round = 0;

  int get taps => _taps;
  int _taps = 0;

  int _allowed = 0;

  String get fact => facts[_round % facts.length];

  /// Close to the fewest taps earns three stars. Finishing always earns one.
  int get stars {
    final extra = _taps - _allowed;
    if (extra <= 0) return 3;
    if (extra <= 6) return 2;
    return 1;
  }

  CircuitResult tap(int cell) {
    if (_puzzle.isLit || cell < 0 || cell >= _puzzle.tiles.length) {
      return CircuitResult.ignored;
    }
    _puzzle.tiles[cell].turns++;
    _taps++;
    return _puzzle.isLit ? CircuitResult.lit : CircuitResult.turned;
  }

  /// Moves on. Returns false when there are no more circuits.
  bool nextRound() {
    if (_round + 1 >= rounds) return false;
    _round++;
    _deal();
    return true;
  }

  void _deal() {
    _puzzle = CircuitPuzzle(size: sizeFor(level), random: _random);
    _allowed += _puzzle.tapsNeeded + _generous;
  }
}
