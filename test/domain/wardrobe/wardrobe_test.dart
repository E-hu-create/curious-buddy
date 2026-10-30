import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/discoveries/discovery_journal.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/wardrobe/buddy_wardrobe.dart';
import 'package:curious_buddy/domain/wardrobe/wardrobe.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

DiscoveryJournal _journal(LearnerProgress progress, {int creations = 0}) =>
    DiscoveryJournal.build(
      progress: progress,
      missions: starterMissions,
      stories: starterStories,
      topics: starterQuizTopics,
      creations: creations,
    );

LearnerProgress _everything() {
  var p = LearnerProgress.empty;
  for (final m in starterMissions) {
    p = p.withMissionResult(m.id, 100);
  }
  for (final s in starterStories) {
    for (final e in s.endings) {
      p = p.withStoryEnding(s.id, e.id);
    }
  }
  for (final t in starterQuizTopics) {
    for (final l in t.levels) {
      p = p.withQuizResult(l.id, l.questions.length);
    }
  }
  for (final id in ArenaRules.allLevelIds) {
    p = p.withGameResult(id, 3);
  }
  return p;
}

void main() {
  group('unlocking', () {
    test('a new explorer has earned nothing', () {
      final j = _journal(LearnerProgress.empty);
      expect(WardrobeItem.values.where((i) => i.isUnlocked(j)), isEmpty);
    });

    test('each activity earns something', () {
      expect(
        WardrobeItem.detectiveHat.isUnlocked(
          _journal(
            LearnerProgress.empty.withMissionResult(
              starterMissions.first.id,
              50,
            ),
          ),
        ),
        isTrue,
      );
      expect(
        WardrobeItem.partyHat.isUnlocked(
          _journal(
            LearnerProgress.empty.withStoryEnding('forest_colours', 'mist'),
          ),
        ),
        isTrue,
      );
      expect(
        WardrobeItem.roundGlasses.isUnlocked(
          _journal(LearnerProgress.empty.withQuizResult('space_starter', 5)),
        ),
        isTrue,
      );
      expect(
        WardrobeItem.bowTie.isUnlocked(
          _journal(LearnerProgress.empty, creations: 1),
        ),
        isTrue,
      );
    });

    test('everything can be earned with the content in the app', () {
      final j = _journal(_everything(), creations: 3);
      expect(WardrobeItem.values.every((i) => i.isUnlocked(j)), isTrue);
    });

    test('every slot has something to earn', () {
      for (final slot in WardrobeSlot.values) {
        expect(WardrobeItem.values.where((i) => i.slot == slot), isNotEmpty);
      }
    });

    test('progress text is honest and never goes past the goal', () {
      final j = _journal(
        LearnerProgress.empty.withStoryEnding('forest_colours', 'mist'),
      );
      expect(WardrobeItem.wizardHat.progressText(j), '1 of 6 story endings');
      expect(WardrobeItem.partyHat.progressText(j), '1 of 1 story ending');
    });
  });

  group('BuddyLook', () {
    test('each slot holds one item', () {
      final look = BuddyLook.none
          .wearing(WardrobeItem.partyHat)
          .wearing(WardrobeItem.crown)
          .wearing(WardrobeItem.sunglasses);

      expect(look.hat, WardrobeItem.crown);
      expect(look.glasses, WardrobeItem.sunglasses);
      expect(look.neck, isNull);
      expect(look.items, hasLength(2));
    });

    test('taking something off leaves the rest', () {
      final look = BuddyLook.none
          .wearing(WardrobeItem.crown)
          .wearing(WardrobeItem.medal)
          .without(WardrobeSlot.hat);

      expect(look.hat, isNull);
      expect(look.neck, WardrobeItem.medal);
    });

    test('round-trips through the saved form', () {
      final look = BuddyLook.none
          .wearing(WardrobeItem.wizardHat)
          .wearing(WardrobeItem.scarf);

      expect(BuddyLook.fromSaved(look.toSaved()), look);
    });

    test('unknown items and items in the wrong slot are ignored', () {
      final look = BuddyLook.fromSaved(const {
        'hat': 'jetpack',
        'glasses': 'crown',
        'neck': 'medal',
      });

      expect(look.hat, isNull);
      expect(look.glasses, isNull);
      expect(look.neck, WardrobeItem.medal);
    });
  });

  group('saved progress (schema 5)', () {
    test('the outfit round-trips, and older data has none', () {
      final saved = LearnerProgress.empty.copyWith(
        buddyLook: const {'hat': 'crown'},
      );
      expect(LearnerProgress.tryFromJson(saved.toJson()), saved);
      expect(
        LearnerProgress.tryFromJson({
          'schemaVersion': 4,
          'buddyLook': {'hat': 'crown'},
        })!.buddyLook,
        isEmpty,
      );
    });

    test('malformed entries are dropped', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 5,
        'buddyLook': {'hat': 'crown', 'neck': 7, 'bad key': 'medal'},
      });
      expect(progress!.buddyLook, {'hat': 'crown'});
    });

    test('the outfit takes part in equality', () {
      expect(
        LearnerProgress.empty.copyWith(buddyLook: const {'hat': 'crown'}),
        isNot(LearnerProgress.empty),
      );
    });
  });

  group('BuddyWardrobe', () {
    late InMemoryKeyValueStore store;
    late LocalProgressRepository progress;

    setUp(() {
      store = InMemoryKeyValueStore();
      progress = LocalProgressRepository(store);
    });

    test('saves the outfit without touching other progress', () async {
      await progress.save(LearnerProgress.empty.withQuizResult('space_a', 4));
      final wardrobe = BuddyWardrobe(progressRepository: progress);
      await wardrobe.load();

      await wardrobe.wear(WardrobeItem.crown);

      final saved = await progress.load();
      expect(saved.buddyLook, {'hat': 'crown'});
      expect(saved.quizBest, {'space_a': 4});
      wardrobe.dispose();
    });

    test('the outfit is back after a restart', () async {
      final first = BuddyWardrobe(progressRepository: progress);
      await first.load();
      await first.wear(WardrobeItem.medal);
      first.dispose();

      final again = BuddyWardrobe(progressRepository: progress);
      await again.load();
      expect(again.look.neck, WardrobeItem.medal);
      again.dispose();
    });

    test('takes things off, and a reset clears the outfit', () async {
      final wardrobe = BuddyWardrobe(progressRepository: progress);
      await wardrobe.load();
      await wardrobe.wear(WardrobeItem.crown);
      await wardrobe.wear(WardrobeItem.bowTie);

      await wardrobe.takeOff(WardrobeSlot.hat);
      expect(wardrobe.look.hat, isNull);

      await progress.clear();
      await wardrobe.load();
      expect(wardrobe.look.isEmpty, isTrue);
      wardrobe.dispose();
    });

    test('storage failures leave Buddy working', () async {
      final wardrobe = BuddyWardrobe(
        progressRepository: LocalProgressRepository(ReadOnlyKeyValueStore()),
      );
      await wardrobe.load();
      await wardrobe.wear(WardrobeItem.crown);

      expect(wardrobe.look.hat, WardrobeItem.crown, reason: 'this session');
      wardrobe.dispose();
    });
  });
}
