import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/games/dino.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/dino_hub_screen.dart';
import 'package:curious_buddy/ui/games/dino_play_screen.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/games/how_to_play.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: tts,
      settings: store,
      sounds: FakeSoundEffectsService(),
    );
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  const allGuides = [
    HowToPlay.memory,
    HowToPlay.pattern,
    HowToPlay.spot,
    HowToPlay.maze,
    HowToPlay.robot,
    HowToPlay.words,
    HowToPlay.sounds,
    HowToPlay.four,
    HowToPlay.number,
    HowToPlay.sort,
    HowToPlay.circuit,
    HowToPlay.dino,
    HowToPlay.quickCreate,
  ];

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Widget arenaGame(GameKind kind) => MaterialApp(
    theme: AppTheme.light(),
    home: GamePlayScreen(
      level: GameLevel(kind, 1),
      voice: voice,
      progressRepository: progress,
      random: Random(1),
    ),
  );

  Widget dinoGame() => MaterialApp(
    theme: AppTheme.light(),
    home: DinoPlayScreen(
      place: DinoPlace.fernForest,
      voice: voice,
      progressRepository: progress,
      random: Random(1),
    ),
  );

  Future<void> openZone(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, store: store));
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.games.title);
  }

  group('instructions', () {
    test('every game explains itself in a few short steps', () {
      for (final guide in allGuides) {
        expect(guide.steps.length, inInclusiveRange(3, 5), reason: guide.game);
        for (final step in guide.steps) {
          expect(step.text.split(' ').length, lessThanOrEqualTo(14));
        }
        expect(guide.spoken, contains(guide.game));
        expect(guide.spoken, contains(guide.steps.last.text));
      }
    });

    test('every Arena game has its own instructions', () {
      expect(
        GameKind.values.map((k) => HowToPlay.of(k).game).toSet(),
        GameKind.values.map((k) => k.title).toSet(),
      );
    });

    for (final kind in GameKind.values) {
      testWidgets('${kind.title} explains itself the first time only', (
        tester,
      ) async {
        usePhoneScreen(tester);
        await tester.pumpWidget(arenaGame(kind));
        await tester.pumpAndSettle();
        final guide = HowToPlay.of(kind);

        expect(find.text(HowToPlaySheet.titleOf(guide)), findsOneWidget);
        expect(tts.spoken.last, guide.spoken);

        await tapText(tester, HowToPlaySheet.letsPlayLabel);
        expect(find.text(HowToPlaySheet.titleOf(guide)), findsNothing);

        await progress.save(
          LearnerProgress.empty.withGameResult(GameLevel(kind, 1).id, 1),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(arenaGame(kind));
        await tester.pumpAndSettle();
        expect(find.text(HowToPlaySheet.titleOf(guide)), findsNothing);
      });
    }

    testWidgets('Dino Discovery explains itself once, across its places', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(dinoGame());
      await tester.pumpAndSettle();
      expect(find.text(HowToPlaySheet.titleOf(HowToPlay.dino)), findsOneWidget);
      await tapText(tester, HowToPlaySheet.letsPlayLabel);

      await progress.save(
        LearnerProgress.empty.withGameResult(DinoPlace.fernForest.id, 1),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(dinoGame());
      await tester.pumpAndSettle();
      expect(find.text(HowToPlaySheet.titleOf(HowToPlay.dino)), findsNothing);
    });

    testWidgets('the help button reopens them during a game', (tester) async {
      await progress.save(LearnerProgress.empty.withGameResult('memory_1', 1));
      usePhoneScreen(tester);
      await tester.pumpWidget(arenaGame(GameKind.memory));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(HowToPlaySheet.buttonTooltip));
      await tester.pumpAndSettle();
      expect(
        find.text(HowToPlaySheet.titleOf(HowToPlay.memory)),
        findsOneWidget,
      );

      await tapText(tester, HowToPlaySheet.gotItLabel);
      expect(find.text(HowToPlaySheet.titleOf(HowToPlay.memory)), findsNothing);
    });

    testWidgets('closing them stops Buddy', (tester) async {
      tts.holdSpeech = true;
      usePhoneScreen(tester);
      await tester.pumpWidget(arenaGame(GameKind.spot));
      await tester.pumpAndSettle();
      expect(tts.isSpeaking, isTrue);

      tts.holdSpeech = false;
      await tapText(tester, HowToPlaySheet.letsPlayLabel);
      expect(tts.isSpeaking, isFalse);
    });

    testWidgets('each menu offers them before playing', (tester) async {
      await openZone(tester);
      await tapText(tester, GameZoneScreen.arenaLabel);
      expect(
        find.text(HowToPlaySheet.buttonTooltip),
        findsNWidgets(GameKind.arena.length + 1),
        reason: 'one for each game, and one for Quick Create',
      );
      await tapText(tester, HowToPlaySheet.buttonTooltip);
      expect(
        find.text(HowToPlaySheet.titleOf(HowToPlay.memory)),
        findsOneWidget,
      );
      await tapText(tester, HowToPlaySheet.gotItLabel);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapText(tester, GameZoneScreen.dinoLabel);
      await tapText(tester, HowToPlaySheet.buttonTooltip);
      expect(find.text(HowToPlaySheet.titleOf(HowToPlay.dino)), findsOneWidget);
      expect(find.text(DinoHubScreen.title), findsOneWidget);
    });

    testWidgets('they meet the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      usePhoneScreen(tester);
      await tester.pumpWidget(dinoGame());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });

    for (final (name, size) in [
      ('small phone', const Size(320, 640)),
      ('tall phone', const Size(412, 892)),
    ]) {
      testWidgets('the longest one fits with 2x text: $name', (tester) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, 2);
        await tester.pumpWidget(dinoGame());
        await tester.pumpAndSettle();

        await tapText(tester, HowToPlaySheet.letsPlayLabel);
        expect(find.byType(DinoPlayScreen), findsOneWidget);
      });
    }
  });

  group('Game Zone', () {
    test('ranks rise with stars and never need more than exist', () {
      expect(GameRank.of(0), GameRank.rookie);
      expect(GameRank.of(5), GameRank.rookie);
      expect(GameRank.of(6), GameRank.player);
      expect(GameRank.of(15), GameRank.starPlayer);
      expect(GameRank.of(ArenaRules.allStars), GameRank.champion);
      expect(GameRank.champion.stars, lessThan(ArenaRules.allStars));
      expect(GameRank.rookie.next, GameRank.player);
      expect(GameRank.champion.next, isNull);
    });

    testWidgets('the scoreboard shows stars, rank and the next rank', (
      tester,
    ) async {
      await progress.save(
        LearnerProgress.empty
            .withGameResult('memory_1', 3)
            .withGameResult('dino_fern_forest', 3),
      );
      await openZone(tester);

      expect(find.text(GameRank.player.label), findsOneWidget);
      expect(
        find.text(GameZoneScreen.starsLabel(6, ArenaRules.allStars)),
        findsOneWidget,
      );
      expect(
        find.text(GameZoneScreen.nextRankLabel(6, GameRank.starPlayer)),
        findsOneWidget,
      );
    });

    for (final (kind, label) in [
      (GameKind.four, GameZoneScreen.fourLabel),
      (GameKind.number, GameZoneScreen.numberLabel),
    ]) {
      testWidgets('${kind.title} has its own big tile', (tester) async {
        await openZone(tester);

        await tapText(tester, label);

        expect(find.text(kind.tagline), findsOneWidget);
        expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
      });
    }

    testWidgets('a storage error still opens the Game Zone', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(store: FailingKeyValueStore()));
      await tester.pumpAndSettle();
      await tapText(tester, HomeDestination.games.title);

      expect(find.text(GameRank.rookie.label), findsOneWidget);
    });

    testWidgets('it meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await openZone(tester);

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
      testWidgets('it lays out: $name', (tester) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        await tester.pumpWidget(buildTestApp(store: store));
        await tester.pumpAndSettle();
        await tapText(tester, HomeDestination.games.title);

        // Overflow errors fail the test automatically.
        expect(find.text(GameZoneScreen.welcome), findsOneWidget);
      });
    }
  });
}
