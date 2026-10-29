import 'dart:async';

import 'package:curious_buddy/data/repositories/mission_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/missions/mission_play_screen.dart';
import 'package:curious_buddy/ui/missions/missions_screen.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

class _FailingMissions implements MissionRepository {
  @override
  Future<List<Mission>> loadMissions() async => throw Exception('disk broke');
}

class _SlowMissions implements MissionRepository {
  final done = Completer<List<Mission>>();
  @override
  Future<List<Mission>> loadMissions() => done.future;
}

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService();
    store = InMemoryKeyValueStore();
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> openMissions(
    WidgetTester tester, {
    MissionRepository? missions,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store, missions: missions),
    );
    await tester.pumpAndSettle();
    await tapText(tester, HomeDestination.missions.title);
  }

  /// Plays the current mission to the end through the UI, inspecting every
  /// clue and answering correctly.
  Future<void> playThrough(WidgetTester tester, Mission mission) async {
    await tapText(tester, MissionPlayScreen.startLabel);
    for (final stage in mission.stages) {
      while (find.text(ClueCard.inspectLabel).evaluate().isNotEmpty) {
        await tapText(tester, ClueCard.inspectLabel);
      }
      switch (stage) {
        case ChoiceStage(:final choices):
          await tapText(tester, choices.firstWhere((c) => c.correct).text);
        case MultiSelectStage(:final choices):
          for (final c in choices.where((c) => c.correct)) {
            await tapText(tester, c.text);
          }
        case OrderStage(:final pieces):
          for (final p in pieces) {
            final button = find.widgetWithText(OutlinedButton, p.text);
            await tester.ensureVisible(button);
            await tester.pumpAndSettle();
            await tester.tap(button);
            await tester.pumpAndSettle();
          }
      }
      await tapText(tester, MissionPlayScreen.checkLabel);
      expect(find.text(FeedbackPanel.correctTitle), findsOneWidget);
      await tapText(
        tester,
        stage == mission.stages.last
            ? MissionPlayScreen.finishLabel
            : MissionPlayScreen.nextLabel,
      );
    }
  }

  testWidgets('Home opens the real Missions screen with three cases', (
    tester,
  ) async {
    await openMissions(tester);

    expect(find.text(MissionsScreen.title), findsOneWidget);
    for (final mission in starterMissions) {
      expect(find.text(mission.title), findsOneWidget);
    }
    expect(find.text(MissionsScreen.newLabel), findsNWidgets(3));
    expect(find.text('0 points'), findsOneWidget);
  });

  testWidgets('shows a loading state, then the missions', (tester) async {
    final slow = _SlowMissions();
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(tts: tts, speech: speech, store: store, missions: slow),
    );
    await tester.pumpAndSettle();
    final card = find.text(HomeDestination.missions.title);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    // The spinner animates forever, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    slow.done.complete(starterMissions);
    await tester.pumpAndSettle();
    expect(find.text(starterMissions.first.title), findsOneWidget);
  });

  testWidgets('empty catalogue shows a friendly message', (tester) async {
    await openMissions(
      tester,
      missions: BundledMissionRepository(missions: []),
    );

    expect(find.text(MissionsScreen.emptyMessage), findsOneWidget);
  });

  testWidgets('a loading error offers a retry', (tester) async {
    await openMissions(tester, missions: _FailingMissions());

    expect(find.text(MissionsScreen.errorMessage), findsOneWidget);
    expect(find.text(MissionsScreen.retryLabel), findsOneWidget);
  });

  testWidgets('playing a mission start to finish earns the badge and points', (
    tester,
  ) async {
    final mission = starterMissions.first;
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);

    // Buddy narrates the opening scene.
    expect(find.text(mission.intro), findsOneWidget);
    expect(tts.spoken.last, contains('Starlight Museum'));

    await playThrough(tester, mission);

    expect(find.text(MissionPlayScreen.caseSolved), findsOneWidget);
    expect(find.text(mission.badge), findsOneWidget);
    expect(find.text(mission.solution), findsOneWidget);
    expect(tts.spoken.last, contains('Case solved!'));
  });

  testWidgets('wrong answers explain why and hints help, without blocking', (
    tester,
  ) async {
    final mission = starterMissions.first;
    final stage = mission.stages.first as ChoiceStage;
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);
    await tapText(tester, MissionPlayScreen.startLabel);

    await tapText(tester, MissionPlayScreen.hintLabel(1, stage.hints.length));
    expect(find.text('Hint 1: ${stage.hints.first}'), findsOneWidget);

    final wrong = stage.choices.firstWhere((c) => !c.correct);
    await tapText(tester, wrong.text);
    await tapText(tester, MissionPlayScreen.checkLabel);
    expect(find.text(FeedbackPanel.tryAgainTitle), findsOneWidget);
    expect(find.textContaining(wrong.feedback), findsOneWidget);

    await tapText(tester, stage.choices.firstWhere((c) => c.correct).text);
    await tapText(tester, MissionPlayScreen.checkLabel);
    expect(find.text(FeedbackPanel.correctTitle), findsOneWidget);
    expect(find.text(MissionPlayScreen.nextLabel), findsOneWidget);
  });

  testWidgets('results are saved, shown as solved, and can be replayed', (
    tester,
  ) async {
    final mission = starterMissions.last; // includes an order puzzle
    await openMissions(tester);
    await tapText(tester, mission.title);
    final play = find.widgetWithText(FilledButton, MissionsScreen.playLabel);
    await tester.ensureVisible(play.last);
    await tester.tap(play.last);
    await tester.pumpAndSettle();
    await playThrough(tester, mission);

    await tapText(tester, MissionPlayScreen.backLabel);

    expect(find.text(MissionsScreen.solvedLabel), findsOneWidget);
    expect(find.text(mission.badge), findsOneWidget);
    expect(find.textContaining('Best:'), findsOneWidget);
    expect(find.text(MissionsScreen.replayLabel), findsOneWidget);

    await tapText(tester, MissionsScreen.replayLabel);
    expect(find.text(MissionPlayScreen.startLabel), findsOneWidget);
  });

  testWidgets('Play again on the completion screen restarts the case', (
    tester,
  ) async {
    final mission = starterMissions[1];
    await openMissions(tester);
    final play = find.widgetWithText(FilledButton, MissionsScreen.playLabel);
    await tester.ensureVisible(play.at(1));
    await tester.tap(play.at(1));
    await tester.pumpAndSettle();
    await playThrough(tester, mission);

    await tapText(tester, MissionPlayScreen.playAgainLabel);

    expect(find.text(mission.intro), findsOneWidget);
    expect(find.text(MissionPlayScreen.startLabel), findsOneWidget);
  });

  testWidgets('leaving a mission mid-narration stops Buddy at once', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);
    expect(tts.isSpeaking, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(tts.isSpeaking, isFalse);
    expect(find.text(MissionsScreen.title), findsOneWidget);
  });

  testWidgets('Stop talking silences narration; text stays on screen', (
    tester,
  ) async {
    tts.holdSpeech = true;
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);

    await tapText(tester, MissionVoiceBar.stopLabel);

    expect(tts.isSpeaking, isFalse);
    expect(find.text(starterMissions.first.intro), findsOneWidget);
    expect(find.text(MissionVoiceBar.hearAgainLabel), findsOneWidget);
  });

  testWidgets('missions never touch the microphone', (tester) async {
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);
    await playThrough(tester, starterMissions.first);

    expect(speech.totalCalls, 0);
  });

  testWidgets('Home shows the new points after a mission', (tester) async {
    await openMissions(tester);
    await tapText(tester, MissionsScreen.playLabel);
    await playThrough(tester, starterMissions.first);
    await tapText(tester, MissionPlayScreen.backLabel);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1 mission solved'), findsOneWidget);
    expect(find.textContaining(' points'), findsWidgets);
  });
}
