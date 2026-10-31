part of 'curated_content.dart';

// More reviewed topics (Stage C, Option A). Same rules as curated_content:
// short sentences, well-established facts, "about" for rounded numbers, and
// honesty where science is not sure. Specific topics only; the broad
// catch-alls (space, ocean, animals, amazing) stay last in curatedTopics.

const _moreTopics = <CuratedTopic>[
  // -------------------------------------------------------------- animals
  CuratedTopic(
    id: 'biggest_animal',
    triggers: [
      ['biggest', 'animal'],
      ['largest', 'animal'],
      ['blue', 'whale'],
    ],
    answers: [
      'The blue whale is the biggest animal known to have ever lived. '
          'It is even bigger than the largest dinosaurs!',
    ],
    followUps: ["What's the fastest animal?", 'Tell me an ocean fact.'],
  ),
  CuratedTopic(
    id: 'cats',
    triggers: [
      ['cat'],
      ['kitten'],
      ['purr'],
    ],
    subject: 'cat',
    pinned: {'purr': 0, 'whisker': 1, 'sleep': 2, 'nap': 2},
    answers: [
      'Cats purr by quickly tightening and relaxing muscles in their throat. '
          'They often purr when they are happy. '
          'Sometimes they purr to calm themselves down, too!',
      'A cat uses its whiskers like measuring sticks. '
          'They help it feel whether it can fit through a gap!',
      'Cats spend about two-thirds of their lives asleep. That is a lot of naps!',
    ],
    followUps: ['Tell me about dogs.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'dogs',
    triggers: [
      ['dog'],
      ['puppy'],
    ],
    subject: 'dog',
    pinned: {'smell': 0, 'nose': 1, 'colour': 2, 'color': 2, 'see': 2},
    answers: [
      'Dogs can smell thousands of times better than people! '
          'Their noses help them find things that are hidden or far away.',
      'Every dog has a unique nose print, a bit like a human fingerprint!',
      'Dogs can see some colours, mostly blues and yellows. '
          'Reds and greens look more brownish to them.',
    ],
    followUps: ['Tell me about cats.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 't_rex',
    triggers: [
      ['t', 'rex'],
      ['trex'],
      ['tyrannosaurus'],
    ],
    subject: 'T. rex',
    pinned: {'teeth': 0, 'tooth': 0, 'when': 0},
    answers: [
      'Tyrannosaurus rex had teeth about as long as bananas! '
          'It lived around 66 to 68 million years ago.',
    ],
    followUps: ['Tell me about dinosaurs.', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'dinosaurs',
    triggers: [
      ['dinosaur'],
      ['dino'],
    ],
    subject: 'dinosaur',
    pinned: {
      'die': 0,
      'died': 0,
      'extinct': 0,
      'real': 0,
      'when': 0,
      'small': 1,
      'big': 1,
    },
    answers: [
      'Dinosaurs lived on Earth for over 160 million years. '
          'Most died out about 66 million years ago, after a huge space rock '
          'hit Earth. Birds are their living relatives!',
      'Some dinosaurs were as small as chickens. '
          'Others were longer than two buses!',
    ],
    followUps: ['Tell me about T. rex.', 'Take me on an adventure.'],
  ),
  CuratedTopic(
    id: 'elephants',
    triggers: [
      ['elephant'],
    ],
    subject: 'elephant',
    pinned: {'feet': 0, 'hear': 0, 'trunk': 1, 'jump': 2},
    answers: [
      'Elephants are the largest land animals. '
          'They can feel low rumbles through the ground with their feet!',
      "An elephant's trunk has thousands of muscles. "
          'It can pick up a peanut or lift a heavy log!',
      "Elephants can't jump! They are so heavy that they always keep at least "
          'one foot on the ground.',
    ],
    followUps: ['Tell me about giraffes.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'giraffes',
    triggers: [
      ['giraffe'],
    ],
    subject: 'giraffe',
    pinned: {'neck': 0, 'bone': 0, 'tall': 1, 'tongue': 1},
    answers: [
      'A giraffe has seven bones in its neck, the same number as you! '
          'Each one is just much, much longer.',
      'Giraffes are the tallest animals on Earth. '
          'Their tongues can be about half a metre long!',
    ],
    followUps: ['Tell me about elephants.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'penguins',
    triggers: [
      ['penguin'],
    ],
    subject: 'penguin',
    pinned: {'fly': 0, 'swim': 0, 'dive': 0},
    answers: [
      "Penguins can't fly, but they are amazing swimmers. "
          'Emperor penguins can dive deeper than 500 metres!',
    ],
    followUps: ['Tell me an ocean fact.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'dolphins',
    triggers: [
      ['dolphin'],
    ],
    subject: 'dolphin',
    pinned: {'sleep': 0, 'name': 1, 'whistle': 1, 'talk': 1},
    answers: [
      'Dolphins sleep with half of their brain at a time. '
          'The other half stays awake so they can keep breathing!',
      'Dolphins give each other names! Each one has its own special whistle.',
    ],
    followUps: ['Tell me an ocean fact.', 'Tell me about penguins.'],
  ),
  CuratedTopic(
    id: 'jellyfish',
    triggers: [
      ['jellyfish'],
    ],
    subject: 'jellyfish',
    pinned: {'brain': 0, 'heart': 0, 'bone': 0},
    answers: [
      'Jellyfish have no brain, no heart and no bones! '
          'Jellyfish have been drifting in the sea for hundreds of millions of '
          'years.',
    ],
    followUps: ['Tell me an ocean fact.', 'Tell me about dolphins.'],
  ),
  CuratedTopic(
    id: 'bees',
    triggers: [
      ['bee'],
      ['honey'],
    ],
    subject: 'bee',
    pinned: {'dance': 0, 'talk': 0, 'make': 1, 'honey': 1, 'last': 2},
    answers: [
      'Bees talk by dancing! '
          'A special waggle dance tells other bees where to find flowers.',
      'Bees make honey from sweet flower nectar. '
          'They store it in wax cells and fan it with their wings until it '
          'thickens!',
      'Honey can last for thousands of years without going bad!',
    ],
    followUps: ['Tell me about ants.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'ants',
    triggers: [
      ['ant'],
    ],
    subject: 'ant',
    pinned: {'strong': 0, 'carry': 0, 'lift': 0},
    answers: [
      'Ants are super strong for their size. '
          'Many can carry things much heavier than their own bodies!',
    ],
    followUps: ['Tell me about bees.', 'Tell me about spiders.'],
  ),
  CuratedTopic(
    id: 'spiders',
    triggers: [
      ['spider'],
    ],
    subject: 'spider',
    pinned: {'insect': 0, 'leg': 0, 'silk': 0, 'web': 0},
    answers: [
      "Spiders have eight legs, so they aren't insects. "
          'Spider silk is amazingly strong for how thin it is!',
    ],
    followUps: ['Tell me about ants.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'butterflies',
    triggers: [
      ['butterfly'],
      ['caterpillar'],
    ],
    subject: 'butterfly',
    pinned: {'taste': 0, 'feet': 0, 'caterpillar': 1, 'chrysalis': 1},
    answers: [
      'Butterflies taste with their feet. '
          'They stand on a leaf to find out if it is good for their eggs!',
      'Every butterfly starts life as a caterpillar. '
          'Inside a case called a chrysalis, its body completely changes!',
    ],
    followUps: ['Tell me about bees.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'bats',
    triggers: [
      ['bat'],
    ],
    subject: 'bat',
    pinned: {'fly': 0, 'dark': 0, 'see': 0, 'echo': 0},
    answers: [
      'Bats are the only mammals that can truly fly. '
          'Many find food in the dark by listening to echoes!',
    ],
    followUps: ['Tell me about owls.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'owls',
    triggers: [
      ['owl'],
    ],
    subject: 'owl',
    pinned: {'head': 0, 'turn': 0, 'eye': 0},
    answers: [
      "Owls can't move their eyes, so they turn their heads instead. "
          'They can turn them about three-quarters of the way around!',
    ],
    followUps: ['Tell me about bats.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'frogs',
    triggers: [
      ['frog'],
      ['toad'],
    ],
    subject: 'frog',
    pinned: {'drink': 0, 'water': 0, 'skin': 0},
    answers: [
      'Many frogs drink water through their skin instead of their mouths!',
    ],
    followUps: ['Tell me about snakes.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'snakes',
    triggers: [
      ['snake'],
    ],
    subject: 'snake',
    pinned: {'smell': 0, 'tongue': 0},
    answers: [
      'Snakes smell with their tongues! '
          'They flick them out to collect smells from the air.',
    ],
    followUps: ['Tell me about frogs.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'chameleons',
    triggers: [
      ['chameleon'],
    ],
    subject: 'chameleon',
    pinned: {'colour': 0, 'color': 0, 'change': 0},
    answers: [
      'Chameleons change colour to show their mood and to warm up or cool '
          'down. Hiding is only part of the story!',
    ],
    followUps: ['Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'cheetahs',
    triggers: [
      ['cheetah'],
      ['fastest', 'animal'],
    ],
    answers: [
      'Cheetahs are the fastest land animals. '
          'They can run about 100 kilometres per hour, but only for short '
          'sprints!',
    ],
    followUps: ['Tell me another animal fact.', 'How fast is light?'],
  ),

  // ---------------------------------------------------------------- space
  CuratedTopic(
    id: 'how_many_planets',
    triggers: [
      ['how', 'many', 'planet'],
      ['name', 'planet'],
    ],
    answers: [
      'There are eight planets in our Solar System. '
          'Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus and Neptune!',
    ],
    followUps: ['Why is Mars red?', 'What are Saturn\'s rings made of?'],
  ),
  CuratedTopic(
    id: 'mars',
    triggers: [
      ['mars'],
    ],
    subject: 'Mars',
    pinned: {'red': 0, 'colour': 0, 'color': 0, 'volcano': 1, 'tall': 1},
    answers: [
      'Mars looks red because its dust has lots of iron in it. '
          'The iron has rusted, like an old bike left in the rain!',
      'Mars has the tallest volcano we know of, called Olympus Mons. '
          'It is about two and a half times as tall as Mount Everest!',
    ],
    followUps: ['How many planets are there?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'saturn',
    triggers: [
      ['saturn'],
    ],
    subject: 'Saturn',
    pinned: {'ring': 0},
    answers: [
      "Saturn's rings are made of countless chunks of ice and rock. "
          'Some are tiny like dust, and some are as big as houses!',
    ],
    followUps: ['How many planets are there?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'black_hole',
    triggers: [
      ['black', 'hole'],
    ],
    answers: [
      'A black hole is a place where gravity pulls so hard that not even '
          'light can escape. Many form when giant stars collapse.',
    ],
    followUps: ['What is gravity?', 'What is a star?'],
  ),
  CuratedTopic(
    id: 'astronauts',
    triggers: [
      ['astronaut'],
      ['space', 'station'],
    ],
    answers: [
      'Astronauts on the space station circle Earth about every 90 minutes. '
          'So they see about 16 sunrises every day!',
    ],
    followUps: ['What is gravity?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'gravity',
    triggers: [
      ['gravity'],
    ],
    answers: [
      'Gravity is a pull between things that have mass. '
          "Earth's gravity keeps your feet on the ground. "
          'It also keeps the Moon going around Earth!',
    ],
    followUps: ['What is a black hole?', 'How far away is the Moon?'],
  ),
  CuratedTopic(
    id: 'moon_phases',
    triggers: [
      ['moon', 'shape'],
      ['moon', 'phase'],
      ['moon', 'change'],
      ['moon', 'light'],
    ],
    answers: [
      "The Moon doesn't make its own light. "
          'We see the part that the Sun is shining on. '
          'That part changes as the Moon travels around Earth!',
    ],
    followUps: ['How far away is the Moon?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'what_is_star',
    triggers: [
      ['what', 'is', 'a', 'star'],
      ['what', 'are', 'star'],
    ],
    answers: [
      'Stars are giant balls of very hot gas. '
          'Our Sun is a star too. It just looks bigger because it is so close!',
    ],
    followUps: ['Why do stars twinkle?', 'How hot is the Sun?'],
  ),
  CuratedTopic(
    id: 'light_speed',
    triggers: [
      ['speed', 'light'],
      ['fast', 'light'],
    ],
    answers: [
      'Light is the fastest thing in the universe. '
          'In one second, it could zoom around Earth about seven times!',
    ],
    followUps: ['What is a black hole?', 'Tell me a space fact.'],
  ),

  // ---------------------------------------------------- Earth and weather
  CuratedTopic(
    id: 'thunder',
    triggers: [
      ['thunder'],
      ['lightning'],
      ['storm'],
    ],
    answers: [
      'Lightning heats the air so fast that it bursts outwards. '
          'That bang is thunder! You see the flash first, because light '
          'travels faster than sound.',
    ],
    followUps: ['Why does it rain?', 'How do rainbows form?'],
  ),
  CuratedTopic(
    id: 'rain',
    triggers: [
      ['rain'],
      ['raining'],
      ['cloud'],
    ],
    answers: [
      'The Sun warms water, and it rises into the sky as invisible vapour. '
          'High up, it cools into tiny drops that make clouds. '
          'When the drops get heavy, they fall as rain!',
    ],
    followUps: ['How does snow form?', 'How do rainbows form?'],
  ),
  CuratedTopic(
    id: 'snow',
    triggers: [
      ['snow'],
      ['snowflake'],
    ],
    answers: [
      'Snow forms when water vapour freezes into ice crystals inside cold '
          'clouds. Almost every snowflake has six sides!',
    ],
    followUps: ['Why does it rain?', 'Why do we have seasons?'],
  ),
  CuratedTopic(
    id: 'volcanoes',
    triggers: [
      ['volcano'],
      ['lava'],
      ['magma'],
    ],
    answers: [
      "A volcano is an opening in Earth's crust. "
          'Hot melted rock called magma pushes up from below. '
          'When it bursts out, we call it lava!',
    ],
    followUps: ['Why do earthquakes happen?', 'Why is Mars red?'],
  ),
  CuratedTopic(
    id: 'earthquakes',
    triggers: [
      ['earthquake'],
    ],
    answers: [
      "Earth's outer shell is broken into giant pieces called plates. "
          'When they suddenly slip past each other, the ground shakes!',
    ],
    followUps: ['How do volcanoes work?', 'Why is the ocean salty?'],
  ),
  CuratedTopic(
    id: 'tides',
    triggers: [
      ['tide'],
    ],
    answers: [
      "The Moon's gravity gently pulls on the oceans. "
          'That makes the sea rise and fall, usually twice a day. '
          'These are called tides!',
    ],
    followUps: ['What is gravity?', 'Tell me an ocean fact.'],
  ),
  CuratedTopic(
    id: 'plants',
    triggers: [
      ['plant'],
      ['photosynthesis'],
      ['tree'],
      ['grass', 'green'],
    ],
    answers: [
      'Plants make their own food from sunlight, water and air. '
          'This is called photosynthesis. '
          'It also gives off the oxygen we breathe!',
    ],
    followUps: ['Why do leaves change colour?', 'Why does it rain?'],
  ),

  // ------------------------------------------------------- your amazing body
  CuratedTopic(
    id: 'heart',
    triggers: [
      ['heartbeat'],
      ['heart', 'beat'],
      ['my', 'heart'],
      ['the', 'heart'],
      ['human', 'heart'],
    ],
    answers: [
      'Your heart is a muscle about the size of your fist. '
          'It beats around 100,000 times every day!',
    ],
    followUps: ['How many bones do we have?', 'How does my brain work?'],
  ),
  CuratedTopic(
    id: 'bones',
    triggers: [
      ['bone'],
      ['skeleton'],
    ],
    answers: [
      'Grown-ups have 206 bones. '
          'Babies are born with more, and some join together as they grow!',
    ],
    followUps: ['How does my heart work?', 'How does my brain work?'],
  ),
  CuratedTopic(
    id: 'brain',
    triggers: [
      ['brain'],
    ],
    answers: [
      'Your brain sends messages along nerves super fast. '
          "It uses about a fifth of your body's energy, even while you sleep!",
    ],
    followUps: ['Why do we sleep?', 'How does my heart work?'],
  ),
  CuratedTopic(
    id: 'sleep',
    triggers: [
      ['why', 'sleep'],
      ['need', 'sleep'],
      ['dream'],
    ],
    answers: [
      'Sleep helps your body grow and repair itself. '
          'It also helps your brain sort out what you learned that day!',
    ],
    followUps: ['How does my brain work?', 'Why do we yawn?'],
  ),
  CuratedTopic(
    id: 'yawn',
    triggers: [
      ['yawn'],
    ],
    answers: [
      "Scientists aren't completely sure why we yawn! "
          'One idea is that it helps cool down the brain. '
          'Yawns are catching, too!',
    ],
    followUps: ['Why do we sleep?', 'Why do we get hiccups?'],
  ),
  CuratedTopic(
    id: 'hiccups',
    triggers: [
      ['hiccup'],
    ],
    answers: [
      'Hiccups happen when a muscle under your lungs, called the diaphragm, '
          'suddenly tightens. Your throat snaps shut for a moment. Hic!',
    ],
    followUps: ['Why do we yawn?', 'How does my heart work?'],
  ),

  // -------------------------------------------------------------- science
  CuratedTopic(
    id: 'magnets',
    triggers: [
      ['magnet'],
      ['magnetic'],
    ],
    answers: [
      'Magnets pull on some metals, like iron. '
          'Every magnet has a north end and a south end. '
          'Opposite ends pull together, and matching ends push apart!',
    ],
    followUps: ['What is gravity?', 'Why do things float?'],
  ),
  CuratedTopic(
    id: 'float',
    triggers: [
      ['float'],
      ['why', 'sink'],
    ],
    pinned: {'ice': 1},
    answers: [
      'Things float when they push aside water that weighs more than they do. '
          'That is how a huge steel ship can float!',
      'Ice floats because water spreads out when it freezes. '
          'That makes ice lighter than the same amount of liquid water!',
    ],
    followUps: ['How do magnets work?', 'Why is the ocean salty?'],
  ),
  CuratedTopic(
    id: 'water_states',
    triggers: [
      ['ice'],
      ['steam'],
      ['water', 'freeze'],
      ['water', 'boil'],
    ],
    answers: [
      'Water can be solid ice, runny liquid, or a gas called vapour. '
          'Cooling and heating it changes it from one to another!',
    ],
    followUps: ['How does snow form?', 'Why does it rain?'],
  ),
  CuratedTopic(
    id: 'computers',
    triggers: [
      ['computer'],
      ['coding'],
      ['code'],
    ],
    answers: [
      'Computers follow step-by-step instructions called code. '
          'Deep down, everything they do is made of tiny on and off signals!',
    ],
    followUps: ['Are you a robot?', 'Tell me something amazing.'],
  ),
  CuratedTopic(
    id: 'biggest_number',
    triggers: [
      ['biggest', 'number'],
      ['largest', 'number'],
      ['infinity'],
    ],
    answers: [
      "There's no biggest number! You can always add one more. "
          'Mathematicians call that never-ending idea infinity.',
    ],
    followUps: ['Tell me something amazing.', 'How fast is light?'],
  ),

  // -------------------------------------------------------------- history
  CuratedTopic(
    id: 'pyramids',
    triggers: [
      ['pyramid'],
      ['egypt'],
    ],
    answers: [
      'The Great Pyramid of Giza was built about 4,500 years ago. '
          'For thousands of years, it was the tallest building in the world!',
    ],
    followUps: ['Tell me about dinosaurs.', 'Tell me something amazing.'],
  ),

  // --------------------------------------------------------------- jokes
  CuratedTopic(
    id: 'jokes',
    triggers: [
      ['joke'],
      ['funny'],
      ['make', 'me', 'laugh'],
    ],
    answers: [
      'Why did the maths book look sad? Because it had too many problems!',
      'What do you call a sleeping dinosaur? A dino-snore!',
      "Why don't scientists trust atoms? Because they make up everything!",
      'What did one ocean say to the other ocean? Nothing, it just waved!',
    ],
    followUps: ['Tell me another joke.', 'Teach me something amazing.'],
  ),
];
