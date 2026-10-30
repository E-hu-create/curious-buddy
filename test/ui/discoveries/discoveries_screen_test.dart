import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/mission_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/discoveries/discovery_journal.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/ui/creative/creative_hub_screen.dart';
import 'package:curious_buddy/ui/discoveries/discoveries_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/missions/missions_screen.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import '../parent_zone/parent_zone_screen_test.dart' show wordsToNumber;

class _FailingMissions implements MissionRepository {
  @override
  Future<List<Mission>> loadMissions() async => throw Exception('disk broke');
}

final _forest = starterStories.first;
final _mission = starterMissions.first;

/// A busy explorer: a case, two endings, a quiz level, a creation.
LearnerProgress _played() => LearnerProgress.empty
    .withMissionResult(_mission.id, 120)
    .withStoryEnding(_forest.id, 'mist')
    .withStoryEnding(_forest.id, 'rain')
    .withQuizResult('space_starter', 5);

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

  Future<void> startApp(
    WidgetTester tester, {
    KeyValueStore? customStore,
    MissionRepository? missions,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        tts: tts,
        speech: speech,
        store: customStore ?? store,
        missions: missions,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openJournal(
    WidgetTester tester, {
    KeyValueStore? customStore,
    MissionRepository? missions,
  }) async {
    await startApp(tester, customStore: customStore, missions: missions);
    await tapText(tester, HomeDestination.discoveries.title);
  }

  Future<void> seed() async {
    await LocalProgressRepository(store).save(_played());
    await LocalCreationsRepository(store).add(
      (id) => Creature(
        id: id,
        name: 'Moxo',
        body: CreatureBody.round,
        colorIndex: 2,
        eyes: CreatureEyes.big,
        mouth: CreatureMouth.smile,
        extra: CreatureExtra.none,
        pattern: CreaturePattern.none,
      ),
    );
  }

  testWidgets('a new explorer gets a welcome and a first suggestion', (
    tester,
  ) async {
    await openJournal(tester);

    expect(find.text(ExplorerRank.beginner.title), findsOneWidget);
    expect(find.textContaining('first discovery'), findsOneWidget);
    expect(find.text(DiscoveriesScreen.nextTitle), findsOneWidget);
    expect(find.textContaining(_mission.title), findsWidgets);
    expect(find.text(DiscoveriesScreen.notYet), findsNWidgets(3));
    expect(find.text(DiscoveriesScreen.noCreations), findsOneWidget);
  });

  testWidgets('Buddy reads the summary when the journal opens', (tester) async {
    await seed();
    await openJournal(tester);

    expect(tts.spoken.last, contains('You\'ve solved 1 case'));
    expect(tts.spoken.last, contains('found 2 story endings'));
    expect(tts.spoken.last, contains('earned 3 quiz stars'));
    expect(tts.spoken.last, contains('made 1 creation'));
  });

  testWidgets('a busy journal shows badges, stories, stars and creations', (
    tester,
  ) async {
    await seed();
    await openJournal(tester);

    expect(find.text(ExplorerRank.keen.title), findsOneWidget);
    expect(
      find.text(DiscoveriesScreen.rankLine(3, ExplorerRank.brave.title)),
      findsOneWidget,
    );
    expect(find.text(_mission.badge), findsOneWidget);
    expect(find.text('3 of 9'), findsOneWidget);
    expect(find.text('Moxo'), findsNothing, reason: 'pictures only');
    expect(find.byType(Image), findsNothing);
    expect(find.bySemanticsLabel(RegExp('^Moxo: ')), findsOneWidget);
  });

  testWidgets('only found endings appear; the rest are just counted', (
    tester,
  ) async {
    await seed();
    await openJournal(tester);

    expect(find.text('The Rainbow Mist'), findsOneWidget);
    expect(find.text('After the Rain'), findsOneWidget);
    expect(find.text(DiscoveriesScreen.moreEndings(2)), findsOneWidget);
    expect(find.text('The Crystal Sunrise'), findsNothing);
    expect(find.text('The Bucket Brigade'), findsNothing);
  });

  testWidgets('tapping a speaker reads that discovery', (tester) async {
    await seed();
    await openJournal(tester);

    final speaker = find.byTooltip(
      DiscoveriesScreen.readTooltip('The Rainbow Mist'),
    );
    await tester.ensureVisible(speaker);
    await tester.pumpAndSettle();
    await tester.tap(speaker);
    await tester.pumpAndSettle();

    expect(tts.spoken.last, startsWith('The Rainbow Mist, from'));
    expect(tts.spoken.last, contains('Tiny water drops'));
  });

  testWidgets('Next adventure opens the right place, and the journal '
      'updates afterwards', (tester) async {
    await openJournal(tester);

    await tapText(tester, DiscoveriesScreen.goLabel(AdventureKind.mission));
    expect(find.text(MissionsScreen.title), findsOneWidget);

    // Solve nothing, but save a result as finishing a case would.
    await LocalProgressRepository(
      store,
    ).save(LearnerProgress.empty.withMissionResult(_mission.id, 100));
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(_mission.badge), findsOneWidget);
    expect(find.text('1 case'), findsOneWidget);
  });

  testWidgets('Open Creative Island goes there', (tester) async {
    await openJournal(tester);

    await tapText(tester, DiscoveriesScreen.openCreative);

    expect(find.text(CreativeHubScreen.welcome), findsOneWidget);
  });

  testWidgets('Buddy opens the journal from his answer', (tester) async {
    await startApp(tester);
    await tester.enterText(find.byType(TextField), 'Show my discoveries');
    await tapText(tester, 'Ask');

    expect(find.textContaining('your explorer journal'), findsWidgets);
    await tapText(tester, 'Open My Discoveries');
    expect(find.text(DiscoveriesScreen.nextTitle), findsOneWidget);
  });

  testWidgets('the journal saves nothing of its own', (tester) async {
    await openJournal(tester);

    expect(await store.read(LocalProgressRepository.storageKey), isNull);
    expect(await store.read(LocalCreationsRepository.storageKey), isNull);
  });

  testWidgets('with no progress readable, it offers a retry', (tester) async {
    await openJournal(tester, customStore: FailingKeyValueStore());

    expect(find.text(DiscoveriesScreen.errorMessage), findsOneWidget);
    expect(find.text(DiscoveriesScreen.retryLabel), findsOneWidget);
  });

  testWidgets('if one section fails, the rest still shows', (tester) async {
    await seed();
    await openJournal(tester, missions: _FailingMissions());

    expect(find.text(DiscoveriesScreen.partialNote), findsOneWidget);
    expect(find.text(DiscoveriesScreen.badgesTitle), findsNothing);
    expect(find.text(DiscoveriesScreen.storiesTitle), findsOneWidget);
    expect(find.text('The Rainbow Mist'), findsOneWidget);
  });

  testWidgets('a parent reset empties the journal, even after a restart', (
    tester,
  ) async {
    await seed();
    await startApp(tester);
    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('What is '));
    final m = RegExp(
      r'^What is ([a-z-]+) times ([a-z-]+)\?$',
    ).firstMatch(question)!;
    await tester.enterText(
      find.byType(TextField),
      '${wordsToNumber(m[1]!) * wordsToNumber(m[2]!)}',
    );
    await tapText(tester, ParentGateView.checkLabel);
    await tapText(tester, ParentZoneScreen.resetLabel);
    await tapText(tester, ResetExplainDialog.continueLabel);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
    );
    await tester.pumpAndSettle();
    await tapText(tester, ParentZoneScreen.backToBuddy);
    await tapText(tester, HomeDestination.discoveries.title);

    expect(find.text(ExplorerRank.beginner.title), findsOneWidget);
    expect(find.text('The Rainbow Mist'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await openJournal(tester);
    expect(find.text(ExplorerRank.beginner.title), findsOneWidget);
    expect(find.text(_mission.badge), findsNothing);
  });

  testWidgets('leaving mid-speech stops Buddy at once', (tester) async {
    tts.holdSpeech = true;
    await seed();
    await openJournal(tester);
    expect(tts.isSpeaking, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
  });

  testWidgets('Stop talking and Hear again work', (tester) async {
    tts.holdSpeech = true;
    await seed();
    await openJournal(tester);

    await tapText(tester, MissionVoiceBar.stopLabel);
    expect(tts.isSpeaking, isFalse);
    expect(find.text(MissionVoiceBar.hearAgainLabel), findsOneWidget);
  });

  testWidgets('with no speech engine, everything is still readable', (
    tester,
  ) async {
    tts.available = false;
    await seed();
    await openJournal(tester);

    expect(tts.spoken, isEmpty);
    expect(find.text('The Rainbow Mist'), findsOneWidget);
    expect(
      find.byTooltip(DiscoveriesScreen.readTooltip('The Rainbow Mist')),
      findsNothing,
    );
  });

  testWidgets('the journal never touches the microphone', (tester) async {
    await seed();
    await openJournal(tester);

    expect(speech.totalCalls, 0);
  });
}
