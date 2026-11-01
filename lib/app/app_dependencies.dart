import 'package:flutter/foundation.dart';

import '../data/repositories/creations_repository.dart';
import '../data/repositories/mission_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/story_repository.dart';
import '../data/services/key_value_store.dart';
import '../data/services/purchase/play_purchase_service.dart';
import '../data/services/purchase/purchase_service.dart';
import '../data/services/shared_preferences_key_value_store.dart';
import '../data/services/sound/sound_effects_service.dart';
import '../data/services/voice/flutter_tts_service.dart';
import '../data/services/voice/recorded_voice_service.dart';
import '../data/services/voice/speech_recognition_service.dart';
import '../data/services/voice/speech_to_text_recognition_service.dart';
import '../data/services/voice/text_to_speech_service.dart';
import '../domain/conversation/curated_response_provider.dart';
import '../domain/voice/educational_response_provider.dart';

/// Composition root: the single place where concrete services are chosen.
///
/// Tests construct this with fakes. Features receive what they need through
/// constructors rather than reaching for globals.
class AppDependencies {
  const AppDependencies({
    required this.textToSpeech,
    required this.speechRecognition,
    required this.progressRepository,
    required this.settingsStore,
    required this.responseProvider,
    required this.missionRepository,
    required this.storyRepository,
    required this.quizRepository,
    required this.creationsRepository,
    required this.soundEffects,
    this.purchases = const NoStorePurchaseService(),
    this.locksOn = false,
  });

  /// Set with --dart-define=PREVIEW_LOCKS=true to try the free version in a
  /// test build. Store builds always lock.
  static const previewLocks = bool.fromEnvironment('PREVIEW_LOCKS');

  /// Set with --dart-define=FRIEND_TEST=true for the file shared with
  /// friends: a small release build with nothing locked. Never used for the
  /// store build.
  static const friendTest = bool.fromEnvironment('FRIEND_TEST');

  /// Speech output plays Buddy's recorded voice, falling back to the
  /// device's built-in engine for lines not recorded. Speech input is
  /// tap-to-talk on Android's recogniser, on-device only unless a grown-up
  /// allows online recognition. Answers come from reviewed offline content.
  /// Progress and settings are saved on the device only.
  factory AppDependencies.defaults() {
    final store = SharedPreferencesKeyValueStore();
    // Purchases only work in the version from Google Play, so test builds
    // are fully open and never contact the store.
    const locksOn = (kReleaseMode && !friendTest) || previewLocks;
    return AppDependencies(
      textToSpeech: RecordedVoiceService(fallback: FlutterTtsService()),
      speechRecognition: SpeechToTextRecognitionService(),
      progressRepository: LocalProgressRepository(store),
      settingsStore: store,
      responseProvider: CuratedResponseProvider(),
      missionRepository: BundledMissionRepository(),
      storyRepository: BundledStoryRepository(),
      quizRepository: BundledQuizRepository(),
      creationsRepository: LocalCreationsRepository(store),
      soundEffects: PlatformSoundEffectsService(),
      purchases: locksOn
          ? PlayPurchaseService()
          : const NoStorePurchaseService(),
      locksOn: locksOn,
    );
  }

  final TextToSpeechService textToSpeech;
  final SpeechRecognitionService speechRecognition;
  final ProgressRepository progressRepository;

  /// Small app settings such as the voice on/off switch.
  final KeyValueStore settingsStore;

  /// Answers children's questions. Reviewed offline content only; no AI
  /// service is connected.
  final EducationalResponseProvider responseProvider;

  /// Mystery Missions content: the reviewed missions bundled in the app.
  final MissionRepository missionRepository;

  /// Living Stories content: the reviewed stories bundled in the app.
  final StoryRepository storyRepository;

  /// Quiz Time questions: the reviewed quizzes bundled in the app.
  final QuizRepository quizRepository;

  /// Creative Island creations, saved on the device only.
  final CreationsRepository creationsRepository;

  /// Short sounds bundled in the app.
  final SoundEffectsService soundEffects;

  /// The one-time full unlock, bought by a grown-up in the Parent Zone.
  final PurchaseService purchases;

  /// Whether the free version's locks apply.
  final bool locksOn;
}
