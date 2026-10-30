import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/sort_it.dart';
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

const _level = GameLevel(GameKind.sort, 1);

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

  SortViewModel viewModel() => SortViewModel(
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

  test('sorting everything saves three stars', () async {
    final vm = viewModel();
    while (!vm.isFinished) {
      vm.pick(vm.game.item.group);
      await pumpEventQueue();
    }
    await pumpEventQueue();

    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'sort_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test(
    'a wrong group is gentle, and the question is read at the start',
    () async {
      final vm = viewModel()..narrateIntro();
      await pumpEventQueue();
      expect(tts.spoken.last, contains(vm.game.set.question));

      vm.pick(vm.game.item.group == 0 ? 1 : 0);
      await pumpEventQueue();
      expect(sounds.played.last, SoundEffect.gentle);
      expect(vm.wasWrong, isTrue);
      vm.dispose();
    },
  );

  test('Play again starts over', () {
    final vm = viewModel();
    vm.pick(vm.game.item.group);
    vm.playAgain();
    expect(vm.game.index, 0);
    expect(vm.wasWrong, isFalse);
    vm.dispose();
  });

  testWidgets('sorting works on screen, group by group', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final game = SortGame(level: 1, random: Random(1));
    expect(find.text(game.set.question), findsOneWidget);

    for (var i = 0; i < SortGame.itemCount; i++) {
      final item = game.items[i];
      expect(find.text(item.name), findsOneWidget);
      final group = find.bySemanticsLabel(
        RegExp('^${game.set.groups[item.group]}'),
      );
      await tester.ensureVisible(group);
      await tester.pumpAndSettle();
      await tester.tap(group);
      await tester.pumpAndSettle();
    }

    expect(find.text('Amazing! Three stars!'), findsOneWidget);
  });

  testWidgets('three groups fit a small phone with 2x text', (tester) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(const GameLevel(GameKind.sort, 3)));
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
    final button = find.text(GameZoneScreen.sortLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.sort.tagline), findsOneWidget);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });
}
