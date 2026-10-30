import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/quiz/quiz.dart';
import '../../domain/quiz/quiz_rules.dart';
import '../../domain/voice/buddy_voice.dart';

enum QuizPhase { question, summary }

enum QuizSaveStatus { notSaved, saving, saved, failed }

/// One question's outcome, for the summary.
class QuizAnswerRecord {
  const QuizAnswerRecord({required this.question, required this.pickedId});

  final QuizQuestion question;
  final String pickedId;

  bool get correct => pickedId == question.answerId;
  QuizOption get picked => question.optionById(pickedId)!;
}

/// One round of a quiz level: each question answered once, with feedback
/// and an explanation, then a summary. Buddy narrates through the shared
/// [BuddyVoice]; everything spoken is also on screen. The microphone is
/// never used here.
class QuizPlayViewModel extends ChangeNotifier {
  QuizPlayViewModel({
    required this.topic,
    required this.level,
    required BuddyVoice voice,
    required ProgressRepository progressRepository,
    Map<String, int> best = const {},
    Random? random,
  }) : _voice = voice,
       _progressRepository = progressRepository,
       _best = {...best},
       _random = random ?? Random() {
    _voice.addListener(_notify);
    _reset();
  }

  final QuizTopic topic;
  final QuizLevel level;
  final BuddyVoice _voice;
  final ProgressRepository _progressRepository;
  final Random _random;
  bool _disposed = false;

  /// Best scores by level id, updated when this round is saved.
  final Map<String, int> _best;

  static const letters = ['A', 'B', 'C', 'D'];

  QuizPhase get phase => _phase;
  QuizPhase _phase = QuizPhase.question;

  int get index => _index;
  int _index = 0;
  int get total => level.questions.length;
  QuizQuestion get question => level.questions[_index];
  bool get isLast => _index == total - 1;

  /// This question's answers, in this round's shuffled order.
  List<QuizOption> get options => _order[_index];
  late List<List<QuizOption>> _order;

  /// The child's pick for this question, once made.
  String? get pickedId => _picks[question.id];
  final Map<String, String> _picks = {};
  bool get hasPicked => pickedId != null;
  bool get pickedCorrect => pickedId == question.answerId;

  // -------------------------------------------------------------- results

  int get correctCount =>
      level.questions.where((q) => _picks[q.id] == q.answerId).length;
  int get stars => QuizRules.stars(correctCount, total);
  bool get passed => QuizRules.passes(correctCount, total);

  /// Best before this round, or null if never finished.
  int? get previousBest => _previousBest;
  int? _previousBest;
  bool get isNewBest =>
      _phase == QuizPhase.summary &&
      correctCount > 0 &&
      correctCount > (_previousBest ?? -1);

  QuizLevel? get nextLevel => QuizRules.nextLevel(topic, level);

  /// Whether the next level is open now (including just opened).
  bool get nextUnlocked {
    final next = nextLevel;
    if (next == null) return false;
    return QuizRules.isUnlocked(topic, topic.levels.indexOf(next), _best);
  }

  /// True when this round opened the next level for the first time.
  bool get justUnlockedNext => nextUnlocked && !_nextWasUnlocked;
  late bool _nextWasUnlocked;

  Map<String, int> get best => Map.unmodifiable(_best);

  List<QuizAnswerRecord> get records => [
    for (final q in level.questions)
      if (_picks[q.id] case final picked?)
        QuizAnswerRecord(question: q, pickedId: picked),
  ];

  QuizSaveStatus get saveStatus => _saveStatus;
  QuizSaveStatus _saveStatus = QuizSaveStatus.notSaved;

  // ---------------------------------------------------------------- voice

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  // -------------------------------------------------------------- actions

  /// Reads the current question and its answers (on open and on each new
  /// question; skipped if a grown-up turned automatic reading off).
  void narrateQuestion() => _say(_questionNarration());

  void readQuestion() => _say(question.prompt, requested: true);

  void readAnswers() => _say(answersNarration(options), requested: true);

  /// Answer the current question. Only the first pick counts.
  void pick(String optionId) {
    if (_phase != QuizPhase.question || hasPicked) return;
    if (question.optionById(optionId) == null) return;
    _picks[question.id] = optionId;
    _notify();
    _say(
      feedbackFor(question, optionId),
      lead: pickedCorrect ? SoundEffect.correct : SoundEffect.gentle,
    );
  }

  Future<void> next() async {
    if (_phase != QuizPhase.question || !hasPicked) return;
    if (!isLast) {
      _index++;
      _notify();
      narrateQuestion();
      return;
    }
    // Record the best first, so the summary knows about a newly opened
    // level.
    _best[level.id] = max(_best[level.id] ?? 0, correctCount);
    _phase = QuizPhase.summary;
    _notify();
    _say(summaryNarration(), lead: passed ? SoundEffect.cheer : null);
    await _save();
  }

  /// Play the same level again, with the answers in a new order.
  void replay() {
    _reset();
    _notify();
    narrateQuestion();
  }

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  // ------------------------------------------------------------ narration

  static const rightTitle = "That's right!";
  static const wrongTitle = 'Not quite.';

  @visibleForTesting
  static String feedbackFor(QuizQuestion q, String pickedId) =>
      pickedId == q.answerId
      ? '$rightTitle ${q.explanation}'
      : '$wrongTitle The answer is ${q.answer.text}. ${q.explanation}';

  @visibleForTesting
  static String answersNarration(List<QuizOption> options) => [
    for (final (i, o) in options.indexed) '${letters[i]}: ${o.text}.',
  ].join(' ');

  String _questionNarration() =>
      'Question ${_index + 1} of $total. ${question.prompt} '
      '${answersNarration(options)}';

  /// The score, an encouraging line and any newly opened level.
  String summaryNarration() =>
      'You got $correctCount out of $total. ${summaryMessage()}';

  /// The encouraging line and any newly opened level (the score is shown
  /// separately on screen).
  String summaryMessage() {
    final message = switch (stars) {
      3 => 'A perfect score! Amazing!',
      2 => 'Brilliant work!',
      1 => 'Well done, you passed!',
      _ => 'Good try! Every answer teaches you something new.',
    };
    final unlocked = justUnlockedNext ? ' You opened the next level!' : '';
    return '$message$unlocked';
  }

  // ------------------------------------------------------------ internals

  Future<void> _save() async {
    _saveStatus = QuizSaveStatus.saving;
    _notify();
    try {
      final progress = await _progressRepository.load();
      await _progressRepository.save(
        progress.withQuizResult(level.id, correctCount),
      );
      _saveStatus = QuizSaveStatus.saved;
    } on Exception {
      // The child still sees the result; it just could not be kept.
      _saveStatus = QuizSaveStatus.failed;
    }
    _notify();
  }

  void _reset() {
    _phase = QuizPhase.question;
    _index = 0;
    _picks.clear();
    _saveStatus = QuizSaveStatus.notSaved;
    _previousBest = _best[level.id];
    _nextWasUnlocked = nextUnlocked;
    _order = [for (final q in level.questions) _shuffle(q.options)];
  }

  /// A shuffled copy; avoids keeping the written order when it can, so
  /// replays do not always show the same layout.
  List<QuizOption> _shuffle(List<QuizOption> options) {
    final copy = [...options]..shuffle(_random);
    if (options.length > 1 && listEquals(copy, options)) {
      copy.add(copy.removeAt(0));
    }
    return copy;
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

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(_notify);
    // Leaving a quiz always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}
