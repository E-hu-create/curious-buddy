import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/missions/mission.dart';
import '../../domain/missions/mission_rules.dart';
import '../../domain/voice/buddy_voice.dart';

enum MissionPhase { intro, stage, complete }

enum SaveStatus { notSaved, saving, saved, failed }

/// Everything a child has done on one stage.
class _StageState {
  final Set<String> inspected = {};
  int hintsShown = 0;
  int attempts = 0;
  bool solved = false;
  bool firstTry = false;

  StageResult toResult() => StageResult(
    solved: solved,
    firstTry: firstTry,
    cluesInspected: inspected.length,
    hintsUsed: hintsShown,
  );
}

/// One play-through of a mission. Buddy narrates through the shared
/// [BuddyVoice] (so speech never overlaps), and nothing is ever spoken
/// that is not also on screen. The microphone is never used here.
class MissionPlayViewModel extends ChangeNotifier {
  MissionPlayViewModel({
    required this.mission,
    required BuddyVoice voice,
    required ProgressRepository progressRepository,
  }) : _voice = voice,
       _progressRepository = progressRepository {
    _voice.addListener(_notify);
    _reset();
  }

  final Mission mission;
  final BuddyVoice _voice;
  final ProgressRepository _progressRepository;
  bool _disposed = false;

  MissionPhase get phase => _phase;
  late MissionPhase _phase;

  int get stageIndex => _stageIndex;
  late int _stageIndex;
  MissionStage get stage => mission.stages[_stageIndex];
  int get stageCount => mission.stages.length;

  late List<_StageState> _stages;
  _StageState get _current => _stages[_stageIndex];

  // ------------------------------------------------------------ selections

  String? get selectedChoice => _selectedChoice;
  String? _selectedChoice;

  Set<String> get selectedChoices => Set.unmodifiable(_selectedChoices);
  final Set<String> _selectedChoices = {};

  /// Pieces placed so far, in the child's order.
  List<OrderPiece> get placedPieces => List.unmodifiable(_placed);
  final List<OrderPiece> _placed = [];

  /// Pieces still to place, in a fixed shuffled order.
  List<OrderPiece> get remainingPieces {
    final stage = this.stage;
    if (stage is! OrderStage) return const [];
    return [
      for (final piece in shuffled(stage.pieces))
        if (!_placed.contains(piece)) piece,
    ];
  }

  // -------------------------------------------------------------- feedback

  CheckResult? get feedback => _feedback;
  CheckResult? _feedback;

  bool get isSolved => _current.solved;
  Set<String> get inspectedClues => Set.unmodifiable(_current.inspected);
  int get hintsShown => _current.hintsShown;
  bool get hasMoreHints => _current.hintsShown < stage.hints.length;
  List<String> get visibleHints => stage.hints.take(hintsShown).toList();

  bool get canCheck {
    if (_current.solved) return false;
    return switch (stage) {
      ChoiceStage() => _selectedChoice != null,
      MultiSelectStage() => _selectedChoices.isNotEmpty,
      OrderStage(:final pieces) => _placed.length == pieces.length,
    };
  }

  bool get isLastStage => _stageIndex == stageCount - 1;

  // ---------------------------------------------------------------- voice

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  // ------------------------------------------------------------- results

  MissionScore? get score => _score;
  MissionScore? _score;

  SaveStatus get saveStatus => _saveStatus;
  SaveStatus _saveStatus = SaveStatus.notSaved;

  int get maxPoints => MissionScore.maxFor(mission);

  // -------------------------------------------------------------- actions

  /// Buddy reads the opening scene. Called when the mission opens.
  void narrateIntro() => _say('${mission.intro} ${mission.objective}');

  void start() {
    _phase = MissionPhase.stage;
    _stageIndex = 0;
    _clearSelection();
    _notify();
    _say(stage.prompt);
  }

  void inspectClue(String clueId) {
    if (!stage.clues.any((c) => c.id == clueId)) return;
    if (_current.inspected.add(clueId)) _notify();
  }

  /// Read one clue aloud (only once inspected).
  void readClue(String clueId) {
    if (!_current.inspected.contains(clueId)) return;
    final clue = stage.clues.firstWhere((c) => c.id == clueId);
    _say('${clue.title}. ${clue.text}', requested: true);
  }

  void readPrompt() => _say(stage.prompt, requested: true);

  void pickChoice(String choiceId) {
    if (_current.solved) return;
    _selectedChoice = choiceId;
    _feedback = null;
    _notify();
  }

  void toggleChoice(String choiceId) {
    if (_current.solved) return;
    if (!_selectedChoices.remove(choiceId)) _selectedChoices.add(choiceId);
    _feedback = null;
    _notify();
  }

  void placePiece(String pieceId) {
    final stage = this.stage;
    if (_current.solved || stage is! OrderStage) return;
    final piece = stage.pieces.firstWhere((p) => p.id == pieceId);
    if (_placed.contains(piece)) return;
    _placed.add(piece);
    _feedback = null;
    _notify();
  }

  void removePlacedPiece(String pieceId) {
    if (_current.solved) return;
    _placed.removeWhere((p) => p.id == pieceId);
    _feedback = null;
    _notify();
  }

  void clearOrder() {
    if (_current.solved) return;
    _placed.clear();
    _feedback = null;
    _notify();
  }

  void showHint() {
    if (!hasMoreHints) return;
    _current.hintsShown++;
    _notify();
    _say('Hint. ${stage.hints[_current.hintsShown - 1]}');
  }

  void check() {
    if (!canCheck) return;
    final result = StageEvaluator.check(stage, _answer());
    _current.attempts++;
    _feedback = result;
    if (result.correct) {
      _current.solved = true;
      _current.firstTry = _current.attempts == 1;
      final explanation = stage is ChoiceStage ? ' ${stage.explanation}' : '';
      _say('${result.feedback}$explanation', lead: SoundEffect.correct);
    } else {
      // Let the child try a different single answer; keep multi/order work.
      if (stage is ChoiceStage) _selectedChoice = null;
      final nudge = _current.inspected.length < stage.clues.length
          ? ' Have you inspected every clue?'
          : '';
      _say('${result.feedback}$nudge', lead: SoundEffect.gentle);
    }
    _notify();
  }

  Future<void> next() async {
    if (!_current.solved) return;
    if (!isLastStage) {
      _stageIndex++;
      _clearSelection();
      _notify();
      _say(stage.prompt);
      return;
    }
    _score = MissionScore.from([for (final s in _stages) s.toResult()]);
    _phase = MissionPhase.complete;
    _notify();
    _say(
      'Case solved! ${mission.solution} You earned ${_score!.total} points '
      'and the ${mission.badge} badge!',
      lead: SoundEffect.cheer,
    );
    await _save(_score!.total);
  }

  /// Start the same mission again from the beginning.
  void replay() {
    _reset();
    _notify();
    narrateIntro();
  }

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  // ------------------------------------------------------------ internals

  StageAnswer _answer() => switch (stage) {
    ChoiceStage() => PickedChoice(_selectedChoice!),
    MultiSelectStage() => PickedChoices(Set.of(_selectedChoices)),
    OrderStage() => OrderedPieces([for (final p in _placed) p.id]),
  };

  Future<void> _save(int points) async {
    _saveStatus = SaveStatus.saving;
    _notify();
    try {
      final progress = await _progressRepository.load();
      await _progressRepository.save(
        progress.withMissionResult(mission.id, points),
      );
      _saveStatus = SaveStatus.saved;
    } on Exception {
      // The child still sees the result; we just could not keep it.
      _saveStatus = SaveStatus.failed;
    }
    _notify();
  }

  void _reset() {
    _phase = MissionPhase.intro;
    _stageIndex = 0;
    _stages = [for (final _ in mission.stages) _StageState()];
    _score = null;
    _saveStatus = SaveStatus.notSaved;
    _clearSelection();
  }

  void _clearSelection() {
    _selectedChoice = null;
    _selectedChoices.clear();
    _placed.clear();
    _feedback = null;
  }

  void _say(String text, {bool requested = false, SoundEffect? lead}) {
    final first = _lastSpoken == null;
    _lastSpoken = text;
    // Enables "Hear again" even when nothing is read aloud automatically.
    if (first) _notify();
    _sayNow(text, requested: requested, lead: lead);
  }

  void _sayNow(String text, {bool requested = false, SoundEffect? lead}) {
    if (_disposed) return;
    unawaited(_voice.say(text, requested: requested, lead: lead));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// A stable shuffle that never shows the pieces already in order.
  @visibleForTesting
  static List<OrderPiece> shuffled(List<OrderPiece> pieces) {
    final result = [...pieces]
      ..sort((a, b) => _hash(a.id).compareTo(_hash(b.id)));
    var same = true;
    for (var i = 0; i < pieces.length; i++) {
      if (result[i] != pieces[i]) same = false;
    }
    return same ? pieces.reversed.toList() : result;
  }

  static int _hash(String text) =>
      text.codeUnits.fold(7, (h, c) => (h * 31 + c) & 0x7fffffff);

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(_notify);
    // Leaving a mission always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}
