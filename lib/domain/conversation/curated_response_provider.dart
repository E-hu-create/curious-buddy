import '../voice/educational_response_provider.dart';
import 'child_safety_filter.dart';
import 'curated_content.dart';

/// Answers from reviewed, offline content only. No network, no AI model,
/// nothing stored.
///
/// Order: safety rules first, then the first matching topic, then an honest
/// "I don't know that one yet".
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

    final words = ChildSafetyFilter.normalize(
      question,
    ).trim().split(' ').toSet();
    for (final topic in topics) {
      if (topic.triggers.any(words.containsAll)) return _answer(topic);
    }
    return fallbackAnswer;
  }

  EducationalResponse _answer(CuratedTopic topic) {
    final index = _nextAnswer[topic.id] ?? 0;
    _nextAnswer[topic.id] = (index + 1) % topic.answers.length;
    return EducationalResponse(
      text: topic.answers[index],
      action: topic.action,
      actionLabel: topic.actionLabel,
      followUps: topic.followUps,
    );
  }
}
