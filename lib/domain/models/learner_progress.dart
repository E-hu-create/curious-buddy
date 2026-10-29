/// A child's saved progress.
///
/// Deliberately contains no personal information: no name, age, photo,
/// location or voice data. Only identifiers of content the child completed,
/// their best mission scores, the story endings they found and where they
/// stopped reading.
class LearnerProgress {
  const LearnerProgress({
    this.completedMissionIds = const {},
    this.completedStoryIds = const {},
    this.missionBestPoints = const {},
    this.storyEndings = const {},
    this.storyBookmarks = const {},
  });

  static const empty = LearnerProgress();

  /// Bump when the stored shape changes, and handle older versions in
  /// [tryFromJson]. History: 1 = ids only; 2 = adds mission best points;
  /// 3 = adds story endings and bookmarks.
  static const schemaVersion = 3;

  static const maxIdLength = 64;
  static const maxPoints = 100000;
  static const maxBookmarkLength = 64;
  static final _validId = RegExp(r'^[a-z0-9_\-]+$');

  final Set<String> completedMissionIds;
  final Set<String> completedStoryIds;

  /// Best score per mission id. Replays never lower it.
  final Map<String, int> missionBestPoints;

  /// Ending ids found per story id.
  final Map<String, Set<String>> storyEndings;

  /// Where the child stopped in an unfinished story: the scene ids from the
  /// start to the current scene. Removed when the story reaches an ending.
  final Map<String, List<String>> storyBookmarks;

  /// Sum of each mission's best score.
  int get totalMissionPoints =>
      missionBestPoints.values.fold(0, (sum, points) => sum + points);

  LearnerProgress copyWith({
    Set<String>? completedMissionIds,
    Set<String>? completedStoryIds,
    Map<String, int>? missionBestPoints,
    Map<String, Set<String>>? storyEndings,
    Map<String, List<String>>? storyBookmarks,
  }) => LearnerProgress(
    completedMissionIds: completedMissionIds ?? this.completedMissionIds,
    completedStoryIds: completedStoryIds ?? this.completedStoryIds,
    missionBestPoints: missionBestPoints ?? this.missionBestPoints,
    storyEndings: storyEndings ?? this.storyEndings,
    storyBookmarks: storyBookmarks ?? this.storyBookmarks,
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

  /// Records a story reaching an ending and clears its bookmark.
  LearnerProgress withStoryEnding(String storyId, String endingId) => copyWith(
    completedStoryIds: {...completedStoryIds, storyId},
    storyEndings: {
      ...storyEndings,
      storyId: {...?storyEndings[storyId], endingId},
    },
    storyBookmarks: {...storyBookmarks}..remove(storyId),
  );

  /// Remembers where the child is in an unfinished story.
  LearnerProgress withStoryBookmark(String storyId, List<String> path) =>
      copyWith(storyBookmarks: {...storyBookmarks, storyId: List.of(path)});

  /// Forgets the place in a story (the child chose to start again).
  LearnerProgress withoutStoryBookmark(String storyId) =>
      copyWith(storyBookmarks: {...storyBookmarks}..remove(storyId));

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'completedMissionIds': completedMissionIds.toList()..sort(),
    'completedStoryIds': completedStoryIds.toList()..sort(),
    'missionBestPoints': missionBestPoints,
    'storyEndings': {
      for (final MapEntry(:key, :value) in storyEndings.entries)
        key: value.toList()..sort(),
    },
    'storyBookmarks': storyBookmarks,
  };

  /// Parses stored progress, returning null if the data is unusable.
  ///
  /// Individual malformed entries are dropped rather than discarding the
  /// whole record, so one bad entry cannot wipe a child's progress. Older
  /// versions (no scores, no story details) are read as-is.
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
      storyEndings: version >= 3 ? _endings(json['storyEndings']) : const {},
      storyBookmarks: version >= 3
          ? _bookmarks(json['storyBookmarks'])
          : const {},
    );
  }

  static Map<String, Set<String>> _endings(Object? raw) {
    if (raw is! Map<String, Object?>) return const {};
    final result = <String, Set<String>>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      final ids = _ids(value);
      if (_isValidId(key) && ids.isNotEmpty) result[key] = ids;
    }
    return result;
  }

  static Map<String, List<String>> _bookmarks(Object? raw) {
    if (raw is! Map<String, Object?>) return const {};
    final result = <String, List<String>>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      final path = _path(value);
      if (_isValidId(key) && path != null) result[key] = path;
    }
    return result;
  }

  /// A bookmark is kept only if every entry is a valid id; a partly broken
  /// path cannot be resumed safely.
  static List<String>? _path(Object? raw) {
    if (raw is! List<Object?> || raw.isEmpty) return null;
    if (raw.length > maxBookmarkLength) return null;
    final path = <String>[];
    for (final id in raw) {
      if (id is! String || !_isValidId(id)) return null;
      path.add(id);
    }
    return path;
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
      _mapEquals(other.missionBestPoints, missionBestPoints) &&
      _keyed(other.storyEndings) == _keyed(storyEndings) &&
      _keyed(other.storyBookmarks) == _keyed(storyBookmarks);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedMissionIds),
    Object.hashAllUnordered(completedStoryIds),
    Object.hashAllUnordered([
      for (final MapEntry(:key, :value) in missionBestPoints.entries)
        '$key=$value',
    ]),
    _keyed(storyEndings),
    _keyed(storyBookmarks),
  );

  /// A canonical string for comparing story maps: endings are sets (order
  /// ignored), bookmarks are paths (order matters).
  static String _keyed(Map<String, Iterable<String>> map) {
    String values(Iterable<String> v) =>
        (v is Set<String> ? (v.toList()..sort()) : v).join(',');
    return ([
      for (final MapEntry(:key, :value) in map.entries) '$key=${values(value)}',
    ]..sort()).join(';');
  }

  static bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  static bool _mapEquals(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}
