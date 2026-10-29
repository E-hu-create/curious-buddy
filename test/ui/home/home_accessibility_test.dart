import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_app.dart';

void main() {
  testWidgets('meets tap target, label and contrast guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('destination cards are announced as labelled buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final destination = HomeDestination.missions;
    await tester.ensureVisible(find.text(destination.title));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text(destination.title)),
      matchesSemantics(
        label: '${destination.title}\n${destination.subtitle}',
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
    ('phone landscape', const Size(892, 412), 1.0),
    ('tablet', const Size(1024, 1366), 1.3),
  ]) {
    testWidgets('lays out without overflow: $name', (tester) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Layout overflow errors fail the test automatically; scroll to the
      // last card to lay out the whole page.
      final last = find.text(HomeDestination.values.last.title);
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      expect(last, findsOneWidget);
    });
  }

  testWidgets('with reduced motion nothing animates', (tester) async {
    useReducedMotion(tester);
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
  });
}
