import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/missions/mission_content.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/ui/creative/widgets/creative_art.dart';
import 'package:curious_buddy/ui/discoveries/discoveries_screen.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_app.dart';

Future<InMemoryKeyValueStore> _busyStore() async {
  final store = InMemoryKeyValueStore();
  var progress = LearnerProgress.empty;
  for (final m in starterMissions) {
    progress = progress.withMissionResult(m.id, 100);
  }
  for (final s in starterStories) {
    for (final e in s.endings) {
      progress = progress.withStoryEnding(s.id, e.id);
    }
  }
  await LocalProgressRepository(
    store,
  ).save(progress.withQuizResult('space_starter', 5));
  final creations = LocalCreationsRepository(store);
  for (var i = 0; i < 5; i++) {
    await creations.add(
      (id) => Creature(
        id: id,
        name: creatureNames[i],
        body: CreatureBody.values[i % 4],
        colorIndex: 1 + i,
        eyes: CreatureEyes.big,
        mouth: CreatureMouth.grin,
        extra: CreatureExtra.wings,
        pattern: CreaturePattern.spots,
      ),
    );
  }
  return store;
}

Future<void> _open(WidgetTester tester, KeyValueStore store) async {
  await tester.pumpWidget(buildTestApp(store: store));
  await tester.pumpAndSettle();
  final card = find.text(HomeDestination.discoveries.title);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  for (final (name, build) in [
    ('new', () async => InMemoryKeyValueStore()),
    ('busy', _busyStore),
  ]) {
    testWidgets('a $name journal meets tap target, label and contrast '
        'guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      usePhoneScreen(tester);
      await _open(tester, await tester.runAsync(build) as KeyValueStore);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }

  testWidgets('only the latest few creations are shown', (tester) async {
    usePhoneScreen(tester);
    await _open(tester, await tester.runAsync(_busyStore) as KeyValueStore);

    expect(find.byType(CreationPicture), findsNWidgets(4));
    expect(find.text(DiscoveriesScreen.creationsTitle), findsOneWidget);
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('phone with 2x text', const Size(412, 892), 2.0),
    ('small phone with 2x text', const Size(320, 640), 2.0),
  ]) {
    testWidgets('the journal lays out without overflow: $name', (tester) async {
      usePhoneScreen(tester, logicalSize: size);
      useTextScale(tester, scale);

      // Overflow errors fail the test automatically.
      await _open(tester, await tester.runAsync(_busyStore) as KeyValueStore);
      expect(find.text(DiscoveriesScreen.nextTitle), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await _open(tester, InMemoryKeyValueStore());
      expect(find.text(DiscoveriesScreen.nextTitle), findsOneWidget);
    });
  }
}
