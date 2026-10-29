import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/missions/mission_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shift each letter by [by] places (A..Z), as the station's code does.
String shift(String word, int by) => String.fromCharCodes([
  for (final c in word.codeUnits) 65 + (c - 65 + by) % 26,
]);

void main() {
  test('there are three starter missions with unique ids', () {
    expect(starterMissions, hasLength(3));
    expect({for (final m in starterMissions) m.id}, hasLength(3));
  });

  for (final mission in starterMissions) {
    group(mission.title, () {
      test('passes validation', () {
        expect(MissionValidator.problems(mission), isEmpty);
      });

      test('has several steps, each with hints and an explanation', () {
        expect(mission.stages.length, greaterThanOrEqualTo(3));
        for (final stage in mission.stages) {
          expect(stage.hints, isNotEmpty, reason: stage.id);
          expect(stage.explanation, isNotEmpty, reason: stage.id);
        }
      });

      test('mixes mechanics (not only one kind of question)', () {
        final kinds = {for (final s in mission.stages) s.runtimeType};
        expect(kinds.length, greaterThanOrEqualTo(2));
      });

      test('every step is solvable with its intended answer', () {
        for (final stage in mission.stages) {
          final answer = switch (stage) {
            ChoiceStage(:final choices) => PickedChoice(
              choices.firstWhere((c) => c.correct).id,
            ),
            MultiSelectStage(:final choices) => PickedChoices({
              for (final c in choices)
                if (c.correct) c.id,
            }),
            OrderStage(:final pieces) => OrderedPieces([
              for (final p in pieces) p.id,
            ]),
          };
          expect(
            StageEvaluator.check(stage, answer).correct,
            isTrue,
            reason: stage.id,
          );
        }
      });

      test('every wrong choice explains why', () {
        for (final stage in mission.stages) {
          final choices = switch (stage) {
            ChoiceStage(:final choices) => choices,
            MultiSelectStage(:final choices) => choices,
            OrderStage() => const <Choice>[],
          };
          for (final choice in choices.where((c) => !c.correct)) {
            expect(choice.feedback.split(' ').length, greaterThan(4));
          }
        }
      });

      test('content is safe and never asks for personal details', () {
        final texts = [
          mission.title,
          mission.intro,
          mission.objective,
          mission.solution,
          for (final stage in mission.stages) ...[
            stage.prompt,
            stage.explanation,
            ...stage.hints,
            for (final clue in stage.clues) clue.text,
          ],
        ];
        for (final text in texts) {
          expect(const ChildSafetyFilter().check(text), isNull, reason: text);
          expect(
            text.toLowerCase(),
            isNot(
              anyOf(
                contains('your name'),
                contains('your address'),
                contains('your school'),
              ),
            ),
          );
        }
      });
    });
  }

  group('the puzzles are logically correct', () {
    final signals = starterMissions.firstWhere(
      (m) => m.id == 'mixed_up_signals',
    );

    test('IPNF shifted back one step is HOME', () {
      expect(shift('IPNF', -1), 'HOME');
      final stage =
          signals.stages.firstWhere((s) => s.id == 'shift_code') as ChoiceStage;
      expect(stage.choices.firstWhere((c) => c.correct).text, 'HOME');
    });

    test('the decoys really encode as their feedback says', () {
      expect(shift('HOPE', 1), 'IPQF');
      expect(shift('GOLD', 1), 'HPME');
      expect(shift('CAT', 1), 'DBU'); // the code example clue
    });

    test('the height readings double to 48', () {
      final readings = [3, 6, 12, 24];
      for (var i = 1; i < readings.length; i++) {
        expect(readings[i], readings[i - 1] * 2);
      }
      expect(readings.last * 2, 48);
    });

    test('the beep pattern repeats in threes and ends with boop next', () {
      const signal = ['beep', 'beep', 'boop', 'beep', 'beep', 'boop'];
      const sofar = [...signal, 'beep', 'beep'];
      expect(signal.sublist(0, 3), signal.sublist(3, 6));
      expect(signal[sofar.length % 3], 'boop');
    });

    test('the word-order clues force exactly one order', () {
      final stage =
          signals.stages.firstWhere((s) => s.id == 'word_order') as OrderStage;
      final words = [for (final p in stage.pieces) p.text];
      // Try every ordering; only the intended one satisfies all three clues.
      final valid = <List<String>>[];
      void permute(List<String> done, List<String> left) {
        if (left.isEmpty) {
          final capitalFirst =
              done.first[0] == done.first[0].toUpperCase() &&
              done.where((w) => w[0] == w[0].toUpperCase()).length == 1;
          final isSecond = done[1] == 'is';
          final safelyLast = done.last == 'safely';
          if (capitalFirst && isSecond && safelyLast) valid.add(done);
          return;
        }
        for (final w in left) {
          permute([...done, w], [...left]..remove(w));
        }
      }

      permute([], words);
      expect(valid, [words]);
    });

    test('the moonstone timeline is consistent', () {
      // Coco saw the gem at 7 pm; the key was taken at 8:15 pm; the light
      // came on at 8:20 pm. Only the curator's statement clashes.
      final moonstone = starterMissions.first;
      final stage =
          moonstone.stages.firstWhere((s) => s.id == 'odd_statement')
              as ChoiceStage;
      expect(stage.choices.where((c) => c.correct).single.id, 'curator');
      expect(stage.clues.map((c) => c.text).join(' '), contains('8:15 pm'));
    });

    test('the garden mission blames overwatering, as the clues show', () {
      final garden = starterMissions.firstWhere(
        (m) => m.id == 'wilting_garden',
      );
      final compare =
          garden.stages.firstWhere((s) => s.id == 'compare_beds')
              as ChoiceStage;
      expect(compare.choices.singleWhere((c) => c.correct).id, 'more_water');
      final clueText = compare.clues.map((c) => c.text).join(' ');
      expect(clueText, contains('Watered four times a day'));
      expect(clueText, contains('same seeds'));
    });
  });
}
