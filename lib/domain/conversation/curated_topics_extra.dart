part of 'curated_content.dart';

// Third batch of reviewed topics. Same rules as curated_content: short
// sentences, well-established facts, "about" for rounded numbers, honesty
// where science or history is not settled. Placed after _moreTopics so
// earlier, more specific topics keep priority.

const _extraTopics = <CuratedTopic>[
  // ------------------------------------------------------------- feelings
  CuratedTopic(
    id: 'feelings',
    triggers: [
      ["i'm", 'sad'],
      ['i', 'am', 'sad'],
      ['i', 'feel', 'sad'],
      ['feeling', 'sad'],
      ["i'm", 'lonely'],
      ['i', 'feel', 'lonely'],
      ["i'm", 'scared'],
      ['i', 'am', 'scared'],
      ["i'm", 'worried'],
      ['i', 'feel', 'worried'],
      ["i'm", 'upset'],
    ],
    answers: [
      'That sounds hard. Talking to a grown-up you trust, like a parent, '
          'carer or teacher, can really help. '
          'If you like, I can tell you a joke or a fun fact.',
    ],
    followUps: ['Tell me a joke!', 'Teach me something amazing.'],
  ),

  // -------------------------------------------------------------- animals
  CuratedTopic(
    id: 'fish',
    triggers: [
      ['fish'],
    ],
    subject: 'fish',
    pinned: {'breathe': 0, 'gill': 0, 'sleep': 1, 'eye': 1},
    answers: [
      'Fish breathe with gills. '
          'Water flows over the gills, and they take in the oxygen mixed into '
          'the water.',
      'Most fish have no eyelids, so they rest with their eyes open!',
    ],
    followUps: ['Tell me an ocean fact.', 'How do worms breathe?'],
  ),
  CuratedTopic(
    id: 'pandas',
    triggers: [
      ['panda'],
    ],
    subject: 'panda',
    pinned: {'eat': 0, 'bamboo': 0, 'food': 0},
    answers: [
      'Giant pandas eat mostly bamboo. '
          'They can spend about half of every day munching it!',
    ],
    followUps: ['Tell me about polar bears.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'lions',
    triggers: [
      ['lion'],
    ],
    subject: 'lion',
    pinned: {'roar': 0, 'loud': 0, 'pride': 1, 'live': 1, 'group': 1},
    answers: [
      "A lion's roar can be heard up to about 8 kilometres away!",
      'Lions live in family groups called prides.',
    ],
    followUps: ['Why do tigers have stripes?', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'tigers',
    triggers: [
      ['tiger'],
    ],
    subject: 'tiger',
    pinned: {'stripe': 0, 'stripes': 0},
    answers: [
      'Every tiger has its own stripe pattern. '
          'Even the skin underneath its fur is striped!',
    ],
    followUps: ['How loud is a lion\'s roar?', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'polar_bears',
    triggers: [
      ['polar', 'bear'],
    ],
    subject: 'polar bear',
    pinned: {'skin': 0, 'fur': 0, 'white': 0, 'colour': 0, 'color': 0},
    answers: [
      'Polar bears have black skin under their fur. '
          'Their fur hairs are actually see-through, not white!',
    ],
    followUps: ['What do pandas eat?', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'kangaroos',
    triggers: [
      ['kangaroo'],
    ],
    subject: 'kangaroo',
    pinned: {'baby': 0, 'joey': 0, 'pouch': 0, 'big': 0},
    answers: [
      'A baby kangaroo is called a joey. '
          'When it is born, it is only about the size of a jelly bean!',
    ],
    followUps: ['Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'crocodiles',
    triggers: [
      ['crocodile'],
      ['alligator'],
    ],
    subject: 'crocodile',
    pinned: {'tongue': 0, 'old': 1, 'dinosaur': 1},
    answers: [
      "Crocodiles can't stick out their tongues! "
          'Their tongues are joined to the bottom of their mouths.',
      'Crocodiles have been around since the time of the dinosaurs!',
    ],
    followUps: ['Tell me about dinosaurs.', 'Tell me another animal fact.'],
  ),
  CuratedTopic(
    id: 'horses',
    triggers: [
      ['horse'],
      ['pony'],
    ],
    subject: 'horse',
    pinned: {'sleep': 0, 'stand': 0, 'standing': 0},
    answers: [
      'Horses can doze standing up! '
          "Special joints lock their legs so they don't fall over.",
    ],
    followUps: ['How many stomachs does a cow have?'],
  ),
  CuratedTopic(
    id: 'cows',
    triggers: [
      ['cow'],
    ],
    subject: 'cow',
    pinned: {'stomach': 0, 'chew': 0, 'eat': 0},
    answers: [
      'A cow has one stomach with four parts. '
          'It swallows its food, then brings it back up to chew again!',
    ],
    followUps: ['Can horses sleep standing up?'],
  ),
  CuratedTopic(
    id: 'birds',
    triggers: [
      ['bird'],
    ],
    subject: 'bird',
    pinned: {'fly': 0, 'bone': 0, 'light': 0},
    answers: [
      'Many birds have hollow bones. '
          'That keeps them light, which helps them fly!',
    ],
    followUps: ['How well can eagles see?', 'Why can parrots talk?'],
  ),
  CuratedTopic(
    id: 'worms',
    triggers: [
      ['worm'],
      ['earthworm'],
    ],
    subject: 'worm',
    pinned: {'breathe': 0, 'lung': 0},
    answers: ["Earthworms don't have lungs. They breathe through their skin!"],
    followUps: ['How do fish breathe?'],
  ),
  CuratedTopic(
    id: 'eagles',
    triggers: [
      ['eagle'],
    ],
    subject: 'eagle',
    pinned: {'see': 0, 'eye': 0, 'sight': 0},
    answers: [
      'Eagles can spot small animals from very far away. '
          'Their eyesight is several times sharper than ours!',
    ],
    followUps: ['How do birds fly?', 'Why can parrots talk?'],
  ),
  CuratedTopic(
    id: 'parrots',
    triggers: [
      ['parrot'],
    ],
    subject: 'parrot',
    pinned: {'talk': 0, 'speak': 0, 'copy': 0, 'word': 0},
    answers: [
      'Parrots are great at copying sounds, including human words. '
          'Some parrots learn hundreds of words!',
    ],
    followUps: ['How do birds fly?', 'How well can eagles see?'],
  ),

  // ------------------------------------------------- science and machines
  CuratedTopic(
    id: 'planes',
    triggers: [
      ['plane'],
      ['aeroplane'],
      ['airplane'],
    ],
    subject: 'plane',
    pinned: {'fly': 0, 'work': 0, 'stay': 0, 'up': 0},
    answers: [
      "A plane's wings are shaped so moving air pushes them upwards. "
          'That upward push is called lift, and it keeps the plane in the sky!',
    ],
    followUps: ['How do rockets work?', 'How do birds fly?'],
  ),
  CuratedTopic(
    id: 'rockets',
    triggers: [
      ['rocket'],
    ],
    subject: 'rocket',
    pinned: {'work': 0, 'fly': 0, 'launch': 0, 'up': 0},
    answers: [
      'Rockets push hot gas out of the bottom very fast. '
          'The gas pushes back on the rocket and sends it upwards!',
    ],
    followUps: ['How do planes fly?', 'Who was the first person on the Moon?'],
  ),
  CuratedTopic(
    id: 'electricity',
    triggers: [
      ['electricity'],
      ['electric'],
      ['electron'],
    ],
    answers: [
      'Electricity is lots of tiny particles called electrons moving through '
          'wires. It powers lights, phones and much more!',
    ],
    followUps: ['How do batteries work?', 'How do magnets work?'],
  ),
  CuratedTopic(
    id: 'batteries',
    triggers: [
      ['battery'],
    ],
    answers: [
      'A battery stores energy in chemicals. '
          'When you switch something on, the chemicals react and make '
          'electricity flow!',
    ],
    followUps: ['What is electricity?'],
  ),
  CuratedTopic(
    id: 'internet',
    triggers: [
      ['internet'],
      ['wifi'],
    ],
    answers: [
      'The internet is millions of computers connected together. '
          'They send messages to each other in tiny pieces, super fast!',
    ],
    followUps: ['How do mobile phones work?', 'How do computers work?'],
  ),
  CuratedTopic(
    id: 'phones',
    triggers: [
      ['phone', 'work'],
      ['mobile', 'phone'],
      ['how', 'phone'],
    ],
    answers: [
      'Mobile phones send and receive invisible radio waves. '
          'Tall masts pass the signals along to other phones!',
    ],
    followUps: ['What is the internet?', 'What is sound?'],
  ),
  CuratedTopic(
    id: 'sound',
    triggers: [
      ['what', 'is', 'sound'],
      ['how', 'sound', 'travel'],
      ['sound', 'made'],
    ],
    answers: [
      'Sound is made by things vibrating. '
          'The vibrations travel through the air and into your ears!',
    ],
    followUps: ['What is an echo?', 'How loud is a lion\'s roar?'],
  ),
  CuratedTopic(
    id: 'echo',
    triggers: [
      ['echo'],
    ],
    answers: [
      'An echo is sound bouncing back to you off a wall, a cliff or a cave!',
    ],
    followUps: ['What is sound?', 'Can bats see in the dark?'],
  ),

  // ---------------------------------------------------- Earth and weather
  CuratedTopic(
    id: 'sea_blue',
    triggers: [
      ['sea', 'blue'],
      ['ocean', 'blue'],
      ['water', 'blue'],
    ],
    answers: [
      'Water soaks up red light more than blue light. '
          'So deep water looks blue, and it reflects the sky too!',
    ],
    followUps: ['Why is the sky blue?', 'Why is the ocean salty?'],
  ),
  CuratedTopic(
    id: 'wind',
    triggers: [
      ['what', 'makes', 'wind'],
      ['what', 'causes', 'wind'],
      ['why', 'windy'],
      ['wind', 'blow'],
      ['where', 'wind'],
    ],
    answers: [
      'Wind is moving air. '
          'The Sun warms some places more than others, and air flows from '
          'cooler places towards warmer ones!',
    ],
    followUps: ['Why does it rain?', 'What makes waves?'],
  ),
  CuratedTopic(
    id: 'waves',
    triggers: [
      ['wave'],
    ],
    subject: 'wave',
    pinned: {'make': 0, 'made': 0, 'cause': 0},
    answers: ['Most ocean waves are made by wind blowing across the water!'],
    followUps: ['What makes wind?', 'What are tides?'],
  ),
  CuratedTopic(
    id: 'mountains',
    triggers: [
      ['mountain'],
      ['everest'],
    ],
    subject: 'mountain',
    pinned: {'made': 0, 'form': 0, 'tallest': 0, 'highest': 0, 'everest': 0},
    answers: [
      "Many mountains form when giant pieces of Earth's crust push together. "
          'Mount Everest is the tallest above sea level, at almost 9 '
          'kilometres!',
    ],
    followUps: ['Why do earthquakes happen?', 'How do volcanoes work?'],
  ),
  CuratedTopic(
    id: 'deserts',
    triggers: [
      ['desert'],
    ],
    subject: 'desert',
    pinned: {'what': 0, 'rain': 0, 'hot': 0, 'cold': 0},
    answers: [
      'Deserts get very little rain. '
          'Some are scorching by day and freezing at night. '
          'Antarctica counts as a desert too!',
    ],
    followUps: ['What lives in the rainforest?', 'Why does it rain?'],
  ),
  CuratedTopic(
    id: 'rainforests',
    triggers: [
      ['rainforest'],
      ['jungle'],
    ],
    subject: 'rainforest',
    pinned: {'live': 0, 'animal': 0, 'plant': 0},
    answers: [
      "Rainforests are home to a huge share of the world's plants and "
          'animals. Many have not even been discovered yet!',
    ],
    followUps: ['What is a desert?', 'How do plants eat?'],
  ),
  CuratedTopic(
    id: 'earth_core',
    triggers: [
      ['earth', 'core'],
      ['middle', 'earth'],
      ['centre', 'earth'],
      ['center', 'earth'],
    ],
    answers: [
      'The centre of Earth is a giant ball of metal. '
          'It is about as hot as the surface of the Sun!',
    ],
    followUps: ['How do volcanoes work?', 'How old is the Earth?'],
  ),

  // ---------------------------------------------------------------- space
  CuratedTopic(
    id: 'sun_size',
    triggers: [
      ['big', 'sun'],
      ['size', 'sun'],
    ],
    answers: [
      'The Sun is so big that about 1.3 million Earths could fit inside!',
    ],
    followUps: ['How far away is the Sun?', 'How hot is the Sun?'],
  ),
  CuratedTopic(
    id: 'sun_distance',
    triggers: [
      ['far', 'sun'],
      ['distance', 'sun'],
    ],
    answers: [
      'The Sun is about 150 million kilometres away. '
          'Its light takes about 8 minutes to reach us!',
    ],
    followUps: ['How big is the Sun?', 'How far away is the Moon?'],
  ),
  CuratedTopic(
    id: 'earth_age',
    triggers: [
      ['old', 'earth'],
      ['age', 'earth'],
    ],
    answers: ['Earth is about 4.5 billion years old!'],
    followUps: [
      'When did the dinosaurs live?',
      'What is in the middle of the Earth?',
    ],
  ),
  CuratedTopic(
    id: 'moon_follows',
    triggers: [
      ['moon', 'follow'],
      ['moon', 'following'],
    ],
    answers: [
      'The Moon is so far away that it hardly seems to move as you travel. '
          'Nearby trees zoom past, so the Moon looks like it is following you!',
    ],
    followUps: ['How far away is the Moon?', 'Why does the Moon change shape?'],
  ),
  CuratedTopic(
    id: 'moon_landing',
    triggers: [
      ['first', 'moon'],
      ['walk', 'moon'],
      ['moon', 'landing'],
      ['armstrong'],
    ],
    answers: [
      'The first people to walk on the Moon were Neil Armstrong and Buzz '
          'Aldrin, in 1969!',
    ],
    followUps: ['How do rockets work?', 'How far away is the Moon?'],
  ),
  CuratedTopic(
    id: 'jupiter',
    triggers: [
      ['jupiter'],
      ['biggest', 'planet'],
      ['largest', 'planet'],
    ],
    subject: 'Jupiter',
    pinned: {'big': 0, 'biggest': 0, 'largest': 0, 'spot': 0, 'storm': 0},
    answers: [
      'Jupiter is the biggest planet in our Solar System. '
          'Its Great Red Spot is a giant storm wider than Earth!',
    ],
    followUps: ['Is Pluto a planet?', "What are Saturn's rings made of?"],
  ),
  CuratedTopic(
    id: 'pluto',
    triggers: [
      ['pluto'],
    ],
    subject: 'Pluto',
    pinned: {'planet': 0, 'dwarf': 0},
    answers: [
      'Pluto used to be called the ninth planet. '
          'In 2006, scientists renamed it a dwarf planet because it is so small!',
    ],
    followUps: ['How many planets are there?', 'What is the biggest planet?'],
  ),
  CuratedTopic(
    id: 'comets',
    triggers: [
      ['comet'],
    ],
    subject: 'comet',
    pinned: {'what': 0, 'tail': 0},
    answers: [
      'Comets are big balls of ice, dust and rock. '
          'When they get near the Sun, they grow long glowing tails!',
    ],
    followUps: ['What is a black hole?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'aliens',
    triggers: [
      ['alien'],
      ['ufo'],
      ['life', 'space'],
      ['life', 'planet'],
    ],
    subject: 'alien',
    pinned: {'real': 0, 'exist': 0, 'life': 0, 'there': 0},
    answers: [
      "Scientists haven't found life beyond Earth yet. "
          "But they're searching, on Mars, on icy moons and around faraway "
          'stars!',
    ],
    followUps: ['Why is Mars red?', 'What is a black hole?'],
  ),

  // -------------------------------------------------------------- history
  CuratedTopic(
    id: 'light_bulb',
    triggers: [
      ['light', 'bulb'],
      ['lightbulb'],
    ],
    answers: [
      'Many inventors worked on electric light. '
          'Thomas Edison and Joseph Swan both made some of the first practical '
          'light bulbs, around 1879!',
    ],
    followUps: ['Who invented the telephone?', 'What is electricity?'],
  ),
  CuratedTopic(
    id: 'telephone',
    triggers: [
      ['telephone'],
      ['invented', 'phone'],
    ],
    answers: [
      'Alexander Graham Bell got the first patent for a telephone in 1876. '
          'Other inventors were working on the idea too!',
    ],
    followUps: ['Who invented the light bulb?', 'How do mobile phones work?'],
  ),

  // ----------------------------------------------------- your amazing body
  CuratedTopic(
    id: 'sneeze',
    triggers: [
      ['sneeze'],
      ['sneezing'],
    ],
    answers: [
      'A sneeze is your body clearing dust or germs out of your nose. '
          'The air rushes out super fast!',
    ],
    followUps: ['Why do we blink?', 'Why do we get hiccups?'],
  ),
  CuratedTopic(
    id: 'body_water',
    triggers: [
      ['need', 'water'],
      ['body', 'water'],
    ],
    answers: [
      'More than half of your body is water! '
          'It helps carry food around your body and keeps you cool.',
    ],
    followUps: ['How does my heart work?', 'Why do we sleep?'],
  ),
  CuratedTopic(
    id: 'teeth',
    triggers: [
      ['my', 'teeth'],
      ['baby', 'teeth'],
      ['how', 'many', 'teeth', 'we'],
      ['how', 'many', 'teeth', 'i'],
      ['lose', 'teeth'],
      ['wobbly', 'tooth'],
    ],
    answers: [
      'Children have 20 baby teeth. '
          'Grown-ups usually have 32 adult teeth!',
    ],
    followUps: ['How many bones do we have?', 'Why do we blink?'],
  ),
  CuratedTopic(
    id: 'blink',
    triggers: [
      ['blink'],
    ],
    answers: [
      'Blinking spreads tears over your eyes to keep them clean and wet. '
          'You blink thousands of times a day!',
    ],
    followUps: ['Why do we sneeze?', 'Why do we yawn?'],
  ),
  CuratedTopic(
    id: 'goosebumps',
    triggers: [
      ['goosebump'],
      ['goose', 'bump'],
    ],
    answers: [
      'Goosebumps happen when tiny muscles in your skin pull your hairs up. '
          'They can pop up when you are cold or excited!',
    ],
    followUps: ['Why do we blink?', 'Why do my fingers wrinkle?'],
  ),
  CuratedTopic(
    id: 'wrinkly_fingers',
    triggers: [
      ['finger', 'wrinkle'],
      ['finger', 'wrinkly'],
      ['wrinkly', 'bath'],
    ],
    answers: [
      'Your fingers wrinkle in water because your nerves tell them to! '
          'Scientists think it may help you grip wet things.',
    ],
    followUps: ['Why do we get goosebumps?', 'Why do we need water?'],
  ),
  CuratedTopic(
    id: 'taste_buds',
    triggers: [
      ['taste', 'bud'],
      ['how', 'taste'],
    ],
    answers: ['You have thousands of taste buds, mostly on your tongue!'],
    followUps: ['How many teeth do we have?', 'Why do we sneeze?'],
  ),

  // ------------------------------------------------------------ riddles
  CuratedTopic(
    id: 'riddles',
    triggers: [
      ['riddle'],
    ],
    answers: [
      "What has keys but can't open locks? A piano!",
      "What has hands but can't clap? A clock!",
      'What gets wetter the more it dries? A towel!',
    ],
    followUps: ['Tell me another riddle.', 'Tell me a joke!'],
  ),
];
