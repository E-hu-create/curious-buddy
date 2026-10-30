import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/circuit.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const _level = GameLevel(GameKind.circuit, 1);

void main() {
  late FakeTextToSpeechService tts;
  late FakeSoundEffectsService sounds;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  setUp(() {
    tts = FakeTextToSpeechService();
    sounds = FakeSoundEffectsService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store, sounds: sounds);
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  CircuitViewModel viewModel() => CircuitViewModel(
    level: _level,
    voice: voice,
    progressRepository: progress,
    random: Random(1),
  );

  Widget screen([GameLevel level = _level]) => MaterialApp(
    theme: AppTheme.light(),
    home: GamePlayScreen(
      level: level,
      voice: voice,
      progressRepository: progress,
      random: Random(1),
      autoGuide: false,
    ),
  );

  Future<void> fix(CircuitViewModel vm) async {
    final puzzle = vm.game.puzzle;
    for (final entry in puzzle.route.entries) {
      final taps = puzzle.tiles[entry.key].tapsToJoin(entry.value);
      for (var i = 0; i < taps; i++) {
        vm.tap(entry.key);
        await pumpEventQueue();
      }
    }
  }

  test('fixing every circuit saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < CircuitGame.rounds; i++) {
      await fix(vm);
      expect(vm.game.puzzle.isLit, isTrue);
      await vm.next();
    }
    await pumpEventQueue();

    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'circuit_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('a lit bulb reads the fact', () async {
    final vm = viewModel();
    await fix(vm);
    await pumpEventQueue();

    expect(tts.spoken.last, contains(vm.game.fact));
    vm.dispose();
  });

  test('Play again starts over', () async {
    final vm = viewModel();
    vm.tap(0);
    vm.playAgain();
    expect(vm.game.taps, 0);
    vm.dispose();
  });

  testWidgets('tapping pieces on screen lights the bulb', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final copy = CircuitGame(level: 1, random: Random(1));
    final size = copy.puzzle.size;

    for (final entry in copy.puzzle.route.entries) {
      final taps = copy.puzzle.tiles[entry.key].tapsToJoin(entry.value);
      for (var i = 0; i < taps; i++) {
        final piece = find.bySemanticsLabel(
          RegExp(
            '^${GamePlayScreen.pieceLabel(entry.key ~/ size + 1, entry.key % size + 1)}',
          ),
        );
        await tester.ensureVisible(piece);
        await tester.pumpAndSettle();
        await tester.tap(piece);
        await tester.pumpAndSettle();
      }
    }

    expect(find.text(GamePlayScreen.nextCircuit), findsOneWidget);
    expect(find.text(copy.fact), findsOneWidget);
  });

  testWidgets('the biggest board fits a small phone with 2x text', (
    tester,
  ) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(const GameLevel(GameKind.circuit, 3)));
    await tester.pumpAndSettle();

    // Overflow errors fail the test automatically.
    expect(find.byType(GamePlayScreen), findsOneWidget);
  });

  testWidgets('it has its own big tile on the Game Zone', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
    final card = find.text(HomeDestination.games.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    final button = find.text(GameZoneScreen.circuitLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.circuit.tagline), findsOneWidget);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });

  test('titles read well whatever the game is called', () {
    final vm = SortTitle.of(GameKind.sort);
    expect(vm, 'Sort It! Starter');
    expect(SortTitle.of(GameKind.circuit), 'Circuit Fixer: Starter');
  });
}

/// Builds a game's screen title through its view model.
abstract final class SortTitle {
  static String of(GameKind kind) {
    final store = InMemoryKeyValueStore();
    final voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
    );
    final vm = SortViewModel(
      level: GameLevel(kind, 1),
      voice: voice,
      progressRepository: LocalProgressRepository(store),
    );
    final title = vm.gameTitle;
    vm.dispose();
    voice.dispose();
    return title;
  }
}
