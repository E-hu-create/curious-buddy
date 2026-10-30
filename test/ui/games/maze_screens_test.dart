import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/maze.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/games/game_play_screen.dart';
import 'package:curious_buddy/ui/games/game_view_models.dart';
import 'package:curious_buddy/ui/games/game_zone_screen.dart';
import 'package:curious_buddy/ui/games/widgets/maze_art.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/games/maze_test.dart' show towards;
import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

const _level = GameLevel(GameKind.maze, 1);

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

  MazeViewModel viewModel() => MazeViewModel(
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

  test('collecting everything and finishing saves three stars', () async {
    final vm = viewModel();
    for (final target in [...vm.game.gems, vm.game.treasure]) {
      while (vm.game.cell != target) {
        vm.go(towards(vm.game, target));
        await pumpEventQueue();
      }
    }
    await pumpEventQueue();

    expect(vm.isFinished, isTrue);
    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'maze_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('bumping a wall plays a gentle sound and changes nothing', () async {
    final vm = viewModel()..go(MazeDirection.up);
    await pumpEventQueue();

    expect(vm.game.cell, MazeGame.start);
    expect(sounds.played.last, SoundEffect.gentle);
    vm.dispose();
  });

  test('Play again makes a new maze', () {
    final vm = viewModel();
    final first = vm.game;
    vm.playAgain();
    expect(vm.game, isNot(same(first)));
    expect(vm.game.cell, MazeGame.start);
    vm.dispose();
  });

  testWidgets('the arrows move Buddy to the treasure', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final copy = MazeGame(size: 5, gems: 2, random: Random(1));

    for (var i = 0; i < 60 && !copy.isWon; i++) {
      final direction = towards(copy, copy.treasure);
      copy.go(direction);
      final arrow = find.bySemanticsLabel(GamePlayScreen.goLabel(direction));
      await tester.ensureVisible(arrow);
      await tester.pumpAndSettle();
      await tester.tap(arrow);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('star'), findsWidgets);
    expect((await progress.load()).gameBest['maze_1'], greaterThan(0));
  });

  testWidgets('a swipe on the maze moves Buddy', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final copy = MazeGame(size: 5, gems: 2, random: Random(1));
    final direction = copy.openings[copy.cell].first;

    await tester.drag(
      find.byType(MazeArt),
      Offset(direction.columnStep * 80, direction.rowStep * 80),
    );
    await tester.pumpAndSettle();

    final where = find.bySemanticsLabel(RegExp('^Buddy is in row'));
    copy.go(direction);
    expect(tester.getSemantics(where).label, GamePlayScreen.whereLabel(copy));
  });

  testWidgets('the Game Zone opens the maze with its levels', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
    final card = find.text(HomeDestination.games.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    final button = find.text(GameZoneScreen.mazeLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.maze.title), findsWidgets);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
    expect(find.text(ArenaScreen.quickTitle), findsNothing);
  });
}
