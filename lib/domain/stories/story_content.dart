import 'story.dart';

/// The three starter stories. Original characters and places, nothing
/// scary, real science woven in. Every ending is a good one, just different:
/// choices change what happens, never whether the child "fails".
/// test/domain/stories checks every story with StoryValidator.
const starterStories = <Story>[_forest, _luma, _inventor];

// ------------------------------------------------------------------ Story A

const _forest = Story(
  id: 'forest_colours',
  title: 'The Forest That Forgot Its Colours',
  tagline: 'Help Fennel bring the colour back to Hue Wood.',
  cover: ScenePicture.forestRainbow,
  intro:
      'Once upon a time, in a wood called Hue Wood, every leaf and flower '
      'glowed with colour. But one morning, everything woke up grey. Let us '
      'find out why, and you decide what happens next.',
  startSceneId: 'grey_morning',
  scenes: [
    StoryScene(
      id: 'grey_morning',
      title: 'A Grey Morning',
      picture: ScenePicture.forestGrey,
      text:
          'Fennel the hedgehog blinked at the forest. The ferns were grey. '
          'The berries were grey. Even the butterflies were grey. "Last night '
          'a big dusty storm blew through," Fennel said. "Ever since, the '
          'colours have been gone." High on the hill, the old oak tree held '
          'the Sun Crystal, which used to scatter light all over the wood. '
          'Down below, a little stream still sparkled, just a bit.',
      choices: [
        StoryChoice(
          id: 'climb_oak',
          text: 'Climb up to the Sun Crystal in the old oak',
          nextSceneId: 'dusty_crystal',
          consequence: 'You and Fennel climbed all the way up the old oak.',
        ),
        StoryChoice(
          id: 'follow_stream',
          text: 'Follow the stream that still sparkles',
          nextSceneId: 'sparkling_stream',
          consequence: 'You followed the stream, hopping from stone to stone.',
        ),
      ],
    ),
    StoryScene(
      id: 'dusty_crystal',
      title: 'The Dusty Crystal',
      picture: ScenePicture.forestOak,
      text:
          'At the top of the oak sat the Sun Crystal, but it was covered in '
          'thick grey dust from the storm. "Sunlight looks white," Fennel '
          'said, "but it is really made of every colour mixed together. The '
          'crystal splits it apart, so the forest gets its colours." Under '
          'the dust, the crystal could not split anything. A breeze tugged '
          'at the leaves, and a family of robins watched from a branch.',
      choices: [
        StoryChoice(
          id: 'ask_wind',
          text: 'Ask the wind to blow the dust away',
          nextSceneId: 'whoosh',
          consequence: 'The breeze grew into a big, swirling wind.',
        ),
        StoryChoice(
          id: 'ask_robins',
          text: 'Ask the robins to brush it clean',
          nextSceneId: 'feather_brush',
          consequence: 'The robins fluttered down and got to work.',
        ),
      ],
    ),
    StoryScene(
      id: 'sparkling_stream',
      title: 'The Sparkling Stream',
      picture: ScenePicture.forestStream,
      text:
          'The stream tumbled over a tiny waterfall. Where sunlight hit the '
          'spray, Fennel spotted something amazing: a faint stripe of red, '
          'yellow and blue. "Water drops can split sunlight too, just like '
          'the crystal!" Fennel gasped. A family of robins was splashing in '
          'the shallow water nearby. Somewhere up the hill, the old oak '
          'creaked in the breeze.',
      choices: [
        StoryChoice(
          id: 'make_mist',
          text: 'Splash the waterfall to make a big mist',
          nextSceneId: 'rainbow_mist',
          consequence: 'Splash! A cloud of tiny drops filled the air.',
        ),
        StoryChoice(
          id: 'ask_robins_stream',
          text: 'Ask the robins to help clean the crystal',
          nextSceneId: 'feather_brush',
          consequence:
              'The robins flew you up to the oak on a carpet of wings.',
        ),
      ],
    ),
    StoryScene(
      id: 'whoosh',
      title: 'Whoosh!',
      picture: ScenePicture.forestOak,
      text:
          'Whoosh! The wind blew so hard that the dust flew off the crystal '
          'in one big cloud. Sunlight poured through, and colours began to '
          'spread. But the dust cloud drifted down and settled on the '
          'flowers below, turning them grey again. The trees were green, but '
          'the meadow was still dull. Dark clouds were gathering at the edge '
          'of the sky.',
      choices: [
        StoryChoice(
          id: 'wash_flowers',
          text: 'Carry stream water to wash the flowers',
          nextSceneId: 'bucket_brigade',
          consequence: 'You found acorn cups and started carrying water.',
        ),
        StoryChoice(
          id: 'wait_rain',
          text: 'Wait for the rain clouds to arrive',
          nextSceneId: 'after_the_rain',
          consequence: 'You and Fennel sat under a mushroom and waited.',
        ),
      ],
    ),
    StoryScene(
      id: 'feather_brush',
      title: 'The Feather Brush',
      picture: ScenePicture.forestOak,
      text:
          'The robins swept the crystal with their soft feathers, very '
          'gently, so it would not get scratched. Bit by bit, the crystal '
          'began to shine. But it was facing the wrong way, towards the '
          'shady side of the hill, so the light only fell on a few mossy '
          'rocks. Fennel scratched her nose. "We could turn it, or we could '
          'use what is already here."',
      choices: [
        StoryChoice(
          id: 'turn_crystal',
          text: 'Turn the crystal to face the morning sun',
          nextSceneId: 'crystal_sunrise',
          consequence: 'Everyone pushed together, and the crystal turned.',
        ),
        StoryChoice(
          id: 'mossy_rocks',
          text: 'Carry the colours down the hill in dewdrops',
          nextSceneId: 'bucket_brigade',
          consequence: 'You collected shining dewdrops in acorn cups.',
        ),
      ],
    ),
    StoryScene(
      id: 'rainbow_mist',
      title: 'The Rainbow Mist',
      picture: ScenePicture.forestRainbow,
      text:
          'The mist rose higher and higher, and the sunlight shone straight '
          'through it. A huge rainbow arched over Hue Wood! Wherever its '
          'light touched, colour came back: purple violets, orange '
          'mushrooms, green ferns. The dust on the crystal could wait until '
          'tomorrow. Fennel danced in a circle. "The water did what the '
          'crystal does!"',
      ending: StoryEnding(
        id: 'mist',
        title: 'The Rainbow Mist',
        discovery:
            'Tiny water drops split sunlight into all its colours. That is '
            'how real rainbows form.',
      ),
    ),
    StoryScene(
      id: 'after_the_rain',
      title: 'After the Rain',
      picture: ScenePicture.forestRainbow,
      text:
          'Pitter, patter, the rain came. It washed the dust off every '
          'petal, and the whole meadow sparkled. Then the sun came out '
          'behind you, and a rainbow appeared in front of you, right over '
          'the dripping trees. The flowers were bright again, even brighter '
          'than before. "Waiting was the hardest part," Fennel laughed, '
          'shaking raindrops off her spines.',
      ending: StoryEnding(
        id: 'rain',
        title: 'After the Rain',
        discovery:
            'You see a rainbow when the sun is behind you and rain is in '
            'front of you.',
      ),
    ),
    StoryScene(
      id: 'bucket_brigade',
      title: 'The Bucket Brigade',
      picture: ScenePicture.forestRainbow,
      text:
          'Cup by cup, you carried water. Squirrels joined in, then beetles, '
          'then a very slow snail. Every flower you washed lit up with '
          'colour: red poppies, yellow buttercups, blue bells. It took all '
          'afternoon, and by the end, everyone in Hue Wood had helped. '
          'Fennel was tired but grinning. "This is the most colourful the '
          'wood has ever been!"',
      ending: StoryEnding(
        id: 'brigade',
        title: 'The Bucket Brigade',
        discovery:
            'Dust blocks light. When the light can reach the flowers again, '
            'their colours show.',
      ),
    ),
    StoryScene(
      id: 'crystal_sunrise',
      title: 'The Crystal Sunrise',
      picture: ScenePicture.forestRainbow,
      text:
          'As the crystal turned, morning sunlight hit it full on. Beams of '
          'colour shot out in every direction: a red beam to the berries, a '
          'green beam to the ferns, a blue beam to the butterflies. In a few '
          'seconds, all of Hue Wood was glowing again. The robins sang the '
          'loudest song of the year.',
      ending: StoryEnding(
        id: 'sunrise',
        title: 'The Crystal Sunrise',
        discovery:
            'A crystal, or prism, bends each colour of light by a different '
            'amount, so white light fans out into a rainbow.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story B

const _luma = Story(
  id: 'luma_signal',
  title: 'The Lost Signal from Planet Luma',
  tagline: 'A strange signal is calling. Who is out there?',
  cover: ScenePicture.lumaSignal,
  intro:
      'Far away, on the purple Planet Luma, you and Buddy are running a '
      'little science camp under two suns. Tonight, something unusual '
      'crackles over the radio. You get to decide how to investigate.',
  startSceneId: 'beep_in_the_dark',
  scenes: [
    StoryScene(
      id: 'beep_in_the_dark',
      title: 'A Beep in the Dark',
      picture: ScenePicture.lumaCamp,
      text:
          'Beep beep. Beep beep beep. The camp radio has been quiet for '
          'weeks, but now it is picking up a signal. The beeps come in '
          'groups, with little pauses in between. Outside, the two suns of '
          'Luma have set, and the sky is full of stars. Beyond the camp '
          'rises Glow Ridge, the tallest hill around.',
      choices: [
        StoryChoice(
          id: 'climb_ridge',
          text: 'Climb Glow Ridge to hear the signal better',
          nextSceneId: 'glow_ridge',
          consequence: 'You packed a torch and set off up the ridge.',
        ),
        StoryChoice(
          id: 'decode',
          text: 'Stay at camp and work out the pattern',
          nextSceneId: 'counting_beeps',
          consequence: 'You grabbed a notebook and listened carefully.',
        ),
      ],
    ),
    StoryScene(
      id: 'glow_ridge',
      title: 'On Glow Ridge',
      picture: ScenePicture.lumaRidge,
      text:
          'From the top of the ridge, the signal comes through loud and '
          'clear. Radio signals travel best when there are no hills in the '
          'way, so up here nothing blocks it. Far below, in a round crater, '
          'a tiny light is blinking: on, off, on, off. It blinks in the same '
          'groups as the beeps.',
      choices: [
        StoryChoice(
          id: 'flash_back',
          text: 'Flash your torch back in the same pattern',
          nextSceneId: 'light_talk',
          consequence: 'Flash, flash. Flash, flash, flash.',
        ),
        StoryChoice(
          id: 'into_crater',
          text: 'Climb down into the crater',
          nextSceneId: 'the_crater',
          consequence: 'You carefully picked your way down the crater wall.',
        ),
      ],
    ),
    StoryScene(
      id: 'counting_beeps',
      title: 'Counting Beeps',
      picture: ScenePicture.lumaCamp,
      text:
          'You write down each group: two beeps, then three, then five, '
          'then seven. "These are prime numbers," Buddy says. "Numbers that '
          'can only be divided by one and themselves." Nature does not make '
          'prime number patterns by itself, so someone, or something, must '
          'be sending them on purpose. The radio\'s antenna can point '
          'towards where the signal is coming from.',
      choices: [
        StoryChoice(
          id: 'send_eleven',
          text: 'Send back the next prime number: eleven',
          nextSceneId: 'number_map',
          consequence: 'You tapped out eleven beeps on the radio button.',
        ),
        StoryChoice(
          id: 'follow_antenna',
          text: 'Follow the antenna to find the sender',
          nextSceneId: 'the_crater',
          consequence: 'The antenna pointed towards a crater nearby.',
        ),
      ],
    ),
    StoryScene(
      id: 'the_crater',
      title: 'Something in the Crater',
      picture: ScenePicture.lumaCrater,
      text:
          'In the middle of the crater sits a small, dusty rover with one '
          'blinking light. Painted on its side is a name: DOT. Its screen '
          'flickers: "Battery low. Lost. Please help." Dot was left here '
          'long ago by explorers and has been calling out ever since. Its '
          'solar panel is covered in purple dust, and one wheel is stuck in '
          'the sand.',
      choices: [
        StoryChoice(
          id: 'clean_panel',
          text: 'Clean the solar panel for the morning suns',
          nextSceneId: 'sunrise_recharge',
          consequence: 'You wiped the panel until it shone like a mirror.',
        ),
        StoryChoice(
          id: 'tow_dot',
          text: 'Tow Dot back to camp with a rope',
          nextSceneId: 'long_tow',
          consequence: 'You tied a rope to Dot and started to pull.',
        ),
      ],
    ),
    StoryScene(
      id: 'light_talk',
      title: 'Light Talk',
      picture: ScenePicture.lumaSignal,
      text:
          'The blinking light in the crater stops, then flashes back faster '
          'and faster, as if it is excited! Then it starts to move. Up the '
          'slope rolls a small rover called Dot, which explorers left behind '
          'long ago. It has been looking for a friend to answer its signal '
          'for years. Now Dot follows your torch all the way to camp.',
      ending: StoryEnding(
        id: 'light_talk',
        title: 'Light Talk',
        discovery:
            'Light can carry messages too. Flashing patterns are one of the '
            'oldest ways to signal over long distances.',
      ),
    ),
    StoryScene(
      id: 'number_map',
      title: 'The Number Map',
      picture: ScenePicture.lumaSignal,
      text:
          'The radio goes quiet. Then, beep, thirteen beeps: the next prime '
          'number! Whoever is out there understood you. A picture slowly '
          'appears on the radio screen, dot by dot: a map, with a path from '
          'your camp to a crater. Waiting at the end is a little rover '
          'called Dot, and it has a store of star charts to share.',
      ending: StoryEnding(
        id: 'number_map',
        title: 'The Number Map',
        discovery:
            'Maths works the same everywhere, so scientists think numbers '
            'could be a way to talk with anyone in the universe.',
      ),
    ),
    StoryScene(
      id: 'sunrise_recharge',
      title: 'Sunrise Recharge',
      picture: ScenePicture.lumaSignal,
      text:
          'You wait with Dot through the night, telling stories. When the '
          'first sun rises, its light hits the clean solar panel. Then the '
          'second sun rises, and Dot\'s battery fills twice as fast. Its '
          'lights blink green, and it rolls out of the sand all by itself. '
          'Dot plays a happy little tune of beeps.',
      ending: StoryEnding(
        id: 'sunrise',
        title: 'Sunrise Recharge',
        discovery:
            'Solar panels turn sunlight into electricity, and dust can block '
            'the light, so keeping them clean helps.',
      ),
    ),
    StoryScene(
      id: 'long_tow',
      title: 'The Long Tow Home',
      picture: ScenePicture.lumaCamp,
      text:
          'Dot is heavy, but Luma has weaker gravity than Earth, so it is '
          'easier to pull than you expected. Step by step, you tow Dot all '
          'the way to camp. You plug it into the camp battery, and Dot\'s '
          'screen lights up: "Thank you, friend." Now the science camp has '
          'a new helper.',
      ending: StoryEnding(
        id: 'tow',
        title: 'The Long Tow Home',
        discovery:
            'On a planet with weaker gravity, things weigh less, so heavy '
            'loads are easier to lift and pull.',
      ),
    ),
  ],
);

// ------------------------------------------------------------------ Story C

const _inventor = Story(
  id: 'tiny_inventor',
  title: 'The Tiny Inventor\'s Big Idea',
  tagline: 'Pim the mouse has a plan to save the garden.',
  cover: ScenePicture.inventorWorkshop,
  intro:
      'In a cosy shed at the bottom of a garden lives Pim, a mouse inventor '
      'no taller than a teacup. The garden is very dry, and Pim has a big '
      'idea. You help choose how to build it.',
  startSceneId: 'big_idea',
  scenes: [
    StoryScene(
      id: 'big_idea',
      title: 'Pim\'s Big Idea',
      picture: ScenePicture.inventorShed,
      text:
          'It has not rained for weeks. The sunflowers are drooping, and the '
          'only water is deep down in the old well. "I am going to build a '
          'machine to bring the water up!" says Pim, waving a pencil. Pim '
          'has drawn two plans. One is a windmill that pumps water. The '
          'other is a bucket on a rope, lifted by a wheel called a pulley.',
      choices: [
        StoryChoice(
          id: 'windmill',
          text: 'Build the windmill pump',
          nextSceneId: 'first_test',
          consequence: 'You and Pim gathered card, sticks and a cork.',
        ),
        StoryChoice(
          id: 'pulley',
          text: 'Build the pulley and bucket',
          nextSceneId: 'heavy_bucket',
          consequence: 'You and Pim found a thimble bucket and some string.',
        ),
      ],
    ),
    StoryScene(
      id: 'first_test',
      title: 'The First Test',
      picture: ScenePicture.inventorWorkshop,
      text:
          'The windmill is ready. Pim holds it up to the breeze and, '
          'flop, the paper blades just bend backwards. They barely turn. Pim '
          'is not upset at all. "That is why inventors test things," Pim '
          'says. "Now we know what to fix." There are two ideas: make the '
          'blades stronger, or move the windmill to the windy hill.',
      choices: [
        StoryChoice(
          id: 'stiff_blades',
          text: 'Fold the blades to make them stiffer',
          nextSceneId: 'stronger_blades',
          consequence: 'You folded each blade into a strong zigzag.',
        ),
        StoryChoice(
          id: 'windy_hill',
          text: 'Carry the windmill up the windy hill',
          nextSceneId: 'windy_hill',
          consequence: 'You carried the windmill all the way up the hill.',
        ),
      ],
    ),
    StoryScene(
      id: 'heavy_bucket',
      title: 'The Heavy Bucket',
      picture: ScenePicture.inventorWorkshop,
      text:
          'Pim hangs the thimble bucket over the well on a single wheel and '
          'pulls. The full bucket is heavier than Pim! The rope slips, and '
          'splash, the water spills back down. "Hmm," says Pim, twitching '
          'her whiskers. "I need the machine to do some of the work." In '
          'the corner of the shed are a spare wheel and a smooth, heavy '
          'pebble.',
      choices: [
        StoryChoice(
          id: 'second_wheel',
          text: 'Add the second wheel to the pulley',
          nextSceneId: 'two_wheels',
          consequence: 'You looped the string around both wheels.',
        ),
        StoryChoice(
          id: 'pebble',
          text: 'Tie the pebble on as a counterweight',
          nextSceneId: 'pebble_balance',
          consequence: 'You tied the pebble to the other end of the rope.',
        ),
      ],
    ),
    StoryScene(
      id: 'stronger_blades',
      title: 'Stronger Blades',
      picture: ScenePicture.inventorWorkshop,
      text:
          'With folded blades, the windmill spins round and round, and '
          'water begins to trickle up the straw pipe. Drip, drip, drip. It '
          'works! But it is slow, and the wind keeps stopping and starting. '
          'The sunflowers need a lot of water. "Maybe the windmill needs a '
          'way to save water for later," Pim wonders, "or maybe it needs '
          'some friends."',
      choices: [
        StoryChoice(
          id: 'add_tank',
          text: 'Add a tank to store the water',
          nextSceneId: 'rain_tank',
          consequence: 'You turned an old teapot into a water tank.',
        ),
        StoryChoice(
          id: 'ask_neighbours',
          text: 'Show the windmill to the garden neighbours',
          nextSceneId: 'whole_garden',
          consequence: 'You invited everyone in the garden to come and see.',
        ),
      ],
    ),
    StoryScene(
      id: 'windy_hill',
      title: 'The Windy Hill',
      picture: ScenePicture.inventorHill,
      text:
          'On the hill, the wind is so strong that the windmill spins like '
          'a top. Water gushes up the pipe! But the hill is far from the '
          'sunflowers, and the gusts make the windmill wobble. A snail and '
          'a family of ants have stopped to watch. "Wow," says the snail. '
          '"Can you make one for us too?"',
      choices: [
        StoryChoice(
          id: 'build_together',
          text: 'Build more windmills with the neighbours',
          nextSceneId: 'whole_garden',
          consequence: 'Everyone rolled up their sleeves to help.',
        ),
        StoryChoice(
          id: 'try_pulley',
          text: 'Leave the windmill here and try the pulley plan',
          nextSceneId: 'heavy_bucket',
          consequence:
              'The windmill kept watering the hill top, and you '
              'headed back to the well with the pulley plan.',
        ),
      ],
    ),
    StoryScene(
      id: 'rain_tank',
      title: 'The Teapot Tank',
      picture: ScenePicture.inventorGarden,
      text:
          'All night long, while the wind blows, the windmill slowly fills '
          'the teapot tank. By morning, it is full to the brim. Pim pours '
          'water onto the sunflowers, and they lift their heads to the sun. '
          'Now, even when the wind stops, there is always water saved up. '
          'Pim writes in a notebook: "Windmill, version two. It works!"',
      ending: StoryEnding(
        id: 'tank',
        title: 'The Teapot Tank',
        discovery:
            'Storing energy or water for later helps when nature is not '
            'steady, like wind that starts and stops.',
      ),
    ),
    StoryScene(
      id: 'whole_garden',
      title: 'The Whole-Garden Machine',
      picture: ScenePicture.inventorGarden,
      text:
          'The ants measure, the snail holds things steady, and the beetles '
          'carry sticks. By sunset, a row of little windmills stands across '
          'the garden, each one pumping water to a different flower bed. '
          'The sunflowers stand tall again. Pim beams. "A big idea is even '
          'bigger when everybody adds to it."',
      ending: StoryEnding(
        id: 'team',
        title: 'The Whole-Garden Machine',
        discovery:
            'Engineers often work in teams, and lots of small machines '
            'working together can do a very big job.',
      ),
    ),
    StoryScene(
      id: 'two_wheels',
      title: 'Two Wheels Lighter',
      picture: ScenePicture.inventorGarden,
      text:
          'With the string looped around two wheels, Pim pulls again. This '
          'time the bucket rises easily! Pim has to pull twice as much '
          'string, but it only takes half the effort. Bucket after bucket '
          'comes up, and soon every sunflower has had a long drink. "More '
          'wheels, less work," Pim squeaks.',
      ending: StoryEnding(
        id: 'two_wheels',
        title: 'Two Wheels Lighter',
        discovery:
            'Pulleys with more wheels trade distance for effort: you pull '
            'more rope, but with less force.',
      ),
    ),
    StoryScene(
      id: 'pebble_balance',
      title: 'The Pebble Balance',
      picture: ScenePicture.inventorGarden,
      text:
          'The pebble is almost as heavy as a full bucket. Now, when Pim '
          'gives a small tug, the pebble goes down and the bucket comes up, '
          'like a seesaw. Lifts in tall buildings use this same trick! Pim '
          'waters the whole garden before lunch and still has time for a '
          'cheese sandwich.',
      ending: StoryEnding(
        id: 'balance',
        title: 'The Pebble Balance',
        discovery:
            'A counterweight balances a load, so only a small push is '
            'needed to move it. Real lifts use one.',
      ),
    ),
  ],
);
