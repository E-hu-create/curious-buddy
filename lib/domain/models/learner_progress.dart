/// A child's saved progress.
///
/// Deliberately contains no personal information: no name, age, photo,
/// location or voice data. Only identifiers of content the child completed
/// and their best mission scores.
class LearnerProgress {
  const LearnerProgress({
    this.completedMissionIds = const {},
    this.completedStoryIds = const {},
    this.missionBestPoints = const {},
  });

  static const empty = LearnerProgress();

  /// Bump when the stored shape changes, and handle older versions in
  /// [tryFromJson]. History: 1 = ids only; 2 = adds mission best points.
  static const schemaVersion = 2;

  static const maxIdLength = 64;
  static const maxPoints = 100000;
  static final _validId = RegExp(r'^[a-z0-9_\-]+$');

  final Set<String> completedMissionIds;
  final Set<String> completedStoryIds;

  /// Best score per mission id. Replays never lower it.
  final Map<String, int> missionBestPoints;

  /// Sum of each mission's best score.
  int get totalMissionPoints =>
      missionBestPoints.values.fold(0, (sum, points) => sum + points);

  LearnerProgress copyWith({
    Set<String>? completedMissionIds,
    Set<String>? completedStoryIds,
    Map<String, int>? missionBestPoints,
  }) => LearnerProgress(
    completedMissionIds: completedMissionIds ?? this.completedMissionIds,
    completedStoryIds: completedStoryIds ?? this.completedStoryIds,
    missionBestPoints: missionBestPoints ?? this.missionBestPoints,
  );

  /// Records a finished mission, keeping the best score so far.
  LearnerProgress withMissionResult(String missionId, int points) {
    final best = missionBestPoints[missionId] ?? 0;
    return copyWith(
      completedMissionIds: {...completedMissionIds, missionId},
      missionBestPoints: {
        ...missionBestPoints,
        missionId: points > best ? points : best,
      },
    );
  }

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'completedMissionIds': completedMissionIds.toList()..sort(),
    'completedStoryIds': completedStoryIds.toList()..sort(),
    'missionBestPoints': missionBestPoints,
  };

  /// Parses stored progress, returning null if the data is unusable.
  ///
  /// Individual malformed entries are dropped rather than discarding the
  /// whole record, so one bad entry cannot wipe a child's progress. Version
  /// 1 data (no scores) is read as-is.
  static LearnerProgress? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final version = json['schemaVersion'];
    // Data from a newer app version cannot be read safely; refuse it so the
    // caller can preserve it instead of overwriting it.
    if (version is! int || version < 1 || version > schemaVersion) return null;
    return LearnerProgress(
      completedMissionIds: _ids(json['completedMissionIds']),
      completedStoryIds: _ids(json['completedStoryIds']),
      missionBestPoints: version >= 2
          ? _points(json['missionBestPoints'])
          : const {},
    );
  }

  static Set<String> _ids(Object? raw) {
    if (raw is! List<Object?>) return const {};
    return {
      for (final id in raw)
        if (id is String && _isValidId(id)) id,
    };
  }

  static Map<String, int> _points(Object? raw) {
    if (raw is! Map<String, Object?>) return const {};
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (_isValidId(key) && value is int && value >= 0 && value <= maxPoints)
          key: value,
    };
  }

  static bool _isValidId(String id) =>
      id.length <= maxIdLength && _validId.hasMatch(id);

  @override
  bool operator ==(Object other) =>
      other is LearnerProgress &&
      _setEquals(other.completedMissionIds, completedMissionIds) &&
      _setEquals(other.completedStoryIds, completedStoryIds) &&
      _mapEquals(other.missionBestPoints, missionBestPoints);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedMissionIds),
    Object.hashAllUnordered(completedStoryIds),
    Object.hashAllUnordered([
      for (final MapEntry(:key, :value) in missionBestPoints.entries)
        '$key=$value',
    ]),
  );

  static bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  static bool _mapEquals(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}
