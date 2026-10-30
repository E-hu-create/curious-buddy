import 'package:curious_buddy/app/app.dart';
import 'package:curious_buddy/app/app_dependencies.dart';
import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/mission_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/repositories/quiz_repository.dart';
import 'package:curious_buddy/data/repositories/story_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/conversation/curated_response_provider.dart';
import 'package:curious_buddy/domain/voice/educational_response_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Builds the whole app with fakes. Pass a store to control saved progress
/// and settings (one store backs both, as in the real app). Answers default
/// to the real curated content.
Widget buildTestApp({
  FakeTextToSpeechService? tts,
  FakeSpeechRecognitionService? speech,
  KeyValueStore? store,
  EducationalResponseProvider? responder,
  MissionRepository? missions,
  StoryRepository? stories,
  QuizRepository? quizzes,
  CreationsRepository? creations,
}) {
  final keyValueStore = store ?? InMemoryKeyValueStore();
  return CuriousBuddyApp(
    dependencies: AppDependencies(
      textToSpeech: tts ?? FakeTextToSpeechService(),
      speechRecognition: speech ?? FakeSpeechRecognitionService(),
      progressRepository: LocalProgressRepository(keyValueStore),
      settingsStore: keyValueStore,
      responseProvider: responder ?? CuratedResponseProvider(),
      missionRepository: missions ?? BundledMissionRepository(),
      storyRepository: stories ?? BundledStoryRepository(),
      quizRepository: quizzes ?? BundledQuizRepository(),
      creationsRepository: creations ?? LocalCreationsRepository(keyValueStore),
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
