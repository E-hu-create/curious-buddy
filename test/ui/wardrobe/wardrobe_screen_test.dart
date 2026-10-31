import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/wardrobe/wardrobe.dart';
import 'package:curious_buddy/ui/core/widgets/buddy/buddy.dart';
import 'package:curious_buddy/ui/core/widgets/buddy/buddy_painter.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:curious_buddy/ui/wardrobe/wardrobe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import '../parent_zone/parent_zone_screen_test.dart' show wordsToNumber;

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
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: customStore ?? store),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openWardrobe(
    WidgetTester tester, {
    KeyValueStore? customStore,
  }) async {
    await startApp(tester, customStore: customStore);
    await tapText(tester, HomeDestination.wardrobe.title);
  }

  /// Earns the party hat (a story ending) and round glasses (a quiz level).
  Future<void> earnSome() => LocalProgressRepository(store).save(
    LearnerProgress.empty
        .withStoryEnding('forest_colours', 'mist')
        .withQuizResult('space_starter', 5),
  );

  BuddyLook lookOnFirstBuddy(WidgetTester tester) {
    final painter = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(Buddy).first,
            matching: find.byType(CustomPaint),
          ),
        )
        .map((p) => p.painter)
        .whereType<BuddyPainter>()
        .first;
    return painter.look;
  }

  testWidgets('a new explorer sees everything locked, with how to earn it', (
    tester,
  ) async {
    await openWardrobe(tester);

    expect(find.text(WardrobeScreen.title), findsOneWidget);
    expect(find.text(WardrobeScreen.unlocked(0, 11)), findsOneWidget);
    expect(find.text('0 of 1 case solved'), findsOneWidget);
    expect(find.text('0 of 1 story ending'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(11));
  });

  testWidgets('Buddy introduces his wardrobe', (tester) async {
    await openWardrobe(tester);

    expect(tts.spoken.last, startsWith('Dress me up!'));
  });

  testWidgets('earned items can be worn, and Buddy shows them at once', (
    tester,
  ) async {
    await earnSome();
    await openWardrobe(tester);
    expect(find.text(WardrobeScreen.unlocked(2, 11)), findsOneWidget);

    await tapText(tester, WardrobeItem.partyHat.title);

    expect(find.text(WardrobeScreen.wearing), findsOneWidget);
    expect(lookOnFirstBuddy(tester).hat, WardrobeItem.partyHat);
    expect(tts.spoken.last, 'My party hat looks great!');
    expect((await LocalProgressRepository(store).load()).buddyLook, {
      'hat': 'partyHat',
    });
  });

  testWidgets('tapping again takes it off', (tester) async {
    await earnSome();
    await openWardrobe(tester);
    await tapText(tester, WardrobeItem.partyHat.title);

    await tapText(tester, WardrobeItem.partyHat.title);

    expect(find.text(WardrobeScreen.wearing), findsNothing);
    expect(lookOnFirstBuddy(tester).isEmpty, isTrue);
  });

  testWidgets('locked items cannot be worn', (tester) async {
    await openWardrobe(tester);

    await tapText(tester, WardrobeItem.crown.title);

    expect(find.text(WardrobeScreen.wearing), findsNothing);
    expect(lookOnFirstBuddy(tester).isEmpty, isTrue);
  });

  testWidgets('Buddy wears his outfit on other screens', (tester) async {
    await earnSome();
    await openWardrobe(tester);
    await tapText(tester, WardrobeItem.roundGlasses.title);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(HomeDestination.wardrobe.title), findsOneWidget);
    expect(lookOnFirstBuddy(tester).glasses, WardrobeItem.roundGlasses);
    expect(
      find.bySemanticsLabel(RegExp('wearing round glasses')),
      findsOneWidget,
    );
  });

  testWidgets('the outfit is back after an app restart', (tester) async {
    await earnSome();
    await openWardrobe(tester);
    await tapText(tester, WardrobeItem.partyHat.title);

    await tester.pumpWidget(const SizedBox());
    await startApp(tester);

    expect(lookOnFirstBuddy(tester).hat, WardrobeItem.partyHat);
  });

  testWidgets('saving a creation earns an item', (tester) async {
    await LocalCreationsRepository(
      store,
    ).add((id) => Drawing(id: id, strokes: const []));
    await openWardrobe(tester);

    await tapText(tester, WardrobeItem.bowTie.title);

    expect(find.text(WardrobeScreen.wearing), findsOneWidget);
  });

  testWidgets('Buddy opens his wardrobe from his answer', (tester) async {
    await startApp(tester);
    await tester.enterText(find.byType(TextField), 'I want to dress up Buddy');
    await tapText(tester, 'Ask');

    await tapText(tester, "Open Buddy's Wardrobe");

    expect(find.text(WardrobeScreen.help), findsOneWidget);
  });

  testWidgets('a storage error offers a retry', (tester) async {
    await openWardrobe(tester, customStore: FailingKeyValueStore());

    expect(find.text(WardrobeScreen.errorMessage), findsOneWidget);
  });

  testWidgets('the Parent Zone shows the outfit, and reset takes it off', (
    tester,
  ) async {
    await earnSome();
    await openWardrobe(tester);
    await tapText(tester, WardrobeItem.partyHat.title);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Grown-ups'));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.text(DataOverviewSection.outfitTitle));
    expect(find.text('1 item worn'), findsOneWidget);

    await tapText(tester, ParentZoneScreen.resetLabel);
    expect(find.text("Buddy's outfit: 1 item worn."), findsOneWidget);
    await tapText(tester, ResetExplainDialog.continueLabel);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
    );
    await tester.pumpAndSettle();
    await tapText(tester, ParentZoneScreen.backToBuddy);

    expect(lookOnFirstBuddy(tester).isEmpty, isTrue);
    expect((await LocalProgressRepository(store).load()).buddyLook, isEmpty);
  });

  testWidgets('leaving mid-speech stops Buddy, with no microphone', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openWardrobe(tester);
    expect(tts.isSpeaking, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
    expect(speech.totalCalls, 0);
  });

  testWidgets('every item can be painted, in every mood', (tester) async {
    usePhoneScreen(tester);
    for (final item in WardrobeItem.values) {
      for (final mood in BuddyMood.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: CustomPaint(
              size: const Size(200, 240),
              painter: BuddyPainter(
                mood: mood,
                look: BuddyLook.none.wearing(item),
              ),
            ),
          ),
        );
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the wardrobe meets the accessibility guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await earnSome();
    await openWardrobe(tester);
    await tapText(tester, WardrobeItem.partyHat.title);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    expect(
      find.bySemanticsLabel(
        WardrobeScreen.itemLabel(WardrobeItem.partyHat.title, worn: true),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Golden crown, locked')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('the wardrobe lays out without overflow: $name', (
      tester,
    ) async {
      await earnSome();
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await tester.pumpWidget(buildTestApp(store: store));
      await tester.pumpAndSettle();
      await tapText(tester, HomeDestination.wardrobe.title);

      // Overflow errors fail the test automatically.
      expect(find.text(WardrobeScreen.title), findsOneWidget);
    });
  }
}
