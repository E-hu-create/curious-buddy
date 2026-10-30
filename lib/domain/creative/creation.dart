/// Creative Island creations: drawings and creatures, kept on the phone.
/// Pure data: no Flutter, no storage.
///
/// Nothing here holds free text typed by a child. Creature names come only
/// from [creatureNames], so no personal information can end up in a
/// creation.
library;

/// A point on the drawing canvas, in units of 0 to [DrawPoint.scale] on
/// both axes (independent of screen size).
class DrawPoint {
  const DrawPoint(this.x, this.y);

  static const scale = 1000;

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is DrawPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// One finger stroke. The eraser paints with the paper colour.
class Stroke {
  const Stroke({
    required this.colorIndex,
    required this.sizeIndex,
    required this.points,
    this.eraser = false,
  });

  final int colorIndex;
  final int sizeIndex;
  final bool eraser;
  final List<DrawPoint> points;
}

sealed class Creation {
  const Creation({required this.id});

  /// Unique on this phone, e.g. `c7`.
  final String id;
}

final class Drawing extends Creation {
  const Drawing({required super.id, required this.strokes});

  final List<Stroke> strokes;

  int get pointCount => strokes.fold(0, (sum, s) => sum + s.points.length);

  /// Colours used, not counting the eraser.
  Set<int> get colorsUsed => {
    for (final s in strokes)
      if (!s.eraser) s.colorIndex,
  };
}

enum CreatureBody { round, tall, wide, blob }

enum CreatureEyes { round, sleepy, big, three }

enum CreatureMouth { smile, grin, open, tongue }

enum CreatureExtra { none, wings, horns, antennae }

enum CreaturePattern { none, spots, stripes }

final class Creature extends Creation {
  const Creature({
    required super.id,
    required this.name,
    required this.body,
    required this.colorIndex,
    required this.eyes,
    required this.mouth,
    required this.extra,
    required this.pattern,
  });

  final String name;
  final CreatureBody body;
  final int colorIndex;
  final CreatureEyes eyes;
  final CreatureMouth mouth;
  final CreatureExtra extra;
  final CreaturePattern pattern;

  Creature copyWith({
    String? id,
    String? name,
    CreatureBody? body,
    int? colorIndex,
    CreatureEyes? eyes,
    CreatureMouth? mouth,
    CreatureExtra? extra,
    CreaturePattern? pattern,
  }) => Creature(
    id: id ?? this.id,
    name: name ?? this.name,
    body: body ?? this.body,
    colorIndex: colorIndex ?? this.colorIndex,
    eyes: eyes ?? this.eyes,
    mouth: mouth ?? this.mouth,
    extra: extra ?? this.extra,
    pattern: pattern ?? this.pattern,
  );
}

/// Limits that keep saved creations small and the shelf tidy.
abstract final class CreativeLimits {
  static const maxCreations = 12;
  static const maxStrokes = 300;
  static const maxPointsPerDrawing = 4000;

  /// Points closer than this to the previous one are dropped.
  static const minPointGap = 6;

  /// Number of colours in the palette (the UI maps indexes to colours).
  static const colorCount = 8;
  static const sizeCount = 3;
}

/// Reviewed names for creatures: playful sounds, short and easy to say,
/// never names of real people or unkind words. test/domain/creative checks
/// them against a word list.
const creatureNames = [
  'Zibble', 'Moxo', 'Pim-Pim', 'Flonk', 'Wibbit', 'Snorbel', 'Tazzle', //
  'Blippo', 'Quibble', 'Nooka', 'Fizzwick', 'Glim', 'Jubjub', 'Kazoo',
  'Lumo', 'Mipsy', 'Norby', 'Ozzle', 'Plinky', 'Rumbo', 'Skeeble',
  'Tumtum', 'Uggle', 'Vroomi', 'Wuzzle', 'Yibbo', 'Zorp', 'Bimble',
  'Doodlebop', 'Frizz', 'Zappo', 'Hoppit', 'Jinks', 'Kerplunk', 'Fluffo',
  'Mumbo', 'Nibbles', 'Poppet', 'Squidge', 'Twinkle',
];

/// What Buddy says about a creature part: a short, true fact.
String creatureFact(Creature creature) => switch (creature.extra) {
  CreatureExtra.wings => 'Wings! Bats are the only mammals that can truly fly.',
  CreatureExtra.horns =>
    'Horns! A rhino horn is made of keratin, the same stuff as your '
        'fingernails.',
  CreatureExtra.antennae =>
    'Antennae! Many insects use them to smell and feel the world.',
  CreatureExtra.none => switch (creature.pattern) {
    CreaturePattern.spots =>
      'Spots! No two giraffes have exactly the same pattern.',
    CreaturePattern.stripes =>
      'Stripes! Every zebra has its own stripe pattern, like a fingerprint.',
    CreaturePattern.none => switch (creature.eyes) {
      CreatureEyes.three =>
        'Three eyes! Some lizards have a third eye on top of their head '
            'that senses light.',
      CreatureEyes.big => 'Big eyes! Owls have huge eyes to see in the dark.',
      _ =>
        'What a friendly creature! Every animal on Earth is a little '
            'bit different.',
    },
  },
};
