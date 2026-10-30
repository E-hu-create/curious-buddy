import '../data/repositories/creations_repository.dart';
import '../data/repositories/mission_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/story_repository.dart';
import '../data/services/key_value_store.dart';
import '../data/services/shared_preferences_key_value_store.dart';
import '../data/services/sound/sound_effects_service.dart';
import '../data/services/voice/flutter_tts_service.dart';
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
  });

  /// Speech output uses the device's built-in engine. Speech input is
  /// tap-to-talk on Android's recogniser, on-device only unless a grown-up
  /// allows online recognition. Answers come from reviewed offline content.
  /// Progress and settings are saved on the device only.
  factory AppDependencies.defaults() {
    final store = SharedPreferencesKeyValueStore();
    return AppDependencies(
      textToSpeech: FlutterTtsService(),
      speechRecognition: SpeechToTextRecognitionService(),
      progressRepository: LocalProgressRepository(store),
      settingsStore: store,
      responseProvider: CuratedResponseProvider(),
      missionRepository: BundledMissionRepository(),
      storyRepository: BundledStoryRepository(),
      quizRepository: BundledQuizRepository(),
      creationsRepository: LocalCreationsRepository(store),
      soundEffects: PlatformSoundEffectsService(),
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
}
