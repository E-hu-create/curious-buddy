/// A child's saved progress.
///
/// Deliberately contains no personal information: no name, age, photo,
/// location or voice data. Only identifiers of content the child completed.
class LearnerProgress {
  const LearnerProgress({
    this.completedMissionIds = const {},
    this.completedStoryIds = const {},
  });

  static const empty = LearnerProgress();

  /// Bump when the stored shape changes, and add a migration in
  /// [tryFromJson].
  static const schemaVersion = 1;

  static const maxIdLength = 64;
  static final _validId = RegExp(r'^[a-z0-9_\-]+$');

  final Set<String> completedMissionIds;
  final Set<String> completedStoryIds;

  LearnerProgress copyWith({
    Set<String>? completedMissionIds,
    Set<String>? completedStoryIds,
  }) => LearnerProgress(
    completedMissionIds: completedMissionIds ?? this.completedMissionIds,
    completedStoryIds: completedStoryIds ?? this.completedStoryIds,
  );

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'completedMissionIds': completedMissionIds.toList()..sort(),
    'completedStoryIds': completedStoryIds.toList()..sort(),
  };

  /// Parses stored progress, returning null if the data is unusable.
  ///
  /// Individual malformed ids are dropped rather than discarding the whole
  /// record, so one bad entry cannot wipe a child's progress.
  static LearnerProgress? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final version = json['schemaVersion'];
    // Data from a newer app version cannot be read safely; refuse it so the
    // caller can preserve it instead of overwriting it.
    if (version is! int || version < 1 || version > schemaVersion) return null;
    return LearnerProgress(
      completedMissionIds: _ids(json['completedMissionIds']),
      completedStoryIds: _ids(json['completedStoryIds']),
    );
  }

  static Set<String> _ids(Object? raw) {
    if (raw is! List<Object?>) return const {};
    return {
      for (final id in raw)
        if (id is String && id.length <= maxIdLength && _validId.hasMatch(id))
          id,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is LearnerProgress &&
      _setEquals(other.completedMissionIds, completedMissionIds) &&
      _setEquals(other.completedStoryIds, completedStoryIds);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedMissionIds),
    Object.hashAllUnordered(completedStoryIds),
  );

  static bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
