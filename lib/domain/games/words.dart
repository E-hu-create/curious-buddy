import 'dart:math';

import 'games.dart';

/// Word Builder: unscramble the letters to make a science or nature word.
/// Pure logic: no Flutter, no storage. Nothing is timed, and a wrong spelling
/// only asks the child to move a letter.

class WordPuzzle {
  const WordPuzzle(this.word, this.clue, {this.picture});

  /// Capital letters only.
  final String word;
  final String clue;
  final GamePicture? picture;
}

/// Each level's words. Words that spell another common word when mixed up
/// (EARTH and HEART, for example) are left out, so a real word a child might
/// know is never marked wrong.
const Map<int, List<WordPuzzle>> wordLevels = {
  1: [
    WordPuzzle('FROG', 'It starts life as a tadpole.'),
    WordPuzzle('BIRD', 'An animal covered in feathers.'),
    WordPuzzle(
      'FISH',
      'It breathes underwater using gills.',
      picture: GamePicture.fish,
    ),
    WordPuzzle(
      'TREE',
      'A tall plant with a woody trunk.',
      picture: GamePicture.tree,
    ),
    WordPuzzle('MOON', 'It travels around Earth, and shines in the night sky.'),
    WordPuzzle('SEED', 'A new plant can grow from this.'),
    WordPuzzle('WIND', 'Moving air.'),
    WordPuzzle('TIGER', 'The largest big cat, with a striped coat.'),
    WordPuzzle(
      'WHALE',
      'The largest animal that has ever lived is one of these.',
      picture: GamePicture.whale,
    ),
    WordPuzzle('RIVER', 'Fresh water flowing towards the sea.'),
    WordPuzzle('PLANT', 'It makes its own food using sunlight.'),
  ],
  2: [
    WordPuzzle(
      'PLANET',
      'A huge round world that travels around a star.',
      picture: GamePicture.planet,
    ),
    WordPuzzle(
      'ROCKET',
      'It blasts off into space.',
      picture: GamePicture.rocket,
    ),
    WordPuzzle(
      'TURTLE',
      'A reptile with a hard shell.',
      picture: GamePicture.turtle,
    ),
    WordPuzzle(
      'FLOWER',
      'The colourful part of a plant that helps make seeds.',
      picture: GamePicture.flower,
    ),
    WordPuzzle(
      'VOLCANO',
      'A mountain that can erupt with hot lava.',
      picture: GamePicture.volcano,
    ),
    WordPuzzle('FOSSIL', 'The remains of an ancient living thing in rock.'),
    WordPuzzle('MAGNET', 'It pulls on iron and steel.'),
    WordPuzzle('GRAVITY', 'The force that pulls things towards the ground.'),
    WordPuzzle('OXYGEN', 'The gas in the air that we need to breathe.'),
    WordPuzzle('DOLPHIN', 'A clever sea mammal that breathes air.'),
    WordPuzzle('PENGUIN', 'A bird that cannot fly, but swims very well.'),
    WordPuzzle('CACTUS', 'A desert plant that stores water.'),
  ],
  3: [
    WordPuzzle(
      'BUTTERFLY',
      'It starts life as a caterpillar.',
      picture: GamePicture.butterfly,
    ),
    WordPuzzle(
      'MUSHROOM',
      'A fungus, which is not a plant at all.',
      picture: GamePicture.mushroom,
    ),
    WordPuzzle('ELEPHANT', 'The largest animal living on land.'),
    WordPuzzle('DINOSAUR', 'Its name means "terrible lizard".'),
    WordPuzzle('SKELETON', 'All the bones in your body.'),
    WordPuzzle('ASTRONAUT', 'A person who travels into space.'),
    WordPuzzle('TELESCOPE', 'It makes faraway stars look closer.'),
    WordPuzzle('MICROSCOPE', 'It makes tiny things look much bigger.'),
    WordPuzzle(
      'EARTHQUAKE',
      'When the ground shakes as rocks shift deep below.',
    ),
    WordPuzzle('HURRICANE', 'A huge spinning storm that forms over warm seas.'),
    WordPuzzle('CHAMELEON', 'A lizard that can change its colour.'),
    WordPuzzle('WATERFALL', 'A river dropping over the edge of a cliff.'),
  ],
};

/// The words of one level, and the letters on the board.
class WordGame {
  WordGame({required this.level, required Random random}) : _random = random {
    _puzzles = ([
      ...wordLevels[level]!,
    ]..shuffle(_random)).take(rounds).toList();
    _deal();
  }

  static const rounds = 5;

  final int level;
  final Random _random;
  late final List<WordPuzzle> _puzzles;

  int get round => _round;
  int _round = 0;

  WordPuzzle get puzzle => _puzzles[_round];

  /// The mixed-up letters.
  List<String> get tiles => _tiles;
  List<String> _tiles = const [];

  /// For each space in the word, the tile placed there.
  List<int?> get slots => _slots;
  List<int?> _slots = const [];

  /// Spaces filled in by a hint, which stay put.
  final Set<int> locked = {};

  int get mistakes => _mistakes;
  int _mistakes = 0;

  int get hints => _hints;
  int _hints = 0;

  /// Whether the word on the board is right.
  bool get isSolved => _solved;
  bool _solved = false;

  /// Whether a full word is on the board that isn't right.
  bool get isWrong => _wrong;
  bool _wrong = false;

  bool get isFull => !_slots.contains(null);

  bool isUsed(int tile) => _slots.contains(tile);

  /// Fewer wrong spellings and hints earn more stars. Finishing always earns
  /// at least one.
  int get stars {
    final slips = _mistakes + _hints;
    if (slips == 0) return 3;
    if (slips <= 3) return 2;
    return 1;
  }

  /// Moves a tile to the first empty space.
  bool place(int tile) {
    if (_solved || isUsed(tile) || isFull) return false;
    _slots[_slots.indexOf(null)] = tile;
    _check();
    return true;
  }

  /// Sends the letter in a space back to the tiles.
  bool remove(int slot) {
    if (_solved || locked.contains(slot) || _slots[slot] == null) return false;
    _slots[slot] = null;
    _wrong = false;
    return true;
  }

  /// Fills in the next letter that isn't right yet.
  bool hint() {
    if (_solved) return false;
    final word = puzzle.word;
    for (var slot = 0; slot < word.length; slot++) {
      if (locked.contains(slot)) continue;
      final placed = _slots[slot];
      if (placed != null && _tiles[placed] == word[slot]) {
        locked.add(slot);
        continue;
      }
      _slots[slot] = null;
      final tile = _freeTile(word[slot]);
      final other = _slots.indexOf(tile);
      if (other >= 0) _slots[other] = null;
      _slots[slot] = tile;
      locked.add(slot);
      _hints++;
      _wrong = false;
      _check(countMistake: false);
      return true;
    }
    return false;
  }

  /// A tile with [letter] that isn't locked, preferring one not in use.
  int _freeTile(String letter) {
    final options = [
      for (var i = 0; i < _tiles.length; i++)
        if (_tiles[i] == letter && !locked.any((slot) => _slots[slot] == i)) i,
    ];
    return options.firstWhere((i) => !isUsed(i), orElse: () => options.first);
  }

  /// Moves on. Returns false when there are no more words.
  bool nextRound() {
    if (_round + 1 >= _puzzles.length) return false;
    _round++;
    _deal();
    return true;
  }

  void _check({bool countMistake = true}) {
    if (!isFull) return;
    final spelled = _slots.map((tile) => _tiles[tile!]).join();
    if (spelled == puzzle.word) {
      _solved = true;
    } else if (countMistake) {
      _wrong = true;
      _mistakes++;
    } else {
      _wrong = true;
    }
  }

  void _deal() {
    final word = puzzle.word;
    final letters = word.split('');
    do {
      letters.shuffle(_random);
    } while (letters.join() == word);
    _tiles = letters;
    _slots = List<int?>.filled(word.length, null);
    locked.clear();
    _solved = false;
    _wrong = false;
  }
}

/// Checks that the words are fair; returns problems, empty when valid.
List<String> wordProblems() {
  final issues = <String>[];
  final seen = <String>{};
  for (final MapEntry(key: level, value: words) in wordLevels.entries) {
    if (words.length < WordGame.rounds) issues.add('level $level: too few');
    for (final puzzle in words) {
      final word = puzzle.word;
      if (!RegExp(r'^[A-Z]+$').hasMatch(word)) issues.add('$word: bad letters');
      if (!seen.add(word)) issues.add('$word: repeated');
      if (puzzle.clue.trim().isEmpty) issues.add('$word: no clue');
      if (puzzle.clue.toUpperCase().contains(word)) {
        issues.add('$word: the clue gives it away');
      }
      if (word.split('').toSet().length < 2) issues.add('$word: can\'t mix');
    }
  }
  return issues;
}
