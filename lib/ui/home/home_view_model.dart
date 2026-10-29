import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/services/voice/text_to_speech_service.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/voice/narrator.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required ProgressRepository progressRepository,
    required TextToSpeechService textToSpeech,
  }) : _progressRepository = progressRepository,
       _textToSpeech = textToSpeech,
       _narrator = Narrator(textToSpeech);

  static const greeting = 'Hi, explorer! Where should we go today?';

  final ProgressRepository _progressRepository;
  final TextToSpeechService _textToSpeech;
  final Narrator _narrator;

  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Null while loading, or if progress could not be read. Home still works
  /// without it; it just hides the explorer log.
  LearnerProgress? get progress => _progress;
  LearnerProgress? _progress;

  /// Whether to offer the "Hear Buddy" button. False until a real speech
  /// engine exists, so the UI never shows a button that does nothing.
  bool get canSpeak => _canSpeak;
  bool _canSpeak = false;

  Future<void> load() async {
    try {
      _progress = await _progressRepository.load();
    } on Exception {
      _progress = null;
    }
    try {
      _canSpeak = await _textToSpeech.isAvailable();
    } on Exception {
      _canSpeak = false;
    }
    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  /// Only ever called from an explicit tap; Home never speaks on its own.
  Future<void> speakGreeting() async {
    await _narrator.narrate(greeting);
  }

  @override
  void dispose() {
    _disposed = true;
    _narrator.stop().ignore();
    super.dispose();
  }
}
