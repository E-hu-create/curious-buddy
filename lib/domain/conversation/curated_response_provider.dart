import '../voice/educational_response_provider.dart';
import 'child_safety_filter.dart';
import 'curated_content.dart';

/// Answers from reviewed, offline content only. No network, no AI model,
/// nothing stored.
///
/// Order: safety rules first, then the feelings topic, then the first
/// matching topic, then an honest
/// "I don't know that one yet".
///
/// Matching is deterministic and forgiving in two small ways, so children's
/// real questions find the right topic:
/// * plurals count as singular ("cats" matches "cat");
/// * one-letter typos are forgiven, but only in [typoTolerantWords] (long,
///   distinctive names like "dinosaur"): swapped neighbours need
///   5+ letters ("dinosuar"), one wrong letter 7+ ("planes" never matches
///   "planet"), one missing or extra letter 7+ ("plant" never matches
///   "planet").
class CuratedResponseProvider implements EducationalResponseProvider {
  CuratedResponseProvider({
    this.safety = const ChildSafetyFilter(),
    this.topics = curatedTopics,
  });

  /// Questions longer than this are cut before matching.
  static const maxQuestionLength = 200;

  final ChildSafetyFilter safety;
  final List<CuratedTopic> topics;

  /// Next answer index per topic, so repeats get a fresh fact. In memory
  /// only; resets when the app restarts.
  final Map<String, int> _nextAnswer = {};

  @override
  Future<EducationalResponse> respond(EducationalPrompt prompt) async {
    final question = prompt.question.length > maxQuestionLength
        ? prompt.question.substring(0, maxQuestionLength)
        : prompt.question;

    final unsafe = safety.check(question);
    if (unsafe != null) return unsafe;

    final topic = match(question);
    return topic == null ? fallbackAnswer : _answer(topic, wordsOf(question));
  }

  /// Topics tried before all others, so a child who shares a feeling is
  /// heard even when the message also says hello or names a topic
  /// ("Hi, I'm sad", "I'm sad my cat died").
  static const firstTopicIds = {'feelings'};

  /// The first topic whose trigger fully appears in [question], or null.
  /// [firstTopicIds] are tried first; the list order is otherwise kept.
  CuratedTopic? match(String question) {
    final words = wordsOf(question);
    bool matches(CuratedTopic topic) => topic.triggers.any(
      (trigger) => trigger.every((word) => _contains(words, word)),
    );
    return topics
            .where((t) => firstTopicIds.contains(t.id))
            .where(matches)
            .firstOrNull ??
        topics.where(matches).firstOrNull;
  }

  /// Lowercase words plus their singular and non-possessive forms.
  static Set<String> wordsOf(String question) {
    final words = ChildSafetyFilter.normalize(
      question,
    ).trim().split(' ').where((w) => w.isNotEmpty).toSet();
    return {
      for (final word in words) ...{word, ..._singulars(word)},
    };
  }

  static Iterable<String> _singulars(String word) sync* {
    if (word.endsWith("'s") && word.length > 3) {
      yield word.substring(0, word.length - 2); // saturn's, dog's
    }
    if (word.length > 4 && word.endsWith('ies')) {
      yield '${word.substring(0, word.length - 3)}y'; // butterflies
    }
    if (word.length > 3 && word.endsWith('es')) {
      yield word.substring(0, word.length - 2); // boxes, volcanoes
    }
    if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) {
      yield word.substring(0, word.length - 1); // cats
    }
  }

  static bool _contains(Set<String> words, String wanted) =>
      words.contains(wanted) ||
      (typoTolerantWords.contains(wanted) &&
          words.any((w) => isNearMiss(w, wanted)));

  /// One small typo: swapped neighbours (5+ letters), one wrong letter (7+),
  /// or one missing/extra letter (7+).
  static bool isNearMiss(String typed, String wanted) {
    if (typed == wanted) return true;
    final lengthGap = (typed.length - wanted.length).abs();
    if (lengthGap == 0) {
      if (wanted.length < 5) return false;
      final diffs = [
        for (var i = 0; i < wanted.length; i++)
          if (typed[i] != wanted[i]) i,
      ];
      if (diffs.length == 1) return wanted.length >= 7; // substitution
      return diffs.length == 2 &&
          diffs[1] == diffs[0] + 1 &&
          typed[diffs[0]] == wanted[diffs[1]] &&
          typed[diffs[1]] == wanted[diffs[0]]; // swapped neighbours
    }
    if (lengthGap != 1) return false;
    final (shorter, longer) = typed.length < wanted.length
        ? (typed, wanted)
        : (wanted, typed);
    if (longer.length < 7) return false;
    for (var i = 0; i < longer.length; i++) {
      if (longer.substring(0, i) + longer.substring(i + 1) == shorter) {
        return true;
      }
    }
    return false;
  }

  EducationalResponse _answer(CuratedTopic topic, Set<String> words) {
    // 1. A pinned answer that really answers this question.
    for (final MapEntry(key: word, value: index) in topic.pinned.entries) {
      if (_contains(words, word)) return _response(topic, topic.answers[index]);
    }

    // 2. Otherwise rotate through the topic's answers.
    final index = _nextAnswer[topic.id] ?? 0;
    _nextAnswer[topic.id] = (index + 1) % topic.answers.length;
    final fact = topic.answers[index];

    // 3. A specific question that only matched a subject gets an honest
    //    lead-in instead of a fact dressed up as an answer.
    final subject = topic.subject;
    final isSpecificQuestion =
        words.any(questionWords.contains) &&
        !words.any(factRequestWords.contains);
    if (subject != null && isSpecificQuestion) {
      return _response(
        topic,
        notSureLeadIn(subject) + fact,
        kind: ResponseKind.fallback,
      );
    }
    return _response(topic, fact);
  }

  static EducationalResponse _response(
    CuratedTopic topic,
    String text, {
    ResponseKind kind = ResponseKind.answer,
  }) => EducationalResponse(
    text: text,
    kind: kind,
    topicId: topic.id,
    action: topic.action,
    actionLabel: topic.actionLabel,
    followUps: topic.followUps,
  );
}
