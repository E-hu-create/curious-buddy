import 'dart:math';

/// Sort It!: put each thing in the right group. Pure logic: no Flutter, no
/// storage. Nothing is timed, and a wrong group only means trying again.

class SortItem {
  const SortItem(this.name, this.group, {this.note});

  final String name;

  /// Which of the set's groups it belongs to.
  final int group;

  /// Shown once it is sorted, for the surprising ones.
  final String? note;
}

class SortSet {
  const SortSet(this.question, this.groups, this.items);

  final String question;
  final List<String> groups;
  final List<SortItem> items;
}

const Map<int, List<SortSet>> sortLevels = {
  1: [
    SortSet(
      'Is it alive?',
      ['Living', 'Not living'],
      [
        SortItem('Tree', 0),
        SortItem('Fish', 0),
        SortItem('Bird', 0),
        SortItem('Flower', 0),
        SortItem('Frog', 0),
        SortItem(
          'Mushroom',
          0,
          note: 'Mushrooms are alive. They are fungi, not plants.',
        ),
        SortItem('Rock', 1),
        SortItem('Spoon', 1),
        SortItem('Rocket', 1),
        SortItem('Clock', 1),
        SortItem('Cloud', 1, note: 'Clouds move, but they are not alive.'),
      ],
    ),
    SortSet(
      'Where does it live?',
      ['On land', 'In water'],
      [
        SortItem('Lion', 0),
        SortItem('Camel', 0),
        SortItem('Elephant', 0),
        SortItem('Tiger', 0),
        SortItem('Horse', 0),
        SortItem('Whale', 1),
        SortItem('Shark', 1),
        SortItem('Octopus', 1),
        SortItem('Jellyfish', 1),
        SortItem('Dolphin', 1),
      ],
    ),
  ],
  2: [
    SortSet(
      'What does it eat?',
      ['Plants', 'Meat'],
      [
        SortItem('Cow', 0),
        SortItem('Rabbit', 0),
        SortItem('Giraffe', 0),
        SortItem('Koala', 0, note: 'Koalas eat mostly eucalyptus leaves.'),
        SortItem('Deer', 0),
        SortItem('Elephant', 0),
        SortItem('Lion', 1),
        SortItem('Shark', 1),
        SortItem('Eagle', 1),
        SortItem('Tiger', 1),
        SortItem('Wolf', 1),
        SortItem('Crocodile', 1),
      ],
    ),
    SortSet(
      'What kind of animal is it?',
      ['Mammal', 'Bird'],
      [
        SortItem(
          'Whale',
          0,
          note: 'Whales breathe air and feed their babies milk.',
        ),
        SortItem('Bat', 0, note: 'Bats fly, but they have fur and feed milk.'),
        SortItem('Dolphin', 0),
        SortItem('Monkey', 0),
        SortItem('Mouse', 0),
        SortItem('Penguin', 1, note: "Penguins can't fly, but they are birds."),
        SortItem('Ostrich', 1, note: 'The ostrich is the largest living bird.'),
        SortItem('Owl', 1),
        SortItem('Robin', 1),
        SortItem('Parrot', 1),
      ],
    ),
  ],
  3: [
    SortSet(
      'What state of matter is it?',
      ['Solid', 'Liquid', 'Gas'],
      [
        SortItem('Ice', 0, note: 'Ice is water in its solid state.'),
        SortItem('Rock', 0),
        SortItem('Wood', 0),
        SortItem('Gold', 0),
        SortItem('Water', 1),
        SortItem('Milk', 1),
        SortItem('Honey', 1, note: 'Honey is thick, but it still flows.'),
        SortItem('Juice', 1),
        SortItem('Oxygen', 2),
        SortItem(
          'Steam',
          2,
          note:
              'Steam is water in its gas state. The white cloud we see is '
              'tiny water drops; the gas itself is invisible.',
        ),
        SortItem('Helium', 2),
      ],
    ),
    SortSet(
      'What is it in space?',
      ['Planet', 'Star', 'Moon'],
      [
        SortItem('Mars', 0),
        SortItem('Jupiter', 0),
        SortItem('Venus', 0),
        SortItem('Saturn', 0),
        SortItem('The Sun', 1, note: 'The Sun is our closest star.'),
        SortItem('Polaris', 1, note: 'Polaris is also called the North Star.'),
        SortItem('Sirius', 1, note: 'Sirius is the brightest star at night.'),
        SortItem('Titan', 2, note: "Titan is Saturn's largest moon."),
        SortItem('Europa', 2, note: 'Europa is a moon of Jupiter.'),
        SortItem('Phobos', 2, note: 'Phobos is a moon of Mars.'),
      ],
    ),
  ],
};

enum SortResult { ignored, wrong, right, won }

/// One game: a set of things to sort, one at a time.
class SortGame {
  SortGame({required this.level, required Random random}) {
    final sets = sortLevels[level]!;
    set = sets[random.nextInt(sets.length)];
    items = ([...set.items]..shuffle(random)).take(itemCount).toList();
  }

  static const itemCount = 8;

  final int level;
  late final SortSet set;
  late final List<SortItem> items;

  int get index => _index;
  int _index = 0;

  SortItem get item => items[_index];

  /// How many went into each group.
  late final List<int> counts = List.filled(set.groups.length, 0);

  /// Groups already tried for this item, which can't count twice.
  final Set<int> tried = {};

  /// The item just sorted, to show its note.
  SortItem? get lastSorted => _lastSorted;
  SortItem? _lastSorted;

  int get mistakes => _mistakes;
  int _mistakes = 0;

  /// Fewer wrong picks earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 2) return 2;
    return 1;
  }

  SortResult pick(int group) {
    if (group < 0 || group >= set.groups.length || tried.contains(group)) {
      return SortResult.ignored;
    }
    if (_index >= items.length) return SortResult.ignored;
    if (group != item.group) {
      tried.add(group);
      _mistakes++;
      return SortResult.wrong;
    }
    counts[group]++;
    _lastSorted = item;
    tried.clear();
    if (_index + 1 >= items.length) return SortResult.won;
    _index++;
    return SortResult.right;
  }
}

/// Checks that the sets are fair; returns problems, empty when valid.
List<String> sortProblems() {
  final issues = <String>[];
  for (final MapEntry(key: level, value: sets) in sortLevels.entries) {
    if (sets.length < 2) issues.add('level $level: needs variety');
    for (final set in sets) {
      final where = set.question;
      if (set.items.length < SortGame.itemCount) issues.add('$where: too few');
      final names = set.items.map((i) => i.name).toSet();
      if (names.length != set.items.length) issues.add('$where: repeats');
      for (var group = 0; group < set.groups.length; group++) {
        if (set.items.where((i) => i.group == group).length < 3) {
          issues.add('$where: too few in ${set.groups[group]}');
        }
      }
      if (set.items.any((i) => i.group >= set.groups.length)) {
        issues.add('$where: an item has no group');
      }
    }
  }
  return issues;
}
