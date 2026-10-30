import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/sound_game.dart';
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

const _level = GameLevel(GameKind.sounds, 1);

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

  SoundViewModel viewModel() => SoundViewModel(
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

  test('Play sound plays the right clip, as often as you like', () async {
    final vm = viewModel()
      ..playSound()
      ..playSound();
    await pumpEventQueue();

    expect(sounds.clips, [vm.game.sound.name, vm.game.sound.name]);
    vm.dispose();
  });

  test('a clip stops Buddy first', () async {
    tts.holdSpeech = true;
    final vm = viewModel()..narrateIntro();
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);

    vm.playSound();
    await pumpEventQueue();

    expect(tts.isSpeaking, isFalse);
    expect(sounds.clips, hasLength(1));
    vm.dispose();
  });

  test(
    'a grown-up turning sounds off silences clips, and shows the clue',
    () async {
      await voice.setSoundsOn(false);
      final vm = viewModel()..playSound();
      await pumpEventQueue();

      expect(sounds.clips, isEmpty);
      expect(vm.isClueShowing, isTrue);
      vm.dispose();
    },
  );

  test('finishing saves stars, and leaving stops the clip', () async {
    final vm = viewModel();
    for (var i = 0; i < vm.game.rounds; i++) {
      vm.pick(vm.game.sound);
      await pumpEventQueue();
      await vm.next();
    }
    await pumpEventQueue();

    expect(vm.isFinished, isTrue);
    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'sounds_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);

    final stops = sounds.clipStops;
    vm.dispose();
    await pumpEventQueue();
    expect(sounds.clipStops, greaterThan(stops));
  });

  test('a wrong pick shows and reads the clue', () async {
    final vm = viewModel();
    final wrong = vm.game.options.firstWhere((o) => o != vm.game.sound);
    vm.pick(wrong);
    await pumpEventQueue();

    expect(vm.isClueShowing, isTrue);
    expect(vm.lastWrong, wrong);
    expect(tts.spoken.last, contains(vm.game.sound.clue));
    expect(sounds.played.last, SoundEffect.gentle);
    vm.dispose();
  });

  testWidgets('a level can be played through on screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final quiz = SoundQuiz(level: 1, random: Random(1));

    for (var i = 0; i < quiz.rounds; i++) {
      await tester.tap(find.text(GamePlayScreen.playSoundLabel));
      await tester.pumpAndSettle();
      expect(sounds.clips.last, quiz.sound.name);

      final answer = find.bySemanticsLabel(quiz.sound.title).first;
      await tester.ensureVisible(answer);
      await tester.pumpAndSettle();
      await tester.tap(answer);
      await tester.pumpAndSettle();
      expect(find.text(quiz.sound.fact), findsOneWidget);

      final next = find.text(
        i + 1 < quiz.rounds
            ? GamePlayScreen.nextSound
            : GamePlayScreen.seeStars,
      );
      await tester.ensureVisible(next);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      quiz.nextRound();
    }

    expect(find.text('Amazing! Three stars!'), findsOneWidget);
  });

  testWidgets('Read a clue shows the clue', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final quiz = SoundQuiz(level: 1, random: Random(1));

    await tester.tap(find.text(GamePlayScreen.clueLabel));
    await tester.pumpAndSettle();

    expect(find.text(quiz.sound.clue), findsOneWidget);
    expect(find.text(GamePlayScreen.clueLabel), findsNothing);
  });

  testWidgets('with sounds off the game explains, and is still playable', (
    tester,
  ) async {
    await voice.setSoundsOn(false);
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final quiz = SoundQuiz(level: 1, random: Random(1));

    expect(find.text(GamePlayScreen.soundsOffNote), findsOneWidget);
    expect(find.text(GamePlayScreen.playSoundLabel), findsNothing);
    expect(find.text(quiz.sound.clue), findsOneWidget);
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
    final button = find.text(GameZoneScreen.soundsLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.sounds.title), findsWidgets);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });
}
