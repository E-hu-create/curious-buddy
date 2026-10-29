import 'dart:async';

import 'package:curious_buddy/app/app.dart';
import 'package:curious_buddy/app/app_dependencies.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing/fakes.dart';

void main() {
  late FakeSpeechRecognitionService speech;
  late FakeTextToSpeechService tts;

  Widget buildApp() => CuriousBuddyApp(
    dependencies: AppDependencies(
      textToSpeech: tts,
      speechRecognition: speech,
      progressRepository: LocalProgressRepository(InMemoryKeyValueStore()),
    ),
  );

  setUp(() {
    speech = FakeSpeechRecognitionService();
    tts = FakeTextToSpeechService();
  });

  testWidgets('app launches to the home route', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Curious Buddy'), findsOneWidget);
  });

  testWidgets('launch does not touch the microphone or speak', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(speech.totalCalls, 0);
    expect(speech.permissionRequests, 0);
    expect(tts.spoken, isEmpty);
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

  testWidgets('default dependencies build without platform plugins', (
    tester,
  ) async {
    await tester.pumpWidget(
      CuriousBuddyApp(dependencies: AppDependencies.defaults()),
    );

    expect(find.text('Curious Buddy'), findsOneWidget);
  });
}
