import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/ui/creative/creative_hub_screen.dart';
import 'package:curious_buddy/ui/creative/creature_screen.dart';
import 'package:curious_buddy/ui/creative/drawing_screen.dart';
import 'package:curious_buddy/ui/creative/widgets/creative_art.dart';
import 'package:curious_buddy/ui/creative/widgets/creative_controls.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import '../parent_zone/parent_zone_screen_test.dart' show wordsToNumber;

final _canvas = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.painter is DrawingPainter,
);

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;
  late LocalCreationsRepository creations;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
    creations = LocalCreationsRepository(store);
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

  Future<void> openIsland(
    WidgetTester tester, {
    KeyValueStore? customStore,
  }) async {
    await startApp(tester, customStore: customStore);
    await tapText(tester, HomeDestination.creative.title);
  }

  Future<void> drawLine(
    WidgetTester tester, {
    Offset by = const Offset(0, 150),
  }) async {
    await tester.ensureVisible(_canvas);
    await tester.pumpAndSettle();
    final centre = tester.getCenter(_canvas);
    final gesture = await tester.startGesture(centre - by / 2);
    for (var i = 1; i <= 6; i++) {
      await gesture.moveBy(by / 6);
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  Future<void> fillShelf() async {
    for (var i = 0; i < CreativeLimits.maxCreations; i++) {
      await creations.add((id) => Drawing(id: id, strokes: const []));
    }
  }

  testWidgets('Home opens the real Creative Island with an empty shelf', (
    tester,
  ) async {
    await openIsland(tester);

    expect(find.text(CreativeHubScreen.title), findsOneWidget);
    expect(find.text(CreativeHubScreen.drawLabel), findsOneWidget);
    expect(find.text(CreativeHubScreen.creatureLabel), findsOneWidget);
    expect(find.text(CreativeHubScreen.emptyShelf), findsOneWidget);
    expect(find.text(CreativeHubScreen.shelfCount(0, 12)), findsOneWidget);
  });

  testWidgets('a storage error offers a retry, not an empty shelf', (
    tester,
  ) async {
    await openIsland(tester, customStore: FailingKeyValueStore());

    expect(find.text(CreativeHubScreen.errorMessage), findsOneWidget);
    expect(find.text(CreativeHubScreen.retryLabel), findsOneWidget);
  });

  group('Drawing Studio', () {
    testWidgets('a vertical stroke draws instead of scrolling the page', (
      tester,
    ) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);

      await drawLine(tester);
      await tapText(tester, DrawingScreen.saveLabel);

      final saved = (await creations.load()).items.single as Drawing;
      expect(saved.strokes, hasLength(1));
      expect(saved.strokes.single.points.length, greaterThan(2));
      final ys = saved.strokes.single.points.map((p) => p.y);
      expect(ys.last - ys.first, greaterThan(200), reason: 'a real line');
    });

    testWidgets('Buddy gives the instructions when it opens', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);

      expect(tts.spoken.last, contains('draw with your finger'));
    });

    testWidgets('Save stays off until there is something to save', (
      tester,
    ) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);
      final save = find.widgetWithText(FilledButton, DrawingScreen.saveLabel);

      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await drawLine(tester);
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    });

    testWidgets('colour, brush and eraser choices are used', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);

      await tapText(tester, 'Purple');
      await tapText(tester, 'Thick');
      await drawLine(tester);
      await tapText(tester, DrawingScreen.eraserLabel);
      await drawLine(tester, by: const Offset(150, 0));
      await tapText(tester, DrawingScreen.saveLabel);

      final saved = (await creations.load()).items.single as Drawing;
      expect(
        saved.strokes[0].colorIndex,
        CreativePalette.names.indexOf('Purple'),
      );
      expect(saved.strokes[0].sizeIndex, 2);
      expect(saved.strokes[1].eraser, isTrue);
    });

    testWidgets('Undo and Start over', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);
      await drawLine(tester);
      await drawLine(tester, by: const Offset(150, 0));

      await tapText(tester, DrawingScreen.undoLabel);
      await tapText(tester, DrawingScreen.clearLabel);
      await tapText(tester, DrawingScreen.clearNo);
      await tapText(tester, DrawingScreen.saveLabel);
      expect(
        ((await creations.load()).items.single as Drawing).strokes,
        hasLength(1),
      );

      await tapText(tester, DrawingScreen.drawAnother);
      await drawLine(tester);
      await tapText(tester, DrawingScreen.clearLabel);
      await tapText(tester, DrawingScreen.clearYes);
      final save = find.widgetWithText(FilledButton, DrawingScreen.saveLabel);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
    });

    testWidgets('after saving: Saved, Draw another, back to the shelf', (
      tester,
    ) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);
      await drawLine(tester);
      await tapText(tester, DrawingScreen.saveLabel);

      expect(find.text(CreativeSaveNote.savedTitle), findsOneWidget);
      expect(find.text(DrawingScreen.drawAnother), findsOneWidget);

      await tapText(tester, CreativeSaveNote.backLabel);
      expect(find.text(CreativeHubScreen.shelfCount(1, 12)), findsOneWidget);
      expect(find.text('Drawing'), findsOneWidget);
    });

    testWidgets('leaving mid-speech stops Buddy at once', (tester) async {
      tts.holdSpeech = true;
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.drawLabel);
      expect(tts.isSpeaking, isTrue);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(tts.isSpeaking, isFalse);
      expect(find.text(CreativeHubScreen.title), findsOneWidget);
    });
  });

  group('Creature Maker', () {
    testWidgets('choosing parts and saving a creature', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.creatureLabel);

      await tapText(tester, 'Wobbly');
      await tapText(tester, 'Purple');
      await tapText(tester, 'Sleepy');
      await tapText(tester, 'Tongue out');
      await tapText(tester, 'Horns');
      await tapText(tester, 'Stripes');
      await tapText(tester, CreatureScreen.saveLabel);

      final saved = (await creations.load()).items.single as Creature;
      expect(saved.body, CreatureBody.blob);
      expect(saved.colorIndex, CreativePalette.names.indexOf('Purple'));
      expect(saved.eyes, CreatureEyes.sleepy);
      expect(saved.mouth, CreatureMouth.tongue);
      expect(saved.extra, CreatureExtra.horns);
      expect(saved.pattern, CreaturePattern.stripes);
      expect(creatureNames, contains(saved.name));
      expect(find.text(CreativeSaveNote.savedTitle), findsOneWidget);
    });

    testWidgets('nothing can be typed: no text boxes anywhere', (tester) async {
      await openIsland(tester);
      expect(find.byType(TextField), findsNothing);

      await tapText(tester, CreativeHubScreen.creatureLabel);
      expect(find.byType(TextField), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapText(tester, CreativeHubScreen.drawLabel);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('New name and Surprise me work; Buddy reacts', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.creatureLabel);

      await tapText(tester, CreatureScreen.newNameLabel);
      expect(tts.spoken.last, startsWith('Hello, '));

      await tapText(tester, CreatureScreen.surpriseLabel);
      await tapText(tester, CreatureScreen.askBuddyLabel);
      expect(tts.spoken.last, isNotEmpty);
    });

    testWidgets('Make another starts a fresh creature', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.creatureLabel);
      await tapText(tester, CreatureScreen.saveLabel);

      await tapText(tester, CreatureScreen.makeAnother);
      await tapText(tester, CreatureScreen.saveLabel);

      expect((await creations.load()).creatures, 2);
    });
  });

  group('My Creations', () {
    Future<void> seedCreature() => creations.add(
      (id) => Creature(
        id: id,
        name: 'Zibble',
        body: CreatureBody.round,
        colorIndex: 1,
        eyes: CreatureEyes.big,
        mouth: CreatureMouth.smile,
        extra: CreatureExtra.wings,
        pattern: CreaturePattern.none,
      ),
    );

    testWidgets('a creation opens, described in words', (tester) async {
      await seedCreature();
      await openIsland(tester);

      await tapText(tester, 'Zibble');

      expect(
        find.text(
          'Zibble: a round coral creature with big eyes, a smile and wings',
        ),
        findsOneWidget,
      );
      await tapText(tester, CreationViewScreen.backLabel);
      expect(find.text(CreativeHubScreen.shelfCount(1, 12)), findsOneWidget);
    });

    testWidgets('removing asks first; Keep it keeps it', (tester) async {
      await seedCreature();
      await openIsland(tester);
      await tapText(tester, 'Zibble');

      await tapText(tester, CreationViewScreen.removeLabel);
      expect(find.text(CreationViewScreen.confirmTitle), findsOneWidget);
      await tapText(tester, CreationViewScreen.keepLabel);

      expect((await creations.load()).items, hasLength(1));
    });

    testWidgets('removing takes it off the shelf for good', (tester) async {
      await seedCreature();
      await openIsland(tester);
      await tapText(tester, 'Zibble');

      await tapText(tester, CreationViewScreen.removeLabel);
      await tapText(tester, CreationViewScreen.yesLabel);

      expect(find.text(CreativeHubScreen.emptyShelf), findsOneWidget);
      expect((await creations.load()).items, isEmpty);
    });

    testWidgets('a full shelf explains itself and pauses new creations', (
      tester,
    ) async {
      await fillShelf();
      await openIsland(tester);

      expect(find.text(CreativeHubScreen.fullShelf), findsOneWidget);
      final draw = find.widgetWithText(
        FilledButton,
        CreativeHubScreen.drawLabel,
      );
      expect(tester.widget<FilledButton>(draw).onPressed, isNull);
    });

    testWidgets('creations survive an app restart', (tester) async {
      await openIsland(tester);
      await tapText(tester, CreativeHubScreen.creatureLabel);
      await tapText(tester, CreatureScreen.saveLabel);

      await tester.pumpWidget(const SizedBox());
      await openIsland(tester);

      expect(find.text(CreativeHubScreen.shelfCount(1, 12)), findsOneWidget);
    });

    testWidgets('Home counts creations in the explorer log', (tester) async {
      await seedCreature();
      await startApp(tester);
      await tester.ensureVisible(find.text('1 creation'));

      expect(find.text('1 creation'), findsOneWidget);
    });
  });

  testWidgets('Buddy opens Creative Island from his answer', (tester) async {
    await startApp(tester);
    await tester.enterText(find.byType(TextField), 'I want to draw');
    await tapText(tester, 'Ask');

    expect(find.textContaining('Creative Island is open!'), findsWidgets);
    await tapText(tester, 'Visit Creative Island');
    expect(find.text(CreativeHubScreen.welcome), findsOneWidget);
  });

  testWidgets('the Parent Zone shows creations, and reset deletes them', (
    tester,
  ) async {
    await creations.add((id) => Drawing(id: id, strokes: const []));
    await creations.add(
      (id) => Creature(
        id: id,
        name: 'Moxo',
        body: CreatureBody.tall,
        colorIndex: 2,
        eyes: CreatureEyes.round,
        mouth: CreatureMouth.grin,
        extra: CreatureExtra.none,
        pattern: CreaturePattern.spots,
      ),
    );
    await store.write(LocalCreationsRepository.corruptBackupKey, 'old');
    await LocalProgressRepository(
      store,
    ).save(LearnerProgress.empty.withMissionResult('moon', 50));
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

    await tester.ensureVisible(find.text(DataOverviewSection.creationsTitle));
    expect(find.text('1 drawing, 1 creature'), findsOneWidget);
    expect(find.text(DataOverviewSection.creationsBackupTitle), findsOneWidget);

    await tapText(tester, ParentZoneScreen.resetLabel);
    expect(
      find.text('Creative Island creations: 1 drawing, 1 creature.'),
      findsOneWidget,
    );
    await tapText(tester, ResetExplainDialog.continueLabel);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
    );
    await tester.pumpAndSettle();

    expect(find.text(ParentZoneScreen.resetDone), findsOneWidget);
    expect(find.text('0 drawings, 0 creatures'), findsOneWidget);
    expect(await store.read(LocalCreationsRepository.storageKey), isNull);
    expect(await store.read(LocalCreationsRepository.corruptBackupKey), isNull);

    await tester.pumpWidget(const SizedBox());
    await openIsland(tester);
    expect(find.text(CreativeHubScreen.emptyShelf), findsOneWidget);
  });

  testWidgets('Stop talking silences Buddy in an activity', (tester) async {
    tts.holdSpeech = true;
    await openIsland(tester);
    await tapText(tester, CreativeHubScreen.creatureLabel);

    await tapText(tester, MissionVoiceBar.stopLabel);

    expect(tts.isSpeaking, isFalse);
    expect(find.text(MissionVoiceBar.hearAgainLabel), findsOneWidget);
  });

  testWidgets('with no speech engine, activities fully work', (tester) async {
    tts.available = false;
    await openIsland(tester);
    await tapText(tester, CreativeHubScreen.creatureLabel);
    await tapText(tester, CreatureScreen.saveLabel);

    expect(tts.spoken, isEmpty);
    expect(find.text(CreativeSaveNote.savedTitle), findsOneWidget);
  });

  testWidgets('Creative Island never touches the microphone', (tester) async {
    await openIsland(tester);
    await tapText(tester, CreativeHubScreen.drawLabel);
    await drawLine(tester);
    await tapText(tester, DrawingScreen.saveLabel);

    expect(speech.totalCalls, 0);
  });
}
