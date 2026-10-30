import 'dart:math';

import 'package:curious_buddy/domain/games/game_content.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:flutter_test/flutter_test.dart';

int? _nextByCheck(List<int> shown, int Function(List<int>) rule) => rule(shown);

void main() {
  group('levels', () {
    test('each game has its levels, with unique ids', () {
      expect(ArenaRules.allLevelIds, hasLength(15));
      expect(ArenaRules.allLevelIds, contains('memory_1'));
      expect(const GameLevel(GameKind.spot, 3).name, 'Expert');
    });

    test('level 1 is open; later ones open with any star', () {
      const two = GameLevel(GameKind.memory, 2);
      const three = GameLevel(GameKind.memory, 3);

      expect(
        ArenaRules.isOpen(const GameLevel(GameKind.memory, 1), {}),
        isTrue,
      );
      expect(ArenaRules.isOpen(two, {}), isFalse);
      expect(ArenaRules.isOpen(two, {'memory_1': 0}), isFalse);
      expect(ArenaRules.isOpen(two, {'memory_1': 1}), isTrue);
      expect(ArenaRules.isOpen(three, {'memory_1': 3}), isFalse);
    });

    test('total stars count only known levels, at most 3 each', () {
      expect(
        ArenaRules.totalStars({'memory_1': 2, 'pattern_1': 3, 'old_game': 3}),
        5,
      );
      expect(ArenaRules.totalStars({'memory_1': 9}), 3);
    });
  });

  group('MemoryGame', () {
    MemoryGame game([int pairs = 3, int seed = 1]) =>
        MemoryGame(pairs: pairs, random: Random(seed));

    /// Index of the match for [index].
    int match(MemoryGame g, int index) => [
      for (var i = 0; i < g.cards.length; i++)
        if (i != index && g.cards[i] == g.cards[index]) i,
    ].single;

    test('deals exactly two of each card', () {
      for (final pairs in [3, 4, 6]) {
        final g = game(pairs);
        expect(g.cards, hasLength(pairs * 2));
        expect(g.cards.toSet(), hasLength(pairs));
      }
    });

    test('a matching pair stays up', () {
      final g = game();
      expect(g.flip(0), FlipResult.first);
      expect(g.flip(match(g, 0)), FlipResult.pair);
      expect(g.isFaceUp(0), isTrue);
      expect(g.moves, 1);
    });

    test('a mismatch stays showing until the next tap', () {
      final g = game();
      final other = [
        for (var i = 1; i < g.cards.length; i++)
          if (g.cards[i] != g.cards[0]) i,
      ].first;

      expect(g.flip(0), FlipResult.first);
      expect(g.flip(other), FlipResult.mismatch);
      expect(g.isFaceUp(0), isTrue);

      final third = [
        for (var i = 1; i < g.cards.length; i++)
          if (i != other) i,
      ].first;
      g.flip(third);
      expect(g.isFaceUp(0), third == 0);
      expect(g.isFaceUp(other), isFalse);
    });

    test('tapping a card already up, or off the board, does nothing', () {
      final g = game()..flip(0);
      expect(g.flip(0), FlipResult.ignored);
      expect(g.flip(99), FlipResult.ignored);
      expect(g.moves, 0);
    });

    test('a perfect game wins with 3 stars', () {
      final g = game();
      for (var i = 0; i < g.cards.length; i++) {
        if (g.isFaceUp(i)) continue;
        g
          ..flip(i)
          ..flip(match(g, i));
      }
      expect(g.isWon, isTrue);
      expect(g.moves, 3);
      expect(g.stars, 3);
    });

    test('more moves earn fewer stars, but never none', () {
      expect(
        [
          for (final moves in [3, 4, 5, 6, 7, 20]) _starsAfter(moves),
        ],
        [3, 3, 3, 2, 1, 1],
      );
    });
  });

  group('Pattern Power content', () {
    test('three levels of five fair rounds', () {
      expect(patternLevels.keys, [1, 2, 3]);
      for (final rounds in patternLevels.values) {
        expect(rounds, hasLength(5));
        expect(patternProblems(rounds), isEmpty);
      }
    });

    test('number answers really follow their rules', () {
      int value(GameToken t) => t.number!;
      void check(int level, int round, int Function(List<int>) rule) {
        final r = patternLevels[level]![round];
        expect(
          _nextByCheck([for (final t in r.shown) value(t)], rule),
          value(r.answer),
          reason: 'level $level round $round',
        );
      }

      check(2, 0, (s) => s.last + 2);
      check(2, 1, (s) => s.last + 5);
      check(2, 2, (s) => s.last - 2);
      check(2, 3, (s) => s.last + 3);
      check(2, 4, (s) => s.last - 10);
      check(3, 0, (s) => s.last * 2);
      check(3, 1, (s) => s.last + s.length + 1);
      check(3, 2, (s) => (s.length + 1) * (s.length + 1));
      check(3, 3, (s) => s[s.length - 1] + s[s.length - 2]);
      expect(value(patternLevels[3]![4].answer), 11, reason: 'next prime');
    });

    test('the validator catches unfair rounds', () {
      const bad = PatternRound(
        shown: [GameToken.number(1)],
        options: [GameToken.number(1), GameToken.number(1)],
        answer: GameToken.number(2),
        explanation: '',
      );
      final problems = patternProblems(const [bad]);

      expect(problems, contains(contains('too short')));
      expect(problems, contains(contains('3 or 4 options')));
      expect(problems, contains(contains('options repeat')));
      expect(problems, contains(contains('exactly one right')));
      expect(problems, contains(contains('no explanation')));
    });
  });

  group('SpotGame', () {
    SpotGame game([int seed = 3]) =>
        SpotGame(rows: 3, columns: 3, changes: 2, random: Random(seed));

    test('only the chosen places differ', () {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(seed);
        expect(g.changed, hasLength(2));
        for (var i = 0; i < g.first.length; i++) {
          expect(g.first[i] != g.second[i], g.changed.contains(i));
        }
      }
    });

    test('finding every change wins with 3 stars', () {
      final g = game();
      final places = g.changed.toList();

      expect(g.tap(places[0]), SpotResult.found);
      expect(g.tap(places[0]), SpotResult.ignored, reason: 'already found');
      expect(g.tap(places[1]), SpotResult.won);
      expect(g.stars, 3);
    });

    test('wrong taps earn fewer stars, but never none', () {
      final g = game();
      final wrong = [
        for (var i = 0; i < g.first.length; i++)
          if (!g.changed.contains(i)) i,
      ].first;

      g.tap(wrong);
      expect(g.stars, 2);
      g
        ..tap(wrong)
        ..tap(wrong);
      expect(g.stars, 1);
      expect(g.misses, 3);
      g.changed.forEach(g.tap);
      expect(g.isWon, isTrue);
      expect(g.stars, 1);
    });
  });

  test('Quick Create has plenty of unique, kind ideas', () {
    expect(quickCreateIdeas.length, greaterThanOrEqualTo(10));
    expect(quickCreateIdeas.toSet(), hasLength(quickCreateIdeas.length));
  });
}

/// Plays a 3-pair game with exactly [moves] moves and returns its stars.
int _starsAfter(int moves) {
  final g = MemoryGame(pairs: 3, random: Random(1));
  int match(int index) => [
    for (var i = 0; i < g.cards.length; i++)
      if (i != index && g.cards[i] == g.cards[index]) i,
  ].single;

  var wasted = moves - 3;
  final first = 0;
  final wrong = [
    for (var i = 1; i < g.cards.length; i++)
      if (g.cards[i] != g.cards[first]) i,
  ].first;
  while (wasted > 0) {
    g
      ..flip(first)
      ..flip(wrong)
      ..flip(first == 0 ? wrong : first);
    g.showing.clear();
    wasted--;
  }
  for (var i = 0; i < g.cards.length; i++) {
    if (g.isFaceUp(i)) continue;
    g
      ..flip(i)
      ..flip(match(i));
  }
  return g.stars;
}
