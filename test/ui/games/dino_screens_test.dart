import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/discoveries/discovery_journal.dart';
import 'package:curious_buddy/domain/games/dino.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/dino_hub_screen.dart';
import 'package:curious_buddy/ui/games/dino_play_screen.dart';
import 'package:curious_buddy/ui/games/dino_view_model.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/games/widgets/dino_art.dart';
import 'package:curious_buddy/ui/games/widgets/game_parts.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late FakeSoundEffectsService sounds;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    sounds = FakeSoundEffectsService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store, sounds: sounds);
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

  Future<void> tapLabel(WidgetTester tester, String label) async {
    final target = find.bySemanticsLabel(label).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> openHub(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store, sounds: sounds),
    );
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.games.title);
    await tapText(tester, GameZoneScreen.dinoLabel);
  }

  Widget playScreen(DinoPlace place) => MaterialApp(
    theme: AppTheme.light(),
    home: DinoPlayScreen(
      place: place,
      voice: voice,
      progressRepository: progress,
      random: Random(1),
    ),
  );

  DinoViewModel viewModel([DinoPlace place = DinoPlace.fernForest]) =>
      DinoViewModel(
        place: place,
        voice: voice,
        progressRepository: progress,
        random: Random(1),
      );

  /// Plays a whole expedition through the screen, without a wrong pick.
  Future<void> winThrough(WidgetTester tester, DinoPlace place) async {
    for (final (i, creature) in place.creatures.indexed) {
      await tapLabel(tester, DinoPlayScreen.spotLabel(i + 1));
      expect(find.text(creature.clues[0]), findsOneWidget);
      await tapLabel(tester, creature.name);
      expect(find.text(creature.fact), findsOneWidget);
      await tapText(
        tester,
        i == place.creatures.length - 1
            ? DinoPlayScreen.startMission
            : DinoPlayScreen.keepExploring,
      );
    }
    for (final (i, task) in place.mission.indexed) {
      expect(find.text(task.prompt), findsOneWidget);
      await tapLabel(tester, task.answer.name);
      expect(find.text(task.explanation), findsOneWidget);
      await tapText(
        tester,
        i == place.mission.length - 1
            ? DinoPlayScreen.seeStars
            : DinoPlayScreen.nextQuestion,
      );
    }
  }

  group('view model', () {
    test('a clue is read out, and "Hear again" repeats it', () async {
      final vm = viewModel()..look(DinoCreature.stegosaurus);
      await pumpEventQueue();

      expect(tts.spoken.last, contains(DinoCreature.stegosaurus.clues[0]));
      expect(sounds.played.last, SoundEffect.pop);
      vm.dispose();
    });

    test('a wrong pick is kind, and brings the next clue', () async {
      final vm = viewModel()..look(DinoCreature.stegosaurus);
      final wrong = vm.expedition.options.firstWhere(
        (o) => o != DinoCreature.stegosaurus,
      );
      vm.pick(wrong);
      await pumpEventQueue();

      expect(vm.lastWrong, wrong);
      expect(tts.spoken.last, contains(DinoCreature.stegosaurus.clues[1]));
      expect(sounds.played.last, SoundEffect.gentle);
      vm.dispose();
    });

    test('finishing saves stars and keeps the best', () async {
      final vm = viewModel();
      Future<void> win() async {
        for (final creature in vm.place.creatures) {
          vm
            ..look(creature)
            ..pick(creature);
          await vm.carryOn();
        }
        for (var i = 0; i < vm.place.mission.length; i++) {
          vm.pick(vm.expedition.task.answer);
          await pumpEventQueue(); // a child can't tap between sounds
          await vm.carryOn();
        }
      }

      await win();
      await pumpEventQueue();
      expect(vm.isFinished, isTrue);
      expect(vm.stars, 3);
      expect(vm.saveStatus, GameSaveStatus.saved);
      expect(sounds.played.last, SoundEffect.cheer);
      expect((await progress.load()).gameBest, {'dino_fern_forest': 3});

      vm.playAgain();
      expect(vm.isFinished, isFalse);
      expect(vm.expedition.found, isEmpty);
      vm.dispose();
    });

    test('a failed save is reported, and the stars still show', () async {
      final vm = DinoViewModel(
        place: DinoPlace.fernForest,
        voice: voice,
        progressRepository: LocalProgressRepository(ReadOnlyKeyValueStore()),
        random: Random(1),
      );
      for (final creature in vm.place.creatures) {
        vm
          ..look(creature)
          ..pick(creature);
        await vm.carryOn();
      }
      for (var i = 0; i < vm.place.mission.length; i++) {
        vm.pick(vm.expedition.task.answer);
        await vm.carryOn();
      }

      expect(vm.saveStatus, GameSaveStatus.failed);
      expect(vm.stars, 3);
      vm.dispose();
    });

    test('leaving stops Buddy', () async {
      tts.holdSpeech = true;
      final vm = viewModel()..narrateIntro();
      await pumpEventQueue();
      expect(tts.isSpeaking, isTrue);

      vm.dispose();
      await pumpEventQueue();
      expect(tts.isSpeaking, isFalse);
    });
  });

  group('journal', () {
    test('expedition stars count as game stars', () {
      final j = DiscoveryJournal.build(
        progress: LearnerProgress.empty.withGameResult('dino_fern_forest', 3),
      );
      expect(j.gameStars, 3);
    });
  });

  group('screens', () {
    testWidgets('the Game Zone opens Dino Discovery with one place open', (
      tester,
    ) async {
      await openHub(tester);

      expect(find.text(DinoHubScreen.title), findsOneWidget);
      expect(
        find.text(DinoHubScreen.exploreLabel(DinoPlace.fernForest)),
        findsOneWidget,
      );
      expect(
        find.text(DinoHubScreen.exploreLabel(DinoPlace.openPlains)),
        findsNothing,
      );
      expect(
        find.text(DinoHubScreen.lockedLabel(DinoPlace.fernForest)),
        findsOneWidget,
      );
      expect(find.text(DinoHubScreen.guideLabel(0, 9)), findsOneWidget);
    });

    for (final place in DinoPlace.values) {
      testWidgets('${place.name} can be played to the end', (tester) async {
        usePhoneScreen(tester);
        await tester.pumpWidget(playScreen(place));
        await tester.pumpAndSettle();

        await winThrough(tester, place);

        expect(find.text('Amazing! Three stars!'), findsOneWidget);
        expect(find.text(DinoPlayScreen.guideTitle), findsOneWidget);
        expect((await progress.load()).gameBest, {place.id: 3});
      });
    }

    testWidgets('a found creature appears in the scene', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(playScreen(DinoPlace.fernForest));
      await tester.pumpAndSettle();
      expect(find.byType(DinoArt), findsNothing);

      await tapLabel(tester, DinoPlayScreen.spotLabel(1));
      await tapLabel(tester, DinoCreature.stegosaurus.name);
      await tapText(tester, DinoPlayScreen.keepExploring);

      expect(find.byType(DinoArt), findsOneWidget);
      expect(find.text(DinoPlayScreen.foundLabel(1, 3)), findsOneWidget);
      expect(find.bySemanticsLabel(DinoPlayScreen.spotLabel(1)), findsNothing);
    });

    testWidgets('a wrong pick shows why and gives the next clue', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(playScreen(DinoPlace.fernForest));
      await tester.pumpAndSettle();
      await tapLabel(tester, DinoPlayScreen.spotLabel(1));

      final expedition = DinoExpedition(
        place: DinoPlace.fernForest,
        random: Random(1),
      )..investigate(DinoCreature.stegosaurus);
      final wrong = expedition.options.firstWhere(
        (o) => o != DinoCreature.stegosaurus,
      );
      await tapLabel(tester, wrong.name);

      expect(find.text(DinoPlayScreen.wrongLabel(wrong)), findsOneWidget);
      expect(find.text(DinoCreature.stegosaurus.clues[1]), findsOneWidget);
    });

    testWidgets('next place carries on, and the hub remembers', (tester) async {
      await openHub(tester);
      await tapText(tester, DinoHubScreen.exploreLabel(DinoPlace.fernForest));
      await winThrough(tester, DinoPlace.fernForest);

      await tapText(
        tester,
        DinoPlayScreen.nextPlaceLabel(DinoPlace.openPlains),
      );
      expect(find.text(DinoPlace.openPlains.intro), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(DinoHubScreen.guideLabel(3, 9)), findsOneWidget);
      expect(
        find.text(DinoHubScreen.exploreLabel(DinoPlace.openPlains)),
        findsOneWidget,
      );
    });

    testWidgets('the Field Guide fills in, and reads an entry aloud', (
      tester,
    ) async {
      await progress.save(
        LearnerProgress.empty.withGameResult(DinoPlace.fernForest.id, 1),
      );
      await openHub(tester);
      await tapText(tester, DinoHubScreen.guideLabel(3, 9));

      final found = DinoCreature.stegosaurus;
      expect(find.text(found.fact), findsOneWidget);

      await tapText(tester, FieldGuideScreen.hearLabel);
      expect(tts.spoken.last, found.guideLine);

      // Further down, the creatures not found yet stay secret.
      await tester.drag(find.byType(ListView), const Offset(0, -2200));
      await tester.pumpAndSettle();
      expect(
        find.text(FieldGuideScreen.lockedLabel(DinoPlace.openPlains)),
        findsWidgets,
      );
      expect(find.text(DinoCreature.triceratops.fact), findsNothing);
      expect(find.text(DinoCreature.triceratops.name), findsNothing);
    });

    testWidgets('leaving the Field Guide stops Buddy', (tester) async {
      await progress.save(
        LearnerProgress.empty.withGameResult(DinoPlace.fernForest.id, 1),
      );
      await openHub(tester);
      await tapText(tester, DinoHubScreen.guideLabel(3, 9));
      tts.holdSpeech = true;
      await tester.tap(find.text(FieldGuideScreen.hearLabel).first);
      await tester.pumpAndSettle();
      expect(tts.isSpeaking, isTrue);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tts.isSpeaking, isFalse);
    });

    testWidgets('a storage error offers a retry', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(store: FailingKeyValueStore()));
      await tester.pumpAndSettle();
      await tapText(tester, HomeDestination.games.title);
      await tapText(tester, GameZoneScreen.dinoLabel);

      expect(find.text(DinoHubScreen.errorMessage), findsOneWidget);
    });

    testWidgets('there is nothing to type, and no microphone', (tester) async {
      await openHub(tester);
      expect(find.byType(TextField), findsNothing);
      expect(speech.totalCalls, 0);
    });

    testWidgets('Play again starts the place over', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(playScreen(DinoPlace.ancientSea));
      await tester.pumpAndSettle();
      await winThrough(tester, DinoPlace.ancientSea);

      await tapText(tester, GameShell.playAgainLabel);

      expect(find.text(DinoPlayScreen.foundLabel(0, 3)), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('every stage meets the guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      usePhoneScreen(tester);
      await tester.pumpWidget(playScreen(DinoPlace.fernForest));
      await tester.pumpAndSettle();

      Future<void> check() async {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }

      await check(); // exploring
      await tapLabel(tester, DinoPlayScreen.spotLabel(1));
      await check(); // identifying
      await tapLabel(tester, DinoCreature.stegosaurus.name);
      await check(); // discovered
      semantics.dispose();
    });

    testWidgets('the hub and Field Guide meet the guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await progress.save(
        LearnerProgress.empty.withGameResult(DinoPlace.fernForest.id, 2),
      );
      await openHub(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      await tapText(tester, DinoHubScreen.guideLabel(3, 9));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });

    for (final (name, size, scale) in [
      ('small phone', const Size(320, 640), 1.0),
      ('phone with 2x text', const Size(412, 892), 2.0),
      ('small phone with 2x text', const Size(320, 640), 2.0),
    ]) {
      testWidgets('every stage lays out: $name', (tester) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        await tester.pumpWidget(playScreen(DinoPlace.ancientSea));
        await tester.pumpAndSettle();

        // Overflow errors fail the test automatically.
        await winThrough(tester, DinoPlace.ancientSea);
        expect(find.byType(DinoPlayScreen), findsOneWidget);
      });

      testWidgets('the hub and Field Guide lay out: $name', (tester) async {
        await progress.save(
          LearnerProgress.empty.withGameResult(DinoPlace.fernForest.id, 2),
        );
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        await tester.pumpWidget(buildTestApp(store: store));
        await tester.pumpAndSettle();
        await tapText(tester, HomeDestination.games.title);
        await tapText(tester, GameZoneScreen.dinoLabel);
        await tapText(tester, DinoHubScreen.guideLabel(3, 9));

        expect(find.text(FieldGuideScreen.title), findsOneWidget);
      });
    }
  });
}
