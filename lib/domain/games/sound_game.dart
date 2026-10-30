import 'dart:math';

/// What's That Sound?: listen to a real recording and work out what made it.
/// Pure logic: no Flutter, no storage. Nothing is timed. Every sound has a
/// written clue, so a child who can't hear it can still play.

enum GameSound {
  rooster(
    'Rooster',
    'A farm bird that calls loudly in the morning.',
    'Roosters often crow at sunrise, but they can crow at any time of day.',
  ),
  cow(
    'Cow',
    'A big farm animal that gives milk.',
    "A cow's stomach has four parts.",
  ),
  sheep(
    'Sheep',
    'A woolly farm animal.',
    'Most sheep need a haircut once a year. It is called shearing.',
  ),
  dog(
    'Dog',
    'A pet that wags its tail.',
    "A dog's nose can smell far better than yours.",
  ),
  cat(
    'Cat',
    'A pet with whiskers that purrs.',
    'Cats use their whiskers to feel the space around them.',
  ),
  frog(
    'Frogs',
    'They live near ponds and start life as tadpoles.',
    'Male frogs sing to attract a mate.',
  ),
  bee(
    'Bumblebee',
    'A fuzzy insect that visits flowers.',
    "A bumblebee's buzz comes from its wings beating very fast.",
  ),
  thunder(
    'Thunder',
    'A loud boom during a storm.',
    'Lightning heats the air so quickly that it makes this boom.',
  ),
  rain(
    'Rain',
    'Water falling from the clouds.',
    'Rain is water that rose into the sky, then fell back down.',
  ),
  sea(
    'Sea waves',
    'Water rolling onto a beach.',
    'Most waves are made by the wind blowing across the water.',
  ),
  train(
    'Steam train',
    'A long vehicle that runs on rails.',
    'Steam trains burn fuel to boil water, and the steam pushes them along.',
  ),
  helicopter(
    'Helicopter',
    'It flies using spinning blades on top.',
    'Helicopters can hover in one place and fly straight up.',
  ),
  clock(
    'Clock',
    'It tells you the time.',
    'A mechanical clock ticks as its gears move one small step at a time.',
  );

  const GameSound(this.title, this.clue, this.fact);

  final String title;

  /// Describes what made the sound, without naming it.
  final String clue;
  final String fact;
}

enum SoundPick { ignored, wrong, right }

/// The sounds of one level, one at a time.
class SoundQuiz {
  SoundQuiz({required this.level, required Random random}) : _random = random {
    _sounds = [...levels[level]!]..shuffle(_random);
    _deal();
  }

  static const levels = {
    1: [
      GameSound.rooster,
      GameSound.cow,
      GameSound.sheep,
      GameSound.dog,
      GameSound.cat,
    ],
    2: [
      GameSound.frog,
      GameSound.bee,
      GameSound.thunder,
      GameSound.rain,
      GameSound.sea,
    ],
    3: [
      GameSound.train,
      GameSound.helicopter,
      GameSound.clock,
      GameSound.bee,
      GameSound.sea,
    ],
  };

  static const optionCount = 3;

  final int level;
  final Random _random;
  late final List<GameSound> _sounds;

  int get rounds => _sounds.length;

  int get round => _round;
  int _round = 0;

  GameSound get sound => _sounds[_round];

  /// The answers on offer.
  List<GameSound> get options => _options;
  List<GameSound> _options = const [];

  /// Picks already tried, which stay visible but can't be picked again.
  final Set<GameSound> wrongPicks = {};

  bool get isSolved => _solved;
  bool _solved = false;

  int get mistakes => _mistakes;
  int _mistakes = 0;

  /// Fewer wrong picks earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 2) return 2;
    return 1;
  }

  SoundPick pick(GameSound choice) {
    if (_solved || !_options.contains(choice) || wrongPicks.contains(choice)) {
      return SoundPick.ignored;
    }
    if (choice != sound) {
      wrongPicks.add(choice);
      _mistakes++;
      return SoundPick.wrong;
    }
    _solved = true;
    return SoundPick.right;
  }

  /// Moves on. Returns false when there are no more sounds.
  bool nextRound() {
    if (_round + 1 >= rounds) return false;
    _round++;
    _deal();
    return true;
  }

  void _deal() {
    // The top level mixes in every sound, for trickier choices.
    final pool = level == 3 ? GameSound.values : levels[level]!;
    final others = [...pool]
      ..remove(sound)
      ..shuffle(_random);
    _options = [sound, ...others.take(optionCount - 1)]..shuffle(_random);
    wrongPicks.clear();
    _solved = false;
  }
}

/// Checks that the content is fair; returns problems, empty when valid.
List<String> soundProblems() {
  final issues = <String>[];
  for (final sound in GameSound.values) {
    final word = sound.title.split(' ').first.toLowerCase();
    if (sound.clue.toLowerCase().contains(word)) {
      issues.add('${sound.title}: the clue gives it away');
    }
    if (sound.clue.trim().isEmpty) issues.add('${sound.title}: no clue');
    if (sound.fact.trim().isEmpty) issues.add('${sound.title}: no fact');
  }
  final used = SoundQuiz.levels.values.expand((level) => level).toSet();
  for (final sound in GameSound.values) {
    if (!used.contains(sound)) issues.add('${sound.title}: never used');
  }
  return issues;
}
