import 'story.dart';

/// Six stories added after the curriculum map: they fill gaps (friction,
/// materials, soils and rocks, adaptation) and bring in more of the world
/// (an Akan folk tale from Ghana, Pacific Islands navigation, a West African
/// pangolin). Same rules as the others: original retellings, nothing scary,
/// real science, every ending a good one. Each has seven or eight scenes and
/// three endings.
const worldStories = <Story>[
  _ananse,
  _slide,
  _umbrella,
  _mole,
  _canoe,
  _pangolin,
];

// ------------------------------------------------------------ Story 14

const _ananse = Story(
  id: 'ananse_wisdom',
  title: 'Ananse and the Pot of Wisdom',
  tagline: 'A clever spider from Ghana tries to keep all the wisdom.',
  cover: ScenePicture.anansePot,
  intro:
      'This is an old story from the Akan people of Ghana, told our own way. '
      'Kweku Ananse the spider was very clever, and he wanted to be the '
      'cleverest of all. You decide what he does next.',
  startSceneId: 'clay_pot',
  scenes: [
    StoryScene(
      id: 'clay_pot',
      title: 'The Clay Pot',
      picture: ScenePicture.ananseVillage,
      text:
          'Long ago, Ananse gathered every bit of wisdom he could find and '
          'sealed it in a clay pot. "Now I know everything," he said, "and I '
          'will not share it." His young son, Ntikuma, watched him. "Where '
          'will you hide it, Father?" Ananse looked at the tallest tree in '
          'the village, and then at his own silky web.',
      choices: [
        StoryChoice(
          id: 'to_tree',
          text: 'Hide it at the top of the tallest tree',
          nextSceneId: 'tall_tree',
          consequence: 'Ananse tied the pot to his front and set off.',
        ),
        StoryChoice(
          id: 'to_web',
          text: 'Hang it in his strong silk web',
          nextSceneId: 'silk_web',
          consequence: 'Ananse began spinning, faster than ever.',
        ),
      ],
    ),
    StoryScene(
      id: 'tall_tree',
      title: 'The Tall Tree',
      picture: ScenePicture.ananseTree,
      text:
          'With the big pot tied to his front, Ananse could not hold on to '
          'the trunk. He slipped down again and again. Ntikuma called up, '
          '"Father, why not tie the pot on your back?" Ananse stopped. His '
          'little son knew something he did not!',
      choices: [
        StoryChoice(
          id: 'listen',
          text: 'Try Ntikuma\'s idea',
          nextSceneId: 'on_back',
          consequence: 'Ananse moved the pot round to his back.',
        ),
        StoryChoice(
          id: 'ask_why',
          text: 'Ask Ntikuma why it would work',
          nextSceneId: 'balance_lesson',
          consequence: 'Ananse climbed down to listen.',
        ),
      ],
    ),
    StoryScene(
      id: 'silk_web',
      title: 'The Silk Web',
      picture: ScenePicture.ananseTree,
      text:
          'Ananse spun thread after thread. Spider silk is very thin, but it '
          'is strong for its size. The web held the heavy pot, swaying '
          'gently in the breeze. But anyone walking by could see it there! '
          '"Hmm," said Ananse. "Perhaps the tree is better after all."',
      choices: [
        StoryChoice(
          id: 'admire_silk',
          text: 'Look closely at the strong silk',
          nextSceneId: 'silk_strength',
          consequence: 'Ananse forgot about hiding for a moment.',
        ),
        StoryChoice(
          id: 'try_tree',
          text: 'Carry the pot to the tall tree',
          nextSceneId: 'tall_tree',
          consequence: 'Ananse tied the pot to his front and set off.',
        ),
      ],
    ),
    StoryScene(
      id: 'balance_lesson',
      title: 'Ntikuma Explains',
      picture: ScenePicture.ananseVillage,
      text:
          '"When the pot is on your front, it pulls you away from the tree," '
          'said Ntikuma. "On your back, it sits close to your middle, so you '
          'can balance and hold on." The village children nodded. That is '
          'why people often carry heavy loads on their backs or heads.',
      choices: [
        StoryChoice(
          id: 'climb_now',
          text: 'Try climbing with the pot on his back',
          nextSceneId: 'on_back',
          consequence: 'Ananse moved the pot round to his back.',
        ),
        StoryChoice(
          id: 'tell_village',
          text: 'Tell the village what Ntikuma knew',
          nextSceneId: 'story_told',
          consequence: 'Everyone gathered round to listen.',
        ),
      ],
    ),
    StoryScene(
      id: 'on_back',
      title: 'Halfway Up',
      picture: ScenePicture.ananseTree,
      text:
          'With the pot on his back, Ananse climbed easily. Halfway up, he '
          'stopped and laughed. "I thought I had all the wisdom in the '
          'world," he said, "but my own son knew something I did not." The '
          'pot felt silly now. What should he do with it?',
      choices: [
        StoryChoice(
          id: 'let_go',
          text: 'Let the pot go, and share the wisdom',
          nextSceneId: 'shared_wisdom',
          consequence: 'Ananse loosened the knot.',
        ),
        StoryChoice(
          id: 'go_tell',
          text: 'Climb down and tell everyone the story',
          nextSceneId: 'story_told',
          consequence: 'Ananse climbed down, chuckling.',
        ),
      ],
    ),
    StoryScene(
      id: 'shared_wisdom',
      title: 'Wisdom for Everyone',
      picture: ScenePicture.anansePot,
      text:
          'The pot fell and cracked open, and the wisdom flew out on the '
          'wind, into every village and every home. "That is fair," said '
          'Ntikuma. "Now everybody has a little." Ananse agreed, and from '
          'then on he listened to others, even the smallest.',
      ending: StoryEnding(
        id: 'wisdom_everywhere',
        title: 'Wisdom for Everyone',
        discovery:
            'Ananse stories come from the Akan people of Ghana. This one '
            'explains why nobody has all the wisdom: we learn from each other.',
      ),
    ),
    StoryScene(
      id: 'silk_strength',
      title: 'Stronger Than It Looks',
      picture: ScenePicture.anansePot,
      text:
          'Ananse plucked a silk thread like a guitar string. "So thin, but '
          'it holds a whole pot!" he said. He decided the best treasure was '
          'not the pot at all. It was knowing how to make something so '
          'strong. He hung the pot where everyone could share it.',
      ending: StoryEnding(
        id: 'silk_strong',
        title: 'Stronger Than It Looks',
        discovery:
            'Spider silk is very strong for how thin and light it is. '
            'Scientists study it to help make strong new materials.',
      ),
    ),
    StoryScene(
      id: 'story_told',
      title: 'The Story Spreads',
      picture: ScenePicture.ananseVillage,
      text:
          'That evening, Ananse told the whole village what had happened, '
          'and they laughed until they cried. The children told it to their '
          'children, and they told it to theirs. That is how the story has '
          'reached you today.',
      ending: StoryEnding(
        id: 'told_aloud',
        title: 'The Story Spreads',
        discovery:
            'Folk tales like Ananse\'s were passed on aloud for hundreds of '
            'years, long before they were written down.',
      ),
    ),
  ],
);

// ------------------------------------------------------------ Story 15

const _slide = Story(
  id: 'slow_slide',
  title: 'The Slow Slide Mystery',
  tagline: 'Why has the new slide stopped being slidey?',
  cover: ScenePicture.slideParachute,
  intro:
      'Esi and her brother Kojo cannot wait to try the new slide at school. '
      'But something is wrong with it. Help them work out what, and you '
      'decide what they try.',
  startSceneId: 'slow_start',
  scenes: [
    StoryScene(
      id: 'slow_start',
      title: 'A Very Slow Slide',
      picture: ScenePicture.slidePlayground,
      text:
          'Esi sat at the top of the shiny new slide, feet first, and let '
          'go. She moved a little, then stopped halfway. "It is the slowest '
          'slide ever!" she laughed. Kojo had a box of toy cars and a few '
          'flat boards. "Something is holding you back," he said.',
      choices: [
        StoryChoice(
          id: 'feel_surface',
          text: 'Feel the slide with your hand',
          nextSceneId: 'rough_surface',
          consequence: 'Esi ran her hand down the slide.',
        ),
        StoryChoice(
          id: 'car_test',
          text: 'Race toy cars down different ramps',
          nextSceneId: 'car_ramps',
          consequence: 'Kojo set up three boards as ramps.',
        ),
      ],
    ),
    StoryScene(
      id: 'rough_surface',
      title: 'Rough and Grippy',
      picture: ScenePicture.slidePlayground,
      text:
          'The slide felt rough, like fine sandpaper. "Rough surfaces rub '
          'against things more," said Kojo. "That rubbing force is called '
          'friction, and it slows things down." The caretaker was painting '
          'the steps nearby. Esi also spotted a smooth plastic mat.',
      choices: [
        StoryChoice(
          id: 'mat_ride',
          text: 'Slide down on the smooth mat',
          nextSceneId: 'smooth_ride',
          consequence: 'Esi sat on the mat at the top.',
        ),
        StoryChoice(
          id: 'ask_caretaker',
          text: 'Ask the caretaker about the paint',
          nextSceneId: 'caretaker',
          consequence: 'They walked over to Mr Mensah.',
        ),
      ],
    ),
    StoryScene(
      id: 'car_ramps',
      title: 'The Ramp Race',
      picture: ScenePicture.slideRamps,
      text:
          'Kojo covered one board with carpet, left one bare wood, and '
          'covered one with shiny plastic. Three cars zoomed down. The car '
          'on plastic won, and the car on carpet crawled. "Bumpy carpet '
          'grips the wheels," said Esi. "Smooth plastic hardly grips at all."',
      choices: [
        StoryChoice(
          id: 'think_grip',
          text: 'Think about where grip is useful',
          nextSceneId: 'good_grip',
          consequence: 'Esi looked down at her trainers.',
        ),
        StoryChoice(
          id: 'paper_test',
          text: 'Drop paper to see what slows it',
          nextSceneId: 'air_brake',
          consequence: 'Kojo grabbed two sheets of paper.',
        ),
      ],
    ),
    StoryScene(
      id: 'caretaker',
      title: 'The Grippy Paint',
      picture: ScenePicture.slideRamps,
      text:
          '"I painted the steps with grippy paint, so nobody slips on the '
          'ladder," said Mr Mensah. "Oh dear, some must have dripped onto '
          'the slide!" He would clean it off tonight. "So grip is good on '
          'steps, but not on slides," said Kojo.',
      choices: [
        StoryChoice(
          id: 'after_clean',
          text: 'Try the slide after it is cleaned',
          nextSceneId: 'smooth_ride',
          consequence: 'The next morning, the slide was shining.',
        ),
        StoryChoice(
          id: 'more_grip',
          text: 'Find other places where grip helps',
          nextSceneId: 'good_grip',
          consequence: 'Esi looked down at her trainers.',
        ),
      ],
    ),
    StoryScene(
      id: 'smooth_ride',
      title: 'Whoosh!',
      picture: ScenePicture.slidePlayground,
      text:
          'Whoosh! Esi zoomed down, feet first, and landed laughing at the '
          'bottom. "Smooth surfaces have less friction," said Kojo, "so you '
          'slide faster." They took turns, one at a time, until the bell '
          'rang.',
      ending: StoryEnding(
        id: 'whoosh',
        title: 'Whoosh!',
        discovery:
            'Friction is a force between two surfaces that rub. Smooth '
            'surfaces make less friction, so things slide more easily.',
      ),
    ),
    StoryScene(
      id: 'good_grip',
      title: 'Grip Is Good',
      picture: ScenePicture.slideRamps,
      text:
          'Esi looked at the bumpy soles of her trainers. "Friction stops me '
          'slipping when I run!" Kojo squeezed the brakes on his bike, and '
          'the rubber pads gripped the wheel. "And friction helps bikes '
          'stop," he said. Friction was not a problem. It was a helper!',
      ending: StoryEnding(
        id: 'grip_helps',
        title: 'Grip Is Good',
        discovery:
            'Friction can be useful. It lets shoes grip the ground and bike '
            'brakes slow the wheels.',
      ),
    ),
    StoryScene(
      id: 'air_brake',
      title: 'The Paper Parachute',
      picture: ScenePicture.slideParachute,
      text:
          'Kojo crumpled one sheet into a ball and kept the other flat. He '
          'dropped them together. The ball fell fast, but the flat sheet '
          'floated down slowly. "The flat sheet pushes against more air," '
          'said Esi. "That is how parachutes work!"',
      ending: StoryEnding(
        id: 'parachute',
        title: 'The Paper Parachute',
        discovery:
            'Air resistance pushes against things moving through the air. A '
            'wide shape catches more air, so it falls more slowly.',
      ),
    ),
  ],
);

// ------------------------------------------------------------ Story 16

const _umbrella = Story(
  id: 'umbrella_problem',
  title: "Benny's Umbrella Problem",
  tagline: 'Which material will keep a picnic dry?',
  cover: ScenePicture.umbrellaWindow,
  intro:
      'Benny the beaver loves building things. Tomorrow is the big riverside '
      'picnic, and the sky looks grey. Help Benny choose the right '
      'materials, and you decide what he tries.',
  startSceneId: 'grey_sky',
  scenes: [
    StoryScene(
      id: 'grey_sky',
      title: 'Grey Clouds',
      picture: ScenePicture.umbrellaRain,
      text:
          'Plip, plop! Rain began to fall on Benny\'s workbench. "I need an '
          'umbrella for the picnic," he said, "but what should I make it '
          'from?" On the bench lay paper, a cotton cloth, a plastic sheet '
          'and some kitchen foil. His friends\' things were piled by the '
          'door.',
      choices: [
        StoryChoice(
          id: 'rain_test',
          text: 'Test each material in the rain',
          nextSceneId: 'rain_test',
          consequence: 'Benny held each one out under the drips.',
        ),
        StoryChoice(
          id: 'look_around',
          text: 'Look at what things are made of',
          nextSceneId: 'material_hunt',
          consequence: 'Benny went on a material hunt.',
        ),
      ],
    ),
    StoryScene(
      id: 'rain_test',
      title: 'The Drip Test',
      picture: ScenePicture.umbrellaTest,
      text:
          'The paper went soggy and tore. Drips crept through the cotton '
          'cloth. But under the plastic sheet and the foil, everything '
          'stayed dry. "These are waterproof," said Benny. "Water cannot get '
          'through them." He wished he could see the sky through them too.',
      choices: [
        StoryChoice(
          id: 'use_plastic',
          text: 'Make the umbrella from the plastic',
          nextSceneId: 'dry_picnic',
          consequence: 'Benny stretched the plastic over a frame of sticks.',
        ),
        StoryChoice(
          id: 'see_through',
          text: 'Find something you can see through',
          nextSceneId: 'clear_window',
          consequence: 'Benny held each material up to the light.',
        ),
      ],
    ),
    StoryScene(
      id: 'material_hunt',
      title: 'The Material Hunt',
      picture: ScenePicture.umbrellaRain,
      text:
          'A spoon of metal. A chair of wood. A jumper of wool. A window of '
          'glass. "Every object is made of a material," said Benny, "and we '
          'choose materials for what they can do." Glass lets light in, and '
          'wood is strong. Then a drip landed on his nose. The roof leaked!',
      choices: [
        StoryChoice(
          id: 'window_idea',
          text: 'Think about the window',
          nextSceneId: 'clear_window',
          consequence: 'Benny held each material up to the light.',
        ),
        StoryChoice(
          id: 'fix_leak',
          text: 'Test materials to fix the leak',
          nextSceneId: 'rain_test',
          consequence: 'Benny held each one out under the drips.',
        ),
      ],
    ),
    StoryScene(
      id: 'clear_window',
      title: 'Through the Window',
      picture: ScenePicture.umbrellaWindow,
      text:
          'Benny could see straight through the glass. Through frosted '
          'plastic, he saw only blurry shapes. Through wood and foil, he saw '
          'nothing at all. "Clear, blurry and blocked!" he said. In his box '
          'was some old clear plastic from a broken toy.',
      choices: [
        StoryChoice(
          id: 'clear_umbrella',
          text: 'Make a see-through umbrella',
          nextSceneId: 'see_through',
          consequence: 'Benny shaped the clear plastic into a dome.',
        ),
        StoryChoice(
          id: 'reuse_plastic',
          text: 'Use old plastic instead of new',
          nextSceneId: 'reuse',
          consequence: 'Benny gathered every scrap from the box.',
        ),
      ],
    ),
    StoryScene(
      id: 'dry_picnic',
      title: 'The Dry Picnic',
      picture: ScenePicture.umbrellaWindow,
      text:
          'At the picnic, the rain pattered down, but everyone under Benny\'s '
          'umbrella stayed snug and dry. "Good choice!" said his friends, '
          'passing round the berries.',
      ending: StoryEnding(
        id: 'waterproof',
        title: 'The Dry Picnic',
        discovery:
            'Waterproof materials, like plastic, do not let water through. '
            'That makes them good for umbrellas and raincoats.',
      ),
    ),
    StoryScene(
      id: 'see_through',
      title: 'Watching the Rain',
      picture: ScenePicture.umbrellaWindow,
      text:
          'Under the clear umbrella, Benny stayed dry and watched every '
          'raindrop splash above him. Then the sun came out, and a rainbow '
          'appeared right through the plastic!',
      ending: StoryEnding(
        id: 'transparent',
        title: 'Watching the Rain',
        discovery:
            'Transparent materials let light through clearly. Translucent '
            'ones let some through, and opaque ones let none through.',
      ),
    ),
    StoryScene(
      id: 'reuse',
      title: 'A Second Life',
      picture: ScenePicture.umbrellaTest,
      text:
          'Benny made his umbrella from old plastic scraps, sewn together '
          'like a patchwork quilt. "This plastic would have lasted for ages '
          'in the river," he said. "Now it keeps us dry instead!"',
      ending: StoryEnding(
        id: 'second_life',
        title: 'A Second Life',
        discovery:
            'Plastic lasts a very long time, so reusing and recycling it '
            'helps keep it out of rivers and seas.',
      ),
    ),
  ],
);

// ------------------------------------------------------------ Story 17

const _mole = Story(
  id: 'mole_garden',
  title: "Mo the Mole's Muddy Garden",
  tagline: 'Dig down to find out what soil is made of.',
  cover: ScenePicture.moleRocks,
  intro:
      'Mo the mole lives under a vegetable garden. One corner is a muddy '
      'puddle, and another is dry as dust. Help Mo find out why, and you '
      'decide where to dig.',
  startSceneId: 'soggy_corner',
  scenes: [
    StoryScene(
      id: 'soggy_corner',
      title: 'A Soggy Corner',
      picture: ScenePicture.moleGarden,
      text:
          'After the rain, the carrots in one corner sat in a muddy puddle. '
          'Across the garden, the beans looked dry and thirsty. Mo poked his '
          'nose out of a molehill. "Same rain, but different ground," he '
          'said. "I wonder what is under there."',
      choices: [
        StoryChoice(
          id: 'dig_down',
          text: 'Dig down to look at the soil',
          nextSceneId: 'soil_layers',
          consequence: 'Mo tunnelled down with his big, strong paws.',
        ),
        StoryChoice(
          id: 'pour_test',
          text: 'Pour water on different soils',
          nextSceneId: 'water_test',
          consequence: 'Mo filled three flowerpots with soil.',
        ),
      ],
    ),
    StoryScene(
      id: 'soil_layers',
      title: 'Down in the Dark',
      picture: ScenePicture.moleTunnel,
      text:
          'Near the top, the soil was dark and crumbly, full of bits of old '
          'leaves. Lower down, under the soggy corner, it was sticky, smooth '
          'clay. Under the dry corner it was gritty sand. Deeper still, Mo\'s '
          'paws hit solid rock.',
      choices: [
        StoryChoice(
          id: 'look_rocks',
          text: 'Look closely at the rocks',
          nextSceneId: 'rock_shelf',
          consequence: 'Mo brushed the dirt off the rocks.',
        ),
        StoryChoice(
          id: 'test_soils',
          text: 'Test how water moves through each soil',
          nextSceneId: 'water_test',
          consequence: 'Mo filled three flowerpots with soil.',
        ),
      ],
    ),
    StoryScene(
      id: 'water_test',
      title: 'The Flowerpot Test',
      picture: ScenePicture.moleGarden,
      text:
          'Mo poured the same amount of water into three pots. Through the '
          'sand, it ran out in a rush. The clay held on to it, and hardly '
          'any dripped through. The dark, crumbly soil let some through and '
          'kept some. A worm wriggled out of the last pot.',
      choices: [
        StoryChoice(
          id: 'mix_soil',
          text: 'Mix the soils to fix the garden',
          nextSceneId: 'happy_garden',
          consequence: 'Mo got to work with a little spade.',
        ),
        StoryChoice(
          id: 'ask_worm',
          text: 'Ask the worm how it helps',
          nextSceneId: 'worm_helpers',
          consequence: 'The worm stretched up to say hello.',
        ),
      ],
    ),
    StoryScene(
      id: 'rock_shelf',
      title: 'The Rock Shelf',
      picture: ScenePicture.moleRocks,
      text:
          'One rock sparkled with tiny crystals. "Granite," said Mo. "It '
          'formed when melted rock cooled down slowly, deep underground." '
          'Another had stripes, like a layer cake. "Sandstone, made of sand '
          'pressed together over a very long time." Little grains crumbled '
          'from its edges.',
      choices: [
        StoryChoice(
          id: 'rock_soil',
          text: 'Find out how rock becomes soil',
          nextSceneId: 'rock_to_soil',
          consequence: 'Mo rubbed two rocks together.',
        ),
        StoryChoice(
          id: 'back_up',
          text: 'Go back up and test the soils',
          nextSceneId: 'water_test',
          consequence: 'Mo filled three flowerpots with soil.',
        ),
      ],
    ),
    StoryScene(
      id: 'happy_garden',
      title: 'The Happy Garden',
      picture: ScenePicture.moleGarden,
      text:
          'With a grown-up gardener\'s help, Mo mixed compost and a little '
          'sand into the sticky clay, and compost into the dry sand. Weeks '
          'later, the carrots and beans were all growing tall.',
      ending: StoryEnding(
        id: 'mixed_soil',
        title: 'The Happy Garden',
        discovery:
            'Clay soil holds lots of water, and sandy soil drains fast. '
            'Mixing in compost helps soil hold just the right amount.',
      ),
    ),
    StoryScene(
      id: 'worm_helpers',
      title: 'The Worm Helpers',
      picture: ScenePicture.moleTunnel,
      text:
          '"We make tunnels," said the worm, "so air and water can get into '
          'the soil. And we pull down dead leaves and turn them into rich '
          'soil." Mo made sure to leave the worms in peace from then on.',
      ending: StoryEnding(
        id: 'worms',
        title: 'The Worm Helpers',
        discovery:
            'Earthworms make tunnels that let air and water into soil, and '
            'they help turn dead leaves into rich new soil.',
      ),
    ),
    StoryScene(
      id: 'rock_to_soil',
      title: 'From Rock to Soil',
      picture: ScenePicture.moleRocks,
      text:
          'A few grains of sand fell off the sandstone. "Rain, wind, ice and '
          'roots break rock into tiny bits," said Mo. "Mixed with rotted '
          'leaves, those bits become soil." It takes a very long time, so '
          'every handful of soil is old and precious.',
      ending: StoryEnding(
        id: 'rock_soil',
        title: 'From Rock to Soil',
        discovery:
            'Soil is made of tiny bits of broken rock mixed with rotted '
            'plants and animals. Rocks break down very slowly.',
      ),
    ),
  ],
);

// ------------------------------------------------------------ Story 18

const _canoe = Story(
  id: 'star_canoe',
  title: 'Kai and the Star Canoe',
  tagline: 'Sail the Pacific with no map, using stars, waves and birds.',
  cover: ScenePicture.canoeIsland,
  intro:
      'Long before maps and compasses, Pacific Islanders sailed great '
      'canoes across thousands of kilometres of ocean. Kai is on her first '
      'voyage with her grandmother, a master navigator. You decide what Kai '
      'learns first.',
  startSceneId: 'night_sail',
  scenes: [
    StoryScene(
      id: 'night_sail',
      title: 'Night on the Ocean',
      picture: ScenePicture.canoeStars,
      text:
          'The big double canoe glided through the dark. There was no map '
          'and no compass on board. "How do we know the way, Grandmother '
          'Mele?" asked Kai, staying close by her side as the crew had '
          'taught her. Grandmother pointed at the stars, and then down at '
          'the rolling waves.',
      choices: [
        StoryChoice(
          id: 'learn_stars',
          text: 'Learn how the stars show the way',
          nextSceneId: 'star_compass',
          consequence: 'Kai looked up at the sky.',
        ),
        StoryChoice(
          id: 'feel_waves',
          text: 'Feel the waves under the canoe',
          nextSceneId: 'ocean_swells',
          consequence: 'Kai sat still and felt the canoe rock.',
        ),
      ],
    ),
    StoryScene(
      id: 'star_compass',
      title: 'The Star Compass',
      picture: ScenePicture.canoeStars,
      text:
          '"Each star rises in the same place on the edge of the sea, every '
          'night," said Grandmother Mele. "And it sets in the same place '
          'too. If you know where your star rises, you know which way to '
          'steer." Kai picked out a bright star low in the east.',
      choices: [
        StoryChoice(
          id: 'steer_star',
          text: 'Help steer by the rising star',
          nextSceneId: 'star_path',
          consequence: 'Kai kept the star just above the bow.',
        ),
        StoryChoice(
          id: 'wait_dawn',
          text: 'Wait to see what morning brings',
          nextSceneId: 'morning_birds',
          consequence: 'Slowly, the sky turned pink.',
        ),
      ],
    ),
    StoryScene(
      id: 'ocean_swells',
      title: 'Reading the Waves',
      picture: ScenePicture.canoeSea,
      text:
          'Long, smooth swells rolled under the canoe, one after another, '
          'all from the same direction. "Those swells were made by winds far '
          'away," said Grandmother. "They keep coming the same way for days. '
          'Feel how they lift the canoe, and you can hold your course."',
      choices: [
        StoryChoice(
          id: 'hold_course',
          text: 'Keep the swells steady under the canoe',
          nextSceneId: 'swell_steer',
          consequence: 'Kai felt each swell lift the left side first.',
        ),
        StoryChoice(
          id: 'watch_sky',
          text: 'Watch the sky as the sun rises',
          nextSceneId: 'morning_birds',
          consequence: 'Slowly, the sky turned pink.',
        ),
      ],
    ),
    StoryScene(
      id: 'morning_birds',
      title: 'The Sea Birds',
      picture: ScenePicture.canoeSea,
      text:
          'At dawn, white sea birds flew past, out to sea to catch fish. '
          '"Watch them again at sunset," said Grandmother. "Some birds fly '
          'home to land each evening." All day, Kai watched. A fluffy cloud '
          'sat still on the horizon while others drifted by.',
      choices: [
        StoryChoice(
          id: 'follow_birds',
          text: 'Follow the birds at sunset',
          nextSceneId: 'island_found',
          consequence: 'As the sun set, the birds all turned one way.',
        ),
        StoryChoice(
          id: 'star_night',
          text: 'Wait for the stars to come out',
          nextSceneId: 'star_path',
          consequence: 'Night fell, and the first stars appeared.',
        ),
      ],
    ),
    StoryScene(
      id: 'star_path',
      title: 'The Star Path',
      picture: ScenePicture.canoeStars,
      text:
          'Star after star rose from the same places, night after night, '
          'and Kai learned their names. On the tenth morning, a green island '
          'rose from the sea, right where Grandmother said it would be.',
      ending: StoryEnding(
        id: 'star_compass',
        title: 'The Star Path',
        discovery:
            'Stars rise and set at the same places on the horizon each '
            'night, so Pacific navigators used them like a compass.',
      ),
    ),
    StoryScene(
      id: 'swell_steer',
      title: 'Steering by Feel',
      picture: ScenePicture.canoeSea,
      text:
          'Even on cloudy nights with no stars, Kai could feel the swells '
          'and keep the canoe on course. "You have the navigator\'s gift," '
          'smiled Grandmother Mele.',
      ending: StoryEnding(
        id: 'swells',
        title: 'Steering by Feel',
        discovery:
            'Ocean swells can travel thousands of kilometres in the same '
            'direction, so navigators could steer by feeling them.',
      ),
    ),
    StoryScene(
      id: 'island_found',
      title: 'Land Ho!',
      picture: ScenePicture.canoeIsland,
      text:
          'The birds flew straight towards the still cloud. Below it, a '
          'green island appeared, with a sandy beach. "Clouds often pile up '
          'over islands," said Grandmother, "and the birds always know the '
          'way home." The crew cheered.',
      ending: StoryEnding(
        id: 'birds_home',
        title: 'Land Ho!',
        discovery:
            'Some sea birds fish far out at sea and fly back to land at '
            'dusk, so navigators watched them to find islands.',
      ),
    ),
  ],
);

// ------------------------------------------------------------ Story 19

const _pangolin = Story(
  id: 'pangolin_night',
  title: "Adwoa the Pangolin's Night Walk",
  tagline: 'A scaly night walk through a West African forest.',
  cover: ScenePicture.pangolinBall,
  intro:
      'In a forest in Ghana, the moon is rising, and Adwoa the pangolin is '
      'waking up. Pangolins come out at night. She is hungry! You decide '
      'where she goes.',
  startSceneId: 'moon_rise',
  scenes: [
    StoryScene(
      id: 'moon_rise',
      title: 'Moonrise',
      picture: ScenePicture.pangolinNight,
      text:
          'Adwoa stretched, and her scales clicked softly, like a coat of '
          'armour. Her eyes were small, but her nose was amazing. "Ants and '
          'termites," she sniffed. "Somewhere close." Above her, a tall tree '
          'creaked. Below, the forest floor was full of smells.',
      choices: [
        StoryChoice(
          id: 'sniff',
          text: 'Sniff along the forest floor',
          nextSceneId: 'sniff_trail',
          consequence: 'Adwoa put her nose down and followed the smell.',
        ),
        StoryChoice(
          id: 'climb',
          text: 'Climb the tree, holding on with her tail',
          nextSceneId: 'tree_climb',
          consequence: 'Adwoa wrapped her long tail round the trunk.',
        ),
      ],
    ),
    StoryScene(
      id: 'sniff_trail',
      title: 'The Termite Mound',
      picture: ScenePicture.pangolinNight,
      text:
          'The smell led to a termite mound, tall and hard as baked clay. '
          'Adwoa\'s front claws were long and strong, perfect for digging. '
          'Then she heard leaves rustling. Something big was coming along '
          'the path!',
      choices: [
        StoryChoice(
          id: 'dig_in',
          text: 'Dig into the mound',
          nextSceneId: 'termite_feast',
          consequence: 'Adwoa scraped and scraped.',
        ),
        StoryChoice(
          id: 'roll_up',
          text: 'Curl up and wait',
          nextSceneId: 'curl_up',
          consequence: 'Adwoa tucked in her head and tail.',
        ),
      ],
    ),
    StoryScene(
      id: 'tree_climb',
      title: 'Up the Tree',
      picture: ScenePicture.pangolinTree,
      text:
          'Adwoa\'s tail gripped the branches like an extra hand. High up, '
          'tree ants had made a nest of leaves. "Supper!" she said. From up '
          'here, she could also smell a termite mound down on the ground.',
      choices: [
        StoryChoice(
          id: 'eat_ants',
          text: 'Have an ant snack in the tree',
          nextSceneId: 'ant_snack',
          consequence: 'Adwoa crept along the branch.',
        ),
        StoryChoice(
          id: 'climb_down',
          text: 'Climb down to the termite mound',
          nextSceneId: 'sniff_trail',
          consequence: 'Adwoa climbed down, tail first.',
        ),
      ],
    ),
    StoryScene(
      id: 'curl_up',
      title: 'A Scaly Ball',
      picture: ScenePicture.pangolinBall,
      text:
          'Adwoa rolled into a tight ball. Her hard scales covered her soft '
          'belly. A big, snuffling bush pig trotted past, sniffed the scaly '
          'ball, and wandered off. It was only looking for fallen fruit! '
          'Soon all was quiet again.',
      choices: [
        StoryChoice(
          id: 'uncurl',
          text: 'Uncurl and go back to the mound',
          nextSceneId: 'termite_feast',
          consequence: 'Adwoa peeped out, then got digging.',
        ),
        StoryChoice(
          id: 'rest',
          text: 'Rest in a burrow until morning',
          nextSceneId: 'safe_burrow',
          consequence: 'Adwoa found an old burrow under a root.',
        ),
      ],
    ),
    StoryScene(
      id: 'termite_feast',
      title: 'The Termite Feast',
      picture: ScenePicture.pangolinNight,
      text:
          'Adwoa broke into the mound and stuck out her long, sticky tongue. '
          'Slurp! Hundreds of termites at a time. Pangolins have no teeth at '
          'all, so tiny insects are just right. By sunrise, she was full and '
          'sleepy.',
      ending: StoryEnding(
        id: 'termites',
        title: 'The Termite Feast',
        discovery:
            'Pangolins have no teeth. They dig with strong claws and lick up '
            'ants and termites with a long, sticky tongue.',
      ),
    ),
    StoryScene(
      id: 'ant_snack',
      title: 'Supper in the Trees',
      picture: ScenePicture.pangolinTree,
      text:
          'Holding on with her tail, Adwoa licked up the tree ants. Then she '
          'curled up in a hollow branch to sleep away the day, high above '
          'the forest floor.',
      ending: StoryEnding(
        id: 'tree_pangolin',
        title: 'Supper in the Trees',
        discovery:
            'Some pangolins live in trees and hold on with their tails. Each '
            'animal has body parts suited to where it lives.',
      ),
    ),
    StoryScene(
      id: 'safe_burrow',
      title: 'Safe and Snug',
      picture: ScenePicture.pangolinBall,
      text:
          'Adwoa curled up in the burrow, snug in her scales, and slept '
          'until the moon rose again. Tomorrow night, the termites would '
          'still be there.',
      ending: StoryEnding(
        id: 'scales',
        title: 'Safe and Snug',
        discovery:
            'A pangolin\'s scales are made of keratin, like your fingernails. '
            'Curling into a ball protects its soft belly.',
      ),
    ),
  ],
);
