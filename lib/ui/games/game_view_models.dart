import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/games/game_content.dart';
import '../../domain/games/games.dart';
import '../../domain/voice/buddy_voice.dart';

enum GameSaveStatus { notSaved, saved, failed }

/// Shared by every Arena game: Buddy's voice, the finish, saving the best
/// stars. Nothing is timed, and the microphone is never used.
abstract class GamePlayViewModel extends ChangeNotifier {
  GamePlayViewModel({
    required this.level,
    required BuddyVoice voice,
    required ProgressRepository progressRepository,
  }) : _voice = voice,
       _progress = progressRepository {
    _voice.addListener(notify);
  }

  final GameLevel level;
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
      await _progress.save(saved.withGameResult(level.id, stars));
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

class MemoryViewModel extends GamePlayViewModel {
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

class PatternViewModel extends GamePlayViewModel {
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

class SpotViewModel extends GamePlayViewModel {
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
