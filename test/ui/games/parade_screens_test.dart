import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/parade.dart';
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

const _level = GameLevel(GameKind.parade, 1);

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

  ParadeViewModel viewModel() => ParadeViewModel(
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

  test('finishing every set saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < ParadeGame.rounds; i++) {
      for (final item in vm.game.set.order) {
        vm.tap(item);
        await pumpEventQueue();
      }
      await vm.next();
      await pumpEventQueue();
    }

    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'parade_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('each set reads its question, and ends with its fact', () async {
    final vm = viewModel()..narrateIntro();
    await pumpEventQueue();
    expect(tts.spoken.last, contains(vm.game.set.question));

    vm.game.set.order.forEach(vm.tap);
    await pumpEventQueue();
    expect(tts.spoken.last, contains(vm.game.set.fact));
    vm.dispose();
  });

  test('a wrong pick is gentle', () async {
    final vm = viewModel();
    vm.tap(vm.game.set.order.last);
    await pumpEventQueue();

    expect(sounds.played.last, SoundEffect.gentle);
    expect(vm.game.placed, 0);
    vm.dispose();
  });

  test('Play again starts over', () {
    final vm = viewModel();
    vm.tap(vm.game.set.order.first);
    vm.playAgain();
    expect(vm.game.placed, 0);
    vm.dispose();
  });

  testWidgets('a set can be put in order on screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final game = ParadeGame(level: 1, random: Random(1));
    expect(find.text(game.set.question), findsOneWidget);

    for (final item in game.set.order) {
      final target = find.bySemanticsLabel(GamePlayScreen.pickLabel(item));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    expect(find.text(game.set.fact), findsOneWidget);
    expect(find.text(GamePlayScreen.nextParade), findsOneWidget);
  });

  testWidgets('all eight planets fit a small phone with 2x text', (
    tester,
  ) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(const GameLevel(GameKind.parade, 3)));
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
    final button = find.text(GameZoneScreen.paradeLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.parade.tagline), findsOneWidget);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });
}
