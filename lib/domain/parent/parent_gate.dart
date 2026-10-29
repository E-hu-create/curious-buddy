import 'dart:math';

import 'package:flutter/foundation.dart';

/// The grown-up check in front of the Parent Zone.
///
/// Each attempt is a fresh multiplication written in words ("What is
/// twenty-four times seven?"), so there is no fixed answer to learn and
/// younger children cannot just tap or guess their way in. After
/// [maxAttempts] wrong answers in a row, the check pauses for [lockout].
///
/// This is a *gate*, not proof of age or identity: an older child who reads
/// well and can multiply may pass. It asks for nothing personal and stores
/// nothing; the pause lives only in memory and resets when the app closes.
class ParentGate {
  ParentGate({Random? random, DateTime Function()? now})
    : _random = random ?? Random(),
      _now = now ?? DateTime.now {
    _next();
  }

  static const maxAttempts = 3;
  static const lockout = Duration(seconds: 60);

  final Random _random;
  final DateTime Function() _now;

  late int _a;
  late int _b;
  int _wrong = 0;
  DateTime? _lockedUntil;

  /// The question, in words, e.g. "What is twenty-four times seven?".
  String get question =>
      'What is ${numberToWords(_a)} times '
      '${numberToWords(_b)}?';

  /// Time left before another try is allowed, or null if not paused.
  Duration? get waitRemaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(_now());
    if (left <= Duration.zero) {
      _lockedUntil = null;
      return null;
    }
    return left;
  }

  bool get isLocked => waitRemaining != null;

  @visibleForTesting
  int get answer => _a * _b;

  /// Wrong answers left before a pause.
  int get attemptsLeft => maxAttempts - _wrong;

  /// Checks [answer]. A wrong answer gets a new question; too many in a row
  /// start the pause. Always false while paused.
  bool check(String answer) {
    if (isLocked) return false;
    if (int.tryParse(answer.trim()) == _a * _b) {
      _wrong = 0;
      _next();
      return true;
    }
    _wrong++;
    if (_wrong >= maxAttempts) {
      _wrong = 0;
      _lockedUntil = _now().add(lockout);
    }
    _next();
    return false;
  }

  /// A two-digit number (13 to 29, never a multiple of ten) times a single
  /// digit (3 to 9): mental arithmetic most adults do quickly.
  void _next() {
    do {
      _a = 13 + _random.nextInt(17);
    } while (_a % 10 == 0);
    _b = 3 + _random.nextInt(7);
  }

  static const _ones = [
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen', //
  ];
  static const _tens = [
    '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy',
    'eighty', 'ninety', //
  ];

  /// English words for 0 to 99.
  static String numberToWords(int n) {
    assert(n >= 0 && n < 100, 'only 0 to 99');
    if (n < 20) return _ones[n];
    final tens = _tens[n ~/ 10];
    return n % 10 == 0 ? tens : '$tens-${_ones[n % 10]}';
  }
}
