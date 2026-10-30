import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/number_pop.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const _level = GameLevel(GameKind.number, 1);

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

  NumberViewModel viewModel() => NumberViewModel(
    level: _level,
    voice: voice,
    progressRepository: progress,
    random: Random(1),
  );

  Widget screen() => MaterialApp(
    theme: AppTheme.light(),
    home: GamePlayScreen(
      level: _level,
      voice: voice,
      progressRepository: progress,
      random: Random(1),
      autoGuide: false,
    ),
  );

  test('finishing every round saves three stars', () async {
    final vm = viewModel();
    while (!vm.isFinished) {
      final game = vm.game;
      final i = [
        for (var i = 0; i < game.bubbles.length; i++)
          if (game.bubbles[i].value == game.target && !game.popped.contains(i))
            i,
      ].first;
      vm.tap(i);
      await pumpEventQueue();
    }
    await pumpEventQueue();

    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'number_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('a wrong bubble is gentle, and each round reads its target', () async {
    final vm = viewModel()..narrateIntro();
    await pumpEventQueue();
    expect(tts.spoken.last, contains('${vm.game.target}'));

    vm.tap(vm.game.bubbles.indexWhere((s) => s.value != vm.game.target));
    await pumpEventQueue();
    expect(sounds.played.last, SoundEffect.gentle);
    vm.dispose();
  });

  test('Play again starts over', () {
    final vm = viewModel();
    vm.tap(vm.game.bubbles.indexWhere((s) => s.value != vm.game.target));
    vm.playAgain();
    expect(vm.game.mistakes, 0);
    vm.dispose();
  });

  testWidgets('popping bubbles on screen clears a round', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final game = NumberPopGame(level: 1, random: Random(1));
    final first = game.target;
    expect(find.text(GamePlayScreen.targetLabel(first)), findsOneWidget);

    for (final sum in game.bubbles.where((s) => s.value == first).toList()) {
      final bubble = find.bySemanticsLabel(sum.spoken);
      await tester.ensureVisible(bubble);
      await tester.pumpAndSettle();
      await tester.tap(bubble);
      await tester.pumpAndSettle();
    }

    expect(find.text(GamePlayScreen.targetLabel(first)), findsNothing);
    expect(
      find.text(GamePlayScreen.roundLabel(2, NumberPopGame.rounds)),
      findsOneWidget,
    );
  });
}
