import 'dart:math';

/// Dino Discovery: explore a prehistoric place, name its creatures from their
/// clues, then finish a short mission. Pure logic: no Flutter, no storage.
/// Nothing is timed, and a wrong pick only brings another clue.

enum DinoDiet {
  plants('Plants'),
  meat('Meat'),
  sea('Fish and other sea animals');

  const DinoDiet(this.label);

  final String label;
}

enum DinoCreature {
  stegosaurus(
    name: 'Stegosaurus',
    sayIt: 'STEG-oh-SORE-us',
    diet: DinoDiet.plants,
    size: 'About 9 metres long',
    clues: [
      'Tall bony plates stood in a row along its back.',
      'Its tail ended in four sharp spikes.',
    ],
    fact:
        'Those tail spikes were a real defence. Scientists found an '
        'Allosaurus bone with a wound that matches a Stegosaurus spike.',
  ),
  diplodocus(
    name: 'Diplodocus',
    sayIt: 'dih-PLOD-oh-kus',
    diet: DinoDiet.plants,
    size: 'About 25 metres long, like a tennis court',
    clues: [
      'It had a very long neck and a tiny head.',
      'Its long, thin tail stretched far out behind it.',
    ],
    fact:
        'Its peg-like teeth stripped leaves from branches. Some scientists '
        'think its thin tail could even crack like a whip.',
  ),
  allosaurus(
    name: 'Allosaurus',
    sayIt: 'AL-oh-SORE-us',
    diet: DinoDiet.meat,
    size: 'About 9 metres long',
    clues: [
      'It walked on two strong legs and had a small bony horn above each eye.',
      'Its long arms ended in big, curved claws.',
    ],
    fact:
        'Allosaurus means "different lizard". It was the top hunter of its '
        'time, long before Tyrannosaurus lived.',
  ),
  tyrannosaurus(
    name: 'Tyrannosaurus',
    sayIt: 'tih-RAN-oh-SORE-us',
    diet: DinoDiet.meat,
    size: 'About 12 metres long',
    clues: [
      'It walked on two legs and had a huge head with a mighty jaw.',
      'Its arms were tiny, with just two fingers on each hand.',
    ],
    fact:
        'Its name means "tyrant lizard". Its biggest teeth, roots included, '
        'were about as long as a banana.',
  ),
  triceratops(
    name: 'Triceratops',
    sayIt: 'try-SERR-uh-tops',
    diet: DinoDiet.plants,
    size: 'About 9 metres long',
    clues: [
      'It had a big bony frill around the back of its head.',
      'It had two long horns above its eyes and a short one on its nose.',
    ],
    fact:
        'Its name means "three-horned face". Its parrot-like beak was great '
        'for snipping tough plants.',
  ),
  ankylosaurus(
    name: 'Ankylosaurus',
    sayIt: 'an-KY-loh-SORE-us',
    diet: DinoDiet.plants,
    size: 'About 7 metres long',
    clues: [
      'It was low and wide, covered in bony armour.',
      'Its tail ended in a heavy, round club.',
    ],
    fact:
        'The bony plates on its back worked like a suit of armour, and it '
        'could swing that tail club hard.',
  ),
  pteranodon(
    name: 'Pteranodon',
    sayIt: 'teh-RAN-oh-don',
    diet: DinoDiet.sea,
    size: 'Wings about 6 metres across',
    isDinosaur: false,
    clues: [
      'It soared on huge wings over the water.',
      'It had a long pointed beak and a long crest on the back of its head.',
    ],
    fact:
        'It was a flying reptile, not a dinosaur. Its name means "wing '
        'without tooth", because its beak had no teeth at all.',
  ),
  mosasaurus(
    name: 'Mosasaurus',
    sayIt: 'MOH-zuh-SORE-us',
    diet: DinoDiet.sea,
    size: 'More than 12 metres long',
    isDinosaur: false,
    clues: [
      'It had a long, sleek body and swam with a strong tail.',
      'Its long jaws were packed with sharp teeth.',
    ],
    fact:
        'It was a giant sea lizard, not a dinosaur. It hunted fish, turtles '
        'and even other sea reptiles.',
  ),
  elasmosaurus(
    name: 'Elasmosaurus',
    sayIt: 'ee-LAZ-moh-SORE-us',
    diet: DinoDiet.sea,
    size: 'About 10 metres long',
    isDinosaur: false,
    clues: [
      'It had an amazingly long neck and a small head.',
      'It paddled through the sea with four big flippers.',
    ],
    fact:
        'It was a sea reptile, not a dinosaur. It had more than 70 bones in '
        'its neck. You have just 7!',
  );

  const DinoCreature({
    required this.name,
    required this.sayIt,
    required this.diet,
    required this.size,
    required this.clues,
    required this.fact,
    this.isDinosaur = true,
  });

  final String name;

  /// How to say the name, shown as text.
  final String sayIt;
  final DinoDiet diet;
  final String size;

  /// The first clue, then a second to help after a wrong pick. Each describes
  /// something the picture really shows.
  final List<String> clues;
  final String fact;
  final bool isDinosaur;

  /// The place this creature lives in the game.
  DinoPlace get place =>
      DinoPlace.values.firstWhere((p) => p.creatures.contains(this));

  /// Buddy reads this out in the Field Guide.
  String get guideLine => '$name. $fact';
}

/// One question in a place's mission.
class DinoTask {
  const DinoTask({
    required this.prompt,
    required this.answer,
    required this.explanation,
  });

  final String prompt;
  final DinoCreature answer;
  final String explanation;
}

enum DinoPlace {
  fernForest(
    name: 'Fern Forest',
    era: 'Jurassic, about 150 million years ago',
    intro: 'Huge ferns and tall trees. Something is moving in there!',
    creatures: [
      DinoCreature.stegosaurus,
      DinoCreature.diplodocus,
      DinoCreature.allosaurus,
    ],
    mission: [
      DinoTask(
        prompt:
            'The sweetest leaves are at the top of a tall tree. Who can '
            'reach them?',
        answer: DinoCreature.diplodocus,
        explanation: "Diplodocus's long neck reached high into the trees.",
      ),
      DinoTask(
        prompt: 'Which of these three ate meat?',
        answer: DinoCreature.allosaurus,
        explanation:
            'Allosaurus was a hunter. Stegosaurus and Diplodocus ate plants.',
      ),
      DinoTask(
        prompt: 'A hunter creeps close. Who swings a spiked tail to stay safe?',
        answer: DinoCreature.stegosaurus,
        explanation: 'Four sharp spikes made that tail a powerful defence.',
      ),
    ],
  ),
  openPlains(
    name: 'Open Plains',
    era: 'Late Cretaceous, about 67 million years ago',
    intro: 'Wide open land under a smoky volcano. Look for tracks!',
    creatures: [
      DinoCreature.triceratops,
      DinoCreature.ankylosaurus,
      DinoCreature.tyrannosaurus,
    ],
    mission: [
      DinoTask(
        prompt: 'Which of these three was the mighty hunter?',
        answer: DinoCreature.tyrannosaurus,
        explanation:
            'Tyrannosaurus ate meat. The other two ate plants, and had '
            'horns or armour to protect them.',
      ),
      DinoTask(
        prompt: 'Who could swing a heavy club at a hungry hunter?',
        answer: DinoCreature.ankylosaurus,
        explanation: 'Ankylosaurus had a big bony club on the end of its tail.',
      ),
      DinoTask(
        prompt: 'Who wore three horns on its face?',
        answer: DinoCreature.triceratops,
        explanation: 'Its name even means "three-horned face".',
      ),
    ],
  ),
  ancientSea(
    name: 'Ancient Sea',
    era: 'Late Cretaceous, about 85 to 80 million years ago',
    intro: 'A warm sea covers the land. Watch the water and the sky!',
    creatures: [
      DinoCreature.pteranodon,
      DinoCreature.mosasaurus,
      DinoCreature.elasmosaurus,
    ],
    mission: [
      DinoTask(
        prompt: 'Who could fly over the waves?',
        answer: DinoCreature.pteranodon,
        explanation: 'Pteranodon soared on huge wings, looking for fish.',
      ),
      DinoTask(
        prompt: 'Who had more than 70 bones in its neck?',
        answer: DinoCreature.elasmosaurus,
        explanation: 'Elasmosaurus had one of the longest necks in the sea.',
      ),
      DinoTask(
        prompt: 'Who was a giant sea lizard with sharp teeth?',
        answer: DinoCreature.mosasaurus,
        explanation:
            'Mosasaurus was a giant lizard. Like everything here, it was '
            'not a dinosaur!',
      ),
    ],
  );

  const DinoPlace({
    required this.name,
    required this.era,
    required this.intro,
    required this.creatures,
    required this.mission,
  });

  final String name;
  final String era;
  final String intro;
  final List<DinoCreature> creatures;
  final List<DinoTask> mission;

  /// The saved results key, kept with the other game results.
  String get id => 'dino_$name'.replaceAll(' ', '_').toLowerCase();
}

abstract final class DinoRules {
  static const identifyOptions = 3;

  static final allIds = {for (final place in DinoPlace.values) place.id};

  /// The first place is always open; each later one opens once the place
  /// before it has been explored.
  static bool isOpen(DinoPlace place, Map<String, int> best) =>
      place.index == 0 || (best[DinoPlace.values[place.index - 1].id] ?? 0) > 0;

  /// Creatures earned by finishing their place.
  static Set<DinoCreature> foundIn(Map<String, int> best) => {
    for (final place in DinoPlace.values)
      if ((best[place.id] ?? 0) > 0) ...place.creatures,
  };

  static bool isComplete(Map<String, int> best) =>
      foundIn(best).length == DinoCreature.values.length;
}

enum DinoStage { explore, identify, discovered, mission, done }

enum DinoPickResult { ignored, wrong, right }

/// One trip to a place: find and name every creature, then do the mission.
class DinoExpedition {
  DinoExpedition({required this.place, required Random random})
    : _random = random;

  final DinoPlace place;
  final Random _random;

  DinoStage get stage => _stage;
  DinoStage _stage = DinoStage.explore;

  final Set<DinoCreature> found = {};

  /// The creature being identified, or just discovered.
  DinoCreature? get current => _current;
  DinoCreature? _current;

  /// The picks on offer for this question.
  List<DinoCreature> get options => _options;
  List<DinoCreature> _options = const [];

  /// Picks already tried, which stay visible but can't be picked again.
  final Set<DinoCreature> wrongPicks = {};

  int get mistakes => _mistakes;
  int _mistakes = 0;

  int get taskIndex => _taskIndex;
  int _taskIndex = 0;
  DinoTask get task => place.mission[_taskIndex];

  /// Whether the current mission question has been answered.
  bool get taskSolved => _taskSolved;
  bool _taskSolved = false;

  /// The clue on show: a wrong pick brings the second.
  String get clue => _current!.clues[wrongPicks.isEmpty ? 0 : 1];

  /// Fewer wrong picks earn more stars; finishing always earns at least one.
  int get stars {
    if (_mistakes == 0) return 3;
    if (_mistakes <= 2) return 2;
    return 1;
  }

  /// Look at a spot in the scene. Returns whether anything happened.
  bool investigate(DinoCreature creature) {
    if (_stage != DinoStage.explore) return false;
    if (!place.creatures.contains(creature) || found.contains(creature)) {
      return false;
    }
    _current = creature;
    wrongPicks.clear();
    final others = [...DinoCreature.values]
      ..remove(creature)
      ..shuffle(_random);
    _options = [creature, ...others.take(DinoRules.identifyOptions - 1)]
      ..shuffle(_random);
    _stage = DinoStage.identify;
    return true;
  }

  DinoPickResult pick(DinoCreature creature) {
    final answer = switch (_stage) {
      DinoStage.identify => _current!,
      DinoStage.mission when !_taskSolved => task.answer,
      _ => null,
    };
    if (answer == null ||
        !_options.contains(creature) ||
        wrongPicks.contains(creature)) {
      return DinoPickResult.ignored;
    }
    if (creature != answer) {
      wrongPicks.add(creature);
      _mistakes++;
      return DinoPickResult.wrong;
    }
    if (_stage == DinoStage.identify) {
      found.add(creature);
      _stage = DinoStage.discovered;
    } else {
      _taskSolved = true;
    }
    return DinoPickResult.right;
  }

  /// Move on from a discovery or a solved mission question.
  void carryOn() {
    if (_stage == DinoStage.discovered) {
      if (found.length < place.creatures.length) {
        _current = null;
        _stage = DinoStage.explore;
      } else {
        _startTask(0);
        _stage = DinoStage.mission;
      }
    } else if (_stage == DinoStage.mission && _taskSolved) {
      if (_taskIndex + 1 < place.mission.length) {
        _startTask(_taskIndex + 1);
      } else {
        _stage = DinoStage.done;
      }
    }
  }

  void _startTask(int index) {
    _taskIndex = index;
    _taskSolved = false;
    wrongPicks.clear();
    _options = [...place.creatures]..shuffle(_random);
  }
}

/// Checks that the content is fair; returns problems, empty when valid.
List<String> dinoProblems() {
  final issues = <String>[];
  for (final creature in DinoCreature.values) {
    final where = creature.name;
    if (creature.clues.length != 2) issues.add('$where: needs two clues');
    if (creature.clues.any((c) => c.contains(where))) {
      issues.add('$where: a clue gives the name away');
    }
    if (creature.fact.trim().isEmpty) issues.add('$where: no fact');
    final homes = DinoPlace.values.where((p) => p.creatures.contains(creature));
    if (homes.length != 1) issues.add('$where: needs exactly one place');
  }
  for (final place in DinoPlace.values) {
    final where = place.name;
    if (place.creatures.length != 3) issues.add('$where: needs 3 creatures');
    if (place.mission.isEmpty) issues.add('$where: no mission');
    for (final task in place.mission) {
      if (!place.creatures.contains(task.answer)) {
        issues.add('$where: mission answer is not from this place');
      }
      if (task.prompt.contains(task.answer.name)) {
        issues.add('$where: a question gives the answer away');
      }
    }
    final answers = place.mission.map((t) => t.answer).toSet();
    if (answers.length != place.mission.length) {
      issues.add('$where: repeated mission answer');
    }
  }
  return issues;
}
