import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/four_in_a_row.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const _level = GameLevel(GameKind.four, 1);

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

  FourViewModel viewModel() => FourViewModel(
    level: _level,
    voice: voice,
    progressRepository: progress,
    random: Random(1),
    buddyDelay: Duration.zero,
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

  test('Buddy answers each move', () async {
    final vm = viewModel();
    await vm.drop(3);
    expect(vm.game.board.where((p) => p == FourPlayer.child), hasLength(1));
    expect(vm.game.board.where((p) => p == FourPlayer.buddy), hasLength(1));
    expect(vm.isBuddyThinking, isFalse);
    vm.dispose();
  });

  test('the child cannot move while Buddy thinks', () async {
    final vm = viewModel();
    final turn = vm.drop(3);
    await vm.drop(4);
    await turn;
    expect(vm.game.board.where((p) => p == FourPlayer.child), hasLength(1));
    vm.dispose();
  });

  test('winning saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < 40 && !vm.isFinished; i++) {
      final column = i ~/ 3 % FourGame.columns;
      await vm.drop(vm.game.canPlay(column) ? column : (column + 1) % 7);
    }
    await pumpEventQueue();

    expect(vm.isFinished, isTrue);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest['four_1'], vm.stars);
    vm.dispose();
  });

  test('a replay is a fresh board', () async {
    final vm = viewModel();
    await vm.drop(3);
    vm.playAgain();
    expect(vm.game.board.every((p) => p == null), isTrue);
    vm.dispose();
  });

  test('leaving during Buddy\'s turn is safe', () async {
    final vm = viewModel();
    final turn = vm.drop(3);
    vm.dispose();
    await turn;
    expect(vm.game.board.where((p) => p == FourPlayer.buddy), isEmpty);
  });

  testWidgets('tapping a column plays, and Buddy replies on screen', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    expect(find.text(GamePlayScreen.yourTurn), findsOneWidget);

    await tester.tap(
      find.bySemanticsLabel(RegExp('^${GamePlayScreen.columnLabel(4, 6)}')),
    );
    await tester.pump();
    expect(find.text(GamePlayScreen.buddyTurn), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(GamePlayScreen.yourTurn), findsOneWidget);
    expect(find.textContaining('Buddy dropped in column'), findsOneWidget);
    expect(sounds.played, contains(SoundEffect.pop));
  });
}
