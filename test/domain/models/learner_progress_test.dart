import 'dart:convert';

import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearnerProgress.tryFromJson', () {
    test('round-trips through toJson', () {
      const progress = LearnerProgress(
        completedMissionIds: {'ocean_1', 'space-2'},
        completedStoryIds: {'dragon'},
      );

      expect(LearnerProgress.tryFromJson(progress.toJson()), progress);
    });

    test('rejects non-map input', () {
      expect(LearnerProgress.tryFromJson(null), isNull);
      expect(LearnerProgress.tryFromJson('text'), isNull);
      expect(LearnerProgress.tryFromJson(<Object?>[]), isNull);
    });

    test('rejects missing, invalid and future schema versions', () {
      expect(LearnerProgress.tryFromJson(<String, Object?>{}), isNull);
      expect(LearnerProgress.tryFromJson({'schemaVersion': 'one'}), isNull);
      expect(LearnerProgress.tryFromJson({'schemaVersion': 0}), isNull);
      expect(
        LearnerProgress.tryFromJson({
          'schemaVersion': LearnerProgress.schemaVersion + 1,
        }),
        isNull,
      );
    });

    test('drops malformed ids but keeps valid ones', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 1,
        'completedMissionIds': [
          'ok_1',
          42,
          null,
          '',
          'Has Spaces',
          'x' * (LearnerProgress.maxIdLength + 1),
        ],
        'completedStoryIds': 'not-a-list',
      });

      expect(progress, isNotNull);
      expect(progress!.completedMissionIds, {'ok_1'});
      expect(progress.completedStoryIds, isEmpty);
    });
  });

  group('mission scores (schema 2)', () {
    test('round-trips best points', () {
      const progress = LearnerProgress(
        completedMissionIds: {'moon'},
        missionBestPoints: {'moon': 120},
      );

      expect(LearnerProgress.tryFromJson(progress.toJson()), progress);
    });

    test('reads version 1 data (no scores) without losing missions', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 1,
        'completedMissionIds': ['moon'],
      });

      expect(progress!.completedMissionIds, {'moon'});
      expect(progress.missionBestPoints, isEmpty);
    });

    test('drops malformed scores but keeps valid ones', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 2,
        'missionBestPoints': {
          'ok': 50,
          'negative': -5,
          'huge': LearnerProgress.maxPoints + 1,
          'text': 'lots',
          'Bad Id': 10,
        },
      });

      expect(progress!.missionBestPoints, {'ok': 50});
    });

    test('withMissionResult records completion and keeps the best score', () {
      final first = LearnerProgress.empty.withMissionResult('moon', 100);
      final worse = first.withMissionResult('moon', 60);
      final better = worse.withMissionResult('moon', 140);

      expect(first.completedMissionIds, {'moon'});
      expect(worse.missionBestPoints['moon'], 100);
      expect(better.missionBestPoints['moon'], 140);
    });

    test('total points add each mission best', () {
      final progress = LearnerProgress.empty
          .withMissionResult('a', 100)
          .withMissionResult('b', 50)
          .withMissionResult('a', 80);

      expect(progress.totalMissionPoints, 150);
    });
  });

  group('story endings and bookmarks (schema 3)', () {
    test('round-trips endings and bookmarks through JSON', () {
      final progress = LearnerProgress.empty
          .withStoryEnding('forest', 'mist')
          .withStoryEnding('forest', 'rain')
          .withStoryBookmark('luma', ['camp', 'ridge']);

      final json = jsonDecode(jsonEncode(progress.toJson()));
      expect(LearnerProgress.tryFromJson(json), progress);
    });

    test('an ending marks the story finished and clears its bookmark', () {
      final progress = LearnerProgress.empty
          .withStoryBookmark('forest', ['a', 'b'])
          .withStoryEnding('forest', 'mist');

      expect(progress.completedStoryIds, {'forest'});
      expect(progress.storyEndings['forest'], {'mist'});
      expect(progress.storyBookmarks, isEmpty);
    });

    test('finding the same ending twice counts once', () {
      final progress = LearnerProgress.empty
          .withStoryEnding('forest', 'mist')
          .withStoryEnding('forest', 'mist');

      expect(progress.storyEndings['forest'], {'mist'});
    });

    test('bookmarks can be replaced and removed', () {
      final progress = LearnerProgress.empty
          .withStoryBookmark('forest', ['a'])
          .withStoryBookmark('forest', ['a', 'b']);
      expect(progress.storyBookmarks['forest'], ['a', 'b']);
      expect(progress.withoutStoryBookmark('forest').storyBookmarks, isEmpty);
    });

    test('bookmark order matters for equality; ending order does not', () {
      expect(
        LearnerProgress.empty.withStoryBookmark('s', ['a', 'b']),
        isNot(LearnerProgress.empty.withStoryBookmark('s', ['b', 'a'])),
      );
      expect(
        LearnerProgress.empty
            .withStoryEnding('s', 'x')
            .withStoryEnding('s', 'y'),
        LearnerProgress.empty
            .withStoryEnding('s', 'y')
            .withStoryEnding('s', 'x'),
      );
    });

    test('older saved data is read without story details', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 2,
        'completedStoryIds': ['forest'],
        'storyEndings': {
          'forest': ['mist'],
        },
      });

      expect(progress!.completedStoryIds, {'forest'});
      expect(progress.storyEndings, isEmpty);
      expect(progress.storyBookmarks, isEmpty);
    });

    test('drops malformed endings and bookmarks but keeps valid ones', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 3,
        'storyEndings': {
          'ok': ['mist', 'Bad Id', 7],
          'empty': <Object>[],
          'Bad Key': ['mist'],
          'text': 'mist',
        },
        'storyBookmarks': {
          'ok': ['a', 'b'],
          'partly_bad': ['a', 'Bad Id'],
          'empty': <Object>[],
          'not_list': 'a',
          'too_long': List.filled(LearnerProgress.maxBookmarkLength + 1, 'a'),
        },
      });

      expect(progress!.storyEndings, {
        'ok': {'mist'},
      });
      expect(progress.storyBookmarks, {
        'ok': ['a', 'b'],
      });
    });

    test('unexpected shapes for the story maps are ignored', () {
      final progress = LearnerProgress.tryFromJson({
        'schemaVersion': 3,
        'storyEndings': ['mist'],
        'storyBookmarks': 42,
      });

      expect(progress!.storyEndings, isEmpty);
      expect(progress.storyBookmarks, isEmpty);
    });
  });
}
