import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/domain/conversation/curated_response_provider.dart';
import 'package:curious_buddy/domain/voice/educational_response_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CuratedResponseProvider provider;

  setUp(() => provider = CuratedResponseProvider());

  Future<EducationalResponse> ask(String question) =>
      provider.respond(EducationalPrompt(question: question));

  group('starter prompts all get real answers', () {
    for (final prompt in starterPrompts) {
      test(prompt, () async {
        final response = await ask(prompt);

        expect(response.kind, ResponseKind.answer);
        expect(response.text, isNotEmpty);
      });
    }
  });

  test('the "bored" example from the brief gets the octopus fact', () async {
    final response = await ask("Buddy, I'm bored. Teach me something amazing.");

    expect(response.text, contains('octopus has three hearts'));
    expect(response.action, BuddyAction.openMissions);
  });

  test('why is the sky blue', () async {
    final response = await ask('why is the sky blue');

    expect(response.text, contains('blue light'));
    expect(response.followUps, isNotEmpty);
  });

  test('matching ignores case, punctuation and word order', () async {
    final a = await ask('WHY IS THE SKY BLUE???');
    provider = CuratedResponseProvider();
    final b = await ask('blue sky, why?');

    expect(a.text, b.text);
  });

  test('repeated questions rotate through fresh answers', () async {
    final first = await ask('Tell me an animal fact.');
    final second = await ask('Tell me an animal fact.');

    expect(second.text, isNot(first.text));
  });

  test('quiz is an honest placeholder that opens the quiz page', () async {
    final response = await ask("Let's play a quiz.");

    expect(response.text, contains('coming soon'));
    expect(response.action, BuddyAction.startQuiz);
    expect(response.actionLabel, isNotNull);
  });

  test('adventure offers Mystery Missions', () async {
    final response = await ask('Take me on an adventure.');

    expect(response.action, BuddyAction.openMissions);
  });

  test('Buddy is honest about being a computer character', () async {
    for (final question in [
      'Are you real?',
      'Are you human?',
      'Are you my friend?',
      'Do you have feelings?',
    ]) {
      final response = await ask(question);

      expect(response.text, contains('computer character'), reason: question);
      expect(response.text, contains('not a person'), reason: question);
      expect(response.text, contains('mistakes'), reason: question);
    }
  });

  test('unknown questions get an honest fallback with ideas', () async {
    final response = await ask('What is the capital of Mongolia?');

    expect(response, fallbackAnswer);
    expect(response.isFallback, isTrue);
    expect(response.text, contains("don't know"));
    expect(response.followUps, isNotEmpty);
  });

  test('safety rules win over topics', () async {
    // Mentions "animal" but contains a phone number.
    final response = await ask('animal fact? my number is 07700 900123');

    expect(response, ChildSafetyFilter.personalInfoResponse);
  });

  test('very long questions are cut, not rejected', () async {
    final response = await ask('${'blah ' * 100} why is the sky blue');

    // The topic words are past the 200-character cut, so it falls back
    // rather than crashing.
    expect(response.isFallback, isTrue);
  });

  group('content rules (every curated answer)', () {
    final everyAnswer = [
      for (final topic in curatedTopics)
        for (final answer in topic.answers) (topic.id, answer),
      ('fallback', fallbackAnswer.text),
    ];

    for (final (id, text) in everyAnswer) {
      test('$id: "${text.substring(0, 24)}..."', () {
        final words = text.split(RegExp(r'\s+'));
        expect(words.length, lessThanOrEqualTo(60), reason: 'too long');

        // Short sentences read aloud well.
        for (final sentence in text.split(RegExp(r'(?<=[.!?])\s+'))) {
          expect(
            sentence.split(RegExp(r'\s+')).length,
            lessThanOrEqualTo(22),
            reason: 'sentence too long: "$sentence"',
          );
        }

        // Never asks for personal details.
        expect(
          text.toLowerCase(),
          isNot(
            anyOf(
              contains('your name'),
              contains('your address'),
              contains('where do you live'),
              contains('your school'),
            ),
          ),
        );

        // Curated answers must not trip the safety filter themselves.
        expect(const ChildSafetyFilter().check(text), isNull);
      });
    }

    test('every topic has a trigger, an answer and a valid action', () {
      for (final topic in curatedTopics) {
        expect(topic.triggers, isNotEmpty, reason: topic.id);
        expect(topic.answers, isNotEmpty, reason: topic.id);
        expect(
          (topic.action == null) == (topic.actionLabel == null),
          isTrue,
          reason: '${topic.id}: action and label go together',
        );
      }
    });

    test('topic ids are unique', () {
      final ids = [for (final topic in curatedTopics) topic.id];
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
