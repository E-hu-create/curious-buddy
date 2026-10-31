import 'dart:async';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/repositories/story_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/stories/more_stories.dart';
import 'package:curious_buddy/domain/stories/story.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:curious_buddy/ui/stories/story_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

class _FailingStories implements StoryRepository {
  @override
  Future<List<Story>> loadStories() async => throw Exception('disk broke');
}

class _SlowStories implements StoryRepository {
  final done = Completer<List<Story>>();
  @override
  Future<List<Story>> loadStories() => done.future;
}

final forest = starterStories.first;

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> openStories(
    WidgetTester tester, {
    StoryRepository? stories,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store, stories: stories),
    );
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.stories.title);
  }

  /// Opens the forest story and reads to the Rainbow Mist ending.
  Future<void> readToMist(WidgetTester tester) async {
    await tapText(tester, StoriesScreen.startLabel);
    await tapText(tester, StoryPlayScreen.beginLabel);
    await tapText(tester, 'Follow the stream that still sparkles');
    await tapText(tester, 'Splash the waterfall to make a big mist');
  }

  Future<LearnerProgress> saved() => LocalProgressRepository(store).load();

  testWidgets('Home opens the real Living Stories screen with every story', (
    tester,
  ) async {
    await openStories(tester);

    expect(find.text(StoriesScreen.title), findsOneWidget);
    for (final story in allStories) {
      await tester.ensureVisible(find.text(story.title));
      expect(find.text(story.title), findsOneWidget);
    }
    expect(
      find.text(StoriesScreen.startLabel),
      findsNWidgets(allStories.length),
    );
    expect(find.text(StoriesScreen.endingsLabel(0, 42)), findsOneWidget);
  });

  testWidgets('shows a loading state, then the stories', (tester) async {
    final slow = _SlowStories();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, stories: slow));
    await tester.pumpAndSettle();
    final card = find.text(HomeDestination.stories.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    // The spinner animates forever, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    slow.done.complete(starterStories);
    await tester.pumpAndSettle();
    expect(find.text(forest.title), findsOneWidget);
  });

  testWidgets('an empty library shows a friendly message', (tester) async {
    await openStories(tester, stories: BundledStoryRepository(stories: []));

    expect(find.text(StoriesScreen.emptyMessage), findsOneWidget);
  });

  testWidgets('a loading error offers a retry', (tester) async {
    await openStories(tester, stories: _FailingStories());

    expect(find.text(StoriesScreen.errorMessage), findsOneWidget);
    expect(find.text(StoriesScreen.retryLabel), findsOneWidget);
  });

  testWidgets('broken story content is left out, not shown', (tester) async {
    final broken = Story(
      id: 'broken',
      title: 'A Broken Story',
      tagline: 't',
      cover: ScenePicture.forestGrey,
      intro: 'i',
      startSceneId: 'missing',
      scenes: forest.scenes,
    );
    await openStories(
      tester,
      stories: BundledStoryRepository(stories: [broken, forest]),
    );

    expect(find.text('A Broken Story'), findsNothing);
    expect(find.text(forest.title), findsOneWidget);
  });

  testWidgets('reading a story: intro, scenes, choices and an ending', (
    tester,
  ) async {
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);

    expect(find.text(forest.intro), findsOneWidget);
    expect(tts.spoken.last, forest.intro);

    await tapText(tester, StoryPlayScreen.beginLabel);
    final first = forest.sceneById(forest.startSceneId)!;
    expect(find.text(first.title), findsOneWidget);
    expect(find.text(first.text), findsOneWidget);
    expect(find.text(StoryPlayScreen.whatNext), findsOneWidget);
    expect(find.text(StoryPlayScreen.pageLabel(1)), findsOneWidget);

    await tapText(tester, 'Follow the stream that still sparkles');
    expect(find.text('The Sparkling Stream'), findsWidgets);
    expect(
      find.text('You followed the stream, hopping from stone to stone.'),
      findsOneWidget,
    );

    await tapText(tester, 'Splash the waterfall to make a big mist');
    expect(find.text(StoryPlayScreen.theEnd), findsOneWidget);
    expect(find.text(StoryPlayScreen.newEnding), findsOneWidget);
    expect(find.text(StoryPlayScreen.discoveredLabel), findsOneWidget);
    expect(find.text(StoryPlayScreen.endingsLabel(1, 4)), findsOneWidget);
    expect(find.text(StoryPlayScreen.whatNext), findsNothing);
  });

  testWidgets('endings are saved and shown on the story card', (tester) async {
    await openStories(tester);
    await readToMist(tester);
    await tapText(tester, StoryPlayScreen.backLabel);

    expect(find.text(StoriesScreen.title), findsOneWidget);
    expect(find.text(StoriesScreen.endingsLabel(1, 4)), findsOneWidget);
    expect(find.text('The Rainbow Mist'), findsOneWidget); // ending chip
    expect(find.text(StoriesScreen.anotherEndingLabel), findsOneWidget);

    final progress = await saved();
    expect(progress.storyEndings[forest.id], {'mist'});
    expect(progress.completedStoryIds, {forest.id});
  });

  testWidgets('Try a different path restarts and finds another ending', (
    tester,
  ) async {
    await openStories(tester);
    await readToMist(tester);

    await tapText(tester, StoryPlayScreen.tryAnotherLabel);
    expect(find.text(StoryPlayScreen.pageLabel(1)), findsOneWidget);

    await tapText(tester, 'Walk up to the Sun Crystal in the old oak');
    await tapText(tester, 'Ask the robins to brush it clean');
    await tapText(tester, 'Turn the crystal to face the morning sun');

    expect(find.text('The Crystal Sunrise'), findsWidgets);
    expect(find.text(StoryPlayScreen.newEnding), findsOneWidget);
    expect(find.text(StoryPlayScreen.endingsLabel(2, 4)), findsOneWidget);
    expect((await saved()).storyEndings[forest.id], {'mist', 'sunrise'});
  });

  testWidgets('reaching an ending again says it was found before', (
    tester,
  ) async {
    await openStories(tester);
    await readToMist(tester);
    await tapText(tester, StoryPlayScreen.tryAnotherLabel);
    await tapText(tester, 'Follow the stream that still sparkles');
    await tapText(tester, 'Splash the waterfall to make a big mist');

    expect(find.text(StoryPlayScreen.foundBefore), findsOneWidget);
    expect(find.text(StoryPlayScreen.endingsLabel(1, 4)), findsOneWidget);
  });

  testWidgets('leaving mid-story can be continued, even after a restart', (
    tester,
  ) async {
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);
    await tapText(tester, StoryPlayScreen.beginLabel);
    await tapText(tester, 'Walk up to the Sun Crystal in the old oak');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(StoriesScreen.continueLabel), findsOneWidget);
    expect(find.text(StoriesScreen.startAgainLabel), findsOneWidget);

    // A fresh app (like reopening the phone app) still remembers the place.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(buildTestApp(tts: tts, store: store));
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.stories.title);
    await tapText(tester, StoriesScreen.continueLabel);

    expect(find.text('The Dusty Crystal'), findsOneWidget);
    expect(find.text(StoryPlayScreen.welcomeBack), findsOneWidget);
    expect(find.text(StoryPlayScreen.pageLabel(2)), findsOneWidget);

    await tapText(tester, 'Ask the wind to blow the dust away');
    expect(find.text(StoryPlayScreen.welcomeBack), findsNothing);
    expect(find.text('Whoosh!'), findsOneWidget);
  });

  testWidgets('Start again ignores the bookmark and opens the intro', (
    tester,
  ) async {
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);
    await tapText(tester, StoryPlayScreen.beginLabel);
    await tapText(tester, 'Walk up to the Sun Crystal in the old oak');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapText(tester, StoriesScreen.startAgainLabel);

    expect(find.text(StoryPlayScreen.beginLabel), findsOneWidget);
    expect(find.text(forest.intro), findsOneWidget);
  });

  testWidgets('a saved place that no longer fits the story is ignored', (
    tester,
  ) async {
    await LocalProgressRepository(store).save(
      LearnerProgress.empty.withStoryBookmark(forest.id, [
        'grey_morning',
        'not_a_scene',
      ]),
    );
    await openStories(tester);

    expect(find.text(StoriesScreen.continueLabel), findsNothing);
    expect(
      find.text(StoriesScreen.startLabel),
      findsNWidgets(allStories.length),
    );
  });

  testWidgets('leaving a story mid-narration stops Buddy at once', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);
    expect(tts.isSpeaking, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
    expect(find.text(StoriesScreen.title), findsOneWidget);
  });

  testWidgets('turning the page interrupts the last narration', (tester) async {
    tts.holdSpeech = true;
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);
    final stops = tts.stopCalls;

    await tapText(tester, StoryPlayScreen.beginLabel);

    expect(tts.stopCalls, greaterThan(stops));
    expect(tts.spoken.last, forest.sceneById(forest.startSceneId)!.text);
  });

  testWidgets('Stop talking silences Buddy; the text stays on screen', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);

    await tapText(tester, MissionVoiceBar.stopLabel);

    expect(tts.isSpeaking, isFalse);
    expect(find.text(forest.intro), findsOneWidget);
    expect(find.text(MissionVoiceBar.hearAgainLabel), findsOneWidget);
  });

  testWidgets('Read the choices reads them aloud in order', (tester) async {
    await openStories(tester);
    await tapText(tester, StoriesScreen.startLabel);
    await tapText(tester, StoryPlayScreen.beginLabel);

    await tapText(tester, StoryPlayScreen.readChoicesLabel);

    expect(tts.spoken.last, startsWith(StoryPlayScreen.whatNext));
    expect(tts.spoken.last, contains('Choice 1: Walk up'));
    expect(tts.spoken.last, contains('Choice 2: Follow the stream'));
  });

  testWidgets('with no speech engine, the story is fully readable', (
    tester,
  ) async {
    tts.available = false;
    await openStories(tester);
    await readToMist(tester);

    expect(tts.spoken, isEmpty);
    expect(find.text(MissionVoiceBar.stopLabel), findsNothing);
    expect(find.text(StoryPlayScreen.readChoicesLabel), findsNothing);
    expect(find.text(StoryPlayScreen.theEnd), findsOneWidget);
  });

  testWidgets('stories never touch the microphone', (tester) async {
    await openStories(tester);
    await readToMist(tester);

    expect(speech.totalCalls, 0);
  });

  testWidgets('Home shows the finished story count afterwards', (tester) async {
    await openStories(tester);
    await readToMist(tester);
    await tapText(tester, StoryPlayScreen.backLabel);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
    expect(find.textContaining('1 story'), findsOneWidget);
  });
}
