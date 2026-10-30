import 'dart:math';

import 'dino.dart';

/// Buddy's Challenge Arena: quick games for memory, logic and observation.
/// Pure logic: no Flutter, no storage. Nothing here is timed, and a wrong
/// move never loses anything already earned.

enum GameKind {
  memory('Memory Match', 'Flip the cards and find the pairs.'),
  pattern('Pattern Power', 'Work out what comes next.'),
  spot('Spot the Change', 'Find what is different in the second picture.'),
  maze(
    'Treasure Maze',
    'Guide Buddy to the chest, collecting gems on the way.',
  ),
  robot('Code the Robot', 'Plan the steps, press Go, and watch your code run.'),
  words('Word Builder', 'Unscramble the letters to make science words.'),
  sounds("What's That Sound?", 'Listen closely and work out what made it.'),
  four('Four in a Row', 'Line up four counters before Buddy does.'),
  number('Number Pop', 'Pop every bubble that makes the target number.'),
  sort('Sort It!', 'Put each thing in the right group.');

  const GameKind(this.title, this.tagline);

  /// The quick games shown together in the Arena. The others have their own
  /// tile in the Game Zone.
  static const arena = [memory, pattern, spot];

  final String title;
  final String tagline;
}

enum GameShape {
  circle('circle'),
  square('square'),
  triangle('triangle'),
  star('star'),
  heart('heart');

  const GameShape(this.label);

  final String label;
}

enum GameColor {
  coral('red'),
  sun('yellow'),
  leaf('green'),
  blue('blue'),
  grape('purple');

  const GameColor(this.label);

  final String label;
}

/// A drawn picture for the Memory Match cards.
enum GamePicture {
  rocket('rocket'),
  planet('planet'),
  fish('fish'),
  turtle('turtle'),
  butterfly('butterfly'),
  flower('flower'),
  tree('tree'),
  whale('whale'),
  volcano('volcano'),
  owl('owl'),
  mushroom('mushroom'),
  sailboat('sailboat');

  const GamePicture(this.label);

  final String label;
}

/// Something shown in a game: a coloured shape, a number or a picture. It
/// always has a word for it, so screen readers and Buddy can say it.
class GameToken {
  const GameToken.shape(GameShape this.shape, GameColor this.color)
    : number = null,
      picture = null;
  const GameToken.number(int this.number)
    : shape = null,
      color = null,
      picture = null;
  const GameToken.picture(GamePicture this.picture)
    : shape = null,
      color = null,
      number = null;

  final GameShape? shape;
  final GameColor? color;
  final int? number;
  final GamePicture? picture;

  String get label =>
      picture?.label ?? number?.toString() ?? '${color!.label} ${shape!.label}';

  @override
  bool operator ==(Object other) =>
      other is GameToken &&
      other.shape == shape &&
      other.color == color &&
      other.number == number &&
      other.picture == picture;

  @override
  int get hashCode => Object.hash(shape, color, number, picture);
}

/// All the shape and colour mixes, for the games that need many.
final List<GameToken> allShapeTokens = [
  for (final shape in GameShape.values)
    for (final color in GameColor.values) GameToken.shape(shape, color),
];

/// Every picture, for dealing Memory Match cards.
final List<GameToken> allPictureTokens = [
  for (final picture in GamePicture.values) GameToken.picture(picture),
];

/// One level of a game: `memory_1`, `pattern_2`, and so on.
class GameLevel {
  const GameLevel(this.kind, this.number);

  final GameKind kind;

  /// 1, 2 or 3.
  final int number;

  String get id => '${kind.name}_$number';
  String get name => switch (number) {
    1 => 'Starter',
    2 => 'Explorer',
    _ => 'Expert',
  };
}

/// A player's rank, from the stars won across every game. Ranks only ever go
/// up: replaying can't lose stars.
enum GameRank {
  rookie('Rookie', 0),
  player('Player', 6),
  starPlayer('Star Player', 15),
  champion('Champion', 30);

  const GameRank(this.label, this.stars);

  final String label;
  final int stars;

  static GameRank of(int stars) =>
      values.lastWhere((rank) => stars >= rank.stars);

  /// The rank after this one, if any.
  GameRank? get next => this == champion ? null : values[index + 1];
}

abstract final class ArenaRules {
  static const levelsPerGame = 3;

  static List<GameLevel> levelsOf(GameKind kind) => [
    for (var n = 1; n <= levelsPerGame; n++) GameLevel(kind, n),
  ];

  /// Everything that earns game stars, including Dino Discovery's places.
  static final allLevelIds = {
    for (final kind in GameKind.values)
      for (final level in levelsOf(kind)) level.id,
    ...DinoRules.allIds,
  };

  /// Level 1 is always open; each later one opens with any star on the one
  /// before.
  static bool isOpen(GameLevel level, Map<String, int> best) =>
      level.number == 1 ||
      (best[GameLevel(level.kind, level.number - 1).id] ?? 0) > 0;

  /// Total stars across every known level. Unknown saved ids are ignored.
  static int totalStars(Map<String, int> best) => allLevelIds.fold(
    0,
    (sum, id) => sum + (best[id] ?? 0).clamp(0, maxStars),
  );

  static const maxStars = 3;

  /// Every star there is to win.
  static int get allStars => allLevelIds.length * maxStars;
}

// -------------------------------------------------------------- Memory Match

enum FlipResult { ignored, first, pair, mismatch, won }

/// A face-down grid of pairs. A mismatched pair stays showing until the next
/// tap, so there is no timer and the child can look as long as they like.
class MemoryGame {
  MemoryGame({required this.pairs, required Random random})
    : cards = _deal(pairs, random);

  static int pairsFor(int level) => switch (level) {
    1 => 3,
    2 => 4,
    _ => 6,
  };

  final List<GameToken> cards;
  final int pairs;

  final Set<int> matched = {};
  final List<int> showing = [];

  int get moves => _moves;
  int _moves = 0;

  bool get isWon => matched.length == cards.length;

  bool isFaceUp(int index) =>
      matched.contains(index) || showing.contains(index);

  /// Fewer moves earn more stars; finishing always earns at least one.
  int get stars {
    if (_moves <= (pairs * 1.5).ceil()) return 3;
    if (_moves <= pairs * 2) return 2;
    return 1;
  }

  FlipResult flip(int index) {
    if (index < 0 || index >= cards.length || isWon) return FlipResult.ignored;
    if (matched.contains(index) || showing.contains(index)) {
      return FlipResult.ignored;
    }
    if (showing.length == 2) showing.clear();
    showing.add(index);
    if (showing.length == 1) return FlipResult.first;

    _moves++;
    if (cards[showing[0]] != cards[showing[1]]) return FlipResult.mismatch;
    matched.addAll(showing);
    showing.clear();
    return isWon ? FlipResult.won : FlipResult.pair;
  }

  static List<GameToken> _deal(int pairs, Random random) {
    final tokens = [...allPictureTokens]..shuffle(random);
    final chosen = tokens.take(pairs);
    return [...chosen, ...chosen]..shuffle(random);
  }
}

// ------------------------------------------------------------- Pattern Power

class PatternRound {
  const PatternRound({
    required this.shown,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  /// The pattern so far. The next item is what the child works out.
  final List<GameToken> shown;
  final List<GameToken> options;
  final GameToken answer;
  final String explanation;
}

/// Checks that rounds are fair; returns problems, empty when valid.
List<String> patternProblems(List<PatternRound> rounds) {
  final issues = <String>[];
  for (final (i, r) in rounds.indexed) {
    if (r.shown.length < 3) issues.add('round $i: too short');
    if (r.options.length < 3 || r.options.length > 4) {
      issues.add('round $i: needs 3 or 4 options');
    }
    if (r.options.toSet().length != r.options.length) {
      issues.add('round $i: options repeat');
    }
    if (r.options.where((o) => o == r.answer).length != 1) {
      issues.add('round $i: needs exactly one right option');
    }
    if (r.explanation.trim().isEmpty) issues.add('round $i: no explanation');
  }
  return issues;
}

// ----------------------------------------------------------- Spot the Change

enum SpotResult { ignored, found, miss, won }

/// Two pictures of shapes, with some items changed in the second. Tap the
/// changes in the second picture.
class SpotGame {
  SpotGame({
    required this.rows,
    required this.columns,
    required int changes,
    required Random random,
  }) : first = _picture(rows * columns, random),
       second = [] {
    second.addAll(first);
    final places = List.generate(first.length, (i) => i)..shuffle(random);
    changed = places.take(changes).toSet();
    for (final i in changed) {
      second[i] = _different(first[i], random);
    }
  }

  static (int rows, int columns, int changes) sizeFor(int level) =>
      switch (level) {
        1 => (3, 3, 2),
        2 => (3, 4, 3),
        _ => (4, 4, 4),
      };

  final int rows;
  final int columns;
  final List<GameToken> first;
  final List<GameToken> second;
  late final Set<int> changed;

  final Set<int> found = {};
  int get misses => _misses;
  int _misses = 0;

  bool get isWon => found.length == changed.length;
  int get left => changed.length - found.length;

  /// Fewer wrong taps earn more stars; finishing always earns at least one.
  int get stars {
    if (_misses == 0) return 3;
    if (_misses <= 2) return 2;
    return 1;
  }

  SpotResult tap(int index) {
    if (index < 0 || index >= second.length) return SpotResult.ignored;
    if (isWon || found.contains(index)) return SpotResult.ignored;
    if (!changed.contains(index)) {
      _misses++;
      return SpotResult.miss;
    }
    found.add(index);
    return isWon ? SpotResult.won : SpotResult.found;
  }

  static List<GameToken> _picture(int count, Random random) => [
    for (var i = 0; i < count; i++)
      allShapeTokens[random.nextInt(allShapeTokens.length)],
  ];

  static GameToken _different(GameToken token, Random random) {
    while (true) {
      final next = allShapeTokens[random.nextInt(allShapeTokens.length)];
      if (next != token) return next;
    }
  }
}
