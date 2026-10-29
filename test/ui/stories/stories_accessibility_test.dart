import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:curious_buddy/ui/stories/story_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

Future<void> _tapText(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// A route from the start to every scene, found by walking the choices.
Map<String, List<String>> _routesTo(Story story) {
  final routes = <String, List<String>>{
    story.startSceneId: [story.startSceneId],
  };
  final queue = [story.startSceneId];
  while (queue.isNotEmpty) {
    final id = queue.removeAt(0);
    for (final choice in story.sceneById(id)!.choices) {
      if (routes.containsKey(choice.nextSceneId)) continue;
      routes[choice.nextSceneId] = [...routes[id]!, choice.nextSceneId];
      queue.add(choice.nextSceneId);
    }
  }
  return routes;
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  late BuddyVoice voice;
  late InMemoryKeyValueStore store;

  setUp(() {
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
  });

  tearDown(() => voice.dispose());

  Widget page(Story story, {List<String>? resumePath}) => MaterialApp(
    theme: AppTheme.light(),
    home: StoryPlayScreen(
      story: story,
      voice: voice,
      progressRepository: LocalProgressRepository(store),
      resumePath: resumePath,
    ),
  );

  testWidgets('the stories list meets tap target, label and contrast '
      'guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await _tapText(tester, HomeDestination.stories.title);

    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('a story intro, a choice page and an ending meet the '
      'guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await _tapText(tester, HomeDestination.stories.title);
    await _tapText(tester, StoriesScreen.startLabel);
    await _expectGuidelines(tester);

    await _tapText(tester, StoryPlayScreen.beginLabel);
    await _tapText(tester, 'Follow the stream that still sparkles');
    await _expectGuidelines(tester);

    await _tapText(tester, 'Splash the waterfall to make a big mist');
    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('choices are announced as numbered buttons', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(page(starterStories.first));
    await tester.pumpAndSettle();
    await _tapText(tester, StoryPlayScreen.beginLabel);

    expect(
      find.bySemanticsLabel(
        'Choice 1: Climb up to the Sun Crystal in the old oak',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('every scene picture has a description', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    final story = starterStories.first;
    await tester.pumpWidget(page(story));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('rainbow')), findsWidgets);
    semantics.dispose();
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('the stories list lays out without overflow: $name', (
      tester,
    ) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      await _tapText(tester, HomeDestination.stories.title);
      // Overflow errors fail the test automatically.
      expect(find.text(StoriesScreen.title), findsOneWidget);
    });

    for (final story in starterStories) {
      testWidgets('every page of "${story.title}" lays out without '
          'overflow: $name', (tester) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);

        await tester.pumpWidget(page(story));
        await tester.pumpAndSettle();
        expect(find.text(StoryPlayScreen.beginLabel), findsOneWidget);

        for (final route in _routesTo(story).values) {
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(page(story, resumePath: route));
          await tester.pumpAndSettle();
          expect(
            find.text(story.sceneById(route.last)!.title),
            findsWidgets,
            reason: route.join(' > '),
          );
        }
      });
    }
  }
}
