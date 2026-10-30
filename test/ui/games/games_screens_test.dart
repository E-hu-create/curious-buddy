import 'dart:math';

import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/discoveries/discovery_journal.dart';
import 'package:curious_buddy/domain/games/game_content.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/domain/wardrobe/wardrobe.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/creative/drawing_screen.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/games/widgets/game_parts.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import '../parent_zone/parent_zone_screen_test.dart' show wordsToNumber;

const _memory1 = GameLevel(GameKind.memory, 1);
const _pattern1 = GameLevel(GameKind.pattern, 1);
const _spot1 = GameLevel(GameKind.spot, 1);

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

  Future<void> tapLabel(WidgetTester tester, Pattern label) async {
    final target = find.bySemanticsLabel(label).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> startApp(WidgetTester tester, {KeyValueStore? custom}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        tts: tts,
        speech: speech,
        store: custom ?? store,
        sounds: sounds,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openArena(WidgetTester tester) async {
    await startApp(tester);
    await tapText(tester, HomeDestination.games.title);
    await tapText(tester, GameZoneScreen.arenaLabel);
  }

  Widget game(GameLevel level, {int seed = 1}) => MaterialApp(
    theme: AppTheme.light(),
    home: GamePlayScreen(
      level: level,
      voice: voice,
      progressRepository: progress,
      random: Random(seed),
      autoGuide: false,
    ),
  );

  /// Wins a memory board shown on screen, using the same seed.
  Future<void> winMemory(WidgetTester tester, int pairs, int seed) async {
    final cards = MemoryGame(pairs: pairs, random: Random(seed)).cards;
    final done = <int>{};
    for (var i = 0; i < cards.length; i++) {
      if (done.contains(i)) continue;
      final j = [
        for (var k = i + 1; k < cards.length; k++)
          if (cards[k] == cards[i]) k,
      ].single;
      done.addAll([i, j]);
      await tapLabel(tester, RegExp('^Card ${i + 1}, face down'));
      await tapLabel(tester, RegExp('^Card ${j + 1}, face down'));
    }
  }

  group('game logic through the view models', () {
    test('Memory: winning saves stars; replays keep the best', () async {
      final vm = MemoryViewModel(
        level: _memory1,
        voice: voice,
        progressRepository: progress,
        random: Random(1),
      );
      void win() {
        final g = vm.game;
        for (var i = 0; i < g.cards.length; i++) {
          if (g.isFaceUp(i)) continue;
          final j = [
            for (var k = i + 1; k < g.cards.length; k++)
              if (g.cards[k] == g.cards[i]) k,
          ].single;
          vm
            ..flip(i)
            ..flip(j);
        }
      }

      win();
      await pumpEventQueue();
      expect(vm.isFinished, isTrue);
      expect(vm.stars, 3);
      expect(vm.saveStatus, GameSaveStatus.saved);
      expect((await progress.load()).gameBest, {'memory_1': 3});
      expect(sounds.played.last, SoundEffect.cheer);

      vm.playAgain();
      expect(vm.isFinished, isFalse);
      expect(vm.game.moves, 0);
      vm.dispose();
      await progress.save(
        (await progress.load()).withGameResult('memory_1', 1),
      );
      expect((await progress.load()).gameBest['memory_1'], 3);
    });

    test('Pattern: one pick per round; stars follow the score', () async {
      for (final (right, stars) in [(5, 3), (4, 2), (3, 1), (2, 0)]) {
        final vm = PatternViewModel(
          level: _pattern1,
          voice: voice,
          progressRepository: progress,
        );
        for (var i = 0; i < vm.total; i++) {
          final r = vm.round;
          vm.pick(
            i < right ? r.answer : r.options.firstWhere((o) => o != r.answer),
          );
          vm.pick(r.answer); // a second pick changes nothing
          await vm.next();
        }
        expect(vm.rightCount, right);
        expect(vm.stars, stars);
        vm.dispose();
      }
    });

    test('Pattern: a wrong answer gives the right one and why', () async {
      final vm = PatternViewModel(
        level: _pattern1,
        voice: voice,
        progressRepository: progress,
      );
      final r = vm.round;
      vm.pick(r.options.firstWhere((o) => o != r.answer));
      await pumpEventQueue();

      expect(tts.spoken.last, contains('The answer is ${r.answer.label}'));
      expect(sounds.played.last, SoundEffect.gentle);
      vm.dispose();
    });

    test(
      'Spot: finding every change finishes; wrong taps cost a star',
      () async {
        final vm = SpotViewModel(
          level: _spot1,
          voice: voice,
          progressRepository: progress,
          random: Random(2),
        );
        final wrong = [
          for (var i = 0; i < vm.game.first.length; i++)
            if (!vm.game.changed.contains(i)) i,
        ].first;

        vm.tap(wrong);
        expect(vm.lastMiss, wrong);
        await pumpEventQueue();
        vm.game.changed.toList().forEach(vm.tap);
        await pumpEventQueue();

        expect(vm.isFinished, isTrue);
        expect(vm.stars, 2);
        expect((await progress.load()).gameBest, {'spot_1': 2});
        vm.dispose();
      },
    );

    test('a failed save is reported, and the stars still show', () async {
      final vm = PatternViewModel(
        level: _pattern1,
        voice: voice,
        progressRepository: LocalProgressRepository(ReadOnlyKeyValueStore()),
      );
      for (var i = 0; i < vm.total; i++) {
        vm.pick(vm.round.answer);
        await vm.next();
      }

      expect(vm.saveStatus, GameSaveStatus.failed);
      expect(vm.stars, 3);
      vm.dispose();
    });

    test('leaving a game stops Buddy', () async {
      tts.holdSpeech = true;
      final vm = PatternViewModel(
        level: _pattern1,
        voice: voice,
        progressRepository: progress,
      )..narrateIntro();
      await pumpEventQueue();
      expect(tts.isSpeaking, isTrue);

      vm.dispose();
      await pumpEventQueue();
      expect(tts.isSpeaking, isFalse);
    });
  });

  group('saved results', () {
    test('round-trip, older data, bad entries, equality', () {
      final saved = LearnerProgress.empty.withGameResult('memory_1', 2);
      expect(LearnerProgress.tryFromJson(saved.toJson()), saved);
      expect(saved, isNot(LearnerProgress.empty));

      expect(
        LearnerProgress.tryFromJson({
          'schemaVersion': 5,
          'gameBest': {'memory_1': 2},
        })!.gameBest,
        isEmpty,
      );
      expect(
        LearnerProgress.tryFromJson({
          'schemaVersion': 6,
          'gameBest': {'ok': 2, 'huge': 9, 'text': 'three'},
        })!.gameBest,
        {'ok': 2},
      );
    });

    test('moves read correctly', () {
      expect(GamePlayScreen.movesLabel(1), '1 move');
      expect(GamePlayScreen.movesLabel(2), '2 moves');
    });

    test('game stars count in the journal', () {
      final j = DiscoveryJournal.build(
        progress: LearnerProgress.empty.withGameResult('memory_1', 3),
      );
      expect(j.gameStars, 3);
      expect(j.discoveries, 3);
      expect(j.summary, contains('won 3 game stars'));
      expect(WardrobeItem.championCap.progressText(j), '3 of 6 game stars');
    });
  });

  group('screens', () {
    testWidgets('Home → Game Zone → Arena shows every game and level', (
      tester,
    ) async {
      await openArena(tester);

      for (final kind in GameKind.arena) {
        await tester.ensureVisible(find.text(kind.title));
        expect(find.text(kind.title), findsOneWidget);
      }
      expect(
        find.bySemanticsLabel('Play Starter'),
        findsNWidgets(GameKind.arena.length),
      );
      expect(
        find.bySemanticsLabel(ArenaScreen.lockedLabel('Starter')),
        findsNWidgets(GameKind.arena.length),
      );
      expect(find.text(ArenaScreen.quickTitle), findsOneWidget);
    });

    testWidgets('the Game Zone has a tile for every game', (tester) async {
      await startApp(tester);
      await tapText(tester, HomeDestination.games.title);

      for (final title in [
        GameZoneScreen.dinoTitle,
        GameZoneScreen.arenaTitle,
        ...GameKind.values
            .where((kind) => !GameKind.arena.contains(kind))
            .map((kind) => kind.title),
      ]) {
        await tester.ensureVisible(find.text(title));
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('Buddy opens the Game Zone from his answer', (tester) async {
      await startApp(tester);
      await tester.enterText(find.byType(TextField), 'I want to play a game');
      await tapText(tester, 'Ask');

      await tapText(tester, 'Open the Game Zone');

      expect(find.text(GameZoneScreen.welcome), findsOneWidget);
    });

    testWidgets('Memory Match can be won by tapping cards', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(game(_memory1));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('face down')), findsNWidgets(6));

      await winMemory(tester, 3, 1);

      expect(find.text('Amazing! Three stars!'), findsOneWidget);
      expect(find.text(GameShell.playAgainLabel), findsOneWidget);
    });

    testWidgets('Pattern Power: answers, explanations, then stars', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(game(_pattern1));
      await tester.pumpAndSettle();
      final rounds = patternLevels[1]!;

      for (var i = 0; i < rounds.length; i++) {
        expect(
          find.text(GamePlayScreen.questionLabel(i + 1, 5)),
          findsOneWidget,
        );
        // The answer buttons come after the pattern itself.
        final answer = find
            .bySemanticsLabel(RegExp('^${rounds[i].answer.label}\$'))
            .last;
        await tester.ensureVisible(answer);
        await tester.pumpAndSettle();
        await tester.tap(answer);
        await tester.pumpAndSettle();
        expect(find.text(rounds[i].explanation), findsOneWidget);
        await tapText(
          tester,
          i == rounds.length - 1
              ? GamePlayScreen.seeStars
              : GamePlayScreen.nextQuestion,
        );
      }

      expect(find.text('Amazing! Three stars!'), findsOneWidget);
    });

    testWidgets('Spot the Change: tap the changes in the second picture', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(game(_spot1, seed: 4));
      await tester.pumpAndSettle();
      final copy = SpotGame(rows: 3, columns: 3, changes: 2, random: Random(4));
      final wrong = [
        for (var i = 0; i < 9; i++)
          if (!copy.changed.contains(i)) i,
      ].first;

      // The second picture's tiles come after the first's.
      Finder tile(int index) => find
          .bySemanticsLabel(
            RegExp(
              '^Row ${index ~/ 3 + 1}, column ${index % 3 + 1}: '
              '${copy.second[index].label}',
            ),
          )
          .last;

      await tester.ensureVisible(tile(wrong));
      await tester.pumpAndSettle();
      await tester.tap(tile(wrong));
      await tester.pumpAndSettle();
      expect(find.text(GamePlayScreen.missNote), findsOneWidget);

      for (final i in copy.changed) {
        await tester.ensureVisible(tile(i));
        await tester.pumpAndSettle();
        await tester.tap(tile(i));
        await tester.pumpAndSettle();
      }
      expect(find.text('Great job! Two stars!'), findsOneWidget);
    });

    testWidgets('a star opens the next level, and Next level goes there', (
      tester,
    ) async {
      await progress.save(LearnerProgress.empty.withGameResult('memory_1', 2));
      await openArena(tester);

      expect(find.bySemanticsLabel('Play Explorer'), findsOneWidget);
      await tapLabel(tester, 'Play Starter');
      expect(find.text('Memory Match: Starter'), findsOneWidget);
    });

    testWidgets('results survive a restart', (tester) async {
      await progress.save(LearnerProgress.empty.withGameResult('pattern_1', 3));
      await openArena(tester);
      await tester.pumpWidget(const SizedBox());
      await openArena(tester);

      expect(find.bySemanticsLabel('Play Explorer'), findsOneWidget);
      expect((await progress.load()).gameBest, {'pattern_1': 3});
    });

    testWidgets('Quick Create gives an idea and opens the Drawing Studio', (
      tester,
    ) async {
      await openArena(tester);
      await tapText(tester, ArenaScreen.newIdea);
      final shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .firstWhere(quickCreateIdeas.contains);

      await tapText(tester, ArenaScreen.startDrawing);

      expect(find.text(DrawingScreen.title), findsOneWidget);
      expect(find.text(shown!), findsOneWidget);
    });

    testWidgets('Quick Create explains a full shelf', (tester) async {
      final creations = LocalCreationsRepository(store);
      for (var i = 0; i < CreativeLimits.maxCreations; i++) {
        await creations.add((id) => Drawing(id: id, strokes: const []));
      }
      await openArena(tester);

      await tester.ensureVisible(find.text(ArenaScreen.shelfFull));
      expect(find.text(ArenaScreen.shelfFull), findsOneWidget);
    });

    testWidgets('a storage error offers a retry', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(store: FailingKeyValueStore()));
      await tester.pumpAndSettle();
      await tapText(tester, HomeDestination.games.title);
      await tapText(tester, GameZoneScreen.arenaLabel);

      expect(find.text(ArenaScreen.errorMessage), findsOneWidget);
    });

    testWidgets('there is nothing to type, and no microphone', (tester) async {
      await openArena(tester);
      expect(find.byType(TextField), findsNothing);
      expect(speech.totalCalls, 0);
    });

    testWidgets('the Parent Zone shows game results, and reset deletes them', (
      tester,
    ) async {
      await progress.save(
        LearnerProgress.empty
            .withGameResult('memory_1', 3)
            .withGameResult('spot_1', 1),
      );
      await startApp(tester);
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
      await tester.ensureVisible(find.text(DataOverviewSection.gamesTitle));
      expect(find.text('2 levels played, 4 stars'), findsOneWidget);

      await tapText(tester, ParentZoneScreen.resetLabel);
      expect(
        find.text('Game Zone results: 2 levels played, 4 stars.'),
        findsOneWidget,
      );
      await tapText(tester, ResetExplainDialog.continueLabel);
      await tester.enterText(find.byType(TextField).last, 'DELETE');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, ResetConfirmDialog.deleteLabel),
      );
      await tester.pumpAndSettle();

      expect((await progress.load()).gameBest, isEmpty);
    });
  });

  group('accessibility', () {
    for (final kind in GameKind.values) {
      testWidgets('${kind.title} meets the guidelines', (tester) async {
        final semantics = tester.ensureSemantics();
        usePhoneScreen(tester);
        await tester.pumpWidget(game(GameLevel(kind, 1)));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }

    testWidgets('the Arena meets the guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await openArena(tester);

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
      for (final kind in GameKind.values) {
        testWidgets('${kind.title} lays out at every level: $name', (
          tester,
        ) async {
          usePhoneScreen(tester, logicalSize: size);
          useTextScale(tester, scale);
          for (final level in ArenaRules.levelsOf(kind)) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpWidget(game(level));
            await tester.pumpAndSettle();
          }
          // Overflow errors fail the test automatically.
          expect(find.byType(GamePlayScreen), findsOneWidget);
        });
      }

      testWidgets('the Arena lays out: $name', (tester) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        await tester.pumpWidget(buildTestApp(store: store));
        await tester.pumpAndSettle();
        await tapText(tester, HomeDestination.games.title);
        await tapText(tester, GameZoneScreen.arenaLabel);

        expect(find.text(ArenaScreen.title), findsOneWidget);
      });
    }
  });
}
