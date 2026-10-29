import 'package:curious_buddy/ui/core/widgets/buddy/buddy.dart';
import 'package:curious_buddy/ui/core/widgets/buddy/buddy_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/test_app.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Center(child: child));

  BuddyPainter painterOf(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(Buddy),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as BuddyPainter;

  testWidgets('is labelled for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(const Buddy()));

    expect(find.bySemanticsLabel(Buddy.semanticLabel), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('waves once on appear, then settles', (tester) async {
    await tester.pumpWidget(host(const Buddy()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(painterOf(tester).armLift, greaterThan(0));

    await tester.pumpAndSettle();
    expect(painterOf(tester).armLift, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('tapping makes Buddy happy until the reaction ends', (
    tester,
  ) async {
    await tester.pumpWidget(host(const Buddy(waveOnAppear: false)));

    await tester.tap(find.byType(Buddy));
    await tester.pump(const Duration(milliseconds: 100));
    expect(painterOf(tester).mood, BuddyMood.happy);

    await tester.pumpAndSettle();
    expect(painterOf(tester).mood, BuddyMood.cheerful);
  });

  testWidgets('with reduced motion, tapping toggles mood without motion', (
    tester,
  ) async {
    useReducedMotion(tester);
    await tester.pumpWidget(host(const Buddy()));

    await tester.tap(find.byType(Buddy));
    await tester.pump();

    expect(painterOf(tester).mood, BuddyMood.happy);
    expect(painterOf(tester).armLift, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final mood in BuddyMood.values) {
    testWidgets('paints the $mood mood without errors', (tester) async {
      await tester.pumpWidget(host(Buddy(mood: mood, waveOnAppear: false)));

      expect(painterOf(tester).mood, mood);
    });
  }
}
