import '../data/repositories/progress_repository.dart';
import '../data/services/key_value_store.dart';
import '../data/services/voice/speech_recognition_service.dart';
import '../data/services/voice/text_to_speech_service.dart';

/// Composition root: the single place where concrete services are chosen.
///
/// Tests construct this with fakes. Features receive what they need through
/// constructors rather than reaching for globals.
class AppDependencies {
  const AppDependencies({
    required this.textToSpeech,
    required this.speechRecognition,
    required this.progressRepository,
  });

  /// Safe defaults until real platform implementations are approved:
  /// voice reports itself as unavailable and progress is held in memory only.
  factory AppDependencies.defaults() => AppDependencies(
    textToSpeech: const UnavailableTextToSpeechService(),
    speechRecognition: const UnavailableSpeechRecognitionService(),
    progressRepository: LocalProgressRepository(InMemoryKeyValueStore()),
  );

  final TextToSpeechService textToSpeech;
  final SpeechRecognitionService speechRecognition;
  final ProgressRepository progressRepository;
}
