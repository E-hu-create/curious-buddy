import 'dart:math';

/// Number Pop: pop every bubble whose sum makes the target number. Pure
/// logic: no Flutter, no storage. Nothing is timed, and bubbles never run
/// away, so a child can work each sum out at their own pace.

enum SumOperator {
  plus('+', 'plus'),
  minus('−', 'minus'),
  times('×', 'times');

  const SumOperator(this.symbol, this.word);

  final String symbol;
  final String word;
}

class BubbleSum {
  const BubbleSum(this.a, this.operator, this.b);

  final int a;
  final SumOperator operator;
  final int b;

  int get value => switch (operator) {
    SumOperator.plus => a + b,
    SumOperator.minus => a - b,
    SumOperator.times => a * b,
  };

  String get text => '$a ${operator.symbol} $b';

  /// How a screen reader says it.
  String get spoken => '$a ${operator.word} $b';
}

enum PopResult { ignored, wrong, popped, cleared, won }

class NumberPopGame {
  NumberPopGame({required this.level, required Random random})
    : _random = random,
      _pool = _sumsFor(level) {
    _deal();
  }

  static const rounds = 5;
  static const bubbleCount = 9;
  static const rightCount = 3;
  static const _closeBy = 4;

  final int level;
  final Random _random;
  final List<BubbleSum> _pool;

  int get round => _round;
  int _round = 0;

  int get target => _target;
  late int _target;

  List<BubbleSum> get bubbles => _bubbles;
  List<BubbleSum> _bubbles = const [];

  final Set<int> popped = {};

  /// Wrong bubbles already tapped, which can't count twice.
  final Set<int> tried = {};

  final Set<int> _usedTargets = {};

  int get mistakes => _mistakes;
  int _mistakes = 0;

  int get left => rightCount - popped.length;

  /// Fewer wrong taps earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 3) return 2;
    return 1;
  }

  PopResult tap(int index) {
    if (index < 0 || index >= _bubbles.length) return PopResult.ignored;
    if (popped.contains(index) || tried.contains(index)) {
      return PopResult.ignored;
    }
    if (_bubbles[index].value != _target) {
      tried.add(index);
      _mistakes++;
      return PopResult.wrong;
    }
    popped.add(index);
    if (left > 0) return PopResult.popped;
    if (_round + 1 >= rounds) return PopResult.won;
    _round++;
    _deal();
    return PopResult.cleared;
  }

  /// Every sum the level can use. Each pair appears once: 3 + 5, not 5 + 3.
  static List<BubbleSum> _sumsFor(int level) => switch (level) {
    1 => [
      for (var a = 1; a <= 9; a++)
        for (var b = a; b <= 9; b++) BubbleSum(a, SumOperator.plus, b),
    ],
    2 => [
      for (var a = 2; a <= 15; a++)
        for (var b = a; b <= 15; b++) BubbleSum(a, SumOperator.plus, b),
      for (var a = 8; a <= 30; a++)
        for (var b = 2; b < a; b++) BubbleSum(a, SumOperator.minus, b),
    ],
    _ => [
      for (var a = 2; a <= 9; a++)
        for (var b = a; b <= 9; b++) BubbleSum(a, SumOperator.times, b),
      for (var a = 4; a <= 25; a++)
        for (var b = a; b <= 25; b++) BubbleSum(a, SumOperator.plus, b),
      for (var a = 12; a <= 50; a++)
        for (var b = 2; b < a; b++) BubbleSum(a, SumOperator.minus, b),
    ],
  };

  void _deal() {
    popped.clear();
    tried.clear();
    _target = _chooseTarget();
    final right = _pool.where((s) => s.value == _target).toList()
      ..shuffle(_random);
    // A times sum first, so Expert always practises times tables.
    right.sort((a, b) => _timesFirst(a).compareTo(_timesFirst(b)));
    final close =
        _pool
            .where(
              (s) =>
                  s.value != _target && (s.value - _target).abs() <= _closeBy,
            )
            .toList()
          ..shuffle(_random);
    _bubbles = [
      ...right.take(rightCount),
      ...close.take(bubbleCount - rightCount),
    ]..shuffle(_random);
  }

  static int _timesFirst(BubbleSum sum) =>
      sum.operator == SumOperator.times ? 0 : 1;

  int _chooseTarget() {
    final counts = <int, int>{};
    for (final sum in _pool) {
      counts[sum.value] = (counts[sum.value] ?? 0) + 1;
    }
    final (low, high) = switch (level) {
      1 => (6, 14),
      2 => (12, 25),
      _ => (12, 48),
    };
    final options = [
      for (final MapEntry(key: value, value: count) in counts.entries)
        if (value >= low &&
            value <= high &&
            count >= rightCount &&
            !_usedTargets.contains(value) &&
            (level < 3 || _hasTimes(value)))
          value,
    ];
    final target = options[_random.nextInt(options.length)];
    _usedTargets.add(target);
    return target;
  }

  bool _hasTimes(int value) =>
      _pool.any((s) => s.operator == SumOperator.times && s.value == value);
}
