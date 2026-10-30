import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/stories/story_maker.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:curious_buddy/ui/stories/story_maker_screen.dart';
import 'package:curious_buddy/ui/stories/story_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  setUp(() {
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
      sounds: FakeSoundEffectsService(),
    );
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Widget maker() => MaterialApp(
    theme: AppTheme.light(),
    home: StoryMakerScreen(
      voice: voice,
      progressRepository: progress,
      random: Random(3),
    ),
  );

  testWidgets('Home has its own Story Maker card', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();

    await tapText(tester, HomeDestination.storyMaker.title);

    expect(find.text(StoryMakerScreen.welcome), findsOneWidget);
  });

  testWidgets('Stories has a Story Maker card that opens it', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.stories.title);

    await tapText(tester, StoriesScreen.makerLabel);

    expect(find.text(StoryMakerScreen.welcome), findsOneWidget);
  });

  testWidgets('picking changes the story, and making plays it', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(maker());
    await tester.pumpAndSettle();
    final hero = StoryMaker.heroes[2];
    final place = StoryMaker.places[3];

    await tapText(tester, hero.intro);
    await tapText(tester, 'The Frosty North');
    await tapText(tester, StoryMakerScreen.makeLabel);

    final story = StoryMaker.make(hero, place, StoryMaker.mysteries.first);
    expect(find.text(story.title), findsWidgets);
    expect(find.text(StoryPlayScreen.beginLabel), findsOneWidget);
  });

  testWidgets('a made story plays to an ending, and nothing is saved', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(maker());
    await tester.pumpAndSettle();
    final story = StoryMaker.make(
      StoryMaker.heroes.first,
      StoryMaker.places.first,
      StoryMaker.mysteries.first,
    );

    await tapText(tester, StoryMakerScreen.makeLabel);
    await tapText(tester, StoryPlayScreen.beginLabel);
    final start = story.sceneById(story.startSceneId)!;
    await tapText(tester, start.choices.first.text);
    final look = story.sceneById('look')!;
    await tapText(tester, look.choices.last.text);

    expect(find.text(StoryPlayScreen.theEnd), findsOneWidget);
    final saved = await tester.runAsync(progress.load);
    expect(saved, LearnerProgress.empty);
  });

  testWidgets('Surprise me picks something new', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(maker());
    await tester.pumpAndSettle();
    final (hero, _, _) = StoryMaker.surprise(Random(3));

    await tapText(tester, StoryMakerScreen.surpriseLabel);

    expect(
      tester.getSemantics(find.bySemanticsLabel(hero.intro)),
      isSemantics(isSelected: true),
    );
  });

  testWidgets('it meets the accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(maker());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('it lays out on a small phone with 2x text', (tester) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(maker());
    await tester.pumpAndSettle();

    // Overflow errors fail the test automatically.
    expect(find.text(StoryMakerScreen.title), findsOneWidget);
  });
}
