import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/models/learner_progress.dart';
import 'package:curious_buddy/ui/home/home_destination.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';
import '../../testing/test_app.dart';

void main() {
  late FakeTextToSpeechService tts;

  setUp(() => tts = FakeTextToSpeechService());

  Future<void> openHome(WidgetTester tester, {KeyValueStore? store}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(tts: tts, store: store));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the greeting and every destination', (tester) async {
    await openHome(tester);

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
    for (final destination in HomeDestination.values) {
      expect(find.text(destination.title), findsOneWidget);
      expect(find.text(destination.subtitle), findsOneWidget);
    }
    expect(find.text('Grown-ups'), findsOneWidget);
  });

  testWidgets('explorer log shows saved progress', (tester) async {
    final store = InMemoryKeyValueStore();
    await LocalProgressRepository(store).save(
      const LearnerProgress(
        completedMissionIds: {'m1', 'm2'},
        completedStoryIds: {'s1'},
      ),
    );

    await openHome(tester, store: store);

    expect(find.text('2 missions solved'), findsOneWidget);
    expect(find.text('1 story finished'), findsOneWidget);
  });

  testWidgets('home still works when progress cannot be read', (tester) async {
    await openHome(tester, store: FailingKeyValueStore());

    expect(find.textContaining('solved'), findsNothing);
    expect(find.text(HomeDestination.missions.title), findsOneWidget);
  });

  testWidgets('each destination opens its page and back returns home', (
    tester,
  ) async {
    await openHome(tester);

    for (final destination in HomeDestination.values) {
      await tester.ensureVisible(find.text(destination.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(destination.title));
      await tester.pumpAndSettle();

      expect(find.text(destination.comingSoonMessage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(HomeViewModel.greeting), findsOneWidget);
    }
  });

  testWidgets('"Back to Home" button returns to Home', (tester) async {
    await openHome(tester);
    await tester.tap(find.text(HomeDestination.missions.title));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    expect(find.text(HomeViewModel.greeting), findsOneWidget);
  });

  testWidgets('Grown-ups button opens the Parent Zone placeholder', (
    tester,
  ) async {
    await openHome(tester);

    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();

    expect(find.text('Parent Zone'), findsOneWidget);
  });

  // Voice behaviour on Home is covered in home_voice_test.dart.
}
