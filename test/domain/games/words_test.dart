import 'dart:math';

import 'package:curious_buddy/domain/games/words.dart';
import 'package:flutter_test/flutter_test.dart';

/// Places the rest of the word correctly, tile by tile.
void solve(WordGame g) {
  final word = g.puzzle.word;
  for (var slot = 0; slot < word.length; slot++) {
    if (g.slots[slot] != null) continue;
    final tile = [
      for (var i = 0; i < g.tiles.length; i++)
        if (g.tiles[i] == word[slot] && !g.isUsed(i)) i,
    ].first;
    g.place(tile);
  }
}

/// Fills the board with a wrong spelling.
void misspell(WordGame g) {
  final order = List.generate(g.tiles.length, (i) => i);
  for (final tiles in [order, order.reversed.toList()]) {
    if (tiles.map((t) => g.tiles[t]).join() == g.puzzle.word) continue;
    tiles.forEach(g.place);
    return;
  }
}

void main() {
  WordGame game([int level = 1, int seed = 1]) =>
      WordGame(level: level, random: Random(seed));

  group('content', () {
    test('passes every fairness check', () {
      expect(wordProblems(), isEmpty);
    });

    test('words get longer with each level', () {
      int longest(int level) =>
          wordLevels[level]!.map((p) => p.word.length).reduce(max);
      int shortest(int level) =>
          wordLevels[level]!.map((p) => p.word.length).reduce(min);
      expect(longest(1), lessThan(shortest(2)));
      expect(longest(2), lessThan(shortest(3)));
    });

    test('every level has enough words for variety', () {
      for (final words in wordLevels.values) {
        expect(words.length, greaterThan(WordGame.rounds));
      }
    });
  });

  group('the board', () {
    test('letters are the word, mixed up, on every deal', () {
      for (final level in wordLevels.keys) {
        for (var seed = 0; seed < 40; seed++) {
          final g = game(level, seed);
          expect(g.tiles.join(), isNot(g.puzzle.word));
          expect(
            ([...g.tiles]..sort()).join(),
            (g.puzzle.word.split('')..sort()).join(),
          );
        }
      }
    });

    test('a game has no repeated words', () {
      final g = game(2);
      final words = {g.puzzle.word};
      while (g.nextRound()) {
        words.add(g.puzzle.word);
      }
      expect(words, hasLength(WordGame.rounds));
    });

    test('tiles fill the first space, and go back when tapped', () {
      final g = game()..place(2);
      expect(g.slots.first, 2);
      expect(g.isUsed(2), isTrue);
      expect(g.place(2), isFalse);

      expect(g.remove(0), isTrue);
      expect(g.isUsed(2), isFalse);
      expect(g.remove(0), isFalse);
    });

    test('the right spelling solves it, and locks the board', () {
      final g = game();
      solve(g);
      expect(g.isSolved, isTrue);
      expect(g.remove(0), isFalse);
      expect(g.hint(), isFalse);
      expect(g.stars, 3);
    });

    test('a wrong spelling is marked, and can be fixed', () {
      final g = game();
      misspell(g);
      expect(g.isWrong, isTrue);
      expect(g.isSolved, isFalse);
      expect(g.mistakes, 1);

      for (var i = 0; i < g.slots.length; i++) {
        g.remove(i);
      }
      expect(g.isWrong, isFalse);
      solve(g);
      expect(g.isSolved, isTrue);
    });
  });

  group('hints', () {
    test('hints alone can finish any word', () {
      for (final level in wordLevels.keys) {
        for (var seed = 0; seed < 30; seed++) {
          final g = game(level, seed);
          for (var i = 0; i < 12 && !g.isSolved; i++) {
            g.hint();
          }
          expect(g.isSolved, isTrue, reason: g.puzzle.word);
        }
      }
    });

    test('a hint fixes a wrong board without counting as a mistake', () {
      for (var seed = 0; seed < 30; seed++) {
        final g = game(2, seed);
        misspell(g);
        final mistakes = g.mistakes;
        for (var i = 0; i < 12 && !g.isSolved; i++) {
          g.hint();
        }
        expect(g.isSolved, isTrue, reason: g.puzzle.word);
        expect(g.mistakes, mistakes);
      }
    });

    test('a hinted letter stays put', () {
      final g = game()..hint();
      expect(g.locked, {0});
      expect(g.tiles[g.slots[0]!], g.puzzle.word[0]);
      expect(g.remove(0), isFalse);
      expect(g.hints, 1);
    });
  });

  group('stars', () {
    test('follow mistakes and hints, and never fall below one', () {
      for (final (slips, stars) in [(0, 3), (1, 2), (3, 2), (4, 1), (9, 1)]) {
        final g = game(3);
        for (var i = 0; i < slips; i++) {
          g.hint();
          if (g.isSolved) g.nextRound();
        }
        expect(g.hints, slips);
        expect(g.stars, stars);
      }
    });
  });
}
