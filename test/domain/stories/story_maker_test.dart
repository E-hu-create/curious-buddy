import 'dart:math';

import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_maker.dart';
import 'package:curious_buddy/domain/stories/story_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every story the maker can make.
Iterable<Story> everyStory() sync* {
  for (final hero in StoryMaker.heroes) {
    for (final place in StoryMaker.places) {
      for (final mystery in StoryMaker.mysteries) {
        yield StoryMaker.make(hero, place, mystery);
      }
    }
  }
}

String everyWord(Story story) => [
  story.title,
  story.intro,
  for (final scene in story.scenes) ...[
    scene.title,
    scene.text,
    for (final choice in scene.choices) ...[
      choice.text,
      choice.consequence ?? '',
    ],
    scene.ending?.discovery ?? '',
  ],
].join(' ');

void main() {
  test('there are 512 different stories to make', () {
    expect(StoryMaker.combinations, 512);
    expect(everyStory().map((s) => s.id).toSet(), hasLength(512));
  });

  test('every made story passes every validation rule', () {
    for (final story in everyStory()) {
      expect(StoryValidator.problems(story), isEmpty, reason: story.id);
    }
  });

  test('every made story has real choices and three endings', () {
    for (final story in everyStory()) {
      final graph = StoryGraph(story);
      expect(story.endings, hasLength(3));
      expect(graph.reachableEndingIds, hasLength(3));
      expect(graph.pathCount, greaterThanOrEqualTo(4));
    }
  });

  test('no blanks are left unfilled', () {
    for (final story in everyStory()) {
      final words = everyWord(story);
      expect(words, isNot(contains('{')), reason: story.id);
      expect(words, isNot(contains('}')), reason: story.id);
    }
  });

  test('sentences never start with a small "the"', () {
    for (final story in everyStory()) {
      for (final scene in story.scenes) {
        expect(scene.text, isNot(startsWith('the ')));
        expect(scene.text, isNot(contains('. the ')));
      }
    }
  });

  test('made stories are not saved, so progress stays tidy', () {
    for (final story in everyStory().take(20)) {
      expect(story.remember, isFalse);
    }
  });

  test('every made story is safe for children', () {
    const filter = ChildSafetyFilter();
    for (final story in everyStory()) {
      for (final scene in story.scenes) {
        expect(filter.check(scene.text), isNull, reason: scene.text);
      }
    }
  });

  test('water and electricity stories keep a grown-up in charge', () {
    MakerMystery mystery(String id) =>
        StoryMaker.mysteries.firstWhere((m) => m.id == id);

    // The problem opens every path, so its safety line is always heard.
    final river = mystery('river_crossing');
    expect(river.problem, contains('without a grown-up'));
    expect(river.science, contains('life jacket'));
    expect(river.endings[0].text, contains('shallow'));
    expect(river.endings[0].text, contains('grown-up'));
    expect(river.endings[1].text, contains('life jackets'));

    final lantern = mystery('dark_lantern');
    expect(lantern.problem, contains('battery lantern'));
    expect(lantern.problem, contains('only for grown-ups'));
    expect(lantern.science, contains('battery out first'));
    expect(lantern.endings[2].text, contains('little battery circuit'));
  });

  test('a surprise picks from every list', () {
    final random = Random(1);
    final seen = <String>{};
    for (var i = 0; i < 200; i++) {
      final (hero, place, mystery) = StoryMaker.surprise(random);
      seen.addAll([hero.id, place.id, mystery.id]);
    }
    expect(
      seen,
      hasLength(
        StoryMaker.heroes.length +
            StoryMaker.places.length +
            StoryMaker.mysteries.length,
      ),
    );
  });
}
