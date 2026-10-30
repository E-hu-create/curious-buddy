import 'dart:async';

import 'package:curious_buddy/app/app.dart';
import 'package:curious_buddy/app/app_dependencies.dart';
import 'package:curious_buddy/ui/home/home_view_model.dart';
import 'package:curious_buddy/ui/home/widgets/buddy_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing/fakes.dart';
import 'testing/test_app.dart';

void main() {
  late FakeSpeechRecognitionService speech;
  late FakeTextToSpeechService tts;

  Widget buildApp() => buildTestApp(tts: tts, speech: speech);

  setUp(() {
    speech = FakeSpeechRecognitionService();
    tts = FakeTextToSpeechService();
  });

  testWidgets('app launches to the home route', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.bySemanticsLabel('Curious Buddy'), findsOneWidget);
  });

  testWidgets('launch speaks only the welcome and never touches the mic', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tts.spoken, [HomeViewModel.greeting]);
    expect(speech.totalCalls, 0);
    expect(speech.permissionRequests, 0);
  });

  testWidgets('unknown routes show a friendly page instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed('/does-not-exist'));
    await tester.pumpAndSettle();

    expect(find.text('Oops!'), findsOneWidget);
  });

  testWidgets(
    'default dependencies work without a speech engine (text fallback)',
    (tester) async {
      // No flutter_tts platform side exists in tests, exactly like a device
      // with no engine: the app must fall back to text, not crash.
      await tester.pumpWidget(
        CuriousBuddyApp(dependencies: AppDependencies.defaults()),
      );
      // The "no plugin" reply arrives on the real event loop.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Curious Buddy'), findsOneWidget);
      expect(find.text(BuddyGreeting.unavailableMessage), findsOneWidget);
      expect(find.text(BuddyGreeting.replayLabel), findsNothing);
    },
  );
}
