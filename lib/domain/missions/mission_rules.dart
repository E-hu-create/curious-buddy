import 'mission.dart';

/// What the child submitted for a stage.
sealed class StageAnswer {
  const StageAnswer();
}

final class PickedChoice extends StageAnswer {
  const PickedChoice(this.choiceId);
  final String choiceId;
}

final class PickedChoices extends StageAnswer {
  const PickedChoices(this.choiceIds);
  final Set<String> choiceIds;
}

final class OrderedPieces extends StageAnswer {
  const OrderedPieces(this.pieceIds);
  final List<String> pieceIds;
}

class CheckResult {
  const CheckResult({required this.correct, required this.feedback});

  final bool correct;

  /// Specific, encouraging and explains the reasoning.
  final String feedback;
}

/// Decides whether an answer is right and what to say about it.
abstract final class StageEvaluator {
  static const tryAgain = 'Not quite yet. ';

  static CheckResult check(MissionStage stage, StageAnswer answer) =>
      switch ((stage, answer)) {
        (final ChoiceStage stage, final PickedChoice answer) => _single(
          stage,
          answer,
        ),
        (final MultiSelectStage stage, final PickedChoices answer) => _multi(
          stage,
          answer,
        ),
        (final OrderStage stage, final OrderedPieces answer) => _order(
          stage,
          answer,
        ),
        _ => throw ArgumentError('Answer does not match the stage type'),
      };

  static CheckResult _single(ChoiceStage stage, PickedChoice answer) {
    final choice = stage.choices.firstWhere(
      (c) => c.id == answer.choiceId,
      orElse: () => throw ArgumentError('Unknown choice ${answer.choiceId}'),
    );
    return CheckResult(
      correct: choice.correct,
      feedback: choice.correct ? choice.feedback : tryAgain + choice.feedback,
    );
  }

  static CheckResult _multi(MultiSelectStage stage, PickedChoices answer) {
    final picked = stage.choices.where((c) => answer.choiceIds.contains(c.id));
    final wrong = picked.where((c) => !c.correct).toList();
    if (wrong.isNotEmpty) {
      return CheckResult(
        correct: false,
        feedback: tryAgain + wrong.first.feedback,
      );
    }
    final allCorrect = stage.choices.where((c) => c.correct).length;
    if (picked.length < allCorrect) {
      return CheckResult(correct: false, feedback: stage.missingFeedback);
    }
    return CheckResult(correct: true, feedback: stage.explanation);
  }

  static CheckResult _order(OrderStage stage, OrderedPieces answer) {
    final expected = [for (final piece in stage.pieces) piece.id];
    if (answer.pieceIds.length != expected.length) {
      return const CheckResult(
        correct: false,
        feedback: 'Place every piece first, then check.',
      );
    }
    for (var i = 0; i < expected.length; i++) {
      if (answer.pieceIds[i] != expected[i]) {
        final misplaced = stage.pieces.firstWhere(
          (p) => p.id == answer.pieceIds[i],
        );
        return CheckResult(
          correct: false,
          feedback:
              '${tryAgain}Look at spot ${i + 1}: does "${misplaced.text}" '
              'really belong there? Check what must come before it.',
        );
      }
    }
    return CheckResult(correct: true, feedback: stage.explanation);
  }
}

/// How one stage went, used for scoring.
class StageResult {
  const StageResult({
    required this.solved,
    required this.firstTry,
    required this.cluesInspected,
    required this.hintsUsed,
  });

  final bool solved;
  final bool firstTry;
  final int cluesInspected;

  /// Recorded but never subtracted: asking for help is fine.
  final int hintsUsed;
}

/// Transparent, encouraging scoring. Rewards finishing, investigating and
/// careful reasoning; never takes points away for mistakes or hints.
class MissionScore {
  const MissionScore({
    required this.completion,
    required this.stagesSolved,
    required this.firstTryBonus,
    required this.cluesInspected,
  });

  static const completionPoints = 50;
  static const pointsPerStage = 10;
  static const pointsPerFirstTry = 10;
  static const pointsPerClue = 5;

  factory MissionScore.from(List<StageResult> results) {
    final solved = results.where((r) => r.solved).length;
    return MissionScore(
      completion: solved == results.length ? completionPoints : 0,
      stagesSolved: solved * pointsPerStage,
      firstTryBonus:
          results.where((r) => r.solved && r.firstTry).length *
          pointsPerFirstTry,
      cluesInspected:
          results.fold(0, (sum, r) => sum + r.cluesInspected) * pointsPerClue,
    );
  }

  /// Most points a mission can give.
  static int maxFor(Mission mission) =>
      completionPoints +
      mission.stages.length * (pointsPerStage + pointsPerFirstTry) +
      mission.stages.fold(0, (sum, s) => sum + s.clues.length) * pointsPerClue;

  final int completion;
  final int stagesSolved;
  final int firstTryBonus;
  final int cluesInspected;

  int get total => completion + stagesSolved + firstTryBonus + cluesInspected;
}

/// Checks that mission content is playable: every stage has a reachable
/// correct answer, hints and an explanation, and ids are unique.
abstract final class MissionValidator {
  static const maxWordsPerText = 70;

  /// Empty when the mission is valid.
  static List<String> problems(Mission mission) {
    final issues = <String>[];
    void check(bool ok, String message) {
      if (!ok) issues.add('${mission.id}: $message');
    }

    check(_validId(mission.id), 'invalid id');
    check(mission.title.trim().isNotEmpty, 'missing title');
    check(mission.intro.trim().isNotEmpty, 'missing intro');
    check(mission.objective.trim().isNotEmpty, 'missing objective');
    check(mission.solution.trim().isNotEmpty, 'missing solution');
    check(mission.badge.trim().isNotEmpty, 'missing badge');
    check(mission.stages.length >= 2, 'needs at least two stages');
    check(
      _unique([for (final s in mission.stages) s.id]),
      'stage ids must be unique',
    );

    for (final stage in mission.stages) {
      final where = 'stage ${stage.id}';
      check(_validId(stage.id), '$where: invalid id');
      check(stage.prompt.trim().isNotEmpty, '$where: missing prompt');
      check(stage.hints.isNotEmpty, '$where: needs at least one hint');
      check(
        stage.hints.every((h) => h.trim().isNotEmpty),
        '$where: empty hint',
      );
      check(stage.explanation.trim().isNotEmpty, '$where: missing explanation');
      check(
        _unique([for (final c in stage.clues) c.id]),
        '$where: clue ids must be unique',
      );
      for (final text in [
        stage.prompt,
        stage.explanation,
        ...stage.hints,
        for (final clue in stage.clues) clue.text,
      ]) {
        check(
          _words(text) <= maxWordsPerText,
          '$where: text too long: "$text"',
        );
      }

      switch (stage) {
        case ChoiceStage(:final choices):
          check(choices.length >= 2, '$where: needs at least two choices');
          check(
            choices.where((c) => c.correct).length == 1,
            '$where: needs exactly one correct choice',
          );
          check(_choicesOk(choices), '$where: choice ids/feedback invalid');
        case MultiSelectStage(:final choices):
          check(
            choices.any((c) => c.correct),
            '$where: needs a correct choice',
          );
          check(
            choices.any((c) => !c.correct),
            '$where: needs an incorrect choice',
          );
          check(_choicesOk(choices), '$where: choice ids/feedback invalid');
        case OrderStage(:final pieces):
          check(pieces.length >= 3, '$where: needs at least three pieces');
          check(
            _unique([for (final p in pieces) p.id]),
            '$where: piece ids must be unique',
          );
          check(
            pieces.every((p) => p.text.trim().isNotEmpty),
            '$where: empty piece',
          );
      }
    }
    return issues;
  }

  static bool _choicesOk(List<Choice> choices) =>
      _unique([for (final c in choices) c.id]) &&
      choices.every((c) => c.text.trim().isNotEmpty && c.feedback.isNotEmpty);

  static bool _unique(List<String> ids) => ids.toSet().length == ids.length;

  static bool _validId(String id) => RegExp(r'^[a-z0-9_\-]+$').hasMatch(id);

  static int _words(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
