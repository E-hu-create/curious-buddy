import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/ui/creative/creative_hub_screen.dart';
import 'package:curious_buddy/ui/creative/drawing_screen.dart';
import 'package:curious_buddy/ui/creative/widgets/creative_art.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_app.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text).first;
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

Future<InMemoryKeyValueStore> _storeWithCreations() async {
  final store = InMemoryKeyValueStore();
  final repository = LocalCreationsRepository(store);
  await repository.add(
    (id) => Drawing(
      id: id,
      strokes: const [
        Stroke(
          colorIndex: 1,
          sizeIndex: 1,
          points: [DrawPoint(100, 100), DrawPoint(800, 800)],
        ),
      ],
    ),
  );
  await repository.add(
    (id) => Creature(
      id: id,
      name: creatureNames.first,
      body: CreatureBody.wide,
      colorIndex: 3,
      eyes: CreatureEyes.three,
      mouth: CreatureMouth.open,
      extra: CreatureExtra.antennae,
      pattern: CreaturePattern.stripes,
    ),
  );
  return store;
}

void main() {
  testWidgets('Creative Island with creations meets the guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: await _storeWithCreations()));
    await tester.pumpAndSettle();
    await _tap(tester, HomeDestination.creative.title);

    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('both activities and the viewer meet the guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: await _storeWithCreations()));
    await tester.pumpAndSettle();
    await _tap(tester, HomeDestination.creative.title);

    await _tap(tester, CreativeHubScreen.drawLabel);
    await _expectGuidelines(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _tap(tester, CreativeHubScreen.creatureLabel);
    await _expectGuidelines(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _tap(tester, creatureNames.first);
    await _expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('the canvas and creations are announced', (tester) async {
    final semantics = tester.ensureSemantics();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(store: await _storeWithCreations()));
    await tester.pumpAndSettle();
    await _tap(tester, HomeDestination.creative.title);

    expect(
      find.bySemanticsLabel(RegExp(r'^Open A drawing with 1 colour$')),
      findsOneWidget,
    );

    await _tap(tester, CreativeHubScreen.drawLabel);
    expect(find.bySemanticsLabel(DrawingScreen.canvasLabel), findsOneWidget);
    semantics.dispose();
  });

  test('every creature can be described in words', () {
    for (final body in CreatureBody.values) {
      for (final eyes in CreatureEyes.values) {
        for (final mouth in CreatureMouth.values) {
          for (final extra in CreatureExtra.values) {
            for (final pattern in CreaturePattern.values) {
              final text = CreationDescriptions.describe(
                Creature(
                  id: 'c1',
                  name: 'Moxo',
                  body: body,
                  colorIndex: 1,
                  eyes: eyes,
                  mouth: mouth,
                  extra: extra,
                  pattern: pattern,
                ),
              );
              expect(text, startsWith('Moxo: a '));
              expect(text, isNot(contains('null')));
            }
          }
        }
      }
    }
  });

  testWidgets('every creature part can be painted', (tester) async {
    usePhoneScreen(tester);
    for (final body in CreatureBody.values) {
      for (final eyes in CreatureEyes.values) {
        for (final mouth in CreatureMouth.values) {
          for (final extra in CreatureExtra.values) {
            final creature = Creature(
              id: 'c1',
              name: 'Moxo',
              body: body,
              colorIndex: 2,
              eyes: eyes,
              mouth: mouth,
              extra: extra,
              pattern: CreaturePattern.values[extra.index % 3],
            );
            await tester.pumpWidget(
              MaterialApp(home: CreationPicture(creation: creature)),
            );
          }
        }
      }
    }
    expect(find.byType(CreationPicture), findsOneWidget);
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('Creative Island lays out without overflow: $name', (
      tester,
    ) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);
      await tester.pumpWidget(buildTestApp(store: await _storeWithCreations()));
      await tester.pumpAndSettle();
      await _tap(tester, HomeDestination.creative.title);

      // Overflow errors fail the test automatically.
      await _tap(tester, CreativeHubScreen.drawLabel);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tap(tester, CreativeHubScreen.creatureLabel);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tap(tester, creatureNames.first);
      expect(find.byType(CreationPicture), findsOneWidget);
    });
  }
}
