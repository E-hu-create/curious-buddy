import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/quiz/quiz.dart';
import '../../domain/quiz/quiz_rules.dart';

enum QuizHubStatus { loading, ready, empty, error }

/// One level's card row: open or locked, and the best result so far.
class QuizLevelSummary {
  const QuizLevelSummary({
    required this.level,
    required this.unlocked,
    required this.best,
  });

  final QuizLevel level;
  final bool unlocked;

  /// Best number right, or null if never finished.
  final int? best;

  int get total => level.questions.length;
  int get stars => QuizRules.stars(best ?? 0, total);
}

class QuizTopicSummary {
  const QuizTopicSummary({required this.topic, required this.levels});

  final QuizTopic topic;
  final List<QuizLevelSummary> levels;

  int get stars => levels.fold(0, (sum, l) => sum + l.stars);
}

class QuizHubViewModel extends ChangeNotifier {
  QuizHubViewModel({
    required QuizRepository quizRepository,
    required ProgressRepository progressRepository,
  }) : _quizzes = quizRepository,
       _progress = progressRepository;

  final QuizRepository _quizzes;
  final ProgressRepository _progress;
  bool _disposed = false;

  QuizHubStatus get status => _status;
  QuizHubStatus _status = QuizHubStatus.loading;

  List<QuizTopicSummary> get topics => _topics;
  List<QuizTopicSummary> _topics = const [];

  /// Best scores by level id, as loaded.
  Map<String, int> get best => _best;
  Map<String, int> _best = const {};

  int get stars => _topics.fold(0, (sum, t) => sum + t.stars);
  int get maxStars => _topics.fold(0, (sum, t) => sum + t.levels.length * 3);

  /// Loads quizzes and progress. Safe to call again (e.g. after a round).
  Future<void> load() async {
    List<QuizTopic> topics;
    try {
      topics = await _quizzes.loadTopics();
    } on Exception {
      _status = QuizHubStatus.error;
      _notify();
      return;
    }
    try {
      _best = (await _progress.load()).quizBest;
    } on Exception {
      // Quizzes still work; stars just are not shown this time.
      _best = LearnerProgress.empty.quizBest;
    }
    _topics = [
      for (final topic in topics)
        QuizTopicSummary(
          topic: topic,
          levels: [
            for (final (i, level) in topic.levels.indexed)
              QuizLevelSummary(
                level: level,
                unlocked: QuizRules.isUnlocked(topic, i, _best),
                best: _best[level.id],
              ),
          ],
        ),
    ];
    _status = topics.isEmpty ? QuizHubStatus.empty : QuizHubStatus.ready;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
