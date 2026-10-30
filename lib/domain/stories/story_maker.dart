import 'dart:math';

import 'story.dart';

/// Story Maker: builds a brand-new branching story from a hero, a place and a
/// mystery that the child picks. Every sentence comes from pieces written and
/// checked in advance, so a made story is as safe as the others, and nothing
/// is ever sent off the phone. Made stories are not saved.

class MakerHero {
  const MakerHero(this.id, this.name, this.intro);

  final String id;

  /// Used through the story, for example "Kiko".
  final String name;

  /// Used once, at the start, for example "Kiko the young astronaut".
  final String intro;
}

class MakerPlace {
  const MakerPlace({
    required this.id,
    required this.name,
    required this.scene,
    required this.friend,
    required this.pictures,
  });

  final String id;

  /// With "the" if it needs it, for example "the Deep Blue Sea".
  final String name;

  /// One or two sentences that set the scene.
  final String scene;

  /// A local friend, for example "octopus".
  final String friend;

  /// For the start, the middle and the endings.
  final (ScenePicture, ScenePicture, ScenePicture) pictures;
}

/// A problem, and the science that solves it. Texts may use {hero}, {place}
/// and {friend}, which are filled in when the story is made.
class MakerMystery {
  const MakerMystery({
    required this.id,
    required this.title,
    required this.problem,
    required this.lookChoice,
    required this.look,
    required this.askChoice,
    required this.ask,
    required this.scienceChoice,
    required this.science,
    required this.endings,
  });

  final String id;
  final String title;
  final String problem;
  final String lookChoice;
  final String look;
  final String askChoice;
  final String ask;
  final String scienceChoice;
  final String science;

  /// Another good idea, teamwork, and a bigger discovery.
  final List<MakerEnding> endings;
}

class MakerEnding {
  const MakerEnding(this.choice, this.title, this.text, this.discovery);

  final String choice;
  final String title;
  final String text;
  final String discovery;
}

abstract final class StoryMaker {
  static const heroes = [
    MakerHero('kiko', 'Kiko', 'Kiko the young astronaut'),
    MakerHero('tali', 'Tali', 'Tali the brave turtle'),
    MakerHero('nova', 'Nova', 'Nova the little robot'),
    MakerHero('ziggy', 'Ziggy', 'Ziggy the curious zebra'),
    MakerHero('pom', 'Professor Pom', 'Professor Pom the penguin'),
    MakerHero('luna', 'Luna', 'Luna the owl'),
    MakerHero('max', 'Max', 'Max the explorer mouse'),
    MakerHero('bree', 'Bree', 'Bree the busy bee'),
  ];

  static const places = [
    MakerPlace(
      id: 'sea',
      name: 'the Deep Blue Sea',
      scene: 'Bubbles drifted past, and bright fish flashed by in shoals.',
      friend: 'octopus',
      pictures: (
        ScenePicture.whaleSea,
        ScenePicture.whaleReef,
        ScenePicture.whaleSong,
      ),
    ),
    MakerPlace(
      id: 'forest',
      name: 'Whispering Wood',
      scene: 'Tall trees creaked, and a stream sparkled between the ferns.',
      friend: 'squirrel',
      pictures: (
        ScenePicture.forestStream,
        ScenePicture.forestOak,
        ScenePicture.forestRainbow,
      ),
    ),
    MakerPlace(
      id: 'mars',
      name: 'the red plains of Mars',
      scene: 'Red dust swirled over the rocks under a pale, pinkish sky.',
      friend: 'rover',
      pictures: (
        ScenePicture.robotDust,
        ScenePicture.robotPanel,
        ScenePicture.robotSun,
      ),
    ),
    MakerPlace(
      id: 'ice',
      name: 'the Frosty North',
      scene: 'Snow sparkled, and every breath puffed out like a little cloud.',
      friend: 'walrus',
      pictures: (
        ScenePicture.snowHill,
        ScenePicture.snowCrystal,
        ScenePicture.snowSunny,
      ),
    ),
    MakerPlace(
      id: 'meadow',
      name: 'Buttercup Meadow',
      scene:
          'Flowers nodded in the breeze, and bees buzzed from bloom to bloom.',
      friend: 'ladybird',
      pictures: (
        ScenePicture.beeMeadow,
        ScenePicture.beeHive,
        ScenePicture.beeBusy,
      ),
    ),
    MakerPlace(
      id: 'hills',
      name: 'the Starry Hills',
      scene: 'Stars twinkled over the hills, and the Moon glowed softly.',
      friend: 'badger',
      pictures: (
        ScenePicture.starNight,
        ScenePicture.starScope,
        ScenePicture.starMap,
      ),
    ),
    MakerPlace(
      id: 'mountain',
      name: 'Misty Mountain',
      scene: 'Steam curled from warm pools between the snowy rocks.',
      friend: 'mountain goat',
      pictures: (
        ScenePicture.springMountain,
        ScenePicture.springPool,
        ScenePicture.springHappy,
      ),
    ),
    MakerPlace(
      id: 'cliffs',
      name: 'the Fossil Cliffs',
      scene: 'Waves washed over the pebbles below tall, striped cliffs.',
      friend: 'crab',
      pictures: (
        ScenePicture.fossilCliff,
        ScenePicture.fossilBrush,
        ScenePicture.fossilDisplay,
      ),
    ),
  ];

  static const mysteries = [
    MakerMystery(
      id: 'toolbox',
      title: 'the Sunken Toolbox',
      problem:
          'Suddenly, {hero} heard a clatter. The explorers\' toolbox had '
          'tipped into a deep, narrow crack, and nobody could reach it!',
      lookChoice: 'Look closely into the crack',
      look:
          '{hero} peered into the crack. The tools were made of iron: a '
          'hammer, some nails and a little shovel. "Iron," {hero} said '
          'slowly. "What pulls on iron?"',
      askChoice: 'Ask the {friend} for help',
      ask:
          'The {friend} thought hard. "I once saw a magnet pick up a whole '
          'pile of nails," it said. {hero} checked the backpack, and found a '
          'strong magnet and a long piece of string.',
      scienceChoice: 'Lower a magnet on a string',
      science:
          '{hero} tied the magnet to the string and lowered it slowly. Click! '
          'The magnet pulled on the iron tools. Up came the hammer, then the '
          'nails, one by one! Everyone cheered.',
      endings: [
        MakerEnding(
          'Try a long stick with a hook',
          'The Clever Hook',
          'It took a lot of tries, but at last the hook caught the toolbox '
              'handle, and up it came. "Patience works too!" said {hero}.',
          'There is often more than one way to solve a problem. Trying '
              'again and again is part of being a scientist.',
        ),
        MakerEnding(
          'Share the magnet with everyone',
          'The Magnet Team',
          'Everyone in {place} took turns fishing for treasure with the '
              'magnet. It picked up a paper clip and a key, but not a leaf.',
          'Magnets attract iron and steel, but not wood, plastic, paper or '
              'leaves.',
        ),
        MakerEnding(
          'Test what else a magnet can do',
          'The Hidden Compass',
          '{hero} hung the magnet from a thread, and it slowly turned to '
              'point the same way every time. "It is a compass!"',
          'The Earth is like a giant magnet, so a magnet that can swing '
              'freely lines up north and south.',
        ),
      ],
    ),
    MakerMystery(
      id: 'dark_cave',
      title: 'the Dark Cave Map',
      problem:
          'Suddenly, {hero} spotted a cave with a treasure map painted deep '
          'inside. But it was far too dark in there to read it!',
      lookChoice: 'Study the sunlight at the cave mouth',
      look:
          'Bright sunlight shone in a straight beam across the entrance, but '
          'it would not bend around the corner. "Light only travels in '
          'straight lines," {hero} said.',
      askChoice: 'Ask the {friend} what to do',
      ask:
          'The {friend} pointed at a shiny pool of water. "It bounces the '
          'sunlight into my eyes every morning," it said. Then {hero} '
          'remembered a little mirror in the backpack.',
      scienceChoice: 'Bounce the sunlight in with the mirror',
      science:
          '{hero} held the mirror in the sunbeam and tilted it carefully. A '
          'bright spot of light jumped deep into the cave, and there was the '
          'map: a big red X!',
      endings: [
        MakerEnding(
          'Light a lantern instead',
          'The Lantern Path',
          '{hero} lit a lantern and walked into the cave slowly and safely. '
              'The map glowed in its warm light. The treasure was a box of '
              'shining crystals!',
          'A lantern makes its own light. Without any light at all, our '
              'eyes cannot see a thing.',
        ),
        MakerEnding(
          'Make a chain of mirrors with friends',
          'The Mirror Chain',
          'Everyone held a shiny thing in a row, and passed the light from '
              'one to the next, right around the corners!',
          'Mirrors reflect light, so a row of them can carry light around '
              'corners.',
        ),
        MakerEnding(
          'Look at the crystals in the light',
          'The Hidden Rainbow',
          'When the light hit the crystals, a rainbow spread across the cave '
              'wall! "The light was hiding colours all along," said {hero}.',
          'White sunlight is made of all the colours, and crystals can split '
              'it into a rainbow.',
        ),
      ],
    ),
    MakerMystery(
      id: 'wilting_plants',
      title: 'the Droopy Plants',
      problem:
          'Suddenly, {hero} noticed the special glow-berry plants were pale '
          'and droopy. The friends of {place} were worried!',
      lookChoice: 'Look closely at the plants',
      look:
          'A big sheet had blown over the plants in the storm, and they had '
          'been in the dark for days. "Plants use sunlight to make their '
          'food," said {hero}.',
      askChoice: 'Ask the {friend} what happened',
      ask:
          'The {friend} pointed up. "Ever since the big storm, they have been '
          'covered by that old sheet," it said. "Could that be why?"',
      scienceChoice: 'Pull the sheet off and let the sun in',
      science:
          'Together they pulled the sheet away, and warm sunlight poured onto '
          'the leaves. Day by day, the plants grew green and strong again.',
      endings: [
        MakerEnding(
          'Give them a drink of water too',
          'The Thirsty Roots',
          '{hero} gave the roots a drink, just enough, not too much. Soon the '
              'plants stood tall, with shiny new berries.',
          'Plants need sunlight, water, air and nutrients from the soil to '
              'grow well.',
        ),
        MakerEnding(
          'Build a shelter for the next storm',
          'The Storm Shelter',
          'Everyone built a fence to stop sheets blowing over again, leaving '
              'plenty of room for the sun.',
          'Working together and planning ahead helps protect living things.',
        ),
        MakerEnding(
          'Watch which way the plants grow',
          'Turning to the Sun',
          'Over the next week, {hero} noticed the plants all leaning towards '
              'the bright side. "They are reaching for the light!"',
          'Plants grow towards light, so their leaves can catch as much '
              'sunshine as possible.',
        ),
      ],
    ),
    MakerMystery(
      id: 'lost_friend',
      title: 'the Lost Little One',
      problem:
          'Suddenly, a small voice squeaked from somewhere far away. A little '
          'friend was lost in {place}, and nobody could see where!',
      lookChoice: 'Listen very carefully',
      look:
          '{hero} closed their eyes and listened. The squeak came from the '
          'left, faint but clear. "Sound travels out in all directions," '
          '{hero} said. "So we can follow it!"',
      askChoice: 'Ask the {friend} to help search',
      ask:
          '"I have very good ears," said the {friend}. "If we are quiet, we '
          'can hear which way the sound comes from. Then call back, loud and '
          'clear!"',
      scienceChoice: 'Call out, then follow the reply',
      science:
          '{hero} cupped their hands and called. The little one called back, '
          'louder now. Step by step they followed the sound, until there it '
          'was, safe and sound, behind a rock!',
      endings: [
        MakerEnding(
          'Leave a trail of pebbles home',
          'The Pebble Trail',
          'On the way back, {hero} left a trail of pebbles, so the little one '
              'could always find the way home.',
          'Leaving clear markers is a good way to find your way back.',
        ),
        MakerEnding(
          'Hold a big search party',
          'The Search Party',
          'Everyone in {place} spread out, calling and listening, and '
              'cheered when the little one was found.',
          'Many ears are better than one! Teamwork helps in any search.',
        ),
        MakerEnding(
          'Shout towards the cliffs',
          'The Echo',
          '{hero} shouted towards a rocky wall, and a moment later, the '
              'shout came back! "Hello, hello, hello!"',
          'An echo is a sound bouncing back off a hard surface, like a rocky '
              'wall.',
        ),
      ],
    ),
    MakerMystery(
      id: 'river_crossing',
      title: 'the Wide River',
      problem:
          'Suddenly, {hero} saw a precious seed pod stuck on the far side of '
          'a wide river. It had to be carried across, without getting wet!',
      lookChoice: 'Watch what floats down the river',
      look:
          'Leaves and sticks bobbed past on the water, but a pebble sank '
          'straight down. "Wood floats," said {hero}. "It is lighter than the '
          'same amount of water."',
      askChoice: 'Ask the {friend} for ideas',
      ask:
          '"Beavers build with logs," said the {friend}. "And logs always '
          'float. Maybe you could build a raft?"',
      scienceChoice: 'Build a raft from sticks and logs',
      science:
          '{hero} tied sticks and logs together with grass. The raft floated '
          'beautifully! Across it went, and back with the seed pod, dry and '
          'safe.',
      endings: [
        MakerEnding(
          'Find the stepping stones',
          'The Stepping Stones',
          'Further along, {hero} found big flat stones across the river, and '
              'hopped carefully from one to the next.',
          'Looking around for another way is a great way to solve a problem.',
        ),
        MakerEnding(
          'Make a bigger raft for friends',
          'The Friendship Raft',
          'Everyone helped build a big raft, and they all floated across '
              'together, singing.',
          'A bigger raft can carry more, as long as it pushes aside enough '
              'water.',
        ),
        MakerEnding(
          'Wonder how heavy boats float',
          'The Floating Boat',
          'A huge metal boat sailed past. "How does heavy metal float?" '
              'asked {hero}. "Its shape pushes aside lots of water!"',
          'A boat floats when it pushes aside water that weighs as much as '
              'the boat. That is why shape matters.',
        ),
      ],
    ),
    MakerMystery(
      id: 'dry_pond',
      title: 'the Disappearing Pond',
      problem:
          'Suddenly, {hero} saw that the little pond was nearly empty! It had '
          'been hot and sunny for days, and the pond was getting smaller.',
      lookChoice: 'Measure the pond each day',
      look:
          'Each day, {hero} put a pebble at the edge. Each day, the water was '
          'further away. "The sun is warming it into vapour," said {hero}. '
          '"It is going up into the air!"',
      askChoice: 'Ask the {friend} about the weather',
      ask:
          '"I can smell rain coming," said the {friend}. "Look at those big '
          'grey clouds. Water goes up, and water comes down."',
      scienceChoice: 'Catch the rain when it comes',
      science:
          'Everyone set out leaves and shells to catch the rain, and a big '
          'cloud drifted over. Pitter-patter! The rain poured into the pond '
          'until it was full again.',
      endings: [
        MakerEnding(
          'Shade the pond with branches',
          'The Shady Pond',
          '{hero} propped up leafy branches to shade the pond. In the shade, '
              'the water dried up much more slowly.',
          'Water evaporates faster in warm sunshine, so shade helps keep it.',
        ),
        MakerEnding(
          'Share the water fairly',
          'Fair Shares',
          'Everyone agreed to use the water carefully until the rain came. '
              'Nobody went thirsty.',
          'Water is precious, and sharing it carefully helps everyone.',
        ),
        MakerEnding(
          'Follow the water\'s journey',
          'The Water Cycle',
          '{hero} drew a circle: sun warms water, vapour rises, clouds form, '
              'rain falls, ponds fill. "It goes round and round!"',
          'This is the water cycle. The same water has been going round and '
              'round for millions of years.',
        ),
      ],
    ),
    MakerMystery(
      id: 'dark_lantern',
      title: 'the Lantern That Went Out',
      problem:
          'Suddenly, the big lantern that lit up {place} at night flickered '
          'and went out. Night was coming!',
      lookChoice: 'Check the wires',
      look:
          '{hero} followed the wire from the battery to the bulb, and found a '
          'gap where it had snapped. "Electricity needs a complete loop," '
          '{hero} said.',
      askChoice: 'Ask the {friend} if it saw anything',
      ask:
          '"A gust of wind shook the lantern last night," said the {friend}. '
          '"I heard a snap!" {hero} took a closer look, and spotted a '
          'broken wire.',
      scienceChoice: 'Join the gap with a piece of metal',
      science:
          '{hero} found a spare piece of copper wire and joined the gap. The '
          'loop was complete, and the lantern shone brightly again!',
      endings: [
        MakerEnding(
          'Try a new battery too',
          'The Fresh Battery',
          '{hero} put in a fresh battery as well, and the lantern glowed '
              'brighter than ever.',
          'A battery stores energy and pushes electricity around a circuit.',
        ),
        MakerEnding(
          'Ask a grown-up to check it is safe',
          'Safety First',
          'A grown-up checked the lantern and covered the join with tape. '
              '"Safe and bright!" Everyone cheered.',
          'Only grown-ups should fix real electrics, and they always switch '
              'the power off first.',
        ),
        MakerEnding(
          'Test what else completes the loop',
          'Conductor Hunt',
          '{hero} tried a key, a spoon, a leaf and a rubber band. The key '
              'and spoon worked, but the leaf and band did not!',
          'Metals are conductors, which let electricity through. Rubber and '
              'leaves are insulators, which do not.',
        ),
      ],
    ),
    MakerMystery(
      id: 'heavy_rock',
      title: 'the Rock in the Road',
      problem:
          'Suddenly, {hero} found a huge rock blocking the only path through '
          '{place}. It was far too heavy to push!',
      lookChoice: 'Look around for something useful',
      look:
          '{hero} spotted a long, strong branch and a small, flat stone. '
          '"With a long lever," {hero} said, "a small push can lift something '
          'heavy."',
      askChoice: 'Ask the {friend} for help',
      ask:
          '"When I sit on one end of a log, my little cousins go flying up '
          'at the other end!" laughed the {friend}. That gave {hero} an idea.',
      scienceChoice: 'Make a lever with the branch',
      science:
          '{hero} slid the branch under the rock and rested it on the small '
          'stone. One push on the long end, and the rock rolled away! The '
          'path was clear.',
      endings: [
        MakerEnding(
          'Walk around it instead',
          'The New Path',
          '{hero} found a winding path around the rock. It took longer, but '
              'it passed a beautiful waterfall!',
          'Sometimes going around a problem works just as well as moving it.',
        ),
        MakerEnding(
          'Push all together',
          'All Together',
          'Everyone pushed on the lever together, and the rock rolled away '
              'with a mighty thud.',
          'Many small pushes together can do what one push cannot.',
        ),
        MakerEnding(
          'Find other levers nearby',
          'Levers Everywhere',
          '{hero} found levers everywhere: a seesaw, a bottle opener, even '
              'scissors! "They are all around us," said {hero}.',
          'A lever turns a small push into a big lift. Seesaws and scissors '
              'use levers.',
        ),
      ],
    ),
  ];

  /// How many different stories can be made.
  static int get combinations =>
      heroes.length * places.length * mysteries.length;

  /// Picks a hero, a place and a mystery at random.
  static (MakerHero, MakerPlace, MakerMystery) surprise(Random random) => (
    heroes[random.nextInt(heroes.length)],
    places[random.nextInt(places.length)],
    mysteries[random.nextInt(mysteries.length)],
  );

  /// Builds the story. It has seven scenes, three endings and real choices.
  static Story make(MakerHero hero, MakerPlace place, MakerMystery mystery) {
    String fill(String text) {
      final out = text
          .replaceAll('{hero}', hero.name)
          .replaceAll('{place}', place.name)
          .replaceAll('{friend}', place.friend);
      // A sentence can start with a place such as "the Deep Blue Sea".
      return out.replaceAllMapped(
        RegExp(r'(^|[.!?]["”]? )the '),
        (m) => '${m[1]}The ',
      );
    }

    final (start, middle, end) = place.pictures;
    final [other, team, discovery] = mystery.endings;
    StoryScene ending(String id, MakerEnding e) => StoryScene(
      id: id,
      title: e.title,
      picture: end,
      text: fill(e.text),
      ending: StoryEnding(id: id, title: e.title, discovery: e.discovery),
    );

    return Story(
      id: 'made-${hero.id}-${place.id}-${mystery.id}',
      title: '${hero.name} and ${_capitalise(mystery.title)}',
      tagline: 'A story made just for you.',
      cover: start,
      intro:
          'Here is a brand-new story, made just for you. You decide what '
          'happens next!',
      startSceneId: 'start',
      remember: false,
      scenes: [
        StoryScene(
          id: 'start',
          title: _capitalise(mystery.title),
          picture: start,
          text: fill(
            '${hero.intro} was exploring {place}. ${place.scene} '
            '${mystery.problem}',
          ),
          choices: [
            StoryChoice(
              id: 'look',
              text: fill(mystery.lookChoice),
              nextSceneId: 'look',
              consequence: fill('{hero} took a closer look.'),
            ),
            StoryChoice(
              id: 'ask',
              text: fill(mystery.askChoice),
              nextSceneId: 'ask',
              consequence: fill('{hero} went to find the {friend}.'),
            ),
          ],
        ),
        StoryScene(
          id: 'look',
          title: 'A Closer Look',
          picture: middle,
          text: fill(mystery.look),
          choices: [
            StoryChoice(
              id: 'science_from_look',
              text: fill(mystery.scienceChoice),
              nextSceneId: 'science',
              consequence: fill('{hero} got to work.'),
            ),
            StoryChoice(
              id: 'other',
              text: fill(other.choice),
              nextSceneId: 'other',
              consequence: fill('{hero} tried another idea.'),
            ),
          ],
        ),
        StoryScene(
          id: 'ask',
          title: 'A Friend Helps',
          picture: start,
          text: fill(mystery.ask),
          choices: [
            StoryChoice(
              id: 'science_from_ask',
              text: fill(mystery.scienceChoice),
              nextSceneId: 'science',
              consequence: fill('{hero} and the {friend} got to work.'),
            ),
            StoryChoice(
              id: 'team',
              text: fill(team.choice),
              nextSceneId: 'team',
              consequence: fill('{hero} called everyone together.'),
            ),
          ],
        ),
        StoryScene(
          id: 'science',
          title: 'Science Saves the Day',
          picture: middle,
          text: fill(mystery.science),
          choices: [
            StoryChoice(
              id: 'discovery',
              text: fill(discovery.choice),
              nextSceneId: 'discovery',
              consequence: fill('{hero} was curious to find out more.'),
            ),
            StoryChoice(
              id: 'celebrate',
              text: fill(team.choice),
              nextSceneId: 'team',
              consequence: fill('{hero} called everyone together.'),
            ),
          ],
        ),
        ending('other', other),
        ending('team', team),
        ending('discovery', discovery),
      ],
    );
  }

  static String _capitalise(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
