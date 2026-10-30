import 'games.dart';

const _n = GameToken.number;

GameToken _s(GameShape shape, GameColor color) => GameToken.shape(shape, color);

const _circle = GameShape.circle;
const _square = GameShape.square;
const _triangle = GameShape.triangle;
const _star = GameShape.star;
const _heart = GameShape.heart;
const _red = GameColor.coral;
const _yellow = GameColor.sun;
const _green = GameColor.leaf;
const _blue = GameColor.blue;
const _purple = GameColor.grape;

/// Pattern Power: five rounds per level. Level 1 is shapes and colours,
/// level 2 is simple number steps, level 3 is trickier number rules.
final patternLevels = <int, List<PatternRound>>{
  1: [
    PatternRound(
      shown: [
        _s(_circle, _red),
        _s(_square, _blue),
        _s(_circle, _red),
        _s(_square, _blue),
      ],
      options: [_s(_circle, _red), _s(_square, _blue), _s(_star, _yellow)],
      answer: _s(_circle, _red),
      explanation: 'Red circle, blue square, over and over.',
    ),
    PatternRound(
      shown: [
        _s(_star, _yellow),
        _s(_star, _yellow),
        _s(_heart, _red),
        _s(_star, _yellow),
        _s(_star, _yellow),
      ],
      options: [_s(_star, _yellow), _s(_heart, _red), _s(_circle, _green)],
      answer: _s(_heart, _red),
      explanation: 'Two stars, then a heart, again and again.',
    ),
    PatternRound(
      shown: [
        _s(_triangle, _green),
        _s(_circle, _purple),
        _s(_square, _yellow),
        _s(_triangle, _green),
        _s(_circle, _purple),
      ],
      options: [
        _s(_square, _yellow),
        _s(_triangle, _green),
        _s(_circle, _purple),
      ],
      answer: _s(_square, _yellow),
      explanation: 'The same three shapes repeat in order.',
    ),
    PatternRound(
      shown: [
        _s(_heart, _blue),
        _s(_heart, _green),
        _s(_heart, _blue),
        _s(_heart, _green),
      ],
      options: [_s(_heart, _blue), _s(_heart, _yellow), _s(_star, _blue)],
      answer: _s(_heart, _blue),
      explanation: 'The shape stays the same, and the colour swaps.',
    ),
    PatternRound(
      shown: [
        _s(_square, _red),
        _s(_square, _red),
        _s(_circle, _blue),
        _s(_circle, _blue),
        _s(_square, _red),
        _s(_square, _red),
      ],
      options: [_s(_circle, _blue), _s(_square, _red), _s(_star, _green)],
      answer: _s(_circle, _blue),
      explanation: 'Two of each, taking turns.',
    ),
  ],
  2: [
    PatternRound(
      shown: [_n(2), _n(4), _n(6), _n(8)],
      options: [_n(9), _n(10), _n(12)],
      answer: _n(10),
      explanation: 'Each number is 2 more than the one before.',
    ),
    PatternRound(
      shown: [_n(5), _n(10), _n(15), _n(20)],
      options: [_n(22), _n(25), _n(30)],
      answer: _n(25),
      explanation: 'These go up in fives.',
    ),
    PatternRound(
      shown: [_n(20), _n(18), _n(16), _n(14)],
      options: [_n(12), _n(13), _n(10)],
      answer: _n(12),
      explanation: 'Each number is 2 less than the one before.',
    ),
    PatternRound(
      shown: [_n(3), _n(6), _n(9), _n(12)],
      options: [_n(14), _n(15), _n(18)],
      answer: _n(15),
      explanation: 'These go up in threes.',
    ),
    PatternRound(
      shown: [_n(50), _n(40), _n(30), _n(20)],
      options: [_n(5), _n(10), _n(15)],
      answer: _n(10),
      explanation: 'Each number is 10 less than the one before.',
    ),
  ],
  3: [
    PatternRound(
      shown: [_n(1), _n(2), _n(4), _n(8)],
      options: [_n(10), _n(12), _n(16), _n(32)],
      answer: _n(16),
      explanation: 'Each number doubles.',
    ),
    PatternRound(
      shown: [_n(1), _n(3), _n(6), _n(10)],
      options: [_n(13), _n(14), _n(15), _n(20)],
      answer: _n(15),
      explanation: 'Add 2, then 3, then 4, then 5.',
    ),
    PatternRound(
      shown: [_n(1), _n(4), _n(9), _n(16)],
      options: [_n(20), _n(23), _n(25), _n(32)],
      answer: _n(25),
      explanation: 'These are square numbers: 1 times 1, 2 times 2, and so on.',
    ),
    PatternRound(
      shown: [_n(1), _n(1), _n(2), _n(3), _n(5)],
      options: [_n(6), _n(7), _n(8), _n(10)],
      answer: _n(8),
      explanation: 'Add the last two numbers to get the next one.',
    ),
    PatternRound(
      shown: [_n(2), _n(3), _n(5), _n(7)],
      options: [_n(9), _n(10), _n(11), _n(12)],
      answer: _n(11),
      explanation: 'These are prime numbers, the same ones as on Planet Luma!',
    ),
  ],
};

/// Quick Create: ideas to draw. Never scored.
const quickCreateIdeas = [
  "A robot's pet",
  'A house for a tiny dragon',
  'A sandwich from outer space',
  'A vehicle that can go anywhere',
  'A monster who is scared of the dark',
  'A hat for a giraffe',
  'The best treehouse ever',
  'A fish that can walk',
  'A machine that tidies your room',
  'An island shaped like an animal',
  'A superhero for snails',
  'A shop that sells clouds',
];
