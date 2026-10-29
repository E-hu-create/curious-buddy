import 'dart:convert';

import '../../domain/models/learner_progress.dart';
import '../services/key_value_store.dart';

abstract interface class ProgressRepository {
  /// Loads saved progress, or [LearnerProgress.empty] if none exists or the
  /// saved data is unreadable.
  ///
  /// Storage failures (as opposed to bad data) are rethrown so callers do
  /// not mistake a temporary error for "no progress" and save over it.
  Future<LearnerProgress> load();

  Future<void> save(LearnerProgress progress);

  /// Deletes all saved progress, including any backup of unreadable data.
  /// Storage failures are rethrown so the caller can say it did not work.
  Future<void> clear();

  /// Whether a copy of unreadable progress is being kept.
  Future<bool> hasCorruptBackup();
}

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._store);

  static const storageKey = 'progress';

  /// Unreadable data is copied here before being replaced, so it can be
  /// inspected or recovered manually rather than silently lost.
  static const corruptBackupKey = 'progress.corrupt_backup';

  final KeyValueStore _store;

  @override
  Future<LearnerProgress> load() async {
    final raw = await _store.read(storageKey);
    if (raw == null) return LearnerProgress.empty;

    LearnerProgress? progress;
    try {
      progress = LearnerProgress.tryFromJson(jsonDecode(raw));
    } on FormatException {
      progress = null;
    }
    if (progress != null) return progress;

    await _store.write(corruptBackupKey, raw);
    return LearnerProgress.empty;
  }

  @override
  Future<void> save(LearnerProgress progress) =>
      _store.write(storageKey, jsonEncode(progress.toJson()));

  @override
  Future<void> clear() async {
    await _store.delete(storageKey);
    await _store.delete(corruptBackupKey);
  }

  @override
  Future<bool> hasCorruptBackup() async =>
      await _store.read(corruptBackupKey) != null;
}
