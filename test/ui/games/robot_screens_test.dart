import 'dart:math';

import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/games/maze.dart';
import 'package:curious_buddy/domain/games/robot.dart';
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

const _level = GameLevel(GameKind.robot, 1);
const _top = GameLevel(GameKind.robot, 3);

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

  RobotViewModel viewModel([GameLevel level = _level]) => RobotViewModel(
    level: level,
    voice: voice,
    progressRepository: progress,
    random: Random(1),
    stepTime: Duration.zero,
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

  void write(RobotViewModel vm, List<RobotStep> code) {
    for (final step in code) {
      vm.add(step.direction);
      if (step.times == 2) vm.toggleRepeat();
    }
  }

  test('solving every puzzle finishes and saves three stars', () async {
    final vm = viewModel();
    for (var i = 0; i < RobotGame.rounds; i++) {
      write(vm, vm.game.puzzle.solution);
      await vm.run();
      expect(vm.isSolved, isTrue);
      expect(vm.cell, vm.game.puzzle.goal);
      await pumpEventQueue();
      await vm.next();
    }
    await pumpEventQueue();

    expect(vm.isFinished, isTrue);
    expect(vm.stars, 3);
    expect(vm.saveStatus, GameSaveStatus.saved);
    expect((await progress.load()).gameBest, {'robot_1': 3});
    expect(sounds.played.last, SoundEffect.cheer);
    vm.dispose();
  });

  test('a run that goes wrong keeps the code and explains', () async {
    final vm = viewModel();
    final solution = vm.game.puzzle.solution;
    write(vm, solution.take(1).toList());
    await vm.run();
    await pumpEventQueue();

    expect(vm.ending, RobotEnding.short);
    expect(vm.game.code, hasLength(1));
    expect(vm.isSolved, isFalse);
    expect(sounds.played.last, SoundEffect.gentle);

    vm.add(solution[1].direction);
    expect(vm.ending, isNull, reason: 'a change clears the old note');
    expect(vm.cell, vm.game.puzzle.start);
    vm.dispose();
  });

  test('code cannot change while it runs, or after it works', () async {
    final vm = viewModel();
    write(vm, vm.game.puzzle.solution);
    final length = vm.game.code.length;
    final running = vm.run();
    vm
      ..undo()
      ..clear();
    expect(vm.game.code, hasLength(length));
    await running;

    vm.undo();
    expect(vm.game.code, hasLength(length));
    vm.dispose();
  });

  test('nothing runs without code', () async {
    final vm = viewModel();
    await vm.run();
    expect(vm.ending, isNull);
    expect(vm.game.failedRuns, 0);
    vm.dispose();
  });

  test('leaving mid-run is safe', () async {
    final vm = viewModel();
    write(vm, vm.game.puzzle.solution);
    final running = vm.run();
    vm.dispose();
    await running;
  });

  test('every ending has a note', () {
    for (final ending in RobotEnding.values) {
      expect(RobotViewModel.noteFor(ending), isNotEmpty);
    }
  });

  testWidgets('writing code and pressing Go solves a puzzle on screen', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    final puzzle = RobotPuzzle.make(1, Random(1));

    for (final step in puzzle.solution) {
      final arrow = find.bySemanticsLabel(
        GamePlayScreen.goLabel(step.direction),
      );
      await tester.ensureVisible(arrow);
      await tester.pumpAndSettle();
      await tester.tap(arrow);
      await tester.pumpAndSettle();
    }
    final go = find.text(GamePlayScreen.goLabel2);
    await tester.ensureVisible(go);
    await tester.pumpAndSettle();
    await tester.tap(go);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text(RobotViewModel.noteFor(RobotEnding.goal)), findsOneWidget);
    expect(find.text(GamePlayScreen.nextPuzzle), findsOneWidget);
  });

  testWidgets('Twice shows only on Expert', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(GamePlayScreen.twiceLabel), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen(_top));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(GamePlayScreen.twiceLabel), findsOneWidget);
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
    final button = find.text(GameZoneScreen.robotLabel);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text(GameKind.robot.title), findsWidgets);
    expect(find.bySemanticsLabel('Play Starter'), findsOneWidget);
  });

  testWidgets('a full line of code and every button lay out', (tester) async {
    usePhoneScreen(tester, logicalSize: const Size(320, 640));
    useTextScale(tester, 2);
    await tester.pumpWidget(screen(_top));
    await tester.pumpAndSettle();

    final arrow = find.bySemanticsLabel(
      GamePlayScreen.goLabel(MazeDirection.up),
    );
    for (var i = 0; i < 20; i++) {
      await tester.ensureVisible(arrow);
      await tester.pumpAndSettle();
      await tester.tap(arrow, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    // Overflow errors fail the test automatically.
    expect(find.byType(GamePlayScreen), findsOneWidget);
  });
}
