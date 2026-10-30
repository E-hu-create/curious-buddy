import 'package:curious_buddy/domain/quiz/more_quiz_topics.dart';
import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_rules.dart';
import 'package:curious_buddy/ui/quiz/widgets/quiz_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ten topics, three levels each, five questions per level', () {
    expect(
      [for (final t in allQuizTopics) t.title],
      [
        'Space',
        'Animals',
        'Amazing Body',
        'Earth & Weather',
        'Dinosaurs & Fossils',
        'Oceans',
        'Plants & Bugs',
        'Electricity & Energy',
        'Matter & Materials',
        'Robots & Inventions',
      ],
    );
    for (final topic in allQuizTopics) {
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
      for (final t in allQuizTopics)
        for (final l in t.levels) l.id,
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  for (final topic in allQuizTopics) {
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
      for (final t in allQuizTopics)
        for (final l in t.levels)
          for (final q in l.questions) q.prompt.toLowerCase(),
    ];
    expect(prompts.toSet(), hasLength(prompts.length));
  });

  test('there are 150 questions in all', () {
    expect(
      allQuizTopics
          .expand((t) => t.levels)
          .fold(0, (sum, l) => sum + l.questions.length),
      150,
    );
  });

  test('every topic has its own icon', () {
    expect({
      for (final t in allQuizTopics) quizTopicStyle(t.id).icon,
    }, hasLength(allQuizTopics.length));
  });

  test('new questions agree with the games and stories', () {
    QuizQuestion find(String levelId, String questionId) => allQuizTopics
        .expand((t) => t.levels)
        .firstWhere((l) => l.id == levelId)
        .questions
        .firstWhere((q) => q.id == questionId);

    expect(find('plants_starter', 'insect_legs').answer.text, 'Six');
    expect(find('dinosaurs_starter', 'triceratops_horns').answer.text, 'Three');
    expect(
      find('energy_starter', 'good_conductor').answer.text,
      'A copper wire',
    );
    expect(find('matter_explorer', 'freezing_point').answer.text, '0 °C');
    expect(find('matter_explorer', 'boiling_point').answer.text, '100 °C');
  });

  test('facts agree with what Buddy says elsewhere', () {
    QuizQuestion find(String levelId, String questionId) => allQuizTopics
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
      for (final t in allQuizTopics)
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
