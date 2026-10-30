import 'dart:convert';

import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/creative/creation_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

const _creature = Creature(
  id: 'c2',
  name: 'Zibble',
  body: CreatureBody.round,
  colorIndex: 3,
  eyes: CreatureEyes.big,
  mouth: CreatureMouth.grin,
  extra: CreatureExtra.wings,
  pattern: CreaturePattern.spots,
);

const _drawing = Drawing(
  id: 'c1',
  strokes: [
    Stroke(
      colorIndex: 1,
      sizeIndex: 2,
      points: [DrawPoint(10, 20), DrawPoint(30, 40)],
    ),
    Stroke(
      colorIndex: 0,
      sizeIndex: 0,
      eraser: true,
      points: [DrawPoint(500, 500)],
    ),
  ],
);

Map<String, Object?> _roundTrip(CreationShelf shelf) =>
    jsonDecode(jsonEncode(shelf.toJson())) as Map<String, Object?>;

void main() {
  group('CreationShelf', () {
    test('round-trips drawings and creatures', () {
      const shelf = CreationShelf(items: [_drawing, _creature], nextId: 3);
      final back = CreationShelf.tryFromJson(_roundTrip(shelf))!;

      expect(back.items, hasLength(2));
      expect(back.nextId, 3);
      final drawing = back.items[0] as Drawing;
      expect(drawing.strokes, hasLength(2));
      expect(drawing.strokes[0].points, _drawing.strokes[0].points);
      expect(drawing.strokes[1].eraser, isTrue);
      expect(drawing.colorsUsed, {1});
      final creature = back.items[1] as Creature;
      expect(creature.name, 'Zibble');
      expect(creature.extra, CreatureExtra.wings);
      expect(back.drawings, 1);
      expect(back.creatures, 1);
    });

    test('rejects unusable data as a whole', () {
      for (final bad in [
        null,
        'text',
        <String, Object?>{},
        {'schemaVersion': 99, 'items': <Object>[]},
        {'schemaVersion': 1, 'items': 'none'},
      ]) {
        expect(CreationShelf.tryFromJson(bad), isNull, reason: '$bad');
      }
    });

    test('drops bad entries but keeps good ones', () {
      final json = _roundTrip(
        const CreationShelf(items: [_drawing, _creature], nextId: 3),
      );
      final items = json['items']! as List<Object?>;
      items.addAll([
        {'type': 'creature', 'id': 'c9', 'name': 'Typed Name'}, // not listed
        {'type': 'drawing', 'id': 'c10', 'strokes': 'x'},
        {
          'type': 'drawing',
          'id': 'c11',
          'strokes': [
            {
              'c': 1,
              's': 1,
              'e': false,
              'p': [5000, 5],
            }, // out of range
          ],
        },
        {'type': 'drawing', 'id': 'bad id', 'strokes': <Object>[]},
        {'type': 'rocket', 'id': 'c12'},
        // A second entry with an id already used.
        (_roundTrip(const CreationShelf(items: [_creature]))['items']!
                as List<Object?>)
            .first,
      ]);

      final back = CreationShelf.tryFromJson(json)!;
      expect([for (final i in back.items) i.id], ['c1', 'c2']);
    });

    test('drawings over the point cap are dropped', () {
      final huge = Drawing(
        id: 'c1',
        strokes: [
          Stroke(
            colorIndex: 0,
            sizeIndex: 0,
            points: List.filled(
              CreativeLimits.maxPointsPerDrawing + 1,
              const DrawPoint(1, 1),
            ),
          ),
        ],
      );
      final back = CreationShelf.tryFromJson(
        _roundTrip(CreationShelf(items: [huge])),
      )!;
      expect(back.items, isEmpty);
    });

    test('keeps at most the shelf limit', () {
      final many = [
        for (var i = 1; i <= CreativeLimits.maxCreations + 3; i++)
          _creature.copyWith(id: 'c$i'),
      ];
      final back = CreationShelf.tryFromJson(
        _roundTrip(CreationShelf(items: many, nextId: 99)),
      )!;
      expect(back.items, hasLength(CreativeLimits.maxCreations));
      expect(back.isFull, isTrue);
    });

    test('the next id never reuses a saved one', () {
      final json = _roundTrip(const CreationShelf(items: [_creature]));
      json['nextId'] = 1; // older or damaged counter
      expect(CreationShelf.tryFromJson(json)!.newId(), 'c3');
    });
  });

  group('creature names', () {
    test('are unique, short and simple', () {
      expect(creatureNames.toSet(), hasLength(creatureNames.length));
      expect(creatureNames.length, greaterThanOrEqualTo(30));
      for (final name in creatureNames) {
        expect(name, matches(RegExp(r'^[A-Z][a-z]+(-[A-Z][a-z]+)?$')));
        expect(name.length, lessThanOrEqualTo(10));
      }
    });

    test('contain no unkind or unsuitable words', () {
      const blocked = [
        'poo', 'butt', 'fart', 'stupid', 'dumb', 'idiot', 'ugly', 'fat', //
        'kill', 'dead', 'hate', 'loser', 'nerd', 'crap', 'damn', 'hell',
        'sex', 'ass', 'gob', 'loo', 'wee', 'bum', 'nut', 'weird', 'freak',
      ];
      for (final name in creatureNames) {
        final lower = name.toLowerCase();
        for (final word in blocked) {
          expect(lower.contains(word), isFalse, reason: '$name has "$word"');
        }
      }
    });
  });

  test('Buddy has a fact for every kind of creature', () {
    for (final extra in CreatureExtra.values) {
      for (final pattern in CreaturePattern.values) {
        for (final eyes in CreatureEyes.values) {
          final fact = creatureFact(
            _creature.copyWith(extra: extra, pattern: pattern, eyes: eyes),
          );
          expect(fact, isNotEmpty);
          expect(fact.split(' ').length, lessThanOrEqualTo(25));
        }
      }
    }
  });
}
