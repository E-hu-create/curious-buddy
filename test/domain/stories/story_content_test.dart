import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/stories/story_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('there are three starter stories with unique ids', () {
    expect(starterStories, hasLength(3));
    expect(starterStories.map((s) => s.id).toSet(), hasLength(3));
    expect(starterStories.map((s) => s.title), [
      'The Forest That Forgot Its Colours',
      'The Lost Signal from Planet Luma',
      'The Tiny Inventor\'s Big Idea',
    ]);
  });

  for (final story in starterStories) {
    group(story.title, () {
      final graph = StoryGraph(story);

      test('passes every validation rule', () {
        expect(StoryValidator.problems(story), isEmpty);
      });

      test('has several scenes, real choices and at least two endings', () {
        expect(story.scenes.length, greaterThanOrEqualTo(6));
        expect(story.endings.length, greaterThanOrEqualTo(2));
        expect(graph.pathCount, greaterThanOrEqualTo(story.endings.length));
        final start = story.sceneById(story.startSceneId)!;
        expect(start.choices.length, greaterThanOrEqualTo(2));
      });

      test('every ending is reached by some sequence of choices', () {
        expect(graph.reachableEndingIds, {for (final e in story.endings) e.id});
      });

      test('every path finishes at an ending without revisiting a scene', () {
        void walk(List<String> path) {
          final scene = story.sceneById(path.last)!;
          expect(graph.isValidPath(path), isTrue, reason: path.join(' > '));
          if (scene.isEnding) return;
          for (final choice in scene.choices) {
            expect(path, isNot(contains(choice.nextSceneId)));
            walk([...path, choice.nextSceneId]);
          }
        }

        walk([story.startSceneId]);
      });

      test('uses a distinct set of pictures from the other stories', () {
        final mine = {for (final s in story.scenes) s.picture};
        for (final other in starterStories.where((s) => s != story)) {
          final theirs = {for (final s in other.scenes) s.picture};
          expect(mine.intersection(theirs), isEmpty);
        }
      });

      test('choices tell the child what happened, without lecturing', () {
        for (final scene in story.scenes) {
          for (final choice in scene.choices) {
            expect(choice.consequence, isNotNull, reason: choice.id);
            expect(
              choice.consequence!.toLowerCase(),
              isNot(matches(RegExp(r'\b(should|wrong|bad|must)\b'))),
            );
          }
        }
      });

      test('never asks for personal information', () {
        final text = [
          story.intro,
          for (final s in story.scenes) ...[
            s.text,
            for (final c in s.choices) c.text,
          ],
        ].join(' ').toLowerCase();
        expect(
          text,
          isNot(matches(RegExp(r'your (name|address|school|age|phone)'))),
        );
      });
    });
  }

  test('scene pictures cover every story picture', () {
    final used = {
      for (final story in starterStories)
        for (final scene in story.scenes) scene.picture,
    };
    expect(used, ScenePicture.values.toSet());
  });
}
