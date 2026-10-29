import 'dart:math';

import 'package:curious_buddy/domain/parent/parent_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  ParentGate gate([int seed = 1]) =>
      ParentGate(random: Random(seed), now: () => now);

  setUp(() => now = DateTime(2026, 10, 29, 12));

  group('numberToWords', () {
    test('writes numbers the way a grown-up reads them', () {
      expect(ParentGate.numberToWords(3), 'three');
      expect(ParentGate.numberToWords(13), 'thirteen');
      expect(ParentGate.numberToWords(20), 'twenty');
      expect(ParentGate.numberToWords(24), 'twenty-four');
      expect(ParentGate.numberToWords(99), 'ninety-nine');
    });
  });

  test('asks a multiplication in words, never in digits', () {
    final g = gate();
    expect(g.question, matches(RegExp(r'^What is [a-z-]+ times [a-z]+\?$')));
    expect(g.question, isNot(matches(RegExp(r'\d'))));
  });

  test('questions vary, and answers always need two or three digits', () {
    final questions = <String>{};
    for (var seed = 0; seed < 50; seed++) {
      final g = gate(seed);
      questions.add(g.question);
      expect(g.answer, inInclusiveRange(39, 261));
    }
    expect(questions.length, greaterThan(20));
  });

  test('the right answer passes; spaces are ignored', () {
    final g = gate();
    expect(g.check(' ${g.answer} '), isTrue);
  });

  test('a wrong answer fails and brings a new question', () {
    final g = gate();
    final before = g.question;
    expect(g.check('${g.answer + 1}'), isFalse);
    expect(g.check('not a number'), isFalse);
    expect(g.attemptsLeft, ParentGate.maxAttempts - 2);
    // A fresh question each time (the seed makes this one differ).
    expect(g.question, isNot(before));
  });

  test('too many wrong answers pause the check, even for the right one', () {
    final g = gate();
    for (var i = 0; i < ParentGate.maxAttempts; i++) {
      g.check('0');
    }

    expect(g.isLocked, isTrue);
    expect(g.waitRemaining, ParentGate.lockout);
    expect(g.check('${g.answer}'), isFalse, reason: 'paused');

    now = now.add(const Duration(seconds: 59));
    expect(g.isLocked, isTrue);

    now = now.add(const Duration(seconds: 1));
    expect(g.isLocked, isFalse);
    expect(g.attemptsLeft, ParentGate.maxAttempts);
    expect(g.check('${g.answer}'), isTrue);
  });

  test('a right answer resets the count of wrong ones', () {
    final g = gate();
    g
      ..check('0')
      ..check('0')
      ..check('${g.answer}');
    expect(g.attemptsLeft, ParentGate.maxAttempts);
    g.check('0');
    expect(g.isLocked, isFalse);
  });
}
