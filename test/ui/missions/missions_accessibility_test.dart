import 'package:curious_buddy/domain/missions/mission.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/missions/mission_play_screen.dart';
import 'package:curious_buddy/ui/missions/missions_screen.dart';
import 'package:curious_buddy/ui/missions/widgets/stage_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_app.dart';

Future<void> _tapText(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _openFirstMission(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
  await _tapText(tester, HomeDestination.missions.title);
  await _tapText(tester, MissionsScreen.playLabel);
}

void main() {
  testWidgets('missions list meets tap target, label and contrast guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await _tapText(tester, HomeDestination.missions.title);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('a mission step meets the guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await _openFirstMission(tester);
    await _tapText(tester, MissionPlayScreen.startLabel);
    await _tapText(tester, ClueCard.inspectLabel);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    for (final (index, mission) in allMissions.indexed) {
      testWidgets('${mission.title} lays out without overflow: $name', (
        tester,
      ) async {
        usePhoneScreen(tester, logicalSize: size);
        useTextScale(tester, scale);
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();
        await _tapText(tester, HomeDestination.missions.title);

        final play = find
            .widgetWithText(FilledButton, MissionsScreen.playLabel)
            .at(index);
        await tester.ensureVisible(play);
        await tester.pumpAndSettle();
        await tester.tap(play);
        await tester.pumpAndSettle();
        await _tapText(tester, MissionPlayScreen.startLabel);

        // Walk each step; overflow errors fail the test automatically.
        for (final stage in mission.stages) {
          while (find.text(ClueCard.inspectLabel).evaluate().isNotEmpty) {
            await _tapText(tester, ClueCard.inspectLabel);
          }
          switch (stage) {
            case ChoiceStage(:final choices):
              await _tapText(tester, choices.firstWhere((c) => c.correct).text);
            case MultiSelectStage(:final choices):
              for (final c in choices.where((c) => c.correct)) {
                await _tapText(tester, c.text);
              }
            case OrderStage(:final pieces):
              for (final p in pieces) {
                final b = find.widgetWithText(OutlinedButton, p.text);
                await tester.ensureVisible(b);
                await tester.pumpAndSettle();
                await tester.tap(b);
                await tester.pumpAndSettle();
              }
          }
          await _tapText(tester, MissionPlayScreen.checkLabel);
          await _tapText(
            tester,
            stage == mission.stages.last
                ? MissionPlayScreen.finishLabel
                : MissionPlayScreen.nextLabel,
          );
        }
        expect(find.text(MissionPlayScreen.caseSolved), findsOneWidget);
      });
    }
  }
}
