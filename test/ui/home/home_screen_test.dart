import 'dart:async';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/ui/creative/creative_hub_screen.dart';
import 'package:curious_buddy/ui/discoveries/discoveries_screen.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/missions/missions_screen.dart';
import 'package:curious_buddy/ui/quiz/quiz_hub_screen.dart';
import 'package:curious_buddy/ui/stories/stories_screen.dart';
import 'package:curious_buddy/ui/stories/story_maker_screen.dart';
import 'package:curious_buddy/ui/wardrobe/wardrobe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;

  setUp(() => tts = FakeTextToSpeechService());

  Future<void> openHome(WidgetTester tester, {KeyValueStore? store}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, store: store));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the greeting and every destination', (tester) async {
    await openHome(tester);

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
    for (final destination in HomeDestination.values) {
      expect(find.text(destination.title), findsOneWidget);
      expect(find.text(destination.subtitle), findsOneWidget);
    }
    expect(find.text('Grown-ups'), findsOneWidget);
  });

  testWidgets('explorer log shows saved progress', (tester) async {
    final store = InMemoryKeyValueStore();
    await LocalProgressRepository(store).save(
      const LearnerProgress(
        completedMissionIds: {'m1', 'm2'},
        completedStoryIds: {'s1'},
      ),
    );

    await openHome(tester, store: store);

    expect(find.text('2 missions solved'), findsOneWidget);
    expect(find.text('1 story finished'), findsOneWidget);
  });

  testWidgets('home still works when progress cannot be read', (tester) async {
    await openHome(tester, store: FailingKeyValueStore());

    expect(find.textContaining('solved'), findsNothing);
    expect(find.text(HomeDestination.missions.title), findsOneWidget);
  });

  testWidgets('each destination opens its page and back returns home', (
    tester,
  ) async {
    await openHome(tester);

    for (final destination in HomeDestination.values) {
      await tester.ensureVisible(find.text(destination.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(destination.title));
      await tester.pumpAndSettle();

      if (destination == HomeDestination.missions) {
        // Built in Phase 4: the real Missions screen, not a placeholder.
        expect(find.text(MissionsScreen.title), findsOneWidget);
      } else if (destination == HomeDestination.stories) {
        // Built in Phase 5: the real Living Stories screen.
        expect(find.text(StoriesScreen.title), findsOneWidget);
      } else if (destination == HomeDestination.quiz) {
        // The real Quiz Time screen.
        expect(find.text(QuizHubScreen.welcome), findsOneWidget);
      } else if (destination == HomeDestination.creative) {
        // The real Creative Island screen.
        expect(find.text(CreativeHubScreen.welcome), findsOneWidget);
      } else if (destination == HomeDestination.games) {
        expect(find.text(GameZoneScreen.welcome), findsOneWidget);
      } else if (destination == HomeDestination.wardrobe) {
        expect(find.text(WardrobeScreen.help), findsOneWidget);
      } else if (destination == HomeDestination.storyMaker) {
        expect(find.text(StoryMakerScreen.welcome), findsOneWidget);
      } else {
        expect(destination, HomeDestination.discoveries);
        expect(find.text(DiscoveriesScreen.nextTitle), findsOneWidget);
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(HomeViewModel.greeting), findsOneWidget);
    }
  });

  testWidgets('"Back to Home" button returns to Home', (tester) async {
    await openHome(tester);
    // The friendly page shown for an unknown route.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed('/does-not-exist'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
  });

  testWidgets('Grown-ups card opens the Parent Zone', (tester) async {
    await openHome(tester);

    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();

    expect(find.text('Parent Zone'), findsOneWidget);
  });

  // Voice behaviour on Home is covered in home_voice_test.dart.
}
