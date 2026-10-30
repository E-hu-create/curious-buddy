import 'package:curious_buddy/domain/discoveries/discovery_journal.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:flutter_test/flutter_test.dart';

DiscoveryJournal _journal(LearnerProgress progress, {int creations = 0}) =>
    DiscoveryJournal.build(
      progress: progress,
      missions: starterMissions,
      stories: starterStories,
      topics: starterQuizTopics,
      creations: creations,
    );

/// Everything in the app finished, with top quiz scores.
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
  return p;
}

void main() {
  group('an empty journal', () {
    final j = _journal(LearnerProgress.empty);

    test('counts nothing and welcomes a new explorer', () {
      expect(j.isEmpty, isTrue);
      expect(j.discoveries, 0);
      expect(j.rank, ExplorerRank.beginner);
      expect(j.summary, contains('first discovery'));
    });

    test('lists every badge as not yet earned', () {
      expect(j.badges, hasLength(starterMissions.length));
      expect(j.badges!.every((b) => !b.earned), isTrue);
    });

    test('suggests a first mission', () {
      expect(j.next.kind, AdventureKind.mission);
      expect(j.next.text, contains(starterMissions.first.title));
    });
  });

  group('counting', () {
    test('adds up cases, endings, stars and creations', () {
      final j = _journal(
        LearnerProgress.empty
            .withMissionResult(starterMissions.first.id, 80)
            .withStoryEnding('forest_colours', 'mist')
            .withStoryEnding('forest_colours', 'rain')
            .withStoryEnding('luma_signal', 'tow')
            .withQuizResult('space_starter', 5)
            .withQuizResult('body_starter', 4),
        creations: 2,
      );

      expect(j.casesSolved, 1);
      expect(j.endingsFound, 3);
      expect(j.quizStars, 5);
      expect(j.creationCount, 2);
      expect(j.discoveries, 11);
    });

    test('a quiz level below the pass mark earns no stars', () {
      final j = _journal(
        LearnerProgress.empty.withQuizResult('space_starter', 2),
      );
      expect(j.quizStars, 0);
      expect(j.isEmpty, isTrue);
    });

    test('quiz stars are shown per topic', () {
      final j = _journal(
        LearnerProgress.empty
            .withQuizResult('space_starter', 5)
            .withQuizResult('space_explorer', 3),
      );
      final space = j.quizzes!.firstWhere((q) => q.topic.id == 'space');
      expect(space.stars, 4);
      expect(space.maxStars, 9);
    });

    test('saved ids that no longer match any content are ignored', () {
      final j = _journal(
        LearnerProgress.empty
            .withMissionResult('old_mission', 500)
            .withStoryEnding('forest_colours', 'old_ending')
            .withStoryEnding('old_story', 'mist')
            .withQuizResult('old_level', 5),
      );
      expect(j.discoveries, 0);
    });
  });

  group('story endings', () {
    test('only found endings are included, so nothing is spoiled', () {
      final j = _journal(
        LearnerProgress.empty.withStoryEnding('forest_colours', 'mist'),
      );
      final forest = j.stories!.firstWhere(
        (s) => s.story.id == 'forest_colours',
      );

      expect([for (final e in forest.found) e.id], ['mist']);
      expect(forest.remaining, forest.story.endings.length - 1);
    });
  });

  group('ranks', () {
    for (final (count, rank, toNext) in [
      (0, ExplorerRank.beginner, 3),
      (2, ExplorerRank.beginner, 1),
      (3, ExplorerRank.keen, 7),
      (9, ExplorerRank.keen, 1),
      (10, ExplorerRank.brave, 10),
      (19, ExplorerRank.brave, 1),
      (20, ExplorerRank.master, null),
      (60, ExplorerRank.master, null),
    ]) {
      test('$count discoveries: ${rank.title}', () {
        final j = _journal(LearnerProgress.empty, creations: count);
        expect(j.rank, rank);
        expect(j.toNextRank, toNext);
      });
    }

    test('the top rank is reachable with the content in the app', () {
      expect(_journal(_everything()).rank, ExplorerRank.master);
    });
  });

  group('summary', () {
    test('mentions only what has been done, with correct plurals', () {
      expect(
        _journal(
          LearnerProgress.empty.withStoryEnding('forest_colours', 'mist'),
        ).summary,
        contains("You've found 1 story ending."),
      );
      expect(
        _journal(
          LearnerProgress.empty
              .withMissionResult(starterMissions.first.id, 80)
              .withQuizResult('space_starter', 5),
          creations: 2,
        ).summary,
        contains(
          "You've solved 1 case, earned 3 quiz stars and made 2 creations.",
        ),
      );
    });
  });

  group('next adventure', () {
    test('points at the area with the least done', () {
      final solvedAll = starterMissions.fold(
        LearnerProgress.empty,
        (LearnerProgress p, m) => p.withMissionResult(m.id, 80),
      );
      expect(_journal(solvedAll).next.kind, AdventureKind.story);

      final plusEndings = starterStories.fold(
        solvedAll,
        (LearnerProgress p, s) => p.withStoryEnding(s.id, s.endings.first.id),
      );
      expect(_journal(plusEndings).next.kind, AdventureKind.quiz);
    });

    test('a started story comes first, wherever it is in the list', () {
      final solved = starterMissions.fold(
        LearnerProgress.empty,
        (LearnerProgress p, m) => p.withMissionResult(m.id, 80),
      );
      final last = starterStories.last;
      final j = _journal(
        solved.withStoryBookmark(last.id, [last.startSceneId]),
      );

      expect(j.next.text, 'Carry on reading: ${last.title}');
    });

    test('a story with every ending found is not suggested', () {
      final first = starterStories.first;
      var p = starterMissions.fold(
        LearnerProgress.empty,
        (LearnerProgress p, m) => p.withMissionResult(m.id, 80),
      );
      for (final e in first.endings) {
        p = p.withStoryEnding(first.id, e.id);
      }
      expect(_journal(p).next.text, isNot(contains(first.title)));
    });

    test('with everything finished, it suggests making something', () {
      final j = _journal(_everything());
      expect(j.next.kind, AdventureKind.creative);
    });
  });

  group('content that could not be loaded', () {
    test('its section is left out; the rest still works', () {
      final j = DiscoveryJournal.build(
        progress: LearnerProgress.empty.withStoryEnding(
          'forest_colours',
          'mist',
        ),
        stories: starterStories,
      );

      expect(j.badges, isNull);
      expect(j.quizzes, isNull);
      expect(j.creations, isNull);
      expect(j.endingsFound, 1);
      expect(j.next.kind, AdventureKind.story);
    });

    test('with nothing loaded, it still has a suggestion', () {
      final j = DiscoveryJournal.build(progress: LearnerProgress.empty);
      expect(j.isEmpty, isTrue);
      expect(j.next.kind, AdventureKind.creative);
    });
  });
}
