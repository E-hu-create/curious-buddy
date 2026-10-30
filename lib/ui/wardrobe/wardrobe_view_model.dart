import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/discoveries/discovery_journal.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/wardrobe/buddy_wardrobe.dart';
import '../../domain/wardrobe/wardrobe.dart';

enum WardrobeStatus { loading, ready, error }

/// Buddy's Wardrobe: what has been earned, and what he is wearing.
class WardrobeViewModel extends ChangeNotifier {
  WardrobeViewModel({
    required ProgressRepository progressRepository,
    required MissionRepository missionRepository,
    required StoryRepository storyRepository,
    required QuizRepository quizRepository,
    required CreationsRepository creationsRepository,
    required BuddyVoice voice,
    required BuddyWardrobe wardrobe,
  }) : _progress = progressRepository,
       _missions = missionRepository,
       _stories = storyRepository,
       _quizzes = quizRepository,
       _creations = creationsRepository,
       _voice = voice,
       _wardrobe = wardrobe {
    _voice.addListener(_notify);
    _wardrobe.addListener(_notify);
  }

  static const intro =
      'Dress me up! Everything you do earns me something new to wear.';

  final ProgressRepository _progress;
  final MissionRepository _missions;
  final StoryRepository _stories;
  final QuizRepository _quizzes;
  final CreationsRepository _creations;
  final BuddyVoice _voice;
  final BuddyWardrobe _wardrobe;
  bool _disposed = false;

  WardrobeStatus get status => _status;
  WardrobeStatus _status = WardrobeStatus.loading;

  BuddyLook get look => _wardrobe.look;

  DiscoveryJournal? _journal;

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  int get unlockedCount => WardrobeItem.values.where(isUnlocked).length;

  bool isUnlocked(WardrobeItem item) {
    final journal = _journal;
    return journal != null && item.isUnlocked(journal);
  }

  String progressText(WardrobeItem item) {
    final journal = _journal;
    return journal == null ? '' : item.progressText(journal);
  }

  Future<void> load() async {
    try {
      final progress = await _progress.load();
      _journal = DiscoveryJournal.build(
        progress: progress,
        missions: await _missions.loadMissions(),
        stories: await _stories.loadStories(),
        topics: await _quizzes.loadTopics(),
        creations: (await _creations.load()).items.length,
      );
      _status = WardrobeStatus.ready;
    } on Exception {
      _status = WardrobeStatus.error;
    }
    _notify();
  }

  void narrateIntro() => _say(intro);

  /// Puts an item on, or takes it off if he is already wearing it. Locked
  /// items cannot be worn.
  void toggle(WardrobeItem item) {
    if (!isUnlocked(item)) return;
    if (look.inSlot(item.slot) == item) {
      unawaited(_wardrobe.takeOff(item.slot));
    } else {
      unawaited(_wardrobe.wear(item));
      _say('I love my ${item.title.toLowerCase()}!');
    }
  }

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  void _say(String text) {
    final first = _lastSpoken == null;
    _lastSpoken = text;
    // Enables "Hear again" even when nothing is read aloud automatically.
    if (first) _notify();
    _sayNow(text);
  }

  void _sayNow(String text, {bool requested = false}) {
    if (_disposed) return;
    unawaited(_voice.say(text, requested: requested));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(_notify);
    _wardrobe.removeListener(_notify);
    // Leaving always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}
