import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const _single = ChoiceStage(
  id: 'single',
  prompt: 'Pick one.',
  hints: ['Look closely.'],
  explanation: 'B is right because of the clue.',
  choices: [
    Choice(id: 'a', text: 'A', feedback: 'A clashes with the clue.'),
    Choice(id: 'b', text: 'B', correct: true, feedback: 'Yes, B fits.'),
  ],
);

const _multi = MultiSelectStage(
  id: 'multi',
  prompt: 'Pick all.',
  hints: ['Two are right.'],
  explanation: 'A and B both help.',
  missingFeedback: 'Some are missing.',
  choices: [
    Choice(id: 'a', text: 'A', correct: true, feedback: 'helps'),
    Choice(id: 'b', text: 'B', correct: true, feedback: 'helps'),
    Choice(id: 'c', text: 'C', feedback: 'C is true but irrelevant.'),
  ],
);

const _order = OrderStage(
  id: 'order',
  prompt: 'Order them.',
  hints: ['Start with 1.'],
  explanation: 'One, two, three.',
  pieces: [
    OrderPiece(id: 'one', text: 'One'),
    OrderPiece(id: 'two', text: 'Two'),
    OrderPiece(id: 'three', text: 'Three'),
  ],
);

Mission _mission({List<MissionStage> stages = const [_single, _order]}) =>
    Mission(
      id: 'test_mission',
      title: 'Test',
      tagline: 'A test.',
      art: MissionArt.garden,
      intro: 'Intro.',
      objective: 'Goal.',
      stages: stages,
      solution: 'Solved.',
      badge: 'Tester',
    );

void main() {
  group('StageEvaluator', () {
    test('single choice: right and wrong, with reasons', () {
      final right = StageEvaluator.check(_single, const PickedChoice('b'));
      final wrong = StageEvaluator.check(_single, const PickedChoice('a'));

      expect(right.correct, isTrue);
      expect(wrong.correct, isFalse);
      expect(wrong.feedback, contains('A clashes with the clue.'));
      expect(wrong.feedback, startsWith(StageEvaluator.tryAgain));
    });

    test('multi select: all and only the right ones', () {
      expect(
        StageEvaluator.check(_multi, const PickedChoices({'a', 'b'})).correct,
        isTrue,
      );
    });

    test('multi select: a wrong pick explains that pick', () {
      final result = StageEvaluator.check(
        _multi,
        const PickedChoices({'a', 'b', 'c'}),
      );

      expect(result.correct, isFalse);
      expect(result.feedback, contains('irrelevant'));
    });

    test('multi select: missing ones get encouragement, not a "wrong"', () {
      final result = StageEvaluator.check(_multi, const PickedChoices({'a'}));

      expect(result.correct, isFalse);
      expect(result.feedback, 'Some are missing.');
    });

    test('order: correct order, and a pointer to the first misplaced spot', () {
      expect(
        StageEvaluator.check(
          _order,
          const OrderedPieces(['one', 'two', 'three']),
        ).correct,
        isTrue,
      );
      final wrong = StageEvaluator.check(
        _order,
        const OrderedPieces(['one', 'three', 'two']),
      );
      expect(wrong.correct, isFalse);
      expect(wrong.feedback, contains('spot 2'));
      expect(wrong.feedback, contains('Three'));
    });

    test('order: incomplete answers ask to place every piece', () {
      final result = StageEvaluator.check(_order, const OrderedPieces(['one']));
      expect(result.correct, isFalse);
      expect(result.feedback, contains('every piece'));
    });

    test('mismatched answer types are a programming error', () {
      expect(
        () => StageEvaluator.check(_single, const PickedChoices({'a'})),
        throwsArgumentError,
      );
    });
  });

  group('MissionScore', () {
    StageResult result({
      bool solved = true,
      bool firstTry = true,
      int clues = 0,
      int hints = 0,
    }) => StageResult(
      solved: solved,
      firstTry: firstTry,
      cluesInspected: clues,
      hintsUsed: hints,
    );

    test('adds up completion, steps, first tries and clues', () {
      final score = MissionScore.from([
        result(clues: 2),
        result(firstTry: false, clues: 1),
      ]);

      expect(score.completion, MissionScore.completionPoints);
      expect(score.stagesSolved, 2 * MissionScore.pointsPerStage);
      expect(score.firstTryBonus, MissionScore.pointsPerFirstTry);
      expect(score.cluesInspected, 3 * MissionScore.pointsPerClue);
      expect(score.total, 50 + 20 + 10 + 15);
    });

    test('hints never cost points', () {
      final noHints = MissionScore.from([result(), result()]);
      final manyHints = MissionScore.from([result(hints: 3), result(hints: 2)]);

      expect(manyHints.total, noHints.total);
    });

    test('mistakes only skip the bonus; finishing still scores well', () {
      final score = MissionScore.from([
        result(firstTry: false),
        result(firstTry: false),
      ]);

      expect(score.total, 50 + 20);
      expect(score.total, greaterThan(0));
    });

    test('max points match a perfect run', () {
      final mission = _mission(
        stages: [
          _single,
          const ChoiceStage(
            id: 'with_clues',
            prompt: 'p',
            hints: ['h'],
            explanation: 'e',
            clues: [
              Clue(id: 'c1', title: 't', text: 'x'),
              Clue(id: 'c2', title: 't', text: 'y'),
            ],
            choices: [
              Choice(id: 'a', text: 'a', correct: true, feedback: 'yes'),
              Choice(id: 'b', text: 'b', feedback: 'no because'),
            ],
          ),
        ],
      );
      final perfect = MissionScore.from([result(), result(clues: 2)]);

      expect(MissionScore.maxFor(mission), perfect.total);
    });
  });

  group('MissionValidator', () {
    test('a well-formed mission has no problems', () {
      expect(MissionValidator.problems(_mission()), isEmpty);
    });

    for (final (name, stage) in [
      (
        'no correct choice',
        const ChoiceStage(
          id: 'bad',
          prompt: 'p',
          hints: ['h'],
          explanation: 'e',
          choices: [
            Choice(id: 'a', text: 'a', feedback: 'f'),
            Choice(id: 'b', text: 'b', feedback: 'f'),
          ],
        ),
      ),
      (
        'two correct choices',
        const ChoiceStage(
          id: 'bad',
          prompt: 'p',
          hints: ['h'],
          explanation: 'e',
          choices: [
            Choice(id: 'a', text: 'a', correct: true, feedback: 'f'),
            Choice(id: 'b', text: 'b', correct: true, feedback: 'f'),
          ],
        ),
      ),
      (
        'no hints',
        const ChoiceStage(
          id: 'bad',
          prompt: 'p',
          hints: [],
          explanation: 'e',
          choices: [
            Choice(id: 'a', text: 'a', correct: true, feedback: 'f'),
            Choice(id: 'b', text: 'b', feedback: 'f'),
          ],
        ),
      ),
      (
        'multi select with nothing wrong to avoid',
        const MultiSelectStage(
          id: 'bad',
          prompt: 'p',
          hints: ['h'],
          explanation: 'e',
          choices: [Choice(id: 'a', text: 'a', correct: true, feedback: 'f')],
        ),
      ),
      (
        'order with too few pieces',
        const OrderStage(
          id: 'bad',
          prompt: 'p',
          hints: ['h'],
          explanation: 'e',
          pieces: [
            OrderPiece(id: 'a', text: 'a'),
            OrderPiece(id: 'b', text: 'b'),
          ],
        ),
      ),
      (
        'missing explanation',
        const ChoiceStage(
          id: 'bad',
          prompt: 'p',
          hints: ['h'],
          explanation: ' ',
          choices: [
            Choice(id: 'a', text: 'a', correct: true, feedback: 'f'),
            Choice(id: 'b', text: 'b', feedback: 'f'),
          ],
        ),
      ),
    ]) {
      test('rejects: $name', () {
        expect(
          MissionValidator.problems(_mission(stages: [_single, stage])),
          isNotEmpty,
        );
      });
    }

    test('rejects a mission with one stage or duplicate stage ids', () {
      expect(
        MissionValidator.problems(_mission(stages: [_single])),
        isNotEmpty,
      );
      expect(
        MissionValidator.problems(_mission(stages: [_single, _single])),
        isNotEmpty,
      );
    });
  });
}
