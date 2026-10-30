import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/voice/buddy_voice.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required ProgressRepository progressRepository,
    required BuddyVoice voice,
    CreationsRepository? creationsRepository,
  }) : _progressRepository = progressRepository,
       _creationsRepository = creationsRepository,
       _voice = voice {
    _voice.addListener(notifyListeners);
  }

  /// Shown in Buddy's speech bubble and spoken as the welcome, so what the
  /// child hears always matches what they can read.
  static const greeting = "Hi! I'm Buddy. Where should we go today?";

  final ProgressRepository _progressRepository;
  final CreationsRepository? _creationsRepository;
  final BuddyVoice _voice;

  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Null while loading, or if progress could not be read. Home still works
  /// without it; it just hides the explorer log.
  LearnerProgress? get progress => _progress;
  LearnerProgress? _progress;

  /// Number of saved Creative Island creations (0 if unknown).
  int get creations => _creations;
  int _creations = 0;

  VoiceStatus get voiceStatus => _voice.status;
  bool get isMuted => _voice.isMuted;

  /// Whether Buddy will speak if asked (voice available and on).
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
    await _loadCreations();
    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  /// Re-reads saved progress (e.g. after finishing a mission).
  Future<void> refreshProgress() async {
    try {
      _progress = await _progressRepository.load();
    } on Exception {
      return; // Keep showing what we had.
    }
    await _loadCreations();
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadCreations() async {
    final repository = _creationsRepository;
    if (repository == null) return;
    try {
      _creations = (await repository.load()).items.length;
    } on Exception {
      // Keep the last count; the log is only a summary.
    }
  }

  Future<void> toggleMuted() => _voice.setMuted(!_voice.isMuted);

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(notifyListeners);
    super.dispose();
  }
}
