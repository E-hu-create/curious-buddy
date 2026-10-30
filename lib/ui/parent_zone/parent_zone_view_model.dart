import 'package:flutter/foundation.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/services/voice/text_to_speech_service.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/settings/display_settings.dart';
import '../../domain/voice/buddy_listener.dart';
import '../../domain/voice/buddy_voice.dart';

enum SummaryStatus { loading, ready, error }

enum ResetStatus { idle, resetting, done, failed }

/// What is saved about the child's activity right now, read from storage.
class ActivitySummary {
  const ActivitySummary({
    required this.progress,
    required this.hasBackup,
    this.drawings = 0,
    this.creatures = 0,
    this.hasCreationsBackup = false,
  });

  final LearnerProgress progress;

  /// A copy of saved progress that could not be read, kept for recovery.
  final bool hasBackup;

  /// Creative Island creations on the shelf.
  final int drawings;
  final int creatures;

  /// A copy of a creations shelf that could not be read.
  final bool hasCreationsBackup;

  int get missionsSolved => progress.completedMissionIds.length;
  int get missionPoints => progress.totalMissionPoints;
  int get storiesFinished => progress.completedStoryIds.length;
  int get endingsFound =>
      progress.storyEndings.values.fold(0, (sum, e) => sum + e.length);
  int get storiesInProgress => progress.storyBookmarks.length;
  int get quizLevelsDone => progress.quizBest.length;
  int get outfitItems => progress.buddyLook.length;
  int get quizBestCorrect =>
      progress.quizBest.values.fold(0, (sum, n) => sum + n);

  bool get isEmpty =>
      progress == LearnerProgress.empty &&
      !hasBackup &&
      drawings == 0 &&
      creatures == 0 &&
      !hasCreationsBackup;
}

/// The unlocked Parent Zone: settings, the saved-data overview and reset.
class ParentZoneViewModel extends ChangeNotifier {
  ParentZoneViewModel({
    required ProgressRepository progressRepository,
    required CreationsRepository creationsRepository,
    required this.voice,
    required this.listener,
    required this.display,
  }) : _progress = progressRepository,
       _creations = creationsRepository;

  final ProgressRepository _progress;
  final CreationsRepository _creations;
  final BuddyVoice voice;
  final BuddyListener listener;
  final DisplaySettings display;
  bool _disposed = false;

  SummaryStatus get status => _status;
  SummaryStatus _status = SummaryStatus.loading;

  ActivitySummary? get summary => _summary;
  ActivitySummary? _summary;

  ResetStatus get resetStatus => _resetStatus;
  ResetStatus _resetStatus = ResetStatus.idle;

  /// Whether the last reset also restored the default settings.
  bool get lastResetIncludedSettings => _lastResetIncludedSettings;
  bool _lastResetIncludedSettings = false;

  Future<void> load() async {
    try {
      _summary = await _read();
      _status = SummaryStatus.ready;
    } on Exception {
      _status = SummaryStatus.error;
    }
    _notify();
  }

  Future<ActivitySummary> _read() async {
    final shelf = await _creations.load();
    return ActivitySummary(
      progress: await _progress.load(),
      hasBackup: await _progress.hasCorruptBackup(),
      drawings: shelf.drawings,
      creatures: shelf.creatures,
      hasCreationsBackup: await _creations.hasCorruptBackup(),
    );
  }

  /// Deletes all saved activity, then reads storage back to make sure
  /// nothing is left. With [settingsToo], every setting goes back to its
  /// default as well; otherwise settings are kept.
  Future<void> reset({required bool settingsToo}) async {
    if (_resetStatus == ResetStatus.resetting) return;
    _resetStatus = ResetStatus.resetting;
    _lastResetIncludedSettings = settingsToo;
    _notify();
    try {
      await _progress.clear();
      await _creations.clear();
      if (settingsToo) await restoreDefaultSettings();
      final left = await _read();
      _summary = left;
      _status = SummaryStatus.ready;
      _resetStatus = left.isEmpty ? ResetStatus.done : ResetStatus.failed;
    } on Exception {
      _resetStatus = ResetStatus.failed;
      await load();
    }
    _notify();
  }

  /// Voice on, normal speed, reads automatically, on-device listening only,
  /// normal motion.
  Future<void> restoreDefaultSettings() async {
    await voice.setMuted(false);
    await voice.setSpeed(SpeechSpeed.normal);
    await voice.setAutoRead(true);
    await listener.setAllowOnline(false);
    await display.setReduceMotion(false);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
