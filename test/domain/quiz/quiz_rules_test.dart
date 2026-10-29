import 'package:curious_buddy/domain/quiz/quiz.dart';
import 'package:curious_buddy/domain/quiz/quiz_rules.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestion _q(
  String id, {
  String prompt = 'Which one?',
  List<String> options = const ['Right', 'Wrong', 'Also wrong'],
  String answer = 'a',
  String explanation = 'Because.',
}) => QuizQuestion(
  id: id,
  prompt: prompt,
  options: [
    for (final (i, text) in options.indexed)
      QuizOption(id: 'abcde'[i], text: text),
  ],
  answerId: answer,
  explanation: explanation,
);

QuizLevel _level(String id, [List<QuizQuestion>? questions]) => QuizLevel(
  id: id,
  difficulty: QuizDifficulty.starter,
  questions: questions ?? [for (var i = 0; i < 5; i++) _q('q$i')],
);

QuizTopic _topic(List<QuizLevel> levels) =>
    QuizTopic(id: 'topic', title: 'Topic', tagline: 't', levels: levels);

Matcher _problem(String fragment) => contains(contains(fragment));

void main() {
  group('scoring', () {
    test('passing needs 3 of 5', () {
      expect(QuizRules.passMark(5), 3);
      expect(QuizRules.passes(2, 5), isFalse);
      expect(QuizRules.passes(3, 5), isTrue);
      expect(QuizRules.passes(0, 0), isFalse);
    });

    test('stars for every score out of 5', () {
      expect(
        [for (var c = 0; c <= 5; c++) QuizRules.stars(c, 5)],
        [0, 0, 0, 1, 2, 3],
      );
      expect(QuizRules.stars(3, 0), 0);
    });
  });

  group('levels', () {
    final topic = _topic([_level('one'), _level('two'), _level('three')]);

    test('the first level is always open', () {
      expect(QuizRules.isUnlocked(topic, 0, const {}), isTrue);
    });

    test('a level opens once the one before is passed', () {
      expect(QuizRules.isUnlocked(topic, 1, const {}), isFalse);
      expect(QuizRules.isUnlocked(topic, 1, const {'one': 2}), isFalse);
      expect(QuizRules.isUnlocked(topic, 1, const {'one': 3}), isTrue);
      expect(QuizRules.isUnlocked(topic, 2, const {'one': 5}), isFalse);
      expect(
        QuizRules.isUnlocked(topic, 2, const {'one': 5, 'two': 3}),
        isTrue,
      );
      expect(QuizRules.isUnlocked(topic, 9, const {}), isFalse);
    });

    test('next level', () {
      expect(QuizRules.nextLevel(topic, topic.levels[0]), topic.levels[1]);
      expect(QuizRules.nextLevel(topic, topic.levels[2]), isNull);
    });
  });

  group('QuizValidator', () {
    test('accepts a well-formed topic', () {
      expect(QuizValidator.problems(_topic([_level('one')])), isEmpty);
    });

    test('rejects a topic without levels or a level without questions', () {
      expect(QuizValidator.problems(_topic([])), _problem('no levels'));
      expect(
        QuizValidator.problems(_topic([_level('one', [])])),
        _problem('no questions'),
      );
    });

    test('rejects repeated level and question ids', () {
      expect(
        QuizValidator.problems(_topic([_level('one'), _level('one')])),
        _problem('level ids repeat'),
      );
      expect(
        QuizValidator.problems(
          _topic([
            _level('one', [_q('same'), _q('same')]),
          ]),
        ),
        _problem('question ids repeat'),
      );
    });

    test('needs exactly one correct answer that exists', () {
      expect(
        QuizValidator.problems(
          _topic([
            _level('one', [_q('x', answer: 'z')]),
          ]),
        ),
        _problem('exactly one correct answer'),
      );
    });

    test('needs three or four different answers', () {
      for (final options in [
        ['Yes', 'No'],
        ['A', 'B', 'C', 'D', 'E'],
      ]) {
        expect(
          QuizValidator.problems(
            _topic([
              _level('one', [_q('x', options: options)]),
            ]),
          ),
          _problem('needs 3 to 4 answers'),
        );
      }
      expect(
        QuizValidator.problems(
          _topic([
            _level('one', [
              _q('x', options: ['Same', 'same', 'Other']),
            ]),
          ]),
        ),
        _problem('answers repeat'),
      );
    });

    test('rejects missing text, explanations and lazy answers', () {
      final problems = QuizValidator.problems(
        _topic([
          _level('one', [
            _q(
              'x',
              prompt: ' ',
              explanation: '',
              options: ['All of the above', 'B', ''],
            ),
          ]),
        ]),
      );
      expect(problems, _problem('missing question'));
      expect(problems, _problem('missing explanation'));
      expect(problems, _problem('empty answer'));
      expect(problems, _problem('all/none of the above'));
    });

    test('rejects text too long to read aloud', () {
      final long = List.filled(41, 'word').join(' ');
      final problems = QuizValidator.problems(
        _topic([
          _level('one', [
            _q('x', prompt: long, explanation: long, options: [long, 'B', 'C']),
          ]),
        ]),
      );
      expect(problems, _problem('question too long'));
      expect(problems, _problem('explanation too long'));
      expect(problems, _problem('answer too long'));
    });

    test('rejects invalid ids', () {
      expect(
        QuizValidator.problems(_topic([_level('Bad Id')])),
        _problem('invalid id'),
      );
    });
  });
}
