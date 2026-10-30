import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/games/circuit.dart';
import '../../domain/games/four_in_a_row.dart';
import '../../domain/games/game_content.dart';
import '../../domain/games/games.dart';
import '../../domain/games/maze.dart';
import '../../domain/games/number_pop.dart';
import '../../domain/games/parade.dart';
import '../../domain/games/robot.dart';
import '../../domain/games/sort_it.dart';
import '../../domain/games/sound_game.dart';
import '../../domain/games/sudoku.dart';
import '../../domain/games/words.dart';
import '../../domain/voice/buddy_voice.dart';

enum GameSaveStatus { notSaved, saved, failed }

/// Shared by every game: Buddy's voice, the finish, saving the best stars.
/// Nothing is timed, and the microphone is never used.
abstract class GamePlayViewModel extends ChangeNotifier {
  GamePlayViewModel({
    required BuddyVoice voice,
    required ProgressRepository progressRepository,
  }) : _voice = voice,
       _progress = progressRepository {
    _voice.addListener(notify);
  }

  final BuddyVoice _voice;
  final ProgressRepository _progress;
  bool _disposed = false;

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  GameSaveStatus get saveStatus => _saveStatus;
  GameSaveStatus _saveStatus = GameSaveStatus.notSaved;

  /// Whether the round is over.
  bool get isFinished => _finished;
  bool _finished = false;

  /// Stars earned this round (once finished).
  int get stars => _stars;
  int _stars = 0;

  /// The key the best stars are saved under.
  String get gameId;

  /// The game's name, for the top of the screen.
  String get gameTitle;

  /// How to play, read when the game opens.
  String get introLine;

  void narrateIntro() => say(introLine);

  /// The encouraging line for the finish screen.
  String get finishLine => switch (_stars) {
    3 => 'Amazing! Three stars!',
    2 => 'Great job! Two stars!',
    1 => 'Well done! You earned a star!',
    _ => 'Good try! Have another go.',
  };

  /// Start the same level again.
  void playAgain() {
    _finished = false;
    _stars = 0;
    _saveStatus = GameSaveStatus.notSaved;
    reset();
    notify();
    narrateIntro();
  }

  @protected
  void reset();

  @protected
  Future<void> finish(int stars) async {
    _finished = true;
    _stars = stars;
    notify();
    say(finishLine, lead: stars > 0 ? SoundEffect.cheer : null);
    try {
      final saved = await _progress.load();
      await _progress.save(saved.withGameResult(gameId, stars));
      _saveStatus = GameSaveStatus.saved;
    } on Exception {
      // The child still sees the result; it just could not be kept.
      _saveStatus = GameSaveStatus.failed;
    }
    notify();
  }

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  @protected
  void sound(SoundEffect effect) => unawaited(_voice.effect(effect));

  @protected
  void say(String text, {SoundEffect? lead}) {
    final first = _lastSpoken == null;
    _lastSpoken = text;
    // Enables "Hear again" even when nothing is read aloud automatically.
    if (first) notify();
    _sayNow(text, lead: lead);
  }

  void _sayNow(String text, {bool requested = false, SoundEffect? lead}) {
    if (_disposed) return;
    unawaited(_voice.say(text, requested: requested, lead: lead));
  }

  /// Whether a grown-up has left sounds on.
  bool get soundsOn => _voice.soundsOn;

  @protected
  void clip(String name) => unawaited(_voice.clip(name));

  @protected
  void stopClip() => unawaited(_voice.stopClip());

  @protected
  bool get isDisposed => _disposed;

  @protected
  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(notify);
    // Leaving a game always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}

/// A game with levels in the Arena.
abstract class ArenaViewModel extends GamePlayViewModel {
  ArenaViewModel({
    required this.level,
    required super.voice,
    required super.progressRepository,
  });

  final GameLevel level;

  @override
  String get gameId => level.id;

  @override
  String get gameTitle {
    final title = level.kind.title;
    final ended = title.endsWith('?') || title.endsWith('!');
    return '${ended ? title : '$title:'} ${level.name}';
  }
}

class MemoryViewModel extends ArenaViewModel {
  MemoryViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _deal();
  }

  final Random _random;

  MemoryGame get game => _game;
  late MemoryGame _game;

  @override
  String get introLine =>
      'Flip two cards to find a pair. Take your time, there is no clock.';

  void _deal() {
    _game = MemoryGame(
      pairs: MemoryGame.pairsFor(level.number),
      random: _random,
    );
  }

  void flip(int index) {
    if (isFinished) return;
    final result = _game.flip(index);
    switch (result) {
      case FlipResult.ignored:
        return;
      case FlipResult.first:
      case FlipResult.mismatch:
        sound(SoundEffect.pop);
      case FlipResult.pair:
        sound(SoundEffect.correct);
      case FlipResult.won:
        unawaited(finish(_game.stars));
    }
    notify();
  }

  @override
  void reset() => _deal();
}

class PatternViewModel extends ArenaViewModel {
  PatternViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    List<PatternRound>? rounds,
  }) : rounds = rounds ?? patternLevels[level.number]!;

  final List<PatternRound> rounds;

  int get index => _index;
  int _index = 0;
  PatternRound get round => rounds[_index];
  int get total => rounds.length;

  /// The child's pick for this round, once made.
  GameToken? get picked => _picked;
  GameToken? _picked;
  bool get pickedRight => _picked == round.answer;

  int get rightCount => _right;
  int _right = 0;

  @override
  String get introLine => 'Look at the pattern. What comes next?';

  void pick(GameToken option) {
    if (isFinished || _picked != null) return;
    if (!round.options.contains(option)) return;
    _picked = option;
    if (pickedRight) _right++;
    notify();
    say(
      pickedRight
          ? "That's right! ${round.explanation}"
          : 'Not quite. The answer is ${round.answer.label}. '
                '${round.explanation}',
      lead: pickedRight ? SoundEffect.correct : SoundEffect.gentle,
    );
  }

  Future<void> next() async {
    if (_picked == null || isFinished) return;
    if (_index + 1 < rounds.length) {
      _index++;
      _picked = null;
      notify();
      return;
    }
    await finish(_starsFor(_right, rounds.length));
  }

  /// 3 right is one star, 4 is two, all 5 is three.
  static int _starsFor(int right, int total) {
    if (right >= total) return 3;
    if (right >= total - 1) return 2;
    if (right >= total - 2) return 1;
    return 0;
  }

  @override
  void reset() {
    _index = 0;
    _right = 0;
    _picked = null;
  }
}

class MazeViewModel extends ArenaViewModel {
  MazeViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _build();
  }

  final Random _random;

  MazeGame get game => _game;
  late MazeGame _game;

  @override
  String get introLine =>
      'Tap the arrows or swipe to run. Collect the gems and find the '
      'treasure.';

  void _build() {
    final (size, gems) = MazeGame.sizeFor(level.number);
    _game = MazeGame(size: size, gems: gems, random: _random);
  }

  void go(MazeDirection direction) {
    if (isFinished) return;
    switch (_game.go(direction)) {
      case MazeMove.ignored:
        return;
      case MazeMove.blocked:
        sound(SoundEffect.gentle);
        return;
      case MazeMove.moved:
        sound(SoundEffect.pop);
      case MazeMove.gem:
        sound(SoundEffect.correct);
      case MazeMove.won:
        unawaited(finish(_game.stars));
    }
    notify();
  }

  @override
  void reset() => _build();
}

class RobotViewModel extends ArenaViewModel {
  RobotViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
    this.stepTime = const Duration(milliseconds: 380),
  }) : _random = random ?? Random() {
    _game = RobotGame(level: level.number, random: _random);
    _cell = _game.puzzle.start;
  }

  final Random _random;

  /// How long the robot takes over each move.
  final Duration stepTime;

  RobotGame get game => _game;
  late RobotGame _game;

  /// Where the robot is now.
  int get cell => _cell;
  late int _cell;

  /// The line of code running now.
  int? get activeLine => _activeLine;
  int? _activeLine;

  bool get isRunning => _running;
  bool _running = false;

  /// How the last run ended, until the code changes.
  RobotEnding? get ending => _ending;
  RobotEnding? _ending;

  bool get isSolved => _ending == RobotEnding.goal;
  bool get canEdit => !_running && !isSolved && !isFinished;

  @override
  String get introLine =>
      'Tap the arrows to write your code, then press Go to get the robot '
      'to the flag.';

  static String noteFor(RobotEnding ending) => switch (ending) {
    RobotEnding.goal => 'Your code works! The robot reached the flag.',
    RobotEnding.rock => 'The robot bumped into a rock. Fix your code!',
    RobotEnding.edge => 'The robot reached the edge. Fix your code!',
    RobotEnding.short => 'The robot stopped before the flag. Add more steps!',
  };

  void _edit(bool Function() change) {
    if (!canEdit || !change()) return;
    _ending = null;
    _cell = _game.puzzle.start;
    sound(SoundEffect.pop);
    notify();
  }

  void add(MazeDirection direction) => _edit(() => _game.add(direction));

  void toggleRepeat() => _edit(_game.toggleRepeat);

  void undo() => _edit(() {
    final had = _game.code.isNotEmpty;
    _game.undo();
    return had;
  });

  void clear() => _edit(() {
    final had = _game.code.isNotEmpty;
    _game.clear();
    return had;
  });

  /// Runs the code one move at a time, so the child can follow it.
  Future<void> run() async {
    if (!canEdit || _game.code.isEmpty) return;
    _running = true;
    _ending = null;
    _cell = _game.puzzle.start;
    notify();
    final trace = _game.run();
    for (final (i, cell) in trace.cells.indexed) {
      _cell = cell;
      _activeLine = trace.stepOfCell[i];
      notify();
      await Future<void>.delayed(stepTime);
      if (isDisposed) return;
    }
    _running = false;
    _activeLine = null;
    _ending = trace.ending;
    notify();
    say(
      noteFor(trace.ending),
      lead: isSolved ? SoundEffect.correct : SoundEffect.gentle,
    );
  }

  /// The next puzzle, or the finish after the last one.
  Future<void> next() async {
    if (!isSolved) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    _ending = null;
    _cell = _game.puzzle.start;
    notify();
  }

  @override
  void reset() {
    _game = RobotGame(level: level.number, random: _random);
    _cell = _game.puzzle.start;
    _ending = null;
    _activeLine = null;
    _running = false;
  }
}

class WordViewModel extends ArenaViewModel {
  WordViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = WordGame(level: level.number, random: _random);
  }

  final Random _random;

  WordGame get game => _game;
  late WordGame _game;

  static const wrongNote = 'Not quite. Tap a letter to move it.';

  @override
  String get introLine => 'Here is your first clue. ${_game.puzzle.clue}';

  void tapTile(int tile) {
    if (isFinished || !_game.place(tile)) return;
    _afterChange();
  }

  void tapSlot(int slot) {
    if (isFinished || !_game.remove(slot)) return;
    sound(SoundEffect.pop);
    notify();
  }

  void hint() {
    if (isFinished || !_game.hint()) return;
    _afterChange();
  }

  void _afterChange() {
    notify();
    if (_game.isSolved) {
      say(
        'Yes! ${_game.puzzle.word.toLowerCase()}.',
        lead: SoundEffect.correct,
      );
    } else if (_game.isWrong) {
      say(wrongNote, lead: SoundEffect.gentle);
    } else {
      sound(SoundEffect.pop);
    }
  }

  /// The next word, or the finish after the last one.
  Future<void> next() async {
    if (!_game.isSolved) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    notify();
    say(_game.puzzle.clue);
  }

  @override
  void reset() => _game = WordGame(level: level.number, random: _random);
}

class SoundViewModel extends ArenaViewModel {
  SoundViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = SoundQuiz(level: level.number, random: _random);
  }

  final Random _random;

  SoundQuiz get game => _game;
  late SoundQuiz _game;

  /// Whether the written clue is showing. It always shows when sounds are off,
  /// so the game can still be played.
  bool get isClueShowing => _clueAsked || !soundsOn;
  bool _clueAsked = false;

  /// The last wrong pick, to explain it on the screen.
  GameSound? get lastWrong => _lastWrong;
  GameSound? _lastWrong;

  @override
  String get introLine => 'Tap Play sound and listen closely.';

  void playSound() {
    if (isFinished || _game.isSolved) return;
    clip(_game.sound.name);
  }

  void showClue() {
    if (_clueAsked) return;
    _clueAsked = true;
    notify();
    say(_game.sound.clue);
  }

  void pick(GameSound choice) {
    if (isFinished) return;
    switch (_game.pick(choice)) {
      case SoundPick.ignored:
        return;
      case SoundPick.wrong:
        _lastWrong = choice;
        _clueAsked = true;
        stopClip();
        notify();
        say(
          "It's not ${choice.title}. ${_game.sound.clue}",
          lead: SoundEffect.gentle,
        );
      case SoundPick.right:
        _lastWrong = null;
        stopClip();
        notify();
        say("That's right! ${_game.sound.fact}", lead: SoundEffect.correct);
    }
  }

  /// The next sound, or the finish after the last one.
  Future<void> next() async {
    if (!_game.isSolved) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    _clueAsked = false;
    notify();
  }

  @override
  void reset() {
    _game = SoundQuiz(level: level.number, random: _random);
    _clueAsked = false;
    _lastWrong = null;
  }

  @override
  void dispose() {
    stopClip();
    super.dispose();
  }
}

class FourViewModel extends ArenaViewModel {
  FourViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
    this.buddyDelay = const Duration(milliseconds: 650),
  }) : _random = random ?? Random() {
    _game = FourGame(level: level.number, random: _random);
  }

  final Random _random;

  /// How long Buddy seems to think, so the child can see each move.
  final Duration buddyDelay;

  FourGame get game => _game;
  late FourGame _game;

  bool get isBuddyThinking => _thinking;
  bool _thinking = false;

  @override
  String get introLine => 'Tap a column to drop your counter. You go first!';

  @override
  String get finishLine => switch (_game.result) {
    FourResult.childWon => 'You beat Buddy! Three stars!',
    FourResult.draw => "It's a draw! Two stars!",
    _ => 'Buddy won this one. Here is a star for playing!',
  };

  Future<void> drop(int column) async {
    if (isFinished || _thinking || !_game.play(column)) return;
    sound(SoundEffect.pop);
    if (_game.isOver) {
      notify();
      await finish(_game.stars);
      return;
    }
    _thinking = true;
    notify();
    final playing = _game;
    await Future<void>.delayed(buddyDelay);
    if (isDisposed || !identical(playing, _game)) return;
    _game.buddyPlays();
    _thinking = false;
    sound(SoundEffect.pop);
    notify();
    if (_game.isOver) await finish(_game.stars);
  }

  @override
  void reset() {
    _game = FourGame(level: level.number, random: _random);
    _thinking = false;
  }
}

class NumberViewModel extends ArenaViewModel {
  NumberViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = NumberPopGame(level: level.number, random: _random);
  }

  final Random _random;

  NumberPopGame get game => _game;
  late NumberPopGame _game;

  @override
  String get introLine => 'Pop every bubble that makes ${_game.target}.';

  void tap(int index) {
    if (isFinished) return;
    switch (_game.tap(index)) {
      case PopResult.ignored:
        return;
      case PopResult.wrong:
        sound(SoundEffect.gentle);
      case PopResult.popped:
        sound(SoundEffect.pop);
      case PopResult.cleared:
        say(introLine, lead: SoundEffect.correct);
      case PopResult.won:
        unawaited(finish(_game.stars));
    }
    notify();
  }

  @override
  void reset() => _game = NumberPopGame(level: level.number, random: _random);
}

class SortViewModel extends ArenaViewModel {
  SortViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = SortGame(level: level.number, random: _random);
  }

  final Random _random;

  SortGame get game => _game;
  late SortGame _game;

  /// Whether the last pick was the wrong group.
  bool get wasWrong => _wrong;
  bool _wrong = false;

  @override
  String get introLine => _game.set.question;

  void pick(int group) {
    if (isFinished) return;
    switch (_game.pick(group)) {
      case SortResult.ignored:
        return;
      case SortResult.wrong:
        _wrong = true;
        sound(SoundEffect.gentle);
      case SortResult.right:
        _wrong = false;
        final note = _game.lastSorted?.note;
        if (note == null) {
          sound(SoundEffect.correct);
        } else {
          say(note, lead: SoundEffect.correct);
        }
      case SortResult.won:
        _wrong = false;
        unawaited(finish(_game.stars));
    }
    notify();
  }

  @override
  void reset() {
    _game = SortGame(level: level.number, random: _random);
    _wrong = false;
  }
}

class CircuitViewModel extends ArenaViewModel {
  CircuitViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = CircuitGame(level: level.number, random: _random);
  }

  final Random _random;

  CircuitGame get game => _game;
  late CircuitGame _game;

  @override
  String get introLine => 'Tap the wires to turn them, and light the bulb.';

  void tap(int cell) {
    if (isFinished) return;
    switch (_game.tap(cell)) {
      case CircuitResult.ignored:
        return;
      case CircuitResult.turned:
        sound(SoundEffect.pop);
      case CircuitResult.lit:
        say('The bulb is on! ${_game.fact}', lead: SoundEffect.correct);
    }
    notify();
  }

  /// The next circuit, or the finish after the last one.
  Future<void> next() async {
    if (!_game.puzzle.isLit) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    notify();
  }

  @override
  void reset() => _game = CircuitGame(level: level.number, random: _random);
}

class SudokuViewModel extends ArenaViewModel {
  SudokuViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _start();
  }

  final Random _random;

  SudokuGame get game => _game;
  late SudokuGame _game;

  /// The square the next picture goes in.
  int? get selected => _selected;
  int? _selected;

  /// Why the last picture didn't fit.
  SudokuClash? get lastClash => _lastClash;
  SudokuClash? _lastClash;

  @override
  String get introLine =>
      'Tap a square, then a picture. No picture can repeat.';

  void _start() {
    _game = SudokuGame(level: level.number, random: _random);
    _selected = _game.puzzle.firstEmpty;
    _lastClash = null;
  }

  void select(int cell) {
    if (isFinished || _game.puzzle.board[cell] != null) return;
    _selected = cell;
    _lastClash = null;
    sound(SoundEffect.pop);
    notify();
  }

  void place(int value) {
    final cell = _selected;
    if (isFinished || cell == null) return;
    final clash = _game.puzzle.clashAt(cell, value);
    switch (_game.place(cell, value)) {
      case SudokuMove.ignored:
        return;
      case SudokuMove.clash:
        _lastClash = clash;
        sound(SoundEffect.gentle);
      case SudokuMove.placed:
        _lastClash = null;
        _selected = _nextEmpty(cell);
        sound(SoundEffect.correct);
      case SudokuMove.solved:
        _lastClash = null;
        _selected = null;
        say('You solved it!', lead: SoundEffect.correct);
    }
    notify();
  }

  /// The next empty square after [cell], wrapping round the grid.
  int? _nextEmpty(int cell) {
    final board = _game.puzzle.board;
    for (var step = 1; step < board.length; step++) {
      final next = (cell + step) % board.length;
      if (board[next] == null) return next;
    }
    return null;
  }

  /// The next puzzle, or the finish after the last one.
  Future<void> next() async {
    if (!_game.puzzle.isSolved) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    _selected = _game.puzzle.firstEmpty;
    notify();
  }

  @override
  void reset() => _start();
}

class ParadeViewModel extends ArenaViewModel {
  ParadeViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _game = ParadeGame(level: level.number, random: _random);
  }

  final Random _random;

  ParadeGame get game => _game;
  late ParadeGame _game;

  @override
  String get introLine => _game.set.question;

  void tap(String item) {
    if (isFinished) return;
    switch (_game.tap(item)) {
      case ParadeTap.ignored:
        return;
      case ParadeTap.wrong:
        sound(SoundEffect.gentle);
      case ParadeTap.right:
        sound(SoundEffect.correct);
      case ParadeTap.finished:
        say('You did it! ${_game.set.fact}', lead: SoundEffect.correct);
    }
    notify();
  }

  /// The next set, or the finish after the last one.
  Future<void> next() async {
    if (!_game.isFinished) return;
    if (!_game.nextRound()) {
      await finish(_game.stars);
      return;
    }
    notify();
    say(_game.set.question);
  }

  @override
  void reset() => _game = ParadeGame(level: level.number, random: _random);
}

class SpotViewModel extends ArenaViewModel {
  SpotViewModel({
    required super.level,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _setUp();
  }

  final Random _random;

  SpotGame get game => _game;
  late SpotGame _game;

  /// The last wrong tap, to show it briefly with a note.
  int? get lastMiss => _lastMiss;
  int? _lastMiss;

  @override
  String get introLine =>
      'Look at both pictures. Tap everything that changed in the second one.';

  void _setUp() {
    final (rows, columns, changes) = SpotGame.sizeFor(level.number);
    _game = SpotGame(
      rows: rows,
      columns: columns,
      changes: changes,
      random: _random,
    );
    _lastMiss = null;
  }

  void tap(int index) {
    if (isFinished) return;
    switch (_game.tap(index)) {
      case SpotResult.ignored:
        return;
      case SpotResult.miss:
        _lastMiss = index;
        sound(SoundEffect.gentle);
      case SpotResult.found:
        _lastMiss = null;
        sound(SoundEffect.correct);
      case SpotResult.won:
        _lastMiss = null;
        unawaited(finish(_game.stars));
    }
    notify();
  }

  @override
  void reset() => _setUp();
}
