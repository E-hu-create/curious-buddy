import 'quiz.dart';

/// Scoring, stars and which levels are open. Transparent and forgiving: a
/// wrong answer never takes away anything already earned.
abstract final class QuizRules {
  /// Share of correct answers needed to pass a level and open the next.
  static const passShare = 0.6;

  /// Correct answers needed to pass a level of [total] questions
  /// (3 of 5).
  static int passMark(int total) => (total * passShare).ceil();

  static bool passes(int correct, int total) =>
      total > 0 && correct >= passMark(total);

  /// 0 to 3 stars: all right is 3, at least 80% is 2, a pass is 1.
  static int stars(int correct, int total) {
    if (total <= 0 || correct <= 0) return 0;
    if (correct >= total) return 3;
    if (correct / total >= 0.8) return 2;
    if (passes(correct, total)) return 1;
    return 0;
  }

  /// The first level is always open; each later one opens once the level
  /// before it has been passed. [best] maps level id to best correct count.
  static bool isUnlocked(
    QuizTopic topic,
    int levelIndex,
    Map<String, int> best,
  ) {
    if (levelIndex <= 0) return true;
    if (levelIndex >= topic.levels.length) return false;
    final previous = topic.levels[levelIndex - 1];
    return passes(best[previous.id] ?? 0, previous.questions.length);
  }

  /// The level after [level] in [topic], if any.
  static QuizLevel? nextLevel(QuizTopic topic, QuizLevel level) {
    final index = topic.levels.indexOf(level);
    if (index < 0 || index + 1 >= topic.levels.length) return null;
    return topic.levels[index + 1];
  }
}

/// Checks that a topic is playable and fair.
abstract final class QuizValidator {
  static const minOptions = 3;
  static const maxOptions = 4;
  static const maxPromptWords = 25;
  static const maxOptionWords = 8;
  static const maxExplanationWords = 40;
  static final _validId = RegExp(r'^[a-z0-9_\-]+$');
  static final _lazyOptions = RegExp(
    r'\b(all|none) of (the|these) (above|answers)\b',
    caseSensitive: false,
  );

  /// Empty when the topic is valid.
  static List<String> problems(QuizTopic topic) {
    final issues = <String>[];
    void check(bool ok, String message) {
      if (!ok) issues.add('${topic.id}: $message');
    }

    check(_validId.hasMatch(topic.id), 'invalid id');
    check(topic.title.trim().isNotEmpty, 'missing title');
    check(topic.levels.isNotEmpty, 'no levels');

    final levelIds = [for (final l in topic.levels) l.id];
    check(levelIds.toSet().length == levelIds.length, 'level ids repeat');

    for (final level in topic.levels) {
      final where = 'level ${level.id}';
      check(_validId.hasMatch(level.id), '$where: invalid id');
      check(level.questions.isNotEmpty, '$where: no questions');
      final questionIds = [for (final q in level.questions) q.id];
      check(
        questionIds.toSet().length == questionIds.length,
        '$where: question ids repeat',
      );
      for (final q in level.questions) {
        final at = '$where, question ${q.id}';
        check(q.prompt.trim().isNotEmpty, '$at: missing question');
        check(_words(q.prompt) <= maxPromptWords, '$at: question too long');
        check(q.explanation.trim().isNotEmpty, '$at: missing explanation');
        check(
          _words(q.explanation) <= maxExplanationWords,
          '$at: explanation too long',
        );
        check(
          q.options.length >= minOptions && q.options.length <= maxOptions,
          '$at: needs $minOptions to $maxOptions answers',
        );
        final optionIds = [for (final o in q.options) o.id];
        check(
          optionIds.toSet().length == optionIds.length,
          '$at: answer ids repeat',
        );
        final texts = [for (final o in q.options) o.text.trim().toLowerCase()];
        check(texts.toSet().length == texts.length, '$at: answers repeat');
        check(
          q.options.where((o) => o.id == q.answerId).length == 1,
          '$at: needs exactly one correct answer',
        );
        for (final o in q.options) {
          check(o.text.trim().isNotEmpty, '$at: empty answer');
          check(_words(o.text) <= maxOptionWords, '$at: answer too long');
          check(!_lazyOptions.hasMatch(o.text), '$at: "all/none of the above"');
        }
      }
    }
    return issues;
  }

  static int _words(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
