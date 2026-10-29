import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/voice/narrator.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required ProgressRepository progressRepository,
    required BuddyVoice voice,
  }) : _progressRepository = progressRepository,
       _voice = voice {
    _voice.addListener(notifyListeners);
  }

  /// Shown in Buddy's speech bubble and spoken as the welcome, so what the
  /// child hears always matches what they can read.
  static const greeting = "Hi! I'm Buddy. Where should we go today?";

  final ProgressRepository _progressRepository;
  final BuddyVoice _voice;

  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Null while loading, or if progress could not be read. Home still works
  /// without it; it just hides the explorer log.
  LearnerProgress? get progress => _progress;
  LearnerProgress? _progress;

  VoiceStatus get voiceStatus => _voice.status;
  bool get isMuted => _voice.isMuted;

  /// Whether to show the "Hear again" button.
  bool get canReplay => _voice.canSpeak;

  /// Loads progress and gives the spoken welcome. The welcome plays once per
  /// app session; [BuddyVoice] ignores later calls.
  Future<void> load() async {
    unawaited(_voice.welcomeOnce(greeting));
    try {
      _progress = await _progressRepository.load();
    } on Exception {
      _progress = null;
    }
    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  Future<NarrationOutcome> replayGreeting() => _voice.say(greeting);

  Future<void> toggleMuted() => _voice.setMuted(!_voice.isMuted);

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(notifyListeners);
    super.dispose();
  }
}
