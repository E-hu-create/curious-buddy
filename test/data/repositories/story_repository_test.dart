import 'package:curious_buddy/data/repositories/story_repository.dart';
import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:flutter_test/flutter_test.dart';

Story _copy(Story source, {String? id, List<StoryScene>? scenes}) => Story(
  id: id ?? source.id,
  title: source.title,
  tagline: source.tagline,
  cover: source.cover,
  intro: source.intro,
  startSceneId: source.startSceneId,
  scenes: scenes ?? source.scenes,
);

void main() {
  test('loads all three starter stories offline', () async {
    final stories = await BundledStoryRepository().loadStories();

    expect(
      [for (final s in stories) s.id],
      ['forest_colours', 'luma_signal', 'tiny_inventor'],
    );
  });

  test('leaves out invalid stories instead of showing them broken', () async {
    final forest = starterStories.first;
    final noScenes = _copy(forest, id: 'empty', scenes: const []);
    final brokenLink = _copy(
      forest,
      id: 'broken_link',
      scenes: [
        for (final scene in forest.scenes)
          scene.id == forest.startSceneId
              ? StoryScene(
                  id: scene.id,
                  title: scene.title,
                  text: scene.text,
                  picture: scene.picture,
                  choices: const [
                    StoryChoice(id: 'x', text: 'Go', nextSceneId: 'nowhere'),
                    StoryChoice(id: 'y', text: 'Go', nextSceneId: 'mist'),
                  ],
                )
              : scene,
      ],
    );

    final stories = await BundledStoryRepository(
      stories: [noScenes, forest, brokenLink],
    ).loadStories();

    expect([for (final s in stories) s.id], ['forest_colours']);
  });

  test('leaves out a second story with the same id', () async {
    final forest = starterStories.first;
    final stories = await BundledStoryRepository(
      stories: [forest, forest],
    ).loadStories();

    expect(stories, hasLength(1));
  });

  test('an empty catalogue loads as an empty list', () async {
    expect(await BundledStoryRepository(stories: []).loadStories(), isEmpty);
  });
}
