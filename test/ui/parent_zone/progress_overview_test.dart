import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/games/games.dart';
import 'package:curious_buddy/domain/missions/more_missions.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_screen.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_settings.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/progress_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';
import 'parent_zone_screen_test.dart' show wordsToNumber;

void main() {
  late InMemoryKeyValueStore store;
  late LocalProgressRepository progress;

  setUp(() {
    store = InMemoryKeyValueStore();
    progress = LocalProgressRepository(store);
  });

  Future<void> openHome(
    WidgetTester tester, {
    Size? size,
    double? scale,
  }) async {
    usePhoneScreen(tester, logicalSize: size ?? const Size(412, 892));
    if (scale != null) useTextScale(tester, scale);
    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
  }

  Future<void> openParentZone(WidgetTester tester) async {
    final card = find.text(HomeScreen.grownUpsLabel);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('What is '));
    final m = RegExp(
      r'^What is ([a-z-]+) times ([a-z-]+)\?$',
    ).firstMatch(question)!;
    await tester.enterText(
      find.byType(TextField),
      '${wordsToNumber(m[1]!) * wordsToNumber(m[2]!)}',
    );
    final check = find.text(ParentGateView.checkLabel);
    await tester.ensureVisible(check);
    await tester.pumpAndSettle();
    await tester.tap(check);
    await tester.pumpAndSettle();
  }

  group('on Home', () {
    testWidgets('Grown-ups sits below everything a child plays with', (
      tester,
    ) async {
      await openHome(tester);

      final grownUps = find.text(HomeScreen.grownUpsLabel);
      await tester.ensureVisible(grownUps);
      await tester.pumpAndSettle();

      final lastCard = find.text(HomeDestination.values.last.title);
      expect(
        tester.getTopLeft(grownUps).dy,
        greaterThan(tester.getTopLeft(lastCard).dy),
      );
      expect(find.text(HomeScreen.grownUpsHelp), findsOneWidget);
    });

    testWidgets('it still asks the parent check before anything opens', (
      tester,
    ) async {
      await openHome(tester);
      final card = find.text(HomeScreen.grownUpsLabel);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.text(ParentGateView.checkLabel), findsOneWidget);
      expect(find.text(ProgressOverviewSection.title), findsNothing);
    });

    testWidgets('it fits a small phone with 2x text', (tester) async {
      await openHome(tester, size: const Size(320, 640), scale: 2);

      // Overflow errors fail the test automatically.
      await tester.ensureVisible(find.text(HomeScreen.grownUpsLabel));
      expect(find.text(HomeScreen.grownUpsLabel), findsOneWidget);
    });
  });

  group('in the Parent Zone', () {
    testWidgets('progress comes first, and shows real numbers', (tester) async {
      await progress.save(
        LearnerProgress.empty
            .withGameResult('memory_1', 3)
            .withGameResult('dino_fern_forest', 2),
      );
      await openHome(tester);
      await openParentZone(tester);

      expect(find.text(ProgressOverviewSection.title), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(ProgressOverviewSection.title)).dy,
        lessThan(tester.getTopLeft(find.text(VoiceSettingsSection.title)).dy),
      );
      expect(
        find.text(ProgressOverviewSection.ofLabel(5, ArenaRules.allStars)),
        findsOneWidget,
      );
      expect(
        find.text(ProgressOverviewSection.ofLabel(3, 9)),
        findsOneWidget,
        reason: 'finishing a place adds its creatures to the Field Guide',
      );
      expect(
        find.text(ProgressOverviewSection.ofLabel(0, allMissions.length)),
        findsOneWidget,
      );
    });

    testWidgets('a new child sees zeros and a next step', (tester) async {
      await openHome(tester);
      await openParentZone(tester);

      expect(find.text(ProgressOverviewSection.nextTitle), findsOneWidget);
    });

    testWidgets('jump links reach each part of the page', (tester) async {
      await openHome(tester);
      await openParentZone(tester);

      final reset = find.text(ParentZoneScreen.resetTitle);
      expect(tester.getTopLeft(reset).dy, greaterThan(892));

      await tester.tap(find.text(ParentZoneScreen.jumpDelete));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(reset).dy, lessThan(892));
    });

    testWidgets('it meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await openHome(tester);
      await openParentZone(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });

    testWidgets('it lays out on a small phone with 2x text', (tester) async {
      await openHome(tester, size: const Size(320, 640), scale: 2);
      await openParentZone(tester);

      // Overflow errors fail the test automatically.
      expect(find.text(ProgressOverviewSection.title), findsOneWidget);
    });

    testWidgets('a storage error is explained, not hidden', (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(buildTestApp(store: FailingKeyValueStore()));
      await tester.pumpAndSettle();
      await openParentZone(tester);

      expect(find.text(ProgressOverviewSection.loadError), findsOneWidget);
    });
  });
}
