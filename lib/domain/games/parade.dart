import 'dart:math';

/// Planet Parade: tap things into the right order, one at a time. Pure logic:
/// no Flutter, no storage. Nothing is timed, and a wrong pick only means
/// trying another.

class ParadeSet {
  const ParadeSet(this.question, this.order, this.fact);

  final String question;

  /// The right order.
  final List<String> order;
  final String fact;
}

const Map<int, List<ParadeSet>> paradeLevels = {
  1: [
    ParadeSet(
      'How does a butterfly grow? Start with the first stage.',
      ['Egg', 'Caterpillar', 'Chrysalis', 'Butterfly'],
      'This big change in an animal\'s body is called metamorphosis.',
    ),
    ParadeSet(
      'How does a frog grow? Start with the first stage.',
      ['Egg', 'Tadpole', 'Froglet', 'Frog'],
      'Tadpoles breathe with gills, and most grown frogs use lungs.',
    ),
    ParadeSet(
      'Put these animals in order, smallest first.',
      ['Ant', 'Mouse', 'Cat', 'Horse', 'Elephant'],
      'The African elephant is the largest animal living on land.',
    ),
  ],
  2: [
    ParadeSet(
      'Which planets are closest to the Sun? Start with the nearest.',
      ['Mercury', 'Venus', 'Earth', 'Mars'],
      'These four planets are all made mostly of rock.',
    ),
    ParadeSet(
      'How does a plant grow? Start with the first stage.',
      ['Seed', 'Sprout', 'Young plant', 'Flower', 'Fruit'],
      'Many fruits hold seeds, ready to grow new plants.',
    ),
    ParadeSet(
      'Put these in order of size, smallest first.',
      ['The Moon', 'Earth', 'The Sun', 'The Milky Way'],
      'The Milky Way is a galaxy of more than 100 billion stars.',
    ),
  ],
  3: [
    ParadeSet(
      'Line up all the planets, starting nearest the Sun.',
      [
        'Mercury',
        'Venus',
        'Earth',
        'Mars',
        'Jupiter',
        'Saturn',
        'Uranus',
        'Neptune',
      ],
      'Neptune is so far away that one of its years lasts about 165 of ours.',
    ),
    ParadeSet(
      'Line up the planets by size, biggest first.',
      [
        'Jupiter',
        'Saturn',
        'Uranus',
        'Neptune',
        'Earth',
        'Venus',
        'Mars',
        'Mercury',
      ],
      'More than 1,000 Earths could fit inside Jupiter.',
    ),
    ParadeSet(
      "Go down through the Earth's layers, starting at the surface.",
      ['Crust', 'Mantle', 'Outer core', 'Inner core'],
      "The Earth's inner core is solid, and the outer core is liquid.",
    ),
    ParadeSet(
      'Build a food chain, starting with the plant.',
      ['Grass', 'Grasshopper', 'Frog', 'Snake', 'Hawk'],
      'Almost all food chains begin with plants or algae, which use sunlight.',
    ),
  ],
};

enum ParadeTap { ignored, wrong, right, finished }

/// One game: a few sets to put in order.
class ParadeGame {
  ParadeGame({required this.level, required Random random}) : _random = random {
    _sets = ([...paradeLevels[level]!]..shuffle(_random)).take(rounds).toList();
    _deal();
  }

  static const rounds = 3;

  final int level;
  final Random _random;
  late final List<ParadeSet> _sets;

  int get round => _round;
  int _round = 0;

  ParadeSet get set => _sets[_round];

  /// The things to tap, mixed up.
  List<String> get options => _options;
  List<String> _options = const [];

  /// How many are in place so far.
  int get placed => _placed;
  int _placed = 0;

  /// Things tried for this place, which can't count twice.
  final Set<String> tried = {};

  bool get isFinished => _placed == set.order.length;

  int get mistakes => _mistakes;
  int _mistakes = 0;

  /// Fewer wrong picks earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 2) return 2;
    return 1;
  }

  bool isPlaced(String item) => set.order.take(_placed).contains(item);

  ParadeTap tap(String item) {
    if (isFinished || !_options.contains(item) || isPlaced(item)) {
      return ParadeTap.ignored;
    }
    if (tried.contains(item)) return ParadeTap.ignored;
    if (item != set.order[_placed]) {
      tried.add(item);
      _mistakes++;
      return ParadeTap.wrong;
    }
    _placed++;
    tried.clear();
    return isFinished ? ParadeTap.finished : ParadeTap.right;
  }

  /// Moves on. Returns false when there are no more sets.
  bool nextRound() {
    if (_round + 1 >= rounds) return false;
    _round++;
    _deal();
    return true;
  }

  void _deal() {
    _placed = 0;
    tried.clear();
    final mixed = [...set.order];
    do {
      mixed.shuffle(_random);
    } while (_sameOrder(mixed, set.order));
    _options = mixed;
  }

  static bool _sameOrder(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Checks that the sets are fair; returns problems, empty when valid.
List<String> paradeProblems() {
  final issues = <String>[];
  for (final MapEntry(key: level, value: sets) in paradeLevels.entries) {
    if (sets.length < ParadeGame.rounds) issues.add('level $level: too few');
    for (final set in sets) {
      if (set.order.length < 3) issues.add('${set.question}: too short');
      if (set.order.toSet().length != set.order.length) {
        issues.add('${set.question}: repeats');
      }
      if (set.fact.trim().isEmpty) issues.add('${set.question}: no fact');
    }
  }
  return issues;
}
