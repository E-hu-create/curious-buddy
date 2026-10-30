import 'creation.dart';

/// Saved shape of the creations shelf. Versioned JSON with tolerant
/// parsing: one bad entry is dropped instead of losing the whole shelf.
class CreationShelf {
  const CreationShelf({this.items = const [], this.nextId = 1});

  static const empty = CreationShelf();
  static const schemaVersion = 1;
  static final _validId = RegExp(r'^c[0-9]{1,6}$');

  /// Oldest first.
  final List<Creation> items;

  /// The number for the next new creation's id.
  final int nextId;

  bool get isFull => items.length >= CreativeLimits.maxCreations;
  int get drawings => items.whereType<Drawing>().length;
  int get creatures => items.whereType<Creature>().length;

  String newId() => 'c$nextId';

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'nextId': nextId,
    'items': [for (final item in items) _encode(item)],
  };

  static Map<String, Object> _encode(Creation item) => switch (item) {
    Drawing(:final id, :final strokes) => {
      'type': 'drawing',
      'id': id,
      'strokes': [
        for (final s in strokes)
          {
            'c': s.colorIndex,
            's': s.sizeIndex,
            'e': s.eraser,
            'p': [
              for (final p in s.points) ...[p.x, p.y],
            ],
          },
      ],
    },
    Creature() => {
      'type': 'creature',
      'id': item.id,
      'name': item.name,
      'body': item.body.name,
      'color': item.colorIndex,
      'eyes': item.eyes.name,
      'mouth': item.mouth.name,
      'extra': item.extra.name,
      'pattern': item.pattern.name,
    },
  };

  /// Parses a saved shelf, or null if the data is unusable as a whole.
  static CreationShelf? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final version = json['schemaVersion'];
    if (version is! int || version < 1 || version > schemaVersion) return null;
    final raw = json['items'];
    if (raw is! List<Object?>) return null;

    final ids = <String>{};
    final items = <Creation>[];
    var highest = 0;
    for (final entry in raw) {
      if (items.length >= CreativeLimits.maxCreations) break;
      final item = _decode(entry);
      if (item == null || !ids.add(item.id)) continue;
      items.add(item);
      final n = int.parse(item.id.substring(1));
      if (n > highest) highest = n;
    }
    final saved = json['nextId'];
    final nextId = saved is int && saved > highest ? saved : highest + 1;
    return CreationShelf(items: items, nextId: nextId);
  }

  static Creation? _decode(Object? raw) {
    if (raw is! Map<String, Object?>) return null;
    final id = raw['id'];
    if (id is! String || !_validId.hasMatch(id)) return null;
    return switch (raw['type']) {
      'drawing' => _drawing(id, raw['strokes']),
      'creature' => _creature(id, raw),
      _ => null,
    };
  }

  static Drawing? _drawing(String id, Object? raw) {
    if (raw is! List<Object?> || raw.length > CreativeLimits.maxStrokes) {
      return null;
    }
    final strokes = <Stroke>[];
    var total = 0;
    for (final s in raw) {
      if (s is! Map<String, Object?>) return null;
      final c = s['c'], size = s['s'], e = s['e'], p = s['p'];
      if (c is! int || c < 0 || c >= CreativeLimits.colorCount) return null;
      if (size is! int || size < 0 || size >= CreativeLimits.sizeCount) {
        return null;
      }
      if (e is! bool || p is! List<Object?> || p.isEmpty || p.length.isOdd) {
        return null;
      }
      final points = <DrawPoint>[];
      for (var i = 0; i < p.length; i += 2) {
        final x = p[i], y = p[i + 1];
        if (!_inRange(x) || !_inRange(y)) return null;
        points.add(DrawPoint(x! as int, y! as int));
      }
      total += points.length;
      if (total > CreativeLimits.maxPointsPerDrawing) return null;
      strokes.add(
        Stroke(colorIndex: c, sizeIndex: size, eraser: e, points: points),
      );
    }
    return Drawing(id: id, strokes: strokes);
  }

  static bool _inRange(Object? v) => v is int && v >= 0 && v <= DrawPoint.scale;

  static Creature? _creature(String id, Map<String, Object?> raw) {
    final name = raw['name'];
    final color = raw['color'];
    if (name is! String || !creatureNames.contains(name)) return null;
    if (color is! int || color < 0 || color >= CreativeLimits.colorCount) {
      return null;
    }
    final body = _enum(CreatureBody.values, raw['body']);
    final eyes = _enum(CreatureEyes.values, raw['eyes']);
    final mouth = _enum(CreatureMouth.values, raw['mouth']);
    final extra = _enum(CreatureExtra.values, raw['extra']);
    final pattern = _enum(CreaturePattern.values, raw['pattern']);
    if (body == null ||
        eyes == null ||
        mouth == null ||
        extra == null ||
        pattern == null) {
      return null;
    }
    return Creature(
      id: id,
      name: name,
      body: body,
      colorIndex: color,
      eyes: eyes,
      mouth: mouth,
      extra: extra,
      pattern: pattern,
    );
  }

  static T? _enum<T extends Enum>(List<T> values, Object? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
