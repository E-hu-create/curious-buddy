import 'package:curious_buddy/app/app.dart';
import 'package:curious_buddy/app/app_dependencies.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Builds the whole app with fakes. Pass a store to control saved progress
/// and settings (one store backs both, as in the real app).
Widget buildTestApp({
  FakeTextToSpeechService? tts,
  FakeSpeechRecognitionService? speech,
  KeyValueStore? store,
}) {
  final keyValueStore = store ?? InMemoryKeyValueStore();
  return CuriousBuddyApp(
    dependencies: AppDependencies(
      textToSpeech: tts ?? FakeTextToSpeechService(),
      speechRecognition: speech ?? FakeSpeechRecognitionService(),
      progressRepository: LocalProgressRepository(keyValueStore),
      settingsStore: keyValueStore,
    ),
  );
}

/// Sizes the test window like a typical Android phone (Samsung A51:
/// 412 x 892 logical pixels), or [logicalSize] if given.
void usePhoneScreen(
  WidgetTester tester, {
  Size logicalSize = const Size(412, 892),
}) {
  const ratio = 2.625;
  tester.view
    ..devicePixelRatio = ratio
    ..physicalSize = logicalSize * ratio;
  addTearDown(tester.view.reset);
}

void useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void useReducedMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
