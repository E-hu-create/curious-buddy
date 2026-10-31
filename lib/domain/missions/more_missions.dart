import 'mission.dart';
import 'mission_content.dart';

/// Every mission in the app, starter ones first.
const allMissions = <Mission>[...starterMissions, ...moreMissions];

/// Seven more cases. As with the starter missions: fictional places and
/// people, nothing scary, real science, and every answer follows from the
/// clues on screen.
const moreMissions = <Mission>[
  _puddle,
  _lighthouse,
  _postcards,
  _footprints,
  _bread,
  _orchard,
  _shadow,
];

// ---------------------------------------------------------------- Mission 4

const _puddle = Mission(
  id: 'vanishing_puddle',
  title: 'The Puddle That Vanished',
  tagline: 'Follow the water and uncover a sky-high secret.',
  art: MissionArt.puddle,
  intro:
      'At Maple Street School, the class drew a chalk circle around a big '
      'puddle on Monday. By Wednesday, the puddle had vanished! Nobody saw it '
      'go. Where did all that water disappear to?',
  objective: 'Work out where the puddle went.',
  badge: 'Water Cycle Detective',
  solution:
      'Nobody took the puddle. Warm sunshine and a breeze turned its water '
      'into invisible water vapour, which rose into the air. One day it will '
      'cool, form clouds and fall as rain. That puddle water may come back!',
  stages: [
    ChoiceStage(
      id: 'where_it_went',
      prompt: 'What most likely happened to the puddle?',
      clues: [
        Clue(
          id: 'chalk',
          title: 'The chalk circle',
          text:
              'Monday: the puddle filled the circle. Tuesday: it was half the '
              'size. Wednesday: it was gone.',
        ),
        Clue(
          id: 'weather',
          title: 'The weather chart',
          text: 'Tuesday and Wednesday were warm, sunny and a little breezy.',
        ),
        Clue(
          id: 'caretaker',
          title: 'The caretaker',
          text:
              'The caretaker says nobody mopped or swept the playground. It '
              'is solid concrete, so water cannot soak through it.',
        ),
      ],
      choices: [
        Choice(
          id: 'evaporated',
          text: 'The sun and breeze turned the water into vapour in the air.',
          correct: true,
          feedback: 'Yes! The puddle shrank slowly during warm, breezy days.',
        ),
        Choice(
          id: 'mopped',
          text: 'Somebody mopped it up.',
          feedback: 'The caretaker says nobody mopped the playground at all.',
        ),
        Choice(
          id: 'soaked',
          text: 'It soaked down through the ground.',
          feedback:
              'The playground is solid concrete, so water cannot soak in.',
        ),
      ],
      hints: [
        'Look at how the puddle changed from day to day.',
        'The caretaker rules out two ideas. What is left?',
      ],
      explanation:
          'Liquid water turned into a gas called water vapour. This is called '
          'evaporation. The vapour is invisible, so the water seems to vanish.',
    ),
    MultiSelectStage(
      id: 'dry_faster',
      prompt:
          'Which of these make water evaporate faster? Select all that fit.',
      clues: [
        Clue(
          id: 'washing',
          title: 'Washing line',
          text:
              'Wet towels dry fastest on warm, windy days, and when they are '
              'spread out flat, not left in a heap.',
        ),
      ],
      choices: [
        Choice(
          id: 'warmth',
          text: 'Warm sunshine',
          correct: true,
          feedback: 'Warmth gives water the energy to become vapour.',
        ),
        Choice(
          id: 'breeze',
          text: 'A breeze',
          correct: true,
          feedback: 'Moving air carries the vapour away.',
        ),
        Choice(
          id: 'spread',
          text: 'Spreading the water out thinly',
          correct: true,
          feedback: 'More water touches the air when it is spread out.',
        ),
        Choice(
          id: 'lid',
          text: 'Putting a tight lid on it',
          feedback: 'A lid traps the vapour, so the water stays in the pot.',
        ),
        Choice(
          id: 'colder',
          text: 'Making it colder',
          feedback: 'Cold water evaporates more slowly than warm water.',
        ),
      ],
      missingFeedback: 'Those are right! But something else helps too.',
      hints: [
        'Think about a washing line on a good drying day.',
        'Three of these help water evaporate faster.',
      ],
      explanation:
          'Warmth, moving air and a wide surface all speed up evaporation. '
          'That is why towels dry best on a warm, windy day.',
    ),
    OrderStage(
      id: 'water_cycle',
      prompt: 'Put the journey of the water in order, from puddle to puddle.',
      pieces: [
        OrderPiece(id: 'warm', text: 'The Sun warms the puddle.'),
        OrderPiece(id: 'rise', text: 'Water vapour rises into the air.'),
        OrderPiece(id: 'cloud', text: 'High up, it cools and forms clouds.'),
        OrderPiece(id: 'rain', text: 'Water falls from the clouds as rain.'),
        OrderPiece(id: 'collect', text: 'The rain collects in a new puddle.'),
      ],
      hints: [
        'Start with the Sun, and end with a new puddle.',
        'Vapour has to rise before it can form clouds.',
      ],
      explanation:
          'This is the water cycle. The same water goes round and round, so '
          'the water in that puddle is very, very old!',
    ),
    ChoiceStage(
      id: 'fair_test',
      prompt:
          'The class wants to prove that sun dries water faster. Which test '
          'is fair?',
      choices: [
        Choice(
          id: 'one_change',
          text: 'Two same trays with the same water: one in sun, one in shade.',
          correct: true,
          feedback: 'Yes! Only one thing is different, so it is a fair test.',
        ),
        Choice(
          id: 'different_water',
          text: 'A full tray in the sun, and a nearly empty tray in the shade.',
          feedback:
              'Two things are different, so we cannot tell which mattered.',
        ),
        Choice(
          id: 'both_sun',
          text: 'Two trays of water, both in the sun.',
          feedback:
              'Nothing is different, so this cannot show what shade does.',
        ),
      ],
      hints: [
        'A fair test changes only one thing.',
        'What is the one thing we want to find out about?',
      ],
      explanation:
          'In a fair test, you change one thing and keep everything else the '
          'same. Then you know what caused the result.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 5

const _lighthouse = Mission(
  id: 'dark_lighthouse',
  title: 'The Lighthouse That Went Dark',
  tagline: 'Trace the circuit and bring back the light.',
  art: MissionArt.lighthouse,
  intro:
      'The little lighthouse at Pebble Bay has gone dark! All the boats are '
      'safely in the harbour, but Keeper Mina needs the lamp back by tonight. '
      'Grab your notebook and help her find the fault.',
  objective: 'Find out why the lamp stopped, and how to mend it.',
  badge: 'Circuit Sleuth',
  solution:
      'A chewed wire had made a gap between test points 2 and 3, so electricity '
      'could not flow around the loop. Keeper Mina switched off the power and '
      'mended it with new copper wire. The light shines over Pebble Bay again!',
  stages: [
    ChoiceStage(
      id: 'what_is_wrong',
      prompt: 'What is the most likely problem?',
      clues: [
        Clue(
          id: 'bulb',
          title: 'The bulb',
          text: 'Keeper Mina tried the bulb in another lamp. It lit up fine.',
        ),
        Clue(
          id: 'battery',
          title: 'The battery',
          text: 'The battery meter says it is full.',
        ),
        Clue(
          id: 'rule',
          title: 'The circuit rule',
          text:
              'Electricity needs a complete loop. One gap anywhere stops all '
              'of it.',
        ),
      ],
      choices: [
        Choice(
          id: 'gap',
          text: 'There is a gap somewhere in the wires.',
          correct: true,
          feedback:
              'Yes! With a good bulb and battery, the loop must be broken.',
        ),
        Choice(
          id: 'bulb_broken',
          text: 'The bulb has broken.',
          feedback: 'The bulb lit up fine in another lamp, so it still works.',
        ),
        Choice(
          id: 'battery_empty',
          text: 'The battery has run out.',
          feedback: 'The meter says the battery is full, so that is not it.',
        ),
      ],
      hints: [
        'Two of the parts have already been tested.',
        'What does the circuit rule say stops electricity?',
      ],
      explanation:
          'The bulb and battery both work. That leaves the wires, and one gap '
          'stops electricity going all the way around.',
    ),
    ChoiceStage(
      id: 'find_the_gap',
      prompt: 'Where is the gap in the wire?',
      clues: [
        Clue(
          id: 'tester',
          title: 'The tester',
          text:
              'The tester shows if electricity has reached a point. The wire '
              'runs from the battery to point 1, 2, 3, then the bulb.',
        ),
        Clue(
          id: 'results',
          title: 'Test results',
          text: 'Point 1: yes. Point 2: yes. Point 3: no.',
        ),
      ],
      choices: [
        Choice(
          id: 'p1_p2',
          text: 'Between points 1 and 2',
          feedback: 'Electricity reached point 2, so that part is fine.',
        ),
        Choice(
          id: 'p2_p3',
          text: 'Between points 2 and 3',
          correct: true,
          feedback: 'Well traced! It reaches point 2, but not point 3.',
        ),
        Choice(
          id: 'p3_bulb',
          text: 'Between point 3 and the bulb',
          feedback: 'Electricity stops before point 3, so look earlier.',
        ),
      ],
      hints: [
        'Follow the wire from the battery, one point at a time.',
        'Find the last point that says yes and the first that says no.',
      ],
      explanation:
          'Electricity reaches point 2 but not point 3, so the gap must be '
          'between them. Testing step by step narrows a problem down.',
    ),
    MultiSelectStage(
      id: 'conductors',
      prompt:
          'Which materials would let electricity flow? Select all that fit.',
      clues: [
        Clue(
          id: 'conductors_note',
          title: 'Workshop poster',
          text:
              'Metals are good conductors: electricity flows through them. '
              'Rubber, plastic and wood are insulators: it does not.',
        ),
      ],
      choices: [
        Choice(
          id: 'copper',
          text: 'Copper wire',
          correct: true,
          feedback: 'Copper is a metal, and carries electricity very well.',
        ),
        Choice(
          id: 'foil',
          text: 'Aluminium foil',
          correct: true,
          feedback: 'Aluminium is a metal, so it conducts electricity.',
        ),
        Choice(
          id: 'steel',
          text: 'A steel paper clip',
          correct: true,
          feedback: 'Steel is a metal, so it conducts electricity too.',
        ),
        Choice(
          id: 'rubber',
          text: 'A rubber band',
          feedback: 'Rubber is an insulator, so electricity will not pass.',
        ),
        Choice(
          id: 'wood',
          text: 'A wooden stick',
          feedback: 'Wood is an insulator, so it would not close the gap.',
        ),
      ],
      missingFeedback: 'Those will work! But there is another one to find.',
      hints: [
        'Read the workshop poster.',
        'Which of these things are made of metal?',
      ],
      explanation:
          'Copper, aluminium and steel are metals, so they conduct. Rubber and '
          'wood are insulators, which is why wires have rubbery coats.',
    ),
    OrderStage(
      id: 'mend_it',
      prompt:
          'Keeper Mina is a trained grown-up. Put her repair steps in order.',
      clues: [
        Clue(
          id: 'safety',
          title: 'Safety first',
          text:
              'Real electrics must only be mended by trained grown-ups, and '
              'always with the power switched off.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'off', text: 'Switch the power off.'),
        OrderPiece(id: 'cut', text: 'Remove the damaged piece of wire.'),
        OrderPiece(id: 'join', text: 'Join in new copper wire.'),
        OrderPiece(id: 'tape', text: 'Cover the join with insulating tape.'),
        OrderPiece(id: 'test', text: 'Switch on and test the lamp.'),
      ],
      hints: [
        'What does the safety card say must happen first?',
        'Testing can only happen when the repair is finished.',
      ],
      explanation:
          'Power goes off first and on again last. Never touch real electrics '
          'yourself: this job is for trained grown-ups.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 6

const _postcards = Mission(
  id: 'mystery_postcards',
  title: 'The Mystery Postcards',
  tagline: 'Use planet clues to track a traveller across space.',
  art: MissionArt.postcards,
  intro:
      'Space explorer Captain Zuri is on a grand tour, and sends postcards to '
      'the Star School. But she forgot to write where she is! Can you work '
      'out which planets she has visited?',
  objective: 'Name each place from the clues on the postcards.',
  badge: 'Planet Tracker',
  solution:
      'Captain Zuri visited Mars and Jupiter, then saw the rings of the giant '
      'planets on her way home. Each planet has its own clues, from red dust '
      'to giant storms. Knowing the facts solved the case!',
  stages: [
    ChoiceStage(
      id: 'first_postcard',
      prompt: 'Where was the first postcard written?',
      clues: [
        Clue(
          id: 'first_card',
          title: 'Postcard 1',
          text:
              'Everything here is covered in rusty red dust. Two small moons '
              'are in the sky.',
        ),
        Clue(
          id: 'first_day',
          title: 'Ship log',
          text: 'One day here lasts just a little longer than a day on Earth.',
        ),
      ],
      choices: [
        Choice(
          id: 'mars',
          text: 'Mars',
          correct: true,
          feedback: 'Yes! Mars is red, has two moons, and a similar day.',
        ),
        Choice(
          id: 'venus',
          text: 'Venus',
          feedback: 'Venus has no moons at all, so it cannot be Venus.',
        ),
        Choice(
          id: 'earth',
          text: 'Earth',
          feedback: 'Earth has one big moon, and Zuri can see two small ones.',
        ),
      ],
      hints: [
        'Which planet is known for being red?',
        'Count the moons in the postcard.',
      ],
      explanation:
          'Mars gets its red colour from rusty dust. Its two small moons are '
          'called Phobos and Deimos.',
    ),
    ChoiceStage(
      id: 'second_postcard',
      prompt: 'Where was the second postcard written?',
      clues: [
        Clue(
          id: 'second_card',
          title: 'Postcard 2',
          text:
              'This is the biggest planet of all! There is no solid ground, '
              'just swirling clouds of gas.',
        ),
        Clue(
          id: 'second_storm',
          title: 'Photo on the back',
          text: 'A giant red storm, wider than the whole Earth.',
        ),
      ],
      choices: [
        Choice(
          id: 'jupiter',
          text: 'Jupiter',
          correct: true,
          feedback: 'Yes! Jupiter is the biggest, with its Great Red Spot.',
        ),
        Choice(
          id: 'mercury',
          text: 'Mercury',
          feedback: 'Mercury is the smallest planet, and it is rocky too.',
        ),
        Choice(
          id: 'neptune',
          text: 'Neptune',
          feedback: 'Neptune is a giant, but not the biggest planet of all.',
        ),
      ],
      hints: [
        'Which planet is the biggest in our solar system?',
        'The red storm has a famous name: the Great Red Spot.',
      ],
      explanation:
          'Jupiter is the largest planet. Its Great Red Spot is a giant storm '
          'that has lasted for hundreds of years.',
    ),
    MultiSelectStage(
      id: 'ringed_planets',
      prompt:
          'Zuri says she saw rings on the way home. Which planets have '
          'rings? Select all that fit.',
      clues: [
        Clue(
          id: 'ring_chart',
          title: 'Space chart',
          text:
              'Giant planets: Jupiter, Saturn, Uranus and Neptune. All four '
              'have rings, but Saturn has the brightest.',
        ),
        Clue(
          id: 'rocky_chart',
          title: 'Rocky planets',
          text: 'Mercury, Venus, Earth and Mars have no rings.',
        ),
      ],
      choices: [
        Choice(
          id: 'saturn',
          text: 'Saturn',
          correct: true,
          feedback: 'Saturn has the brightest and most famous rings.',
        ),
        Choice(
          id: 'jupiter_rings',
          text: 'Jupiter',
          correct: true,
          feedback: 'Jupiter has thin, faint rings that are hard to see.',
        ),
        Choice(
          id: 'uranus',
          text: 'Uranus',
          correct: true,
          feedback: 'Uranus has dark, narrow rings around it.',
        ),
        Choice(
          id: 'neptune_rings',
          text: 'Neptune',
          correct: true,
          feedback: 'Neptune has faint, dusty rings.',
        ),
        Choice(
          id: 'mars_rings',
          text: 'Mars',
          feedback: 'Mars is a rocky planet, and rocky planets have no rings.',
        ),
        Choice(
          id: 'venus_rings',
          text: 'Venus',
          feedback: 'Venus is a rocky planet, and rocky planets have no rings.',
        ),
      ],
      missingFeedback: 'Those have rings! But the chart lists more of them.',
      hints: [
        'Read the space chart carefully. It may surprise you!',
        'Four planets have rings.',
      ],
      explanation:
          'All four giant planets have rings, made of ice, rock and dust. '
          "Saturn's are simply the brightest.",
    ),
    OrderStage(
      id: 'trip_home',
      prompt:
          'Zuri flies from the Sun outwards. Put these planets in the order '
          'she passes them.',
      clues: [
        Clue(
          id: 'memory',
          title: "Zuri's note",
          text:
              'Going out from the Sun, Earth comes after Venus, and Mars is '
              'next door to Earth. Jupiter is much further out.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'venus_order', text: 'Venus'),
        OrderPiece(id: 'earth_order', text: 'Earth'),
        OrderPiece(id: 'mars_order', text: 'Mars'),
        OrderPiece(id: 'jupiter_order', text: 'Jupiter'),
      ],
      hints: [
        'Start with the planet nearest the Sun.',
        "Use Zuri's note: which planet comes straight after Venus?",
      ],
      explanation:
          'Going out from the Sun, the order is Venus, Earth, Mars and then '
          'Jupiter. Mercury is closer in, and the other giants are further out.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 7

const _footprints = Mission(
  id: 'beach_footprints',
  title: 'The Strange Tracks on the Beach',
  tagline: 'Read the sand to find out who visited in the night.',
  art: MissionArt.beach,
  intro:
      'At sunrise on Coral Beach, Ranger Tala found strange tracks leading up '
      'from the sea to the dunes and back again. Nobody saw who made them. '
      'Bring your magnifying glass!',
  objective: 'Find out who made the tracks, and why.',
  badge: 'Beach Ranger',
  solution:
      'A sea turtle came ashore after high tide, laid her eggs in the warm '
      'sand and went back to the sea. Ranger Tala marked the nest and turned '
      'off the bright beach lights. The tracks told the whole story!',
  stages: [
    ChoiceStage(
      id: 'who_made_them',
      prompt: 'Which animal made the tracks?',
      clues: [
        Clue(
          id: 'shape',
          title: 'The tracks',
          text:
              'Two rows of flipper marks, with a smooth groove down the '
              'middle, as if something heavy was dragged.',
        ),
        Clue(
          id: 'route',
          title: 'The route',
          text: 'The tracks start at the sea, go up to the dunes and go back.',
        ),
      ],
      choices: [
        Choice(
          id: 'turtle',
          text: 'A sea turtle',
          correct: true,
          feedback: 'Yes! Flippers and a heavy shell leave tracks like these.',
        ),
        Choice(
          id: 'gull',
          text: 'A seagull',
          feedback: 'A gull has small webbed feet, and leaves no heavy groove.',
        ),
        Choice(
          id: 'crab',
          text: 'A crab',
          feedback: 'A crab has many small legs, and makes tiny sideways dots.',
        ),
      ],
      hints: [
        'Which animal has flippers and comes out of the sea?',
        'The groove shows that the animal has a heavy body.',
      ],
      explanation:
          'Sea turtles pull themselves up the beach with their flippers, and '
          'their heavy shell leaves a groove in the sand.',
    ),
    ChoiceStage(
      id: 'why_ashore',
      prompt: 'Why did the turtle come ashore?',
      clues: [
        Clue(
          id: 'mound',
          title: 'Up in the dunes',
          text: 'The tracks stop at a big patch of freshly dug sand.',
        ),
        Clue(
          id: 'book',
          title: "The ranger's guide",
          text:
              'Sea turtles live in the sea, but mother turtles lay their eggs '
              'in warm sand on land.',
        ),
      ],
      choices: [
        Choice(
          id: 'eggs',
          text: 'To lay her eggs in the sand',
          correct: true,
          feedback: "Yes! The dug sand and the ranger's guide both show that.",
        ),
        Choice(
          id: 'sunbathe',
          text: 'To sunbathe all day',
          feedback: 'The turtle went back before sunrise, so no sunbathing.',
        ),
        Choice(
          id: 'food',
          text: 'To look for food in the dunes',
          feedback: 'Turtles feed in the sea, and the guide does not say this.',
        ),
      ],
      hints: ['What did the tracks lead to?', "Read the ranger's guide."],
      explanation:
          'Female sea turtles come ashore to dig a nest, lay their eggs and '
          'cover them with sand. Then they return to the sea.',
    ),
    ChoiceStage(
      id: 'when_it_happened',
      prompt: 'When did the turtle cross the beach?',
      clues: [
        Clue(
          id: 'tide_table',
          title: 'Tide table',
          text: 'High tide was at 10 pm. Low tide was at 4 am.',
        ),
        Clue(
          id: 'waves',
          title: "Ranger's note",
          text:
              'High tide waves wash the lower beach smooth. The tracks cross '
              'the lower beach, and have not been washed away.',
        ),
      ],
      choices: [
        Choice(
          id: 'after_high',
          text: 'After 10 pm, when the tide was going out',
          correct: true,
          feedback: 'Yes! Tracks made before high tide would have been washed.',
        ),
        Choice(
          id: 'before_high',
          text: 'Before 10 pm, when the tide was coming in',
          feedback: 'The high tide waves would have washed those tracks away.',
        ),
        Choice(
          id: 'noon',
          text: 'At midday the day before',
          feedback: 'High tide came after midday, so it would wash them away.',
        ),
      ],
      hints: [
        'What do high tide waves do to the sand?',
        'The tracks were not washed away. So were they made before or after '
            'high tide?',
      ],
      explanation:
          'The waves smooth the sand at high tide, so tracks that survive must '
          'be newer than 10 pm. Using time like this is good detective work.',
    ),
    MultiSelectStage(
      id: 'protect_nest',
      prompt: 'How can we help protect the nest? Select all that fit.',
      clues: [
        Clue(
          id: 'hatchlings',
          title: 'Ranger guide: hatchlings',
          text:
              'Baby turtles find the sea by heading to the brightest part of '
              'the night sky. Bright lights on land can confuse them.',
        ),
      ],
      choices: [
        Choice(
          id: 'lights',
          text: 'Turn off bright beach lights at night',
          correct: true,
          feedback: 'That helps the hatchlings find their way to the sea.',
        ),
        Choice(
          id: 'mark',
          text: 'Ask the rangers to mark the nest',
          correct: true,
          feedback: 'Then people know to keep their distance.',
        ),
        Choice(
          id: 'distance',
          text: 'Keep people and dogs away from it',
          correct: true,
          feedback: 'Leaving the nest in peace keeps the eggs safe.',
        ),
        Choice(
          id: 'dig',
          text: 'Dig up the eggs to take a look',
          feedback: 'Eggs should never be disturbed, or they may not hatch.',
        ),
        Choice(
          id: 'torch',
          text: 'Shine torches at the nest every night',
          feedback: 'Bright lights could confuse the hatchlings on the beach.',
        ),
      ],
      missingFeedback: 'Those will help! But there are more ways to help.',
      hints: [
        'Read how baby turtles find the sea.',
        'Three of these keep the nest safe.',
      ],
      explanation:
          'The best help is to leave the nest alone, mark it, and keep the '
          'beach dark, so the hatchlings can reach the sea.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 8

const _bread = Mission(
  id: 'flat_loaf',
  title: 'The Case of the Flat Loaf',
  tagline: 'Investigate the tiny living thing that makes bread rise.',
  art: MissionArt.bread,
  intro:
      "Baker Bo's bakery is famous for tall, fluffy loaves. But today every "
      'loaf came out flat as a plate! The recipe has not changed. Put on your '
      'apron and help find out what went wrong.',
  objective: "Find out why the bread didn't rise.",
  badge: 'Bakery Scientist',
  solution:
      'Yesterday the dough rose beside the warm oven, but today it sat by an '
      'open window on a cold morning. Yeast works slowly in the cold, so it '
      'made too few gas bubbles. Baker Bo moved the dough somewhere warm, and '
      'the fluffy loaves came back!',
  stages: [
    MultiSelectStage(
      id: 'yeast_needs',
      prompt:
          'Yeast is a tiny living thing. What does it need to work? Select '
          'all that fit.',
      clues: [
        Clue(
          id: 'yeast_note',
          title: "Baker Bo's notebook",
          text:
              'Yeast wakes up with water, feeds on sugars from the flour, and '
              'works best when it is comfortably warm.',
        ),
      ],
      choices: [
        Choice(
          id: 'water',
          text: 'Water',
          correct: true,
          feedback: 'Dried yeast wakes up when it gets wet.',
        ),
        Choice(
          id: 'sugar',
          text: 'Food, such as sugars from the flour',
          correct: true,
          feedback: 'Yeast feeds on sugars, as the notebook says.',
        ),
        Choice(
          id: 'warm',
          text: 'Warmth',
          correct: true,
          feedback: 'Yeast is most active when it is comfortably warm.',
        ),
        Choice(
          id: 'freezer',
          text: 'A very cold freezer',
          feedback: 'Yeast barely works in the cold, so this will not help.',
        ),
        Choice(
          id: 'music',
          text: 'Loud music',
          feedback: 'Yeast has no ears, so music makes no difference to it.',
        ),
      ],
      missingFeedback: 'Those are right! The notebook lists one or two more.',
      hints: ["Read Baker Bo's notebook.", 'Yeast needs three things.'],
      explanation:
          'Yeast is a tiny living fungus. With water, food and warmth, it '
          'becomes busy and starts to make gas.',
    ),
    ChoiceStage(
      id: 'what_changed',
      prompt: 'What changed between the good loaves and the flat ones?',
      clues: [
        Clue(
          id: 'monday',
          title: 'Monday: tall loaves',
          text:
              'Same flour, same yeast, same recipe. The dough rested beside '
              'the warm oven for one hour.',
        ),
        Clue(
          id: 'tuesday',
          title: 'Tuesday: flat loaves',
          text:
              'Same flour, same yeast, same recipe. The dough rested by an '
              'open window on a cold morning for one hour.',
        ),
      ],
      choices: [
        Choice(
          id: 'temperature',
          text: 'The dough rested somewhere much colder.',
          correct: true,
          feedback: 'Yes! The place it rested is the only difference.',
        ),
        Choice(
          id: 'recipe',
          text: 'The recipe was different.',
          feedback: 'Both days used the same recipe, as the notes show.',
        ),
        Choice(
          id: 'rest_time',
          text: 'The dough rested for less time.',
          feedback: 'The dough rested for one hour on both days.',
        ),
      ],
      hints: [
        'Compare the two days, line by line.',
        'Flour, yeast, recipe and time are all the same.',
      ],
      explanation:
          'Everything matched except where the dough rested. Comparing two '
          'days like this is a fair test.',
    ),
    OrderStage(
      id: 'how_bread_rises',
      prompt: 'Put the steps in order to show how yeast makes bread rise.',
      pieces: [
        OrderPiece(id: 'eats', text: 'Yeast feeds on sugars in the dough.'),
        OrderPiece(id: 'gas', text: 'It gives off bubbles of gas.'),
        OrderPiece(id: 'traps', text: 'The stretchy dough traps the bubbles.'),
        OrderPiece(id: 'puffs', text: 'The dough puffs up and rises.'),
        OrderPiece(id: 'bakes', text: 'Baking sets the bread, full of holes.'),
      ],
      hints: [
        'Start with the yeast feeding.',
        'Bubbles have to appear before they can be trapped.',
      ],
      explanation:
          'The gas is carbon dioxide. Those are the little holes you see when '
          'you slice a loaf of bread!',
    ),
    ChoiceStage(
      id: 'fix_loaf',
      prompt: 'What should Baker Bo do tomorrow?',
      clues: [
        Clue(
          id: 'hot_note',
          title: 'Warning in the notebook',
          text: 'Very high heat stops yeast working. Warm is good, not hot.',
        ),
      ],
      choices: [
        Choice(
          id: 'warm_spot',
          text: 'Rest the dough somewhere warm, like beside the oven.',
          correct: true,
          feedback: 'Yes! Warm dough is what worked well on Monday.',
        ),
        Choice(
          id: 'more_flour',
          text: 'Add more flour to the dough.',
          feedback: 'The recipe was never the problem, so this will not help.',
        ),
        Choice(
          id: 'in_oven',
          text: 'Put raw dough straight into the hot oven to rest.',
          feedback: 'The notebook warns that very high heat stops the yeast.',
        ),
      ],
      hints: [
        'Fix what actually changed.',
        'Which day made good bread, and where did the dough rest?',
      ],
      explanation:
          'Resting the dough somewhere warm lets the yeast make plenty of gas, '
          'and the loaves rise tall again.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 9

const _orchard = Mission(
  id: 'quiet_orchard',
  title: 'The Quiet Orchard',
  tagline: 'Discover why one row of apple trees has no fruit.',
  art: MissionArt.orchard,
  intro:
      'Farmer Lin has three rows of apple trees. Rows A and B are heavy with '
      'apples, but Row C has hardly any! The trees look healthy, and the '
      'flowers were beautiful in spring. What is going on?',
  objective: 'Find out why Row C grew so few apples.',
  badge: 'Pollination Pro',
  solution:
      'A beehive beside Row C was moved away in the spring, so few bees '
      'visited its flowers. Without pollination, flowers cannot turn into '
      'apples. Farmer Lin brought the hive back and planted wildflowers. Next '
      'year, Row C will be full of fruit!',
  stages: [
    OrderStage(
      id: 'how_apples_grow',
      prompt:
          'First, how does a flower become an apple? Put the steps in order.',
      clues: [
        Clue(
          id: 'pollen_note',
          title: "Farmer Lin's book",
          text:
              'Apple flowers need pollen from another apple tree. Bees carry '
              'it as they fly from flower to flower.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'visit', text: 'A bee visits a flower for nectar.'),
        OrderPiece(id: 'sticks', text: 'Pollen sticks to its furry body.'),
        OrderPiece(id: 'carry', text: 'The bee flies on to another flower.'),
        OrderPiece(id: 'rub', text: 'Pollen rubs off onto that flower.'),
        OrderPiece(id: 'fruit', text: 'The flower grows into an apple.'),
      ],
      hints: [
        'Start with the bee and finish with the fruit.',
        "Read Farmer Lin's book.",
      ],
      explanation:
          'This is called pollination. The bee gets a meal of nectar, and the '
          'flower gets the pollen it needs.',
    ),
    ChoiceStage(
      id: 'count_bees',
      prompt: 'Which clue best explains Row C?',
      clues: [
        Clue(
          id: 'bee_count',
          title: 'Bee count in spring',
          text: 'Row A: 40 bees an hour. Row B: 35. Row C: only 3.',
        ),
        Clue(
          id: 'same_trees',
          title: 'Orchard notes',
          text: 'All rows have the same apple trees, sun, soil and water.',
        ),
      ],
      choices: [
        Choice(
          id: 'few_bees',
          text: 'Row C had far fewer bee visitors.',
          correct: true,
          feedback: 'Yes! With so few bees, little pollen was carried there.',
        ),
        Choice(
          id: 'less_sun',
          text: 'Row C had less sunshine.',
          feedback: 'The orchard notes say that all rows get the same sun.',
        ),
        Choice(
          id: 'other_trees',
          text: 'Row C has a different kind of tree.',
          feedback: 'The notes say that all the rows have the same trees.',
        ),
      ],
      hints: [
        'What is the same for all three rows?',
        'Look at the numbers in the bee count.',
      ],
      explanation:
          'Trees, sun, soil and water are all the same. The big difference is '
          'the number of bees.',
    ),
    ChoiceStage(
      id: 'why_no_bees',
      prompt: 'Why did so few bees visit Row C?',
      clues: [
        Clue(
          id: 'diary',
          title: "Farmer Lin's diary",
          text:
              'March: moved the hive from beside Row C to the far side of the '
              'farm, past Row A.',
        ),
        Clue(
          id: 'distance',
          title: 'Bee fact',
          text: 'Bees visit the flowers closest to their hive the most.',
        ),
      ],
      choices: [
        Choice(
          id: 'hive_moved',
          text: 'The hive was moved further away from Row C.',
          correct: true,
          feedback: 'Yes! The bees stayed close to their new home.',
        ),
        Choice(
          id: 'scared',
          text: 'The bees dislike the colour of Row C.',
          feedback: 'All the trees are the same, so their flowers match too.',
        ),
        Choice(
          id: 'asleep',
          text: 'The bees slept all spring.',
          feedback: 'Rows A and B had lots of bees, so they were awake.',
        ),
      ],
      hints: [
        'Read the diary. What changed in March?',
        'Where do bees like to find their flowers?',
      ],
      explanation:
          'Moving the hive put Row C far from the bees, so most of them '
          'stopped visiting it. One small change can make a big difference.',
    ),
    MultiSelectStage(
      id: 'bring_bees_back',
      prompt: 'How can Farmer Lin bring the bees back? Select all that fit.',
      choices: [
        Choice(
          id: 'return_hive',
          text: 'Move a hive back beside Row C',
          correct: true,
          feedback: 'Then the bees will be close to the flowers again.',
        ),
        Choice(
          id: 'wildflowers',
          text: 'Plant wildflowers nearby',
          correct: true,
          feedback: 'Wildflowers give bees food for more of the year.',
        ),
        Choice(
          id: 'no_spray',
          text: 'Avoid sprays that could harm bees',
          correct: true,
          feedback: 'Keeping bees healthy keeps the orchard healthy.',
        ),
        Choice(
          id: 'cut_flowers',
          text: 'Cut off all the flowers',
          feedback: 'No flowers means no food for bees, and no apples.',
        ),
        Choice(
          id: 'shoo',
          text: 'Chase the bees away with a fan',
          feedback: 'We want more bees in Row C, not fewer of them.',
        ),
      ],
      missingFeedback: 'Good ideas! But there are more ways to help the bees.',
      hints: [
        'What do bees want? Food, safety and a nearby home.',
        'Three of these will help.',
      ],
      explanation:
          'A nearby hive, plenty of flowers and no harmful sprays make the '
          'orchard a good place for bees, and for apples too.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 10

const _shadow = Mission(
  id: 'shrinking_shadow',
  title: 'The Case of the Shrinking Shadow',
  tagline: 'Use shadows to tell the time without a clock.',
  art: MissionArt.shadow,
  intro:
      'Four photos of the Town Hall statue were found with no times on them. '
      'Its shadow looks different in each one! Mayor Ada needs them in the '
      'right order for the town album. Can shadows tell us the time?',
  objective: 'Put the photos in order, using the shadows.',
  badge: 'Shadow Detective',
  solution:
      "The statue's shadow changes because the Sun seems to move across the "
      'sky each day. Shadows are long in the morning and evening, and shortest '
      'around midday. You read the time like an ancient sundial!',
  stages: [
    ChoiceStage(
      id: 'what_is_shadow',
      prompt: 'First, what makes a shadow?',
      clues: [
        Clue(
          id: 'torch_test',
          title: 'Torch test',
          text:
              'Light travels in straight lines. Hold a toy in front of a '
              'torch, and a dark shape appears behind it.',
        ),
      ],
      choices: [
        Choice(
          id: 'blocks',
          text: 'Something blocks the light, leaving a dark area behind it.',
          correct: true,
          feedback: 'Yes! Light cannot bend around the toy, so a shadow forms.',
        ),
        Choice(
          id: 'makes_dark',
          text: 'Objects give off darkness.',
          feedback: 'Darkness is not given off. It is just a lack of light.',
        ),
        Choice(
          id: 'ground_paint',
          text: 'The ground changes colour by itself.',
          feedback:
              'The dark shape moves when the toy moves, so it is not that.',
        ),
      ],
      hints: [
        'Light travels in straight lines.',
        'What is the toy doing to the light from the torch?',
      ],
      explanation:
          'Light travels in straight lines. A solid object stops it, and the '
          'dark area behind the object is its shadow.',
    ),
    OrderStage(
      id: 'order_photos',
      prompt: 'Put the photos in order, from early morning to evening.',
      clues: [
        Clue(
          id: 'sun_path',
          title: 'The Sun in the sky',
          text:
              'The Sun rises in the east, is highest around midday and sets '
              'in the west.',
        ),
        Clue(
          id: 'shadow_rule',
          title: 'Shadow rule',
          text:
              'A shadow points away from the Sun. The lower the Sun, the '
              'longer the shadow.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'long_west', text: 'A very long shadow pointing west'),
        OrderPiece(id: 'mid_west', text: 'A shorter shadow pointing west'),
        OrderPiece(id: 'short', text: 'The shortest shadow of all'),
        OrderPiece(id: 'long_east', text: 'A long shadow pointing east'),
      ],
      hints: [
        'In the early morning, the Sun is low in the east.',
        'A shadow points away from the Sun, so where does it point at dawn?',
      ],
      explanation:
          'At dawn the Sun is low in the east, so the shadow is long and '
          'points west. By evening it points east. It is shortest around '
          'midday. Near the Equator, as in Ghana, the midday Sun is almost '
          'overhead, so midday shadows are tiny.',
    ),
    ChoiceStage(
      id: 'odd_caption',
      prompt: 'Three captions came with the photos. Which one cannot be true?',
      clues: [
        Clue(
          id: 'shadow_rule_two',
          title: 'Shadow rule',
          text:
              'Around midday the Sun is high, so shadows are at their shortest.',
        ),
      ],
      choices: [
        Choice(
          id: 'noon_long',
          text: 'Midday: the statue had a very long shadow.',
          correct: true,
          feedback: 'Well spotted! A high Sun makes a short shadow, not long.',
        ),
        Choice(
          id: 'dawn_long',
          text: 'Sunrise: the statue had a very long shadow.',
          feedback:
              'That fits: at sunrise the Sun is low, so shadows are long.',
        ),
        Choice(
          id: 'noon_short',
          text: 'Midday: the statue had a short shadow.',
          feedback:
              'That fits: at midday the Sun is high, so shadows are short.',
        ),
      ],
      hints: [
        'Where is the Sun around midday?',
        'High Sun, short shadow. Low Sun, long shadow.',
      ],
      explanation:
          'Around midday the Sun is at its highest, so a very long shadow '
          'cannot be from then. The caption must be a mistake.',
    ),
    MultiSelectStage(
      id: 'why_sun_moves',
      prompt:
          'Which of these are true about shadows and the Sun? Select all '
          'that fit.',
      clues: [
        Clue(
          id: 'earth_spin',
          title: "Scientist's note",
          text:
              'The Sun only seems to cross the sky. Really, the Earth spins '
              'once a day. A sundial tells the time using a shadow.',
        ),
      ],
      choices: [
        Choice(
          id: 'spin',
          text: 'The Earth spinning makes the Sun seem to move.',
          correct: true,
          feedback: 'Yes! We turn towards the Sun, then away from it.',
        ),
        Choice(
          id: 'sundial',
          text: 'A sundial uses a shadow to tell the time.',
          correct: true,
          feedback: 'Yes! The shadow moves around the dial during the day.',
        ),
        Choice(
          id: 'noon_short_true',
          text: 'Shadows are shortest around midday.',
          correct: true,
          feedback: 'Yes! The Sun is at its highest then.',
        ),
        Choice(
          id: 'sun_orbits',
          text: 'The Sun travels around the Earth every day.',
          feedback: 'It looks that way, but really it is the Earth that spins.',
        ),
        Choice(
          id: 'same_shadow',
          text: 'Shadows stay the same length all day.',
          feedback: 'The photos show that shadows change throughout the day.',
        ),
      ],
      missingFeedback: 'Those are true! But one or more are still to find.',
      hints: ["Read the scientist's note.", 'Three of these are true.'],
      explanation:
          'The Earth spins, so the Sun seems to cross the sky, and shadows '
          'change. People have used that to tell the time for thousands of years.',
    ),
  ],
);
