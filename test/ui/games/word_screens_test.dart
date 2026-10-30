import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/words.dart';
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

const _level = GameLevel(GameKind.words, 1);

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

  WordViewModel viewModel() => WordViewModel(
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

  void spell(WordViewModel vm) {
    final game = vm.game;
    final word = game.puzzle.word;
    for (var slot = 0; slot < word.length; slot++) {
      final tile = [
        for (var i = 0; i < game.tiles.length; i++)
          if (game.tiles[i] == word[slot] && !game.isUsed(i)) i,
      ].first;
      vm.tapTile(tile);
    }
  }

  test('spelling every word finishes and saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < WordGame.rounds; i++) {
      spell(vm);
      expect(vm.game.isSolved, isTrue);
      await pumpEventQueue();
      await vm.next();
    }
    await pumpEventQueue();

    expect(vm.isFinished, isTrue);
    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'words_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('a clue is read for each word', () async {
    final vm = viewModel()..narrateIntro();
    await pumpEventQueue();
    expect(tts.spoken.last, contains(vm.game.puzzle.clue));

    spell(vm);
    await pumpEventQueue();
    await vm.next();
    await pumpEventQueue();
    expect(tts.spoken.last, vm.game.puzzle.clue);
    vm.dispose();
  });

  test('a wrong spelling is gentle, and gives a tip', () async {
    final vm = viewModel();
    final order = List.generate(vm.game.tiles.length, (i) => i);
    expect(vm.game.tiles.join(), isNot(vm.game.puzzle.word));
    order.forEach(vm.tapTile);
    await pumpEventQueue();

    expect(vm.game.isWrong, isTrue);
    expect(sounds.played.last, SoundEffect.gentle);
    expect(tts.spoken.last, WordViewModel.wrongNote);
    vm.dispose();
  });

  test('Play again starts with no slips', () async {
    final vm = viewModel()..hint();
    vm.playAgain();
    expect(vm.game.hints, 0);
    expect(vm.game.round, 0);
    vm.dispose();
  });

  testWidgets('words can be spelled and fixed on screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final game = WordGame(level: 1, random: Random(1));
    final word = game.puzzle.word;
    expect(find.text(game.puzzle.clue), findsOneWidget);

    Future<void> tapLabel(String label) async {
      final target = find.bySemanticsLabel(label).first;
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    // Send one letter back, then finish properly.
    await tapLabel(GamePlayScreen.tileLabel(word[0]));
    await tapLabel(GamePlayScreen.slotLabel(1, word[0]));
    expect(find.bySemanticsLabel(GamePlayScreen.slotLabel(1, null)), findsOne);

    for (final letter in word.split('')) {
      await tapLabel(GamePlayScreen.tileLabel(letter));
    }
    expect(find.text(GamePlayScreen.nextWord), findsOneWidget);
  });

  testWidgets('Hint fills in letters until the word is done', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    for (var i = 0; i < 6; i++) {
      final hint = find.text(GamePlayScreen.hintLabel);
      if (hint.evaluate().isEmpty) break;
      await tester.ensureVisible(hint);
      await tester.pumpAndSettle();
      await tester.tap(hint);
      await tester.pumpAndSettle();
    }
    expect(find.text(GamePlayScreen.nextWord), findsOneWidget);
  });

  testWidgets('the Game Zone opens the game with its levels', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
    final card = find.text(HomeDestination.games.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    final button = find.text(GameZoneScreen.wordsLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.words.title), findsWidgets);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });

  testWidgets('the longest word fits a small phone with 2x text', (
    tester,
  ) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(const GameLevel(GameKind.words, 3)));
    await tester.pumpAndSettle();

    // Overflow errors fail the test automatically.
    expect(find.byType(GamePlayScreen), findsOneWidget);
  });
}
