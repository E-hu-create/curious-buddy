import 'package:curious_buddy/ui/core/themes/app_theme.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_screen.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/parent_gate_view.dart';
import 'package:curious_buddy/ui/parent_zone/widgets/reset_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_app.dart';
import 'parent_zone_screen_test.dart' show wordsToNumber;

Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Grown-ups'));
  await tester.tap(find.text('Grown-ups'));
  await tester.pumpAndSettle();
}

Future<void> _unlock(WidgetTester tester) async {
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
  final button = find.text(ParentGateView.checkLabel);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text).last;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  testWidgets('the parent check meets the guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await _open(tester);

    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('the unlocked settings meet the guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await _open(tester);
    await _unlock(tester);

    await _expectGuidelines(tester);
    semantics.dispose();
  });

  for (final (name, dialog) in [
    ('step 1', const ResetExplainDialog(summary: null)),
    ('step 2', const ResetConfirmDialog(settingsToo: true)),
  ]) {
    testWidgets('reset dialog $name meets the guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      usePhoneScreen(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => dialog,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await _expectGuidelines(tester);
      semantics.dispose();
    });
  }

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('the Parent Zone lays out without overflow: $name', (
      tester,
    ) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await _open(tester);
      await _unlock(tester);

      // Overflow errors fail the test automatically.
      await _tap(tester, ParentZoneScreen.resetLabel);
      await _tap(tester, ResetExplainDialog.continueLabel);
      expect(find.text(ResetConfirmDialog.title), findsOneWidget);
    });
  }
}
