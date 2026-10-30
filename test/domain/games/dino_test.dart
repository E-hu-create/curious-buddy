import 'dart:math';

import 'package:curious_buddy/domain/games/dino.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers everything right, except for [wrongFirst] extra picks.
void play(DinoExpedition e, {int wrongFirst = 0}) {
  var wrongLeft = wrongFirst;
  void answer(DinoCreature right) {
    for (final option in e.options) {
      if (wrongLeft == 0) break;
      if (option != right) {
        expect(e.pick(option), DinoPickResult.wrong);
        wrongLeft--;
      }
    }
    expect(e.pick(right), DinoPickResult.right);
    e.carryOn();
  }

  for (final creature in e.place.creatures) {
    expect(e.investigate(creature), isTrue);
    answer(creature);
  }
  for (final task in e.place.mission) {
    answer(task.answer);
  }
}

void main() {
  DinoExpedition expedition([DinoPlace place = DinoPlace.fernForest]) =>
      DinoExpedition(place: place, random: Random(1));

  group('content', () {
    test('passes every fairness check', () {
      expect(dinoProblems(), isEmpty);
    });

    test('nine creatures in three places, each with a home', () {
      expect(DinoCreature.values, hasLength(9));
      expect(DinoPlace.values, hasLength(3));
      for (final place in DinoPlace.values) {
        for (final creature in place.creatures) {
          expect(creature.place, place);
        }
      }
    });

    test('the sea creatures are honestly not dinosaurs', () {
      expect(DinoPlace.ancientSea.creatures.any((c) => c.isDinosaur), isFalse);
      for (final creature in DinoPlace.ancientSea.creatures) {
        expect(creature.fact, contains('not a dinosaur'));
      }
      expect(DinoPlace.fernForest.creatures.every((c) => c.isDinosaur), isTrue);
    });

    test('saved ids are stable and count as game stars', () {
      expect(DinoRules.allIds, {
        'dino_fern_forest',
        'dino_open_plains',
        'dino_ancient_sea',
      });
      expect(ArenaRules.allLevelIds, containsAll(DinoRules.allIds));
      expect(ArenaRules.totalStars({'dino_fern_forest': 2, 'memory_1': 1}), 3);
    });
  });

  group('rules', () {
    test('the first place is open; finishing one opens the next', () {
      expect(DinoRules.isOpen(DinoPlace.fernForest, {}), isTrue);
      expect(DinoRules.isOpen(DinoPlace.openPlains, {}), isFalse);
      expect(
        DinoRules.isOpen(DinoPlace.openPlains, {'dino_fern_forest': 1}),
        isTrue,
      );
      expect(
        DinoRules.isOpen(DinoPlace.ancientSea, {'dino_fern_forest': 3}),
        isFalse,
      );
    });

    test('finishing a place adds its creatures to the guide', () {
      expect(DinoRules.foundIn({}), isEmpty);
      expect(
        DinoRules.foundIn({'dino_open_plains': 1}),
        DinoPlace.openPlains.creatures.toSet(),
      );
      expect(DinoRules.isComplete({'dino_open_plains': 1}), isFalse);
      expect(
        DinoRules.isComplete({for (final id in DinoRules.allIds) id: 1}),
        isTrue,
      );
    });
  });

  group('expedition', () {
    test('a perfect trip goes explore, identify, mission, done', () {
      final e = expedition();
      expect(e.stage, DinoStage.explore);
      play(e);
      expect(e.stage, DinoStage.done);
      expect(e.found, e.place.creatures.toSet());
      expect(e.stars, 3);
    });

    test('stars follow the wrong picks, and never fall below one', () {
      for (final (wrong, stars) in [(0, 3), (1, 2), (2, 2), (3, 1), (8, 1)]) {
        final e = expedition();
        play(e, wrongFirst: wrong);
        expect(e.mistakes, wrong);
        expect(e.stars, stars);
      }
    });

    test('identify offers the creature and two others', () {
      for (var seed = 0; seed < 20; seed++) {
        final e = DinoExpedition(
          place: DinoPlace.openPlains,
          random: Random(seed),
        )..investigate(DinoCreature.triceratops);
        expect(e.options, hasLength(3));
        expect(e.options.toSet(), hasLength(3));
        expect(e.options, contains(DinoCreature.triceratops));
      }
    });

    test('a wrong pick brings the second clue and locks that pick', () {
      final e = expedition()..investigate(DinoCreature.stegosaurus);
      expect(e.clue, DinoCreature.stegosaurus.clues[0]);

      final wrong = e.options.firstWhere((o) => o != DinoCreature.stegosaurus);
      expect(e.pick(wrong), DinoPickResult.wrong);
      expect(e.clue, DinoCreature.stegosaurus.clues[1]);
      expect(e.pick(wrong), DinoPickResult.ignored);
      expect(e.mistakes, 1);
      expect(e.stage, DinoStage.identify);
    });

    test('ignores what does not fit the moment', () {
      final e = expedition();
      expect(e.investigate(DinoCreature.mosasaurus), isFalse);
      expect(e.pick(DinoCreature.stegosaurus), DinoPickResult.ignored);

      e.investigate(DinoCreature.stegosaurus);
      expect(e.investigate(DinoCreature.diplodocus), isFalse);
      final outside = DinoCreature.values.firstWhere(
        (c) => !e.options.contains(c),
      );
      expect(e.pick(outside), DinoPickResult.ignored);

      e
        ..pick(DinoCreature.stegosaurus)
        ..carryOn();
      expect(e.investigate(DinoCreature.stegosaurus), isFalse);
    });

    test('a solved mission question waits, then moves on', () {
      final e = expedition();
      for (final creature in e.place.creatures) {
        e
          ..investigate(creature)
          ..pick(creature)
          ..carryOn();
      }
      expect(e.stage, DinoStage.mission);
      expect(e.taskIndex, 0);
      expect(e.options.toSet(), e.place.creatures.toSet());

      e.pick(e.task.answer);
      expect(e.taskSolved, isTrue);
      expect(e.pick(e.options.first), DinoPickResult.ignored);

      e.carryOn();
      expect(e.taskIndex, 1);
      expect(e.taskSolved, isFalse);
      expect(e.wrongPicks, isEmpty);
    });

    test('every place can be finished', () {
      for (final place in DinoPlace.values) {
        final e = expedition(place);
        play(e);
        expect(e.stage, DinoStage.done);
      }
    });
  });

  group('Memory pictures', () {
    test('there are enough for the biggest board, each with a word', () {
      expect(allPictureTokens.length, greaterThanOrEqualTo(6));
      expect(allPictureTokens.toSet(), hasLength(allPictureTokens.length));
      for (final token in allPictureTokens) {
        expect(token.label, isNotEmpty);
      }
    });

    test('Memory Match deals pictures', () {
      final game = MemoryGame(pairs: 6, random: Random(1));
      expect(game.cards.every((c) => c.picture != null), isTrue);
    });

    test('tokens of different kinds are never equal', () {
      expect(
        const GameToken.picture(GamePicture.fish),
        isNot(const GameToken.shape(GameShape.star, GameColor.sun)),
      );
      expect(
        const GameToken.picture(GamePicture.fish),
        const GameToken.picture(GamePicture.fish),
      );
    });
  });
}
