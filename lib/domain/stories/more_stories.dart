import 'story.dart';
import 'story_content.dart';

/// Every story in the app, starter ones first.
const allStories = <Story>[...starterStories, ...moreStories];

/// Ten more stories. As with the starter stories: original characters and
/// places, nothing scary, real science woven in, and every ending a good one.
/// Each has seven scenes and three endings.
const moreStories = <Story>[
  _whale,
  _snow,
  _dance,
  _bubbles,
  _stars,
  _spring,
  _seed,
  _robot,
  _fossil,
  _monarchs,
];

// ------------------------------------------------------------------ Story 4

const _whale = Story(
  id: 'whale_song',
  title: 'The Whale Who Lost Her Song',
  tagline: 'Help young Coral find her voice across the sea.',
  cover: ScenePicture.whaleSong,
  intro:
      'Deep in the blue Sapphire Sea, a young whale called Coral was learning '
      'to sing. But today her family has swum far away, and she cannot hear '
      'them. Let us help her, and you decide what happens next.',
  startSceneId: 'quiet_sea',
  scenes: [
    StoryScene(
      id: 'quiet_sea',
      title: 'A Quiet Sea',
      picture: ScenePicture.whaleSea,
      text:
          'Coral floated alone in the blue water. "I sang, but nobody '
          'answered," she said. Pip the little pilot fish swam by. "Sound '
          'travels a very long way underwater," said Pip. "Far faster than in '
          'air! Maybe you need a better place to sing." Coral looked down at '
          'the dark, deep water, then up at the bright reef nearby.',
      choices: [
        StoryChoice(
          id: 'dive_deep',
          text: 'Dive down to the deep water',
          nextSceneId: 'deep_channel',
          consequence: 'You and Coral glided down, down, down.',
        ),
        StoryChoice(
          id: 'visit_reef',
          text: 'Swim to the bright coral reef',
          nextSceneId: 'busy_reef',
          consequence: 'You and Coral swam towards the colourful reef.',
        ),
      ],
    ),
    StoryScene(
      id: 'deep_channel',
      title: 'The Deep Channel',
      picture: ScenePicture.whaleReef,
      text:
          'Down here the water was calm and still. Coral hummed a low note, '
          'and it rolled away into the blue. "Low sounds can travel hundreds '
          'of kilometres," said Pip. Coral could sing louder here, or she '
          'could stop and listen carefully for a reply.',
      choices: [
        StoryChoice(
          id: 'sing_loud',
          text: 'Sing the lowest note she can',
          nextSceneId: 'family_found',
          consequence: 'Coral took a deep breath and sang.',
        ),
        StoryChoice(
          id: 'listen',
          text: 'Stop and listen very carefully',
          nextSceneId: 'faint_echo',
          consequence: 'Everyone stayed still and listened.',
        ),
      ],
    ),
    StoryScene(
      id: 'busy_reef',
      title: 'The Busy Reef',
      picture: ScenePicture.whaleReef,
      text:
          'The reef crackled and popped with life! Tiny shrimp snapped their '
          'claws, and fish chattered. "It is so noisy here," said Coral. An '
          'old sea turtle paddled past. "I passed your family near the warm '
          'current," she said. "Or you could ask the dolphins. They are very '
          'good at sending messages."',
      choices: [
        StoryChoice(
          id: 'ask_dolphins',
          text: 'Ask the dolphins to pass on a message',
          nextSceneId: 'dolphin_relay',
          consequence: 'A pod of dolphins came clicking and whistling.',
        ),
        StoryChoice(
          id: 'warm_current',
          text: 'Follow the warm current',
          nextSceneId: 'faint_echo',
          consequence: 'The warm water carried you along gently.',
        ),
      ],
    ),
    StoryScene(
      id: 'faint_echo',
      title: 'A Faint Echo',
      picture: ScenePicture.whaleReef,
      text:
          'Very faintly, a long, low song drifted through the water. '
          '"That is Grandmother!" Coral cried. "Each group of whales has its '
          'own song," said Pip. "That is how you know it is yours." Coral '
          'could swim straight towards it, or sing the family song back.',
      choices: [
        StoryChoice(
          id: 'swim_to_song',
          text: 'Swim towards the song',
          nextSceneId: 'long_swim',
          consequence: 'Coral swam on, following the sound.',
        ),
        StoryChoice(
          id: 'sing_back',
          text: 'Sing the family song back',
          nextSceneId: 'family_found',
          consequence: 'Coral sang, and her song rolled away through the sea.',
        ),
      ],
    ),
    StoryScene(
      id: 'family_found',
      title: 'Together Again',
      picture: ScenePicture.whaleSong,
      text:
          'Far across the sea, the family heard Coral, and they sang back! '
          'Their voices came closer and closer, until huge friendly shapes '
          'appeared in the blue. Coral nuzzled her grandmother, and they all '
          'sang together.',
      ending: StoryEnding(
        id: 'family_song',
        title: 'The Family Song',
        discovery:
            'Low sounds travel a very long way through water, so whales can '
            'call to each other across huge distances.',
      ),
    ),
    StoryScene(
      id: 'dolphin_relay',
      title: 'The Dolphin Relay',
      picture: ScenePicture.whaleSong,
      text:
          'The dolphins raced off, passing the message from pod to pod. '
          'Before long, Coral\'s family came swimming over the horizon, led '
          'by a dolphin doing happy flips. "You are never alone in the sea," '
          'said Grandmother, "as long as you have friends."',
      ending: StoryEnding(
        id: 'dolphin_friends',
        title: 'Friends Across the Sea',
        discovery:
            'Dolphins use clicks and whistles to talk, and many sea animals '
            'live in groups and help each other.',
      ),
    ),
    StoryScene(
      id: 'long_swim',
      title: 'The Long Swim',
      picture: ScenePicture.whaleSong,
      text:
          'Coral swam for hours, stopping at the surface to breathe through '
          'her blowhole. Whoosh! The song grew louder with every stroke. At '
          'last, she saw her family ahead. "You followed your ears all the '
          'way here," laughed Grandmother. "You are growing up!"',
      ending: StoryEnding(
        id: 'follow_ears',
        title: 'Following Her Ears',
        discovery:
            'Whales are mammals, so they breathe air at the surface, and they '
            'rely on sound to find their way in the sea.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story 5

const _snow = Story(
  id: 'snowflake_secret',
  title: 'The Secret of the Six-Sided Snowflake',
  tagline: 'Join Nell the fox on a frosty science adventure.',
  cover: ScenePicture.snowCrystal,
  intro:
      'High in the snowy north, Nell the Arctic fox has noticed something '
      'odd. Every snowflake that lands on her nose has exactly six sides. '
      'Let us find out why, and you decide what happens next.',
  startSceneId: 'first_snow',
  scenes: [
    StoryScene(
      id: 'first_snow',
      title: 'The First Snow',
      picture: ScenePicture.snowHill,
      text:
          'Soft snow was falling over Frost Hill. Nell caught a flake on her '
          'black nose and peered at it with her magnifying glass. "Six sides '
          'again!" she said. "Why is it always six?" Up on the hill stood the '
          'Weather Hut, and down by the lake old Walrus was mending a sledge.',
      choices: [
        StoryChoice(
          id: 'weather_hut',
          text: 'Climb up to the Weather Hut',
          nextSceneId: 'weather_hut_inside',
          consequence: 'You and Nell climbed through the deep snow.',
        ),
        StoryChoice(
          id: 'ask_walrus',
          text: 'Go down and ask old Walrus',
          nextSceneId: 'lake_walrus',
          consequence: 'You and Nell slid down the hill to the lake.',
        ),
      ],
    ),
    StoryScene(
      id: 'weather_hut_inside',
      title: 'The Weather Hut',
      picture: ScenePicture.snowCrystal,
      text:
          'Inside the hut, Professor Puffin had drawn water on a chalkboard. '
          '"When water freezes, its tiny parts join up in a pattern of six," '
          'the professor said. "So every ice crystal starts with six sides." '
          'Nell wondered what happens next. Should she catch more flakes, or '
          'grow an ice crystal herself?',
      choices: [
        StoryChoice(
          id: 'catch_more',
          text: 'Catch lots of flakes to compare them',
          nextSceneId: 'flake_collection',
          consequence: 'Nell caught flakes on a cold, dark cloth.',
        ),
        StoryChoice(
          id: 'grow_crystal',
          text: 'Try to grow a crystal on the window',
          nextSceneId: 'window_frost',
          consequence: 'Nell breathed on the cold window glass.',
        ),
      ],
    ),
    StoryScene(
      id: 'lake_walrus',
      title: 'Down by the Lake',
      picture: ScenePicture.snowHill,
      text:
          '"Snowflakes? I just shovel them!" Walrus chuckled. "But look at '
          'the frost on my sledge." Feathery patterns spread across the metal '
          'like tiny ferns. "They grow from the air when it is very cold," '
          'said Walrus. The lake had a new sheet of clear ice too.',
      choices: [
        StoryChoice(
          id: 'study_frost',
          text: 'Study the frost on the sledge',
          nextSceneId: 'window_frost',
          consequence: 'Nell got her magnifying glass out again.',
        ),
        StoryChoice(
          id: 'study_lake',
          text: 'Look at the ice on the lake',
          nextSceneId: 'floating_ice',
          consequence: 'You crept up to the edge of the lake with Walrus.',
        ),
      ],
    ),
    StoryScene(
      id: 'flake_collection',
      title: 'No Two Alike',
      picture: ScenePicture.snowCrystal,
      text:
          'Nell laid out twenty flakes. All had six sides, but they all '
          'looked different! Some were plates, and some were stars with long '
          'arms. "Each one takes its own path through the cloud," said '
          'Professor Puffin, "so each one grows a little differently." Nell '
          'wanted to tell everyone.',
      choices: [
        StoryChoice(
          id: 'snow_show',
          text: 'Hold a Snowflake Show for the valley',
          nextSceneId: 'snowflake_show',
          consequence: 'Nell invited everyone in the valley.',
        ),
        StoryChoice(
          id: 'check_frost',
          text: 'Check if frost has six-sided patterns too',
          nextSceneId: 'window_frost',
          consequence: 'Nell trotted over to the frosty window.',
        ),
      ],
    ),
    StoryScene(
      id: 'snowflake_show',
      title: 'The Snowflake Show',
      picture: ScenePicture.snowSunny,
      text:
          'Everyone in the valley came to see Nell\'s drawings of snowflakes. '
          'The little lemmings cheered, and Professor Puffin gave Nell a tiny '
          'medal made of pine cone. "You looked closely," the professor said, '
          '"and that is what scientists do."',
      ending: StoryEnding(
        id: 'no_two_alike',
        title: 'No Two Alike',
        discovery:
            'All snowflakes begin with six sides, but each one takes its own '
            'path through the clouds, so each grows differently.',
      ),
    ),
    StoryScene(
      id: 'window_frost',
      title: 'Crystal Ferns',
      picture: ScenePicture.snowSunny,
      text:
          'Slowly, feathery crystals spread across the cold glass, branching '
          'again and again. "Water vapour in the air turned straight into '
          'ice," said Nell. "It did not even become water first!" She drew '
          'every pattern in her notebook, while the sun rose and made the '
          'frost sparkle.',
      ending: StoryEnding(
        id: 'crystal_ferns',
        title: 'Crystal Ferns',
        discovery:
            'On very cold surfaces, water vapour can turn straight into ice, '
            'growing frost crystals with no liquid water at all.',
      ),
    ),
    StoryScene(
      id: 'floating_ice',
      title: 'The Floating Ice',
      picture: ScenePicture.snowSunny,
      text:
          'Under the clear ice, fish were swimming calmly. "Ice floats!" '
          'said Nell. "Most liquids shrink as they freeze, but water spreads '
          'out in its six-sided pattern, so ice is lighter." Walrus '
          'nodded. "And it keeps the lake below from freezing solid. Handy '
          'for the fish!"',
      ending: StoryEnding(
        id: 'floating_ice',
        title: 'The Ice Blanket',
        discovery:
            'Ice floats because water spreads out as it freezes, and a layer '
            'of ice helps keep the water below it from freezing.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story 6

const _dance = Story(
  id: 'bee_dance',
  title: 'The Bee Who Danced a Map',
  tagline: 'Help Bumble tell the hive about a hidden meadow.',
  cover: ScenePicture.beeHive,
  intro:
      'Bumble the honeybee has found the most wonderful meadow, far beyond '
      'the old stone wall. But how can a little bee tell the whole hive where '
      'it is? Let us find out, and you decide what happens next.',
  startSceneId: 'hidden_meadow',
  scenes: [
    StoryScene(
      id: 'hidden_meadow',
      title: 'The Hidden Meadow',
      picture: ScenePicture.beeMeadow,
      text:
          'Bumble buzzed from flower to flower, full of sweet nectar. "The '
          'whole hive has to see this!" she said. But bees cannot talk. '
          'Back at the hive, Old Queenie was the wisest bee of all. Close by, '
          'a line of ants marched past, following a trail to some food.',
      choices: [
        StoryChoice(
          id: 'fly_home',
          text: 'Fly straight home to Old Queenie',
          nextSceneId: 'old_queenie',
          consequence: 'Bumble zoomed back to the hive as fast as she could.',
        ),
        StoryChoice(
          id: 'watch_ants',
          text: 'Watch how the ants share the news',
          nextSceneId: 'ant_trail',
          consequence: 'Bumble landed on a leaf and watched the ants.',
        ),
      ],
    ),
    StoryScene(
      id: 'old_queenie',
      title: 'Old Queenie',
      picture: ScenePicture.beeHive,
      text:
          '"Use your body, little one," said Old Queenie. "Dance!" She showed '
          'Bumble a figure of eight with a wiggle in the middle. "The angle '
          'of your wiggle points the way, compared to the Sun. The longer you '
          'wiggle, the further away the flowers are." Bumble gulped. The '
          'meadow was very far.',
      choices: [
        StoryChoice(
          id: 'long_dance',
          text: 'Do one long, careful waggle dance',
          nextSceneId: 'long_waggle',
          consequence: 'Bumble began to wiggle in the dark hive.',
        ),
        StoryChoice(
          id: 'scent',
          text: 'Share the scent of the flowers first',
          nextSceneId: 'sweet_scent',
          consequence: 'Bumble shared a drop of nectar with her sisters.',
        ),
      ],
    ),
    StoryScene(
      id: 'ant_trail',
      title: 'The Ant Trail',
      picture: ScenePicture.beeMeadow,
      text:
          '"We leave a scent trail on the ground," said a busy ant. "Everyone '
          'just follows the smell!" Bumble looked at her wings. "But I fly," '
          'she said. "I cannot leave a trail in the air." The ant shrugged. '
          '"Then at least share the smell of your flowers."',
      choices: [
        StoryChoice(
          id: 'share_smell',
          text: 'Fly home and share the smell',
          nextSceneId: 'sweet_scent',
          consequence: 'Bumble flew home, smelling of sweet flowers.',
        ),
        StoryChoice(
          id: 'go_home_late',
          text: 'Fly home and try a dance',
          nextSceneId: 'long_waggle',
          consequence: 'Bumble flew home with a new idea buzzing in her head.',
        ),
      ],
    ),
    StoryScene(
      id: 'sweet_scent',
      title: 'A Sweet Scent',
      picture: ScenePicture.beeHive,
      text:
          'Bumble shared the flower scent, and the other bees sniffed '
          'eagerly. Now they knew what to look for, but not where to go. Some '
          'wanted to set off and search. Others wanted Bumble to lead them '
          'there herself, or dance the way.',
      choices: [
        StoryChoice(
          id: 'lead_them',
          text: 'Lead a small team to the meadow',
          nextSceneId: 'scout_team',
          consequence: 'Bumble flew out in front, with five bees behind her.',
        ),
        StoryChoice(
          id: 'dance_now',
          text: 'Dance the way for the whole hive',
          nextSceneId: 'long_waggle',
          consequence: 'Bumble climbed onto the honeycomb and began.',
        ),
        StoryChoice(
          id: 'make_honey',
          text: 'Help turn the nectar into honey',
          nextSceneId: 'honey_store',
          consequence: 'Bumble joined the busy house bees inside the hive.',
        ),
      ],
    ),
    StoryScene(
      id: 'long_waggle',
      title: 'The Great Waggle Dance',
      picture: ScenePicture.beeBusy,
      text:
          'Bumble wiggled and turned, over and over. Her sisters pressed '
          'close, feeling her steps in the dark. Then, one by one, they flew '
          'straight to the meadow! Soon a stream of bees was carrying nectar '
          'home. "Your dance was a map," said Old Queenie.',
      ending: StoryEnding(
        id: 'dancing_map',
        title: 'The Dancing Map',
        discovery:
            'Honeybees really do a waggle dance. It shows other bees which '
            'way to fly compared to the Sun, and how far to go.',
      ),
    ),
    StoryScene(
      id: 'scout_team',
      title: 'The Scout Team',
      picture: ScenePicture.beeBusy,
      text:
          'Bumble led her team past the old stone wall, and there it was! '
          'The scouts filled up on nectar, and pollen dusted their furry '
          'legs. As they buzzed from bloom to bloom, the meadow grew even '
          'more beautiful. "We carried the pollen," they said, "and the '
          'flowers will make seeds."',
      ending: StoryEnding(
        id: 'pollen_helpers',
        title: 'The Pollen Helpers',
        discovery:
            'As bees collect nectar, pollen sticks to their furry bodies. '
            'Carrying it from flower to flower helps plants make seeds.',
      ),
    ),
    StoryScene(
      id: 'honey_store',
      title: 'Honey for Winter',
      picture: ScenePicture.beeBusy,
      text:
          'Bumble passed the nectar to the house bees, who fanned it with '
          'their wings. Hour by hour, it grew thick and golden, and the '
          'bees sealed it into the honeycomb with wax. "This will keep us '
          'fed all winter," said Old Queenie. Bumble smiled. A meadow in '
          'the sun had become a store of sunshine.',
      ending: StoryEnding(
        id: 'winter_honey',
        title: 'Honey for Winter',
        discovery:
            'Bees make honey by fanning nectar until most of its water '
            'dries out, then store it in wax cells to eat in winter.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story 7

const _bubbles = Story(
  id: 'bubble_dragon',
  title: 'The Dragon Who Sneezed Bubbles',
  tagline: 'Find out why Zephyr\'s sneezes are full of surprises.',
  cover: ScenePicture.bubbleRainbow,
  intro:
      'In a warm cave lives Zephyr, a small, gentle dragon. Every dragon '
      'sneezes sparks, except Zephyr, who sneezes bubbles! Zephyr wishes they '
      'would last longer. Let us help, and you decide what happens next.',
  startSceneId: 'big_sneeze',
  scenes: [
    StoryScene(
      id: 'big_sneeze',
      title: 'A Big Sneeze',
      picture: ScenePicture.bubbleCave,
      text:
          '"A-CHOO!" A stream of shining bubbles floated through the cave. '
          'Each one was perfectly round. Then, pop, pop, pop, they were gone. '
          '"Why do they pop so fast?" sighed Zephyr. In the corner, Mole had a '
          'jar of soapy water. Outside, a cool, misty morning had begun.',
      choices: [
        StoryChoice(
          id: 'ask_mole',
          text: 'Ask Mole about the soapy water',
          nextSceneId: 'soapy_jar',
          consequence: 'Mole held the jar up, and it wobbled and shone.',
        ),
        StoryChoice(
          id: 'go_outside',
          text: 'Try sneezing outside in the mist',
          nextSceneId: 'misty_morning',
          consequence: 'Zephyr padded outside, and you followed.',
        ),
      ],
    ),
    StoryScene(
      id: 'soapy_jar',
      title: 'The Soapy Jar',
      picture: ScenePicture.bubbleBig,
      text:
          '"A bubble is a thin skin of soapy water with air inside," said '
          'Mole. "The skin pulls itself tight, like a stretchy balloon. That '
          'is why it goes round." Mole added a drop of syrup. "Or we could '
          'try a bigger wand," Mole said, holding up a loop of wire.',
      choices: [
        StoryChoice(
          id: 'add_syrup',
          text: 'Mix in the sticky syrup',
          nextSceneId: 'strong_bubbles',
          consequence: 'You stirred slowly, so it would not get foamy.',
        ),
        StoryChoice(
          id: 'big_wand',
          text: 'Try the big wire wand',
          nextSceneId: 'giant_bubble',
          consequence: 'Zephyr took a very, very deep breath.',
        ),
      ],
    ),
    StoryScene(
      id: 'misty_morning',
      title: 'The Misty Morning',
      picture: ScenePicture.bubbleBig,
      text:
          'Zephyr sneezed into the damp air, and the bubbles floated much '
          'longer! "Bubbles pop when their water dries up," said Mole, '
          'hurrying out behind you. "Damp air slows that down." The sun was '
          'coming up now, and the first bubbles began to show pale colours.',
      choices: [
        StoryChoice(
          id: 'watch_colours',
          text: 'Watch the colours in the bubbles',
          nextSceneId: 'bubble_colours',
          consequence: 'You all sat on a rock and watched.',
        ),
        StoryChoice(
          id: 'more_bubbles',
          text: 'Make the biggest bubble ever',
          nextSceneId: 'giant_bubble',
          consequence: 'Mole fetched the big wire wand.',
        ),
      ],
    ),
    StoryScene(
      id: 'giant_bubble',
      title: 'The Giant Bubble',
      picture: ScenePicture.bubbleBig,
      text:
          'Zephyr blew gently, and a wobbling bubble grew and grew, as big as '
          'a boulder! It stretched into long shapes, then pulled itself back '
          'into a ball. "It always wants to be round," said Mole. Should '
          'Zephyr try to make it stronger, or simply watch it float away?',
      choices: [
        StoryChoice(
          id: 'stronger',
          text: 'Make the next one stronger',
          nextSceneId: 'strong_bubbles',
          consequence: 'Mole fetched the syrup.',
        ),
        StoryChoice(
          id: 'let_go',
          text: 'Watch it float into the sunshine',
          nextSceneId: 'bubble_colours',
          consequence: 'The giant bubble drifted up into the morning light.',
        ),
        StoryChoice(
          id: 'ask_round',
          text: 'Ask why it always goes round',
          nextSceneId: 'round_bubbles',
          consequence: 'Zephyr sat down beside Mole to think about it.',
        ),
      ],
    ),
    StoryScene(
      id: 'strong_bubbles',
      title: 'The Strongest Bubbles',
      picture: ScenePicture.bubbleRainbow,
      text:
          'The syrup slowed down the drying, and Zephyr\'s new bubbles '
          'lasted and lasted. They bounced softly off Mole\'s nose! All the '
          'animals came to play. "You are the best dragon in the whole '
          'mountain," said the rabbits.',
      ending: StoryEnding(
        id: 'lasting_bubbles',
        title: 'The Lasting Bubbles',
        discovery:
            'Bubbles pop when their thin skin of water dries out, so sticky '
            'syrup helps them last longer.',
      ),
    ),
    StoryScene(
      id: 'bubble_colours',
      title: 'Rainbow Bubbles',
      picture: ScenePicture.bubbleRainbow,
      text:
          'In the sunshine, swirls of pink, gold and green slid across the '
          'bubbles. "The skin is so thin that it splits light into colours," '
          'Mole said softly. Zephyr laughed and sneezed again. Now the whole '
          'valley shimmered with tiny rainbows. Sparks were never this '
          'pretty!',
      ending: StoryEnding(
        id: 'rainbow_sneeze',
        title: 'The Rainbow Sneeze',
        discovery:
            'Colours swirl on bubbles because light bounces off both sides of '
            'the very thin soapy skin.',
      ),
    ),
    StoryScene(
      id: 'round_bubbles',
      title: 'Why Bubbles Are Round',
      picture: ScenePicture.bubbleRainbow,
      text:
          '"Why does it always go back to a ball?" asked Zephyr. Mole '
          'smiled. "The skin pulls itself as tight as it can. A ball '
          'holds the most air inside the smallest skin." Zephyr tried to '
          'sneeze a square bubble, and laughed as it wobbled back into a '
          'ball. Some things just know their shape!',
      ending: StoryEnding(
        id: 'ball_shape',
        title: 'The Perfect Ball',
        discovery:
            'Bubbles are round because their stretchy skin pulls tight, and '
            'a ball holds the most air inside the least skin.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story 8

const _stars = Story(
  id: 'star_library',
  title: 'The Library of Old Starlight',
  tagline: 'Discover how looking up means looking back in time.',
  cover: ScenePicture.starMap,
  intro:
      'On a hill stands a tall tower where Stella the owl keeps watch over '
      'the night sky. Tonight, one of her star maps does not match the sky. '
      'Let us find out why, and you decide what happens next.',
  startSceneId: 'tower_night',
  scenes: [
    StoryScene(
      id: 'tower_night',
      title: 'The Star Tower',
      picture: ScenePicture.starNight,
      text:
          'Stella spread her oldest star map across the floor. "How strange," '
          'she hooted. "The stars in the Great Bear seem to have moved a '
          'tiny bit." In the corner stood a long brass telescope. Beside it, '
          'a shelf held thousands of notebooks from all the owls before her.',
      choices: [
        StoryChoice(
          id: 'telescope',
          text: 'Look through the brass telescope',
          nextSceneId: 'telescope_view',
          consequence: 'You and Stella swung the telescope towards the sky.',
        ),
        StoryChoice(
          id: 'notebooks',
          text: 'Read the old notebooks',
          nextSceneId: 'old_notebooks',
          consequence: 'Stella pulled down a dusty notebook.',
        ),
      ],
    ),
    StoryScene(
      id: 'telescope_view',
      title: 'Through the Telescope',
      picture: ScenePicture.starScope,
      text:
          'Thousands more stars appeared! "Light from these stars left them '
          'long ago," said Stella. "Some of it has travelled for hundreds of '
          'years to reach your eye." You gasped. So you were looking back in '
          'time! One very bright light shone near the horizon. A fuzzy patch '
          'glowed above it.',
      choices: [
        StoryChoice(
          id: 'bright_star',
          text: 'Point at the very bright light',
          nextSceneId: 'not_a_star',
          consequence: 'You turned the telescope a little to the left.',
        ),
        StoryChoice(
          id: 'fuzzy_patch',
          text: 'Point at the fuzzy patch of light',
          nextSceneId: 'far_galaxy',
          consequence: 'You turned the telescope up towards the glow.',
        ),
      ],
    ),
    StoryScene(
      id: 'old_notebooks',
      title: 'The Old Notebooks',
      picture: ScenePicture.starScope,
      text:
          'The notebook was a thousand years old, and its stars were in '
          'slightly different places. "Stars are moving all the time," said '
          'Stella, "but they are so far away that it takes ages to notice." '
          'You could copy the stars onto a new map, or go to look for a '
          'blinking light outside.',
      choices: [
        StoryChoice(
          id: 'new_map',
          text: 'Draw a brand new star map',
          nextSceneId: 'new_star_map',
          consequence: 'Stella sharpened a fresh feather pen.',
        ),
        StoryChoice(
          id: 'bright_light',
          text: 'Go and see the bright light',
          nextSceneId: 'not_a_star',
          consequence: 'You followed Stella up to the balcony.',
        ),
      ],
    ),
    StoryScene(
      id: 'not_a_star',
      title: 'Not a Star at All',
      picture: ScenePicture.starScope,
      text:
          'The light did not twinkle like the others. It shone with a steady '
          'glow. "Stars twinkle because their tiny points of light are '
          'jiggled by our air," said Stella. "That is the planet Venus!" Now '
          'you wanted to explore further, or to mark everything you had found.',
      choices: [
        StoryChoice(
          id: 'look_further',
          text: 'Look further out into space',
          nextSceneId: 'far_galaxy',
          consequence: 'You swung the telescope as far as it would go.',
        ),
        StoryChoice(
          id: 'mark_map',
          text: 'Mark it all on a new map',
          nextSceneId: 'new_star_map',
          consequence: 'You spread a clean sheet across the floor.',
        ),
        StoryChoice(
          id: 'just_eyes',
          text: 'Put the telescope down and just look up',
          nextSceneId: 'shooting_star',
          consequence: 'You stepped out into the cool, dark night.',
        ),
      ],
    ),
    StoryScene(
      id: 'far_galaxy',
      title: 'The Far Galaxy',
      picture: ScenePicture.starMap,
      text:
          '"That patch is a whole galaxy of stars," Stella whispered. "Its '
          'light left over two million years ago, before there were any '
          'people to see it. And tonight, it landed in your eye." You stood '
          'very still, looking up at the oldest light you had ever seen.',
      ending: StoryEnding(
        id: 'oldest_light',
        title: 'The Oldest Light',
        discovery:
            'Light takes time to travel. The Andromeda galaxy is so far away '
            'that we see it as it was over two million years ago.',
      ),
    ),
    StoryScene(
      id: 'new_star_map',
      title: 'A New Star Map',
      picture: ScenePicture.starMap,
      text:
          'By dawn, the new map was finished, with Venus marked in gold. '
          'Stella gave you a new title in the book of owls: Star Friend. '
          '"In a thousand years," she said, "someone will read this, '
          'and see how the sky has changed."',
      ending: StoryEnding(
        id: 'star_friend',
        title: 'Star Friend',
        discovery:
            'Stars move very slowly across the sky. Careful records help '
            'scientists see changes that take many lifetimes.',
      ),
    ),
    StoryScene(
      id: 'shooting_star',
      title: 'A Streak of Light',
      picture: ScenePicture.starMap,
      text:
          'You and Stella stepped out onto the balcony, and let your eyes '
          'get used to the dark. Then, whoosh! A bright streak flashed '
          'across the sky. "A shooting star!" you gasped. Stella hooted '
          'softly. "It is not a star at all. It is a speck of space dust, '
          'burning up high in our air."',
      ending: StoryEnding(
        id: 'shooting_star',
        title: 'The Speck of Dust',
        discovery:
            'Shooting stars are meteors: tiny bits of space dust that glow '
            'as they rush through the air high above us.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story 9

const _spring = Story(
  id: 'hot_spring',
  title: 'The Mountain That Kept Warm',
  tagline: 'Follow the steam to find a hidden hot spring.',
  cover: ScenePicture.springPool,
  intro:
      'In a snowy valley, Tessa the tortoise has noticed steam rising from '
      'the mountain. Snow is falling, yet one place never freezes. Let us '
      'find out why, and you decide what happens next.',
  startSceneId: 'steamy_valley',
  scenes: [
    StoryScene(
      id: 'steamy_valley',
      title: 'The Steamy Valley',
      picture: ScenePicture.springMountain,
      text:
          'A curl of white steam rose from the side of the mountain. "Why is '
          'it warm up there?" asked Tessa. "Everything else is frozen." A '
          'stony path wound up to the steam. Beside the frozen river, Mina '
          'the mouse was digging a little tunnel to stay warm.',
      choices: [
        StoryChoice(
          id: 'climb_path',
          text: 'Take the stony path upwards',
          nextSceneId: 'warm_stones',
          consequence: 'You and Tessa went slowly up the path.',
        ),
        StoryChoice(
          id: 'ask_mina',
          text: 'Talk to Mina by the river',
          nextSceneId: 'mina_tunnel',
          consequence: 'You crunched through the snow to the river.',
        ),
      ],
    ),
    StoryScene(
      id: 'warm_stones',
      title: 'The Warm Stones',
      picture: ScenePicture.springPool,
      text:
          'The stones on the path felt warm, and the snow around them had '
          'melted. Tessa sniffed. "Eggs?" she said, wrinkling her nose. Ahead '
          'lay two trails: one to a small steaming pool, and one to a crack '
          'in the rock that whistled softly with steam.',
      choices: [
        StoryChoice(
          id: 'see_pool',
          text: 'Go to the steaming pool',
          nextSceneId: 'steaming_pool',
          consequence: 'You followed the warm trail to the pool.',
        ),
        StoryChoice(
          id: 'see_crack',
          text: 'Look at the crack from a safe distance',
          nextSceneId: 'whistling_crack',
          consequence: 'You stopped well back and watched the steam.',
        ),
      ],
    ),
    StoryScene(
      id: 'mina_tunnel',
      title: 'Mina\'s Tunnel',
      picture: ScenePicture.springMountain,
      text:
          '"The deeper I dig, the warmer it gets," said Mina. "Snow is a '
          'blanket, you know. And the ground is warmer far below." Tessa '
          'thought about that. "Then how warm is it deep under the mountain?" '
          'Mina shrugged. "Ask the river. Part of it never freezes."',
      choices: [
        StoryChoice(
          id: 'unfrozen_river',
          text: 'Find the part of the river that never freezes',
          nextSceneId: 'steaming_pool',
          consequence: 'You followed the river upstream, past the ice.',
        ),
        StoryChoice(
          id: 'ask_rocks',
          text: 'Look at the rocks by the river',
          nextSceneId: 'whistling_crack',
          consequence: 'Tessa found a strange grey rock full of little holes.',
        ),
      ],
    ),
    StoryScene(
      id: 'whistling_crack',
      title: 'The Whistling Crack',
      picture: ScenePicture.springPool,
      text:
          'Mountain goat Ama stood watching from a ledge. "Rain sinks deep '
          'into the ground," she said, "where the rock is hot. It heats up '
          'and rises again as steam." She nodded at the valley. "My family '
          'comes here every winter." You could follow her, or stay and draw.',
      choices: [
        StoryChoice(
          id: 'follow_goat',
          text: 'Follow Ama to the warm pool',
          nextSceneId: 'steaming_pool',
          consequence: 'Ama led the way, stepping from rock to rock.',
        ),
        StoryChoice(
          id: 'draw_map',
          text: 'Draw a map of the warm places',
          nextSceneId: 'warm_map',
          consequence: 'Tessa took out her notebook and pencil.',
        ),
        StoryChoice(
          id: 'wait_watch',
          text: 'Wait and see what the crack does next',
          nextSceneId: 'the_geyser',
          consequence: 'Ama led you all up to a safe, high ledge.',
        ),
      ],
    ),
    StoryScene(
      id: 'steaming_pool',
      title: 'The Hidden Hot Spring',
      picture: ScenePicture.springHappy,
      text:
          'There it was: a pool of warm blue water, with snow all around it. '
          'A family of snow monkeys were sitting in it up to their chins, '
          'looking very pleased. "Rain sank down, the hot rock warmed it, and '
          'up it came," said Tessa. "The mountain has its own bath!"',
      ending: StoryEnding(
        id: 'mountain_bath',
        title: 'The Mountain\'s Bath',
        discovery:
            'Hot springs form when water sinks deep underground, is warmed by '
            'hot rock, and rises back to the surface.',
      ),
    ),
    StoryScene(
      id: 'warm_map',
      title: 'The Warm Map',
      picture: ScenePicture.springHappy,
      text:
          'Tessa marked every warm stone and steaming crack. Soon the valley '
          'animals used her map to find the cosy spots on the coldest days. '
          '"Warmth from deep in the Earth," said Mina, snuggling up on a warm '
          'stone. "And it is free for everyone."',
      ending: StoryEnding(
        id: 'warm_map',
        title: 'The Warm Map',
        discovery:
            'Heat from deep inside the Earth is called geothermal energy. '
            'Some countries use it to warm homes.',
      ),
    ),
    StoryScene(
      id: 'the_geyser',
      title: 'The Fountain',
      picture: ScenePicture.springHappy,
      text:
          'From a safe distance, you all waited and watched. The crack '
          'hissed and gurgled. Then, with a whoosh, a tall fountain of '
          'hot water shot into the air, and rained down on the rocks. '
          '"Water trapped below heats up until it bursts out," said Ama. '
          '"It will do it again soon."',
      ending: StoryEnding(
        id: 'the_fountain',
        title: 'The Mountain Fountain',
        discovery:
            'A geyser shoots out hot water when water trapped underground '
            'is heated by hot rock until it bursts upwards.',
      ),
    ),
  ],
);

// ----------------------------------------------------------------- Story 10

const _seed = Story(
  id: 'little_seed',
  title: 'The Little Seed\'s Long Journey',
  tagline: 'Choose how a tiny seed travels to a new home.',
  cover: ScenePicture.seedTall,
  intro:
      'On a windy hill stands a dandelion, and on it is a tiny seed called '
      'Tuft, ready to leave home. Plants cannot walk, so how will Tuft travel? '
      'Let us find out, and you decide what happens next.',
  startSceneId: 'windy_hill',
  scenes: [
    StoryScene(
      id: 'windy_hill',
      title: 'The Windy Hill',
      picture: ScenePicture.seedHill,
      text:
          'Tuft the seed held on tight to the dandelion clock, with a fluffy '
          'parachute above. "Why do I have to leave?" Tuft asked. "So you can '
          'find your own patch of sun," said Mother Dandelion. "Too many '
          'plants in one spot have to share." A gust blew past. A rabbit '
          'hopped closer.',
      choices: [
        StoryChoice(
          id: 'catch_wind',
          text: 'Let go and ride the wind',
          nextSceneId: 'on_the_wind',
          consequence: 'Whoosh! Tuft was up in the air.',
        ),
        StoryChoice(
          id: 'hop_rabbit',
          text: 'Hold on, and cling to the rabbit',
          nextSceneId: 'rabbit_ride',
          consequence: 'Tuft caught hold of the rabbit\'s soft fur.',
        ),
      ],
    ),
    StoryScene(
      id: 'on_the_wind',
      title: 'On the Wind',
      picture: ScenePicture.seedRiver,
      text:
          'Tuft floated high above the fields, the fluffy parachute catching '
          'every breeze. Below was a sparkling river on one side and a sunny '
          'garden wall on the other. A burr seed drifted past. "I travel by '
          'fur," it said. "Hooks are the best!" Where would Tuft come down?',
      choices: [
        StoryChoice(
          id: 'land_river',
          text: 'Drift down towards the river',
          nextSceneId: 'river_trip',
          consequence: 'The breeze dropped, and Tuft landed with a tiny plip.',
        ),
        StoryChoice(
          id: 'land_wall',
          text: 'Drift over to the garden wall',
          nextSceneId: 'wall_crack',
          consequence: 'The breeze carried Tuft over to the warm old wall.',
        ),
        StoryChoice(
          id: 'keep_flying',
          text: 'Stay up and keep on flying',
          nextSceneId: 'far_field',
          consequence: 'A warm bubble of air carried Tuft even higher.',
        ),
      ],
    ),
    StoryScene(
      id: 'rabbit_ride',
      title: 'The Rabbit Ride',
      picture: ScenePicture.seedRiver,
      text:
          'The rabbit bounced across the meadow, and Tuft bounced too! '
          'Burr seeds were hooked in its fur all around. "Animals carry lots '
          'of us," said a burr. "Berries get eaten, and their seeds come out '
          'somewhere new." At the river, the rabbit stopped to drink, then '
          'scratched its ear.',
      choices: [
        StoryChoice(
          id: 'fall_river',
          text: 'Let go and fall into the river',
          nextSceneId: 'river_trip',
          consequence: 'Tuft slipped from the fur with a tiny plop.',
        ),
        StoryChoice(
          id: 'stay_meadow',
          text: 'Stay on until the sunny meadow',
          nextSceneId: 'sunny_meadow',
          consequence: 'The rabbit scratched, and Tuft tumbled onto soft soil.',
        ),
      ],
    ),
    StoryScene(
      id: 'river_trip',
      title: 'The River Trip',
      picture: ScenePicture.seedRiver,
      text:
          'Tuft floated along like a tiny boat. A coconut bobbed past, in no '
          'hurry at all. "Some of us cross whole oceans," said the coconut. '
          '"Our shells float." The river curved past a muddy bank and a sunny '
          'meadow. Tuft had to find soil, water and light to grow.',
      choices: [
        StoryChoice(
          id: 'muddy_bank',
          text: 'Wash up on the muddy bank',
          nextSceneId: 'wall_crack',
          consequence: 'A ripple pushed Tuft gently into a crack by the bank.',
        ),
        StoryChoice(
          id: 'to_meadow',
          text: 'Drift on to the sunny meadow',
          nextSceneId: 'sunny_meadow',
          consequence: 'A little wave lifted Tuft up onto the grass.',
        ),
      ],
    ),
    StoryScene(
      id: 'wall_crack',
      title: 'The Crack in the Wall',
      picture: ScenePicture.seedTall,
      text:
          'It was a small place, but rain trickled in, and the sun warmed it '
          'every morning. Tuft put down one tiny root, then another. Slowly a '
          'green shoot pushed out of the crack. People walked past and '
          'smiled. "Fancy growing there!" they said. Tuft felt very proud.',
      ending: StoryEnding(
        id: 'wall_flower',
        title: 'The Brave Little Flower',
        discovery:
            'Dandelion seeds ride the wind on tiny parachutes, and they can '
            'grow in very small spaces with soil, water and light.',
      ),
    ),
    StoryScene(
      id: 'sunny_meadow',
      title: 'The Sunny Meadow',
      picture: ScenePicture.seedTall,
      text:
          'The meadow soil was soft and damp. Tuft\'s root reached down and a '
          'shoot reached up to the Sun. Soon a yellow flower opened, and '
          'then a fluffy dandelion clock full of new seeds. "Your turn," '
          'said Tuft, as the wind began to blow.',
      ending: StoryEnding(
        id: 'new_clock',
        title: 'A New Dandelion Clock',
        discovery:
            'Plants spread their seeds by wind, water and animals, so new '
            'plants have room to grow, and the cycle starts again.',
      ),
    ),
    StoryScene(
      id: 'far_field',
      title: 'The Far Field',
      picture: ScenePicture.seedTall,
      text:
          'Warm air lifted Tuft higher and higher, over fields, roads and '
          'a whole town. The parachute held steady for hours. At last, '
          'the wind dropped, and Tuft drifted down onto a far hillside, '
          'where no dandelion had ever grown. Soon, one bright yellow '
          'flower opened all alone. It was the very first of many.',
      ending: StoryEnding(
        id: 'far_field',
        title: 'The Very First Flower',
        discovery:
            'Light seeds on parachutes can ride rising warm air for a long '
            'way, which is how plants reach brand new places.',
      ),
    ),
  ],
);

// ----------------------------------------------------------------- Story 11

const _robot = Story(
  id: 'rusty_robot',
  title: 'Rusty and the Dusty Solar Panels',
  tagline: 'Help a little Mars robot wake up its friends.',
  cover: ScenePicture.robotSun,
  intro:
      'On Mars, a small robot called Rusty is exploring with two friends. '
      'After a big dust storm, the others have stopped moving. Let us help, '
      'and you decide what happens next.',
  startSceneId: 'after_storm',
  scenes: [
    StoryScene(
      id: 'after_storm',
      title: 'After the Storm',
      picture: ScenePicture.robotDust,
      text:
          'The red sky was clearing. Rusty blinked its lights. "Dot? Dash? '
          'Are you awake?" Its two robot friends stood silent, covered in '
          'red dust. Rusty checked its own battery: one quarter full. Far '
          'off, a thin swirl of wind was dancing across the sand.',
      choices: [
        StoryChoice(
          id: 'go_dot',
          text: 'Roll over to check on Dot',
          nextSceneId: 'dusty_panels',
          consequence: 'Rusty rolled slowly across the red rocks.',
        ),
        StoryChoice(
          id: 'wind_swirl',
          text: 'Study the swirl of wind',
          nextSceneId: 'dust_devil',
          consequence: 'Rusty turned its camera towards the swirl.',
        ),
      ],
    ),
    StoryScene(
      id: 'dusty_panels',
      title: 'The Dusty Panels',
      picture: ScenePicture.robotPanel,
      text:
          'Dot\'s solar panels were thick with dust. "Solar panels turn '
          'sunlight into electricity," Rusty said. "But dust blocks the '
          'light, so Dot cannot charge." Rusty had a soft brush arm. It also '
          'had a little battery to share, if it was careful.',
      choices: [
        StoryChoice(
          id: 'brush',
          text: 'Brush the dust away',
          nextSceneId: 'clean_panels',
          consequence: 'Rusty swept the panels, very gently.',
        ),
        StoryChoice(
          id: 'share',
          text: 'Share some of Rusty\'s battery',
          nextSceneId: 'share_power',
          consequence: 'Rusty unrolled its charging cable.',
        ),
      ],
    ),
    StoryScene(
      id: 'dust_devil',
      title: 'The Dust Devil',
      picture: ScenePicture.robotPanel,
      text:
          'The swirl was a dust devil, a spinning column of air. Rusty '
          'calculated its path. "Warm air is rising and spinning," it said. '
          '"It may sweep the dust away for us!" Rusty could steer the others '
          'nearer to its path, or leave it and start cleaning.',
      choices: [
        StoryChoice(
          id: 'wait_devil',
          text: 'Wait for the dust devil to pass',
          nextSceneId: 'wind_cleaning',
          consequence: 'Rusty parked and tucked in its camera.',
        ),
        StoryChoice(
          id: 'clean_self',
          text: 'Start brushing by hand',
          nextSceneId: 'clean_panels',
          consequence: 'Rusty rolled over to Dot and reached out its brush.',
        ),
      ],
    ),
    StoryScene(
      id: 'clean_panels',
      title: 'Clean Panels',
      picture: ScenePicture.robotPanel,
      text:
          'Bit by bit, the panels shone blue again. Sunlight touched them. '
          'A tiny green light came on, then Dot beeped. "Hello, Rusty!" Now '
          'Dash needed help too. It was a long way off, and the Sun would '
          'set soon. Mars days are only a little longer than Earth days.',
      choices: [
        StoryChoice(
          id: 'race_dash',
          text: 'Go together to help Dash',
          nextSceneId: 'team_of_three',
          consequence: 'Rusty and Dot rolled off side by side.',
        ),
        StoryChoice(
          id: 'save_power',
          text: 'Charge up first, and go at sunrise',
          nextSceneId: 'share_power',
          consequence: 'They turned their panels and rested until morning.',
        ),
      ],
    ),
    StoryScene(
      id: 'wind_cleaning',
      title: 'Cleaned by the Wind',
      picture: ScenePicture.robotSun,
      text:
          'Whoosh! The dust devil swept past, and the dust lifted off in a '
          'long red ribbon. Dot and Dash woke up together, beeping happily. '
          '"Thanks, wind!" said Rusty. This has really helped robots on Mars.',
      ending: StoryEnding(
        id: 'lucky_wind',
        title: 'Thanks, Wind!',
        discovery:
            'Dust devils are real on Mars. Scientists saw that wind sometimes '
            'cleaned the solar panels of real Mars rovers.',
      ),
    ),
    StoryScene(
      id: 'team_of_three',
      title: 'A Team of Three',
      picture: ScenePicture.robotSun,
      text:
          'Together, Rusty and Dot brushed Dash clean as the Sun sank in a '
          'soft blue glow. Dash beeped awake just in time. Three little '
          'robots stood side by side, watching a Martian sunset. Yes, on '
          'Mars, sunsets really do look blue!',
      ending: StoryEnding(
        id: 'blue_sunset',
        title: 'The Blue Sunset',
        discovery:
            'Fine dust in the air of Mars scatters light, so its sunsets '
            'glow blue, unlike the red and orange sunsets on Earth.',
      ),
    ),
    StoryScene(
      id: 'share_power',
      title: 'Sharing Power',
      picture: ScenePicture.robotSun,
      text:
          'Rusty shared its power with its friends through the cold night. '
          'In the morning, their panels drank in the sunlight, and soon '
          'everyone was awake. "We '
          'run on sunshine," said Rusty, "and on each other." The three '
          'friends rolled off to explore the next crater.',
      ending: StoryEnding(
        id: 'running_on_sun',
        title: 'Running on Sunshine',
        discovery:
            'Solar panels turn sunlight into electricity, and batteries store '
            'it for when the Sun is not shining.',
      ),
    ),
  ],
);

// ----------------------------------------------------------------- Story 12

const _fossil = Story(
  id: 'cliff_fossil',
  title: 'The Mystery in the Cliff',
  tagline: 'Dig through time with young fossil hunter Milo.',
  cover: ScenePicture.fossilDisplay,
  intro:
      'After a big storm at Ammonite Bay, a small piece of cliff has fallen '
      'on the beach. Milo the fossil hunter spots something curly in the '
      'stone. Let us find out what, and you decide what happens next.',
  startSceneId: 'stormy_bay',
  scenes: [
    StoryScene(
      id: 'stormy_bay',
      title: 'After the Storm',
      picture: ScenePicture.fossilCliff,
      text:
          'Milo crouched by a fallen stone. A perfect spiral curled across '
          'it. "A fossil!" Milo said. High up, the cliff showed stripes of '
          'grey and brown rock. Along the beach walked Dr. Anning, the town '
          'fossil expert, with her little hammer and brush.',
      choices: [
        StoryChoice(
          id: 'ask_doctor',
          text: 'Show it to Dr. Anning',
          nextSceneId: 'dr_anning',
          consequence: 'Milo ran across the pebbles, waving.',
        ),
        StoryChoice(
          id: 'study_cliff',
          text: 'Study the stripes in the cliff',
          nextSceneId: 'rock_layers',
          consequence: 'You and Milo stayed well back and looked up.',
        ),
      ],
    ),
    StoryScene(
      id: 'dr_anning',
      title: 'Dr. Anning',
      picture: ScenePicture.fossilBrush,
      text:
          '"That is an ammonite!" said Dr. Anning. "It was a sea creature '
          'with a spiral shell, and it lived about 190 million years ago." '
          'Milo stared. "But this is a cliff." She smiled. "Back then, this '
          'was the sea floor!" She offered Milo a soft brush.',
      choices: [
        StoryChoice(
          id: 'clean_fossil',
          text: 'Gently brush the fossil clean',
          nextSceneId: 'careful_clean',
          consequence: 'Milo brushed slowly, grain by grain.',
        ),
        StoryChoice(
          id: 'ask_how',
          text: 'Ask how a shell turns into stone',
          nextSceneId: 'how_fossils_form',
          consequence: 'Dr. Anning sat down on a rock to explain.',
        ),
      ],
    ),
    StoryScene(
      id: 'rock_layers',
      title: 'Stripes in the Cliff',
      picture: ScenePicture.fossilBrush,
      text:
          '"Each stripe was once a layer of mud on the sea floor," said Milo, '
          'checking a notebook. "New layers settle on top of old ones, so the '
          'lowest are the oldest." So walking along the cliff was like '
          'turning the pages of a book. Which page first?',
      choices: [
        StoryChoice(
          id: 'how_formed',
          text: 'Find out how a fossil forms in the layers',
          nextSceneId: 'how_fossils_form',
          consequence: 'Milo opened the notebook to a new page.',
        ),
        StoryChoice(
          id: 'look_beach',
          text: 'Search the beach for more fallen stones',
          nextSceneId: 'careful_clean',
          consequence: 'You searched between the pebbles, far from the cliff.',
        ),
      ],
    ),
    StoryScene(
      id: 'how_fossils_form',
      title: 'From Shell to Stone',
      picture: ScenePicture.fossilBrush,
      text:
          '"When the animal died, its shell sank into the mud," said Dr. '
          'Anning. "More mud covered it, and over millions of years, the mud '
          'turned to rock, and minerals replaced the shell." Milo looked at '
          'the stone in amazement. Where should it go now?',
      choices: [
        StoryChoice(
          id: 'to_museum',
          text: 'Give it to the town museum',
          nextSceneId: 'museum_day',
          consequence: 'Milo wrapped the fossil carefully in a soft cloth.',
        ),
        StoryChoice(
          id: 'to_school',
          text: 'Take it to show the class',
          nextSceneId: 'class_show',
          consequence: 'Milo carried the fossil to school in a box.',
        ),
      ],
    ),
    StoryScene(
      id: 'careful_clean',
      title: 'A Careful Clean',
      picture: ScenePicture.fossilDisplay,
      text:
          'Under the mud, tiny ridges appeared along the spiral. Dr. Anning '
          'held up a magnifying glass. "Wonderful! Careful hands like yours '
          'are how we learn from fossils." Milo wrote down the date and the '
          'place. "A good fossil hunter always records where it was found."',
      ending: StoryEnding(
        id: 'careful_hands',
        title: 'Careful Hands',
        discovery:
            'Fossil hunters clean fossils gently and record exactly where '
            'each was found, since the place tells us its age.',
      ),
    ),
    StoryScene(
      id: 'museum_day',
      title: 'Museum Day',
      picture: ScenePicture.fossilDisplay,
      text:
          'A week later, Milo\'s ammonite sat in a glass case, with a small '
          'card: "Found by Milo." Visitors peered in, and little children '
          'pressed their noses to the glass. "Now everyone can learn from '
          'it," Dr. Anning said.',
      ending: StoryEnding(
        id: 'found_by_milo',
        title: 'Found by Milo',
        discovery:
            'Fossils form when living things are buried and slowly turn to '
            'rock. Museums keep them safe for everyone to study.',
      ),
    ),
    StoryScene(
      id: 'class_show',
      title: 'Show and Tell',
      picture: ScenePicture.fossilDisplay,
      text:
          'Milo drew the rock layers on the board. "The lowest layers are '
          'the oldest," Milo explained. "So fossils tell us what lived, and '
          'when." The whole class wanted to go to the beach. Soon, everyone '
          'was a fossil hunter!',
      ending: StoryEnding(
        id: 'rock_pages',
        title: 'Pages of Rock',
        discovery:
            'Rock layers build up over time, so lower layers are usually '
            'older. Fossils in them are like pages of Earth\'s history.',
      ),
    ),
  ],
);

// ----------------------------------------------------------------- Story 13

const _monarchs = Story(
  id: 'monarch_journey',
  title: 'The Great Butterfly Journey',
  tagline: 'Fly south with Orla and thousands of monarchs.',
  cover: ScenePicture.monarchForest,
  intro:
      'As summer ends, Orla the monarch butterfly feels a strange pull. '
      'Something is telling her to fly south, thousands of kilometres, to a '
      'place she has never seen. Let us go with her, and you decide what '
      'happens next.',
  startSceneId: 'end_of_summer',
  scenes: [
    StoryScene(
      id: 'end_of_summer',
      title: 'The End of Summer',
      picture: ScenePicture.monarchField,
      text:
          'The days were getting shorter, and the milkweed was fading. "Time '
          'to go," said an older monarch, opening orange wings. "But I have '
          'never been there," said Orla. "How will I know the way?" Above '
          'them, the Sun shone bright. Other butterflies gathered in a tree.',
      choices: [
        StoryChoice(
          id: 'follow_sun',
          text: 'Set off by watching the Sun',
          nextSceneId: 'sun_compass',
          consequence: 'Orla rose up into the warm air.',
        ),
        StoryChoice(
          id: 'join_tree',
          text: 'Join the butterflies in the tree',
          nextSceneId: 'roost_tree',
          consequence: 'Orla fluttered over and landed among hundreds more.',
        ),
      ],
    ),
    StoryScene(
      id: 'sun_compass',
      title: 'The Sun Compass',
      picture: ScenePicture.monarchMountains,
      text:
          'Orla found that if she kept the Sun in the right place, she was '
          'always heading south. "It is like a compass in my head," she '
          'said. By midday, warm air was rising from the hills. A cold '
          'wind was blowing near the lake below.',
      choices: [
        StoryChoice(
          id: 'ride_thermal',
          text: 'Glide up on the warm rising air',
          nextSceneId: 'thermal_ride',
          consequence: 'The warm air lifted Orla high, with hardly a flap.',
        ),
        StoryChoice(
          id: 'to_lake',
          text: 'Fly lower, near the lake',
          nextSceneId: 'nectar_stop',
          consequence: 'Orla dropped down towards the flowers by the shore.',
        ),
      ],
    ),
    StoryScene(
      id: 'roost_tree',
      title: 'The Roost Tree',
      picture: ScenePicture.monarchMountains,
      text:
          'The branches were orange with butterflies, keeping each other '
          'warm through the cool night. "Monarchs fly only by day," said a '
          'neighbour. "We rest together." In the morning, some flew high on '
          'the warm air, and others went looking for flowers.',
      choices: [
        StoryChoice(
          id: 'go_high',
          text: 'Fly high with the others',
          nextSceneId: 'thermal_ride',
          consequence: 'Orla joined the great orange stream in the sky.',
        ),
        StoryChoice(
          id: 'find_flowers',
          text: 'Stop to find some flowers',
          nextSceneId: 'nectar_stop',
          consequence: 'Orla followed the sweet smell of the goldenrod.',
        ),
        StoryChoice(
          id: 'stay_group',
          text: 'Stay with this group all the way',
          nextSceneId: 'flying_together',
          consequence: 'Orla kept close to her new friends.',
        ),
      ],
    ),
    StoryScene(
      id: 'nectar_stop',
      title: 'The Nectar Stop',
      picture: ScenePicture.monarchMountains,
      text:
          'Orla sipped nectar until she felt strong. "This is the fuel for '
          'the whole trip," said a bee. "Without flowers along the way, you '
          'could not fly so far." People had planted a garden just for '
          'butterflies. Orla could rest here, or press straight on.',
      choices: [
        StoryChoice(
          id: 'rest_garden',
          text: 'Rest in the butterfly garden',
          nextSceneId: 'garden_helpers',
          consequence: 'Orla settled on a flower in the evening sun.',
        ),
        StoryChoice(
          id: 'press_on',
          text: 'Fly on towards the south',
          nextSceneId: 'thermal_ride',
          consequence: 'Full of energy, Orla climbed into the sky.',
        ),
      ],
    ),
    StoryScene(
      id: 'thermal_ride',
      title: 'The Mountain Forest',
      picture: ScenePicture.monarchForest,
      text:
          'Weeks later, tall fir trees appeared on the mountains of Mexico, '
          'and they were covered in orange wings. Orla had arrived, a place '
          'she had never seen. Millions of monarchs rested together in the '
          'cool, misty air, waiting for spring.',
      ending: StoryEnding(
        id: 'mountain_forest',
        title: 'The Mountain Forest',
        discovery:
            'Monarch butterflies from North America fly thousands of '
            'kilometres to the same mountains, using the Sun to find the way.',
      ),
    ),
    StoryScene(
      id: 'garden_helpers',
      title: 'The Butterfly Garden',
      picture: ScenePicture.monarchForest,
      text:
          'A family came out to count the butterflies, smiling at Orla from '
          'a safe distance. "We planted milkweed and flowers to help you on '
          'your way," a child whispered. The next morning, Orla flew on, '
          'strong and rested. Small gardens can help a huge journey.',
      ending: StoryEnding(
        id: 'garden_stop',
        title: 'The Garden Stop',
        discovery:
            'Monarch caterpillars eat only milkweed, and adults need nectar, '
            'so planting wildflowers really helps them.',
      ),
    ),
    StoryScene(
      id: 'flying_together',
      title: 'Flying Together',
      picture: ScenePicture.monarchForest,
      text:
          'Orla stayed with the group, day after day, until they reached '
          'the misty mountains. All winter they rested. In spring, she '
          'flew north, laid her eggs on milkweed, and her caterpillars '
          'grew. It would be her great-grandchildren who finished the '
          'trip home, and they had never seen the way either.',
      ending: StoryEnding(
        id: 'great_grandchildren',
        title: 'The Family Journey',
        discovery:
            'The trip north takes several generations of monarchs, so '
            'butterflies finish a journey that their great-grandparents '
            'began.',
      ),
    ),
  ],
);
