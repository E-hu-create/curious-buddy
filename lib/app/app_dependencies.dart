import '../data/repositories/progress_repository.dart';
import '../data/services/key_value_store.dart';
import '../data/services/voice/flutter_tts_service.dart';
import '../data/services/voice/speech_recognition_service.dart';
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
  });

  /// Speech output uses the device's built-in engine. Speech input stays
  /// unavailable (no microphone). Answers come from reviewed offline
  /// content. Storage is in memory only until a persistent store is approved.
  factory AppDependencies.defaults() {
    final store = InMemoryKeyValueStore();
    return AppDependencies(
      textToSpeech: FlutterTtsService(),
      speechRecognition: const UnavailableSpeechRecognitionService(),
      progressRepository: LocalProgressRepository(store),
      settingsStore: store,
      responseProvider: CuratedResponseProvider(),
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
}
