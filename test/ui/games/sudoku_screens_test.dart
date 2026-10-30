import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/sudoku.dart';
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

const _level = GameLevel(GameKind.sudoku, 1);

void main() {
  late FakeSoundEffectsService sounds;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late LocalProgressRepository progress;

  setUp(() {
    sounds = FakeSoundEffectsService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(
      textToSpeech: FakeTextToSpeechService(),
      settings: store,
      sounds: sounds,
    );
    progress = LocalProgressRepository(store);
  });

  tearDown(() => voice.dispose());

  SudokuViewModel viewModel() => SudokuViewModel(
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

  Future<void> solve(SudokuViewModel vm) async {
    while (!vm.game.puzzle.isSolved) {
      vm.place(vm.game.puzzle.solution[vm.selected!]);
      await pumpEventQueue();
    }
  }

  test('solving both puzzles saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < SudokuGame.rounds; i++) {
      await solve(vm);
      await vm.next();
    }
    await pumpEventQueue();

    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'sudoku_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('the first empty square starts selected, and moves on', () {
    final vm = viewModel();
    final first = vm.selected!;
    expect(vm.game.puzzle.board[first], isNull);

    vm.place(vm.game.puzzle.solution[first]);
    expect(vm.selected, isNot(first));
    expect(vm.game.puzzle.board[vm.selected!], isNull);
    vm.dispose();
  });

  test('a square can be chosen, but not a filled one', () {
    final vm = viewModel();
    final other = [
      for (var i = 0; i < vm.game.puzzle.board.length; i++)
        if (vm.game.puzzle.board[i] == null) i,
    ].last;
    vm.select(other);
    expect(vm.selected, other);

    vm.select(vm.game.puzzle.given.first);
    expect(vm.selected, other);
    vm.dispose();
  });

  test('a wrong picture is gentle and explains itself', () async {
    final vm = viewModel();
    final cell = vm.selected!;
    vm.place((vm.game.puzzle.solution[cell] + 1) % vm.game.puzzle.size);
    await pumpEventQueue();

    expect(vm.lastClash, isNotNull);
    expect(sounds.played.last, SoundEffect.gentle);
    expect(vm.game.puzzle.board[cell], isNull);
    vm.dispose();
  });

  test('every clash has a note', () {
    for (final clash in SudokuClash.values) {
      expect(GamePlayScreen.clashNote(clash), isNotEmpty);
    }
  });

  testWidgets('a puzzle can be solved on screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final game = SudokuGame(level: 1, random: Random(1));
    final puzzle = game.puzzle;

    while (puzzle.firstEmpty != null) {
      final cell = puzzle.firstEmpty!;
      final value = puzzle.solution[cell];
      puzzle.board[cell] = value;
      final button = find.bySemanticsLabel(
        GamePlayScreen.placeLabel(game.pictures[value].label),
      );
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    expect(find.text(GamePlayScreen.nextPuzzle), findsOneWidget);
  });

  testWidgets('the 6 by 6 grid fits a small phone with 2x text', (
    tester,
  ) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(const GameLevel(GameKind.sudoku, 3)));
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
    final button = find.text(GameZoneScreen.sudokuLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.sudoku.tagline), findsOneWidget);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });
}
