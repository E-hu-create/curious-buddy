import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/quiz/quiz_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('four topics, three levels each, five questions per level', () {
    expect(
      [for (final t in starterQuizTopics) t.title],
      ['Space', 'Animals', 'Amazing Body', 'Earth & Weather'],
    );
    for (final topic in starterQuizTopics) {
      expect([
        for (final l in topic.levels) l.difficulty,
      ], QuizDifficulty.values);
      for (final level in topic.levels) {
        expect(level.questions, hasLength(5), reason: level.id);
      }
    }
  });

  test('level ids are unique across all topics', () {
    final ids = [
      for (final t in starterQuizTopics)
        for (final l in t.levels) l.id,
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  for (final topic in starterQuizTopics) {
    test('${topic.title}: passes every validation rule', () {
      expect(QuizValidator.problems(topic), isEmpty);
    });

    test('${topic.title}: the right answer is not always in one place', () {
      for (final level in topic.levels) {
        final positions = {
          for (final q in level.questions)
            q.options.indexWhere((o) => o.id == q.answerId),
        };
        expect(positions.length, greaterThanOrEqualTo(3), reason: level.id);
      }
    });
  }

  test('no question is asked twice anywhere', () {
    final prompts = [
      for (final t in starterQuizTopics)
        for (final l in t.levels)
          for (final q in l.questions) q.prompt.toLowerCase(),
    ];
    expect(prompts.toSet(), hasLength(prompts.length));
  });

  test('facts agree with what Buddy says elsewhere', () {
    QuizQuestion find(String levelId, String questionId) => starterQuizTopics
        .expand((t) => t.levels)
        .firstWhere((l) => l.id == levelId)
        .questions
        .firstWhere((q) => q.id == questionId);

    expect(find('space_starter', 'planet_count').answer.text, 'Eight');
    expect(find('body_explorer', 'bones').answer.text, '206');
    expect(find('body_starter', 'adult_teeth').answer.text, '32');
    expect(find('space_explorer', 'moon_walk').answer.text, '1969');
    expect(find('earth_explorer', 'tides').answer.text, "The Moon's gravity");
  });

  test('never asks for personal information', () {
    final text = [
      for (final t in starterQuizTopics)
        for (final l in t.levels)
          for (final q in l.questions) ...[
            q.prompt,
            for (final o in q.options) o.text,
          ],
    ].join(' ').toLowerCase();
    expect(
      text,
      isNot(matches(RegExp(r'your (name|address|school|age|phone|email)'))),
    );
  });
}
