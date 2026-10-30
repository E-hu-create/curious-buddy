import 'package:flutter/foundation.dart';

import '../../domain/quiz/more_quiz_topics.dart';
import '../../domain/quiz/quiz.dart';
import '../../domain/quiz/quiz_rules.dart';

/// Where Quiz Time questions come from. Today: the quizzes bundled in the
/// app (offline). Kept behind an interface so more
/// can be added later without changing screens.
abstract interface class QuizRepository {
  /// Only valid, playable topics. Invalid ones are left out (and logged)
  /// rather than shown broken.
  Future<List<QuizTopic>> loadTopics();
}

class BundledQuizRepository implements QuizRepository {
  BundledQuizRepository({List<QuizTopic>? topics})
    : topics = topics ?? allQuizTopics;

  final List<QuizTopic> topics;

  @override
  Future<List<QuizTopic>> loadTopics() async {
    final topicIds = <String>{};
    final levelIds = <String>{};
    return [
      for (final topic in topics)
        if (_isPlayable(topic, topicIds, levelIds)) topic,
    ];
  }

  static bool _isPlayable(
    QuizTopic topic,
    Set<String> topicIds,
    Set<String> levelIds,
  ) {
    final problems = QuizValidator.problems(topic);
    if (!topicIds.add(topic.id)) problems.add('duplicate id ${topic.id}');
    // Level ids are saved in progress, so they must be unique app-wide.
    for (final level in topic.levels) {
      if (levelIds.contains(level.id)) {
        problems.add('level ${level.id} is used by another topic');
      }
    }
    if (problems.isEmpty) {
      levelIds.addAll([for (final l in topic.levels) l.id]);
      return true;
    }
    debugPrint('Quiz: skipping invalid topic: ${problems.join('; ')}');
    return false;
  }
}
