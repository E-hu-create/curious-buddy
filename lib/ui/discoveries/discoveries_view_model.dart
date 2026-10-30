import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/creative/creation.dart';
import '../../domain/discoveries/discovery_journal.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/voice/buddy_voice.dart';

enum DiscoveriesStatus { loading, ready, error }

/// My Discoveries. Only reads what is already saved; it writes nothing.
class DiscoveriesViewModel extends ChangeNotifier {
  DiscoveriesViewModel({
    required ProgressRepository progressRepository,
    required MissionRepository missionRepository,
    required StoryRepository storyRepository,
    required QuizRepository quizRepository,
    required CreationsRepository creationsRepository,
    required BuddyVoice voice,
  }) : _progress = progressRepository,
       _missions = missionRepository,
       _stories = storyRepository,
       _quizzes = quizRepository,
       _creations = creationsRepository,
       _voice = voice {
    _voice.addListener(_notify);
  }

  /// Latest creations shown in the journal.
  static const recentCount = 4;

  final ProgressRepository _progress;
  final MissionRepository _missions;
  final StoryRepository _stories;
  final QuizRepository _quizzes;
  final CreationsRepository _creations;
  final BuddyVoice _voice;
  bool _disposed = false;

  DiscoveriesStatus get status => _status;
  DiscoveriesStatus _status = DiscoveriesStatus.loading;

  DiscoveryJournal? get journal => _journal;
  DiscoveryJournal? _journal;

  /// Newest first.
  List<Creation> get recentCreations => _recent;
  List<Creation> _recent = const [];

  /// True when one section could not be loaded and is left out.
  bool get isPartial => _partial;
  bool _partial = false;

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  /// Reads everything. Safe to call again (e.g. back from an activity).
  Future<void> load() async {
    LearnerProgress progress;
    try {
      progress = await _progress.load();
    } on Exception {
      // Without progress there is nothing true to show.
      _status = DiscoveriesStatus.error;
      _notify();
      return;
    }
    _partial = false;
    final missions = await _attempt(_missions.loadMissions);
    final stories = await _attempt(_stories.loadStories);
    final topics = await _attempt(_quizzes.loadTopics);
    final shelf = await _attempt(_creations.load);
    _recent =
        shelf?.items.reversed.take(recentCount).toList() ?? const <Creation>[];
    _journal = DiscoveryJournal.build(
      progress: progress,
      missions: missions,
      stories: stories,
      topics: topics,
      creations: shelf?.items.length,
    );
    _status = DiscoveriesStatus.ready;
    _notify();
  }

  Future<T?> _attempt<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on Exception {
      _partial = true;
      return null;
    }
  }

  /// Buddy reads the summary (when the page opens).
  void narrateSummary() {
    final journal = _journal;
    if (journal != null) _say(journal.summary);
  }

  /// Buddy reads one discovery, when the child taps its speaker.
  void readDiscovery(String storyTitle, String title, String discovery) =>
      _say('$title, from $storyTitle. $discovery', requested: true);

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  void _say(String text, {bool requested = false}) {
    final first = _lastSpoken == null;
    _lastSpoken = text;
    // Enables "Hear again" even when nothing is read aloud automatically.
    if (first) _notify();
    _sayNow(text, requested: requested);
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
    // Leaving the journal always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}
