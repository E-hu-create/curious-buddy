import 'quiz.dart';

/// The starter quizzes: four topics, three levels each, five questions per
/// level. Facts are well established and agree with Buddy's own answers
/// (curated_content.dart). Wrong answers are clearly wrong, not tricks.
/// test/domain/quiz checks every question with QuizValidator.
final starterQuizTopics = <QuizTopic>[_space, _animals, _body, _earth];

/// Option ids are a, b, c, d in the order written; [answer] is the index of
/// the correct one.
QuizQuestion _q(
  String id,
  String prompt,
  List<String> options,
  int answer,
  String explanation,
) {
  const ids = ['a', 'b', 'c', 'd'];
  return QuizQuestion(
    id: id,
    prompt: prompt,
    options: [
      for (final (i, text) in options.indexed)
        QuizOption(id: ids[i], text: text),
    ],
    answerId: ids[answer],
    explanation: explanation,
  );
}

// ------------------------------------------------------------------- Space

final _space = QuizTopic(
  id: 'space',
  title: 'Space',
  tagline: 'Planets, stars and the Moon.',
  levels: [
    QuizLevel(
      id: 'space_starter',
      difficulty: QuizDifficulty.starter,
      questions: [
        _q(
          'closest_star',
          'Which star is closest to Earth?',
          ['The North Star', 'The Sun', 'A shooting star', 'The Dog Star'],
          1,
          'The Sun is a star, and it is the closest one to us. Its light takes '
              'about 8 minutes to reach Earth.',
        ),
        _q(
          'planet_count',
          'How many planets are in our Solar System?',
          ['Eight', 'Nine', 'Seven', 'Twelve'],
          0,
          'There are eight planets. Pluto used to be called the ninth, but in '
              '2006 scientists renamed it a dwarf planet.',
        ),
        _q(
          'astronaut',
          'What do we call a person who travels into space?',
          ['A pilot', 'A sailor', 'An astronaut', 'A lifeguard'],
          2,
          'Astronauts train for years to live and work in space.',
        ),
        _q(
          'home_planet',
          'Which planet do we live on?',
          ['Mars', 'Venus', 'Jupiter', 'Earth'],
          3,
          'We live on Earth, the third planet from the Sun.',
        ),
        _q(
          'moon_shine',
          'Why does the Moon shine at night?',
          [
            'It reflects light from the Sun',
            'It is on fire',
            'It makes its own light',
          ],
          0,
          'The Moon does not make light. Sunlight bounces off it, like light '
              'off a mirror.',
        ),
      ],
    ),
    QuizLevel(
      id: 'space_explorer',
      difficulty: QuizDifficulty.explorer,
      questions: [
        _q(
          'red_planet',
          'Which planet is called the Red Planet?',
          ['Jupiter', 'Neptune', 'Mars', 'Venus'],
          2,
          'Mars looks red because its dust has lots of iron in it, a bit like '
              'rust.',
        ),
        _q(
          'biggest_planet',
          'Which is the biggest planet in our Solar System?',
          ['Earth', 'Jupiter', 'Saturn', 'Mercury'],
          1,
          'Jupiter is the biggest planet. More than a thousand Earths could '
              'fit inside it.',
        ),
        _q(
          'rings',
          'Which planet is famous for its huge, bright rings?',
          ['Saturn', 'Mars', 'Mercury', 'Venus'],
          0,
          "Saturn's rings are made of countless pieces of ice and rock.",
        ),
        _q(
          'year',
          'About how long does Earth take to travel once around the Sun?',
          ['One day', 'One month', 'One hundred years', 'One year'],
          3,
          'One trip around the Sun takes about 365 days. That is what a year '
              'is!',
        ),
        _q(
          'moon_walk',
          'In which year did people first walk on the Moon?',
          ['1909', '1969', '1999', '2019'],
          1,
          'Neil Armstrong and Buzz Aldrin walked on the Moon in 1969.',
        ),
      ],
    ),
    QuizLevel(
      id: 'space_expert',
      difficulty: QuizDifficulty.expert,
      questions: [
        _q(
          'closest_to_sun',
          'Which planet is closest to the Sun?',
          ['Venus', 'Mercury', 'Earth', 'Mars'],
          1,
          'Mercury is the closest planet to the Sun, and also the smallest '
              'planet.',
        ),
        _q(
          'hottest_planet',
          'Which planet is the hottest?',
          ['Mercury', 'Mars', 'Jupiter', 'Venus'],
          3,
          'Venus is hotter than Mercury, even though it is farther from the '
              'Sun. Its thick clouds trap the heat like a blanket.',
        ),
        _q(
          'pluto',
          'What do scientists call Pluto now?',
          ['A dwarf planet', 'A star', 'A comet', 'A moon of Earth'],
          0,
          'In 2006, scientists renamed Pluto a dwarf planet. It is even '
              'smaller than our Moon.',
        ),
        _q(
          'sunlight_time',
          'About how long does sunlight take to reach Earth?',
          [
            'About 8 seconds',
            'About 8 hours',
            'About 8 minutes',
            'About 8 days',
          ],
          2,
          'The Sun is about 150 million kilometres away, so its light takes '
              'about 8 minutes to reach us.',
        ),
        _q(
          'black_hole',
          'What is a black hole?',
          [
            'A tunnel through Earth',
            'A place where gravity traps even light',
            'A planet painted black',
            'The shadow of the Moon',
          ],
          1,
          'A black hole squeezes so much stuff into a small space that its '
              'gravity pulls in everything nearby, even light.',
        ),
      ],
    ),
  ],
);

// ----------------------------------------------------------------- Animals

final _animals = QuizTopic(
  id: 'animals',
  title: 'Animals',
  tagline: 'Wild facts about amazing creatures.',
  levels: [
    QuizLevel(
      id: 'animals_starter',
      difficulty: QuizDifficulty.starter,
      questions: [
        _q(
          'biggest_animal',
          'What is the biggest animal that has ever lived?',
          ['The African elephant', 'The blue whale', 'T. rex', 'The giraffe'],
          1,
          'The blue whale is the biggest animal that has ever lived, even '
              'bigger than the largest dinosaurs.',
        ),
        _q(
          'tallest',
          'Which animal is the tallest?',
          ['The giraffe', 'The elephant', 'The horse', 'The camel'],
          0,
          'Giraffes are the tallest animals. Their long necks help them reach '
              'leaves high up in trees.',
        ),
        _q(
          'spider_legs',
          'How many legs does a spider have?',
          ['Six', 'Ten', 'Eight', 'Four'],
          2,
          'Spiders have eight legs. Insects, like ants and bees, have six.',
        ),
        _q(
          'bees',
          'What do honeybees make?',
          ['Milk', 'Silk', 'Wool', 'Honey'],
          3,
          'Honeybees make honey from the nectar of flowers and store it in '
              'their hive.',
        ),
        _q(
          'mammal',
          'Which of these animals is a mammal?',
          ['A shark', 'A goldfish', 'A dolphin', 'An octopus'],
          2,
          'Dolphins are mammals. They breathe air and feed their babies milk.',
        ),
      ],
    ),
    QuizLevel(
      id: 'animals_explorer',
      difficulty: QuizDifficulty.explorer,
      questions: [
        _q(
          'fastest',
          'What is the fastest land animal?',
          ['The lion', 'The horse', 'The cheetah', 'The kangaroo'],
          2,
          'Cheetahs can run about 100 kilometres per hour, but only for short '
              'sprints.',
        ),
        _q(
          'baby_frog',
          'What is a baby frog called?',
          ['A tadpole', 'A kitten', 'A cub', 'A chick'],
          0,
          'Frogs hatch from eggs as tadpoles. Tadpoles live in water and '
              'slowly grow legs.',
        ),
        _q(
          'caterpillar',
          'What does a caterpillar grow into?',
          ['A spider', 'A beetle', 'A worm', 'A butterfly or moth'],
          3,
          'A caterpillar makes a case around itself and changes inside it, '
              'coming out as a butterfly or moth.',
        ),
        _q(
          'penguins',
          'Penguins cannot fly. What are they brilliant at?',
          ['Swimming', 'Climbing trees', 'Digging tunnels'],
          0,
          'Penguins use their wings like flippers. They are fast, strong '
              'swimmers.',
        ),
        _q(
          'chameleon',
          'Which animal can change the colour of its skin?',
          ['The elephant', 'The chameleon', 'The owl', 'The rabbit'],
          1,
          'Chameleons change colour to show their mood and to warm up or cool '
              'down.',
        ),
      ],
    ),
    QuizLevel(
      id: 'animals_expert',
      difficulty: QuizDifficulty.expert,
      questions: [
        _q(
          'bats',
          'How do many bats find food in the dark?',
          [
            'They glow like fireflies',
            'They listen to echoes of their calls',
            'They follow the Moon',
            'They smell the walls',
          ],
          1,
          'Many bats make high sounds and listen to the echoes that bounce '
              'back. This is called echolocation.',
        ),
        _q(
          'octopus_hearts',
          'How many hearts does an octopus have?',
          ['One', 'Two', 'Eight', 'Three'],
          3,
          'An octopus has three hearts. Two pump blood to its gills, and one '
              'pumps it around its body.',
        ),
        _q(
          'pride',
          'What is a group of lions called?',
          ['A pride', 'A pack', 'A flock', 'A school'],
          0,
          'Lions live in groups called prides. Most other big cats live alone.',
        ),
        _q(
          'reptile',
          'Which of these animals is a reptile?',
          ['A frog', 'A dolphin', 'A crocodile', 'A penguin'],
          2,
          'Crocodiles are reptiles, with scaly skin. Frogs are amphibians, '
              'dolphins are mammals and penguins are birds.',
        ),
        _q(
          'owl_heads',
          'Why do owls turn their heads so far?',
          [
            'To scare mice',
            'Their eyes cannot move',
            'To dry their feathers',
            'To hear music',
          ],
          1,
          "Owls can't move their eyes, so they turn their heads instead, about "
              'three-quarters of the way around.',
        ),
      ],
    ),
  ],
);

// ------------------------------------------------------------ Amazing Body

final _body = QuizTopic(
  id: 'body',
  title: 'Amazing Body',
  tagline: 'How your own body works.',
  levels: [
    QuizLevel(
      id: 'body_starter',
      difficulty: QuizDifficulty.starter,
      questions: [
        _q(
          'heart',
          'Which part of your body pumps blood?',
          ['Your lungs', 'Your heart', 'Your stomach', 'Your brain'],
          1,
          'Your heart is a strong muscle. It beats all day and night, pumping '
              'blood around your body.',
        ),
        _q(
          'lungs',
          'What do your lungs help you do?',
          ['Breathe', 'See', 'Hear', 'Taste'],
          0,
          'Your lungs take in air, so oxygen can get into your blood.',
        ),
        _q(
          'adult_teeth',
          'How many adult teeth do grown-ups usually have?',
          ['20', '50', '32', '100'],
          2,
          'Children have 20 baby teeth. Grown-ups usually have 32 adult '
              'teeth.',
        ),
        _q(
          'nose',
          'Which sense do you use your nose for?',
          ['Touch', 'Sight', 'Hearing', 'Smell'],
          3,
          'Your nose is for smelling. Smell also helps you taste your food.',
        ),
        _q(
          'skull',
          'What protects your brain?',
          ['Your skull', 'Your ribs', 'Your hair', 'Your knees'],
          0,
          'Your skull is a hard case of bone that keeps your brain safe.',
        ),
      ],
    ),
    QuizLevel(
      id: 'body_explorer',
      difficulty: QuizDifficulty.explorer,
      questions: [
        _q(
          'bones',
          'How many bones does a grown-up have?',
          ['About 50', 'About 1,000', 'About 12', '206'],
          3,
          'Grown-ups have 206 bones. Babies are born with more, and some join '
              'together as they grow.',
        ),
        _q(
          'largest_organ',
          'What is the largest organ of your body?',
          ['Your skin', 'Your liver', 'Your heart', 'Your brain'],
          0,
          'Your skin is your largest organ. It keeps germs out and helps you '
              'stay at the right temperature.',
        ),
        _q(
          'sleep',
          'Why does your body need sleep?',
          [
            'To keep your bed warm',
            'To rest, grow and remember',
            'To make your hair longer',
          ],
          1,
          'While you sleep, your body rests and grows, and your brain sorts '
              'out what you learned.',
        ),
        _q(
          'stomach',
          'What does your stomach do?',
          [
            'Pumps blood',
            'Helps you see',
            'Helps break down food',
            'Makes your bones',
          ],
          2,
          'Your stomach squeezes and mixes food with special juices to break '
              'it down.',
        ),
        _q(
          'taste',
          'Where are most of your taste buds?',
          ['On your ears', 'On your tongue', 'On your elbows', 'In your hair'],
          1,
          'Your tongue is covered in thousands of tiny taste buds.',
        ),
      ],
    ),
    QuizLevel(
      id: 'body_expert',
      difficulty: QuizDifficulty.expert,
      questions: [
        _q(
          'nerves',
          'What carries messages between your brain and your body?',
          ['Your nerves', 'Your muscles', 'Your hair', 'Your fingernails'],
          0,
          'Your brain sends messages along nerves super fast, so you can move '
              'and feel.',
        ),
        _q(
          'oxygen_cells',
          'Which cells carry oxygen around your body?',
          ['Skin cells', 'Bone cells', 'Red blood cells', 'Hair cells'],
          2,
          'Red blood cells pick up oxygen in your lungs and carry it all '
              'around your body.',
        ),
        _q(
          'smallest_bone',
          'Where is the smallest bone in your body?',
          ['In your toe', 'In your knee', 'In your nose', 'In your ear'],
          3,
          'The stirrup bone, deep inside your ear, is smaller than a grain of '
              'rice. It helps you hear.',
        ),
        _q(
          'body_water',
          'How much of your body is water?',
          ['Almost none', 'More than half', 'All of it'],
          1,
          'More than half of your body is water. It carries food around your '
              'body and keeps you cool.',
        ),
        _q(
          'pupils',
          'What happens to your pupils in bright light?',
          [
            'They get smaller',
            'They get bigger',
            'They change colour',
            'They disappear',
          ],
          0,
          'Your pupils are the dark circles in your eyes. They shrink in '
              'bright light to let in less light.',
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------- Earth & Weather

final _earth = QuizTopic(
  id: 'earth',
  title: 'Earth & Weather',
  tagline: 'Rain, oceans, volcanoes and more.',
  levels: [
    QuizLevel(
      id: 'earth_starter',
      difficulty: QuizDifficulty.starter,
      questions: [
        _q(
          'rain',
          'What do we call water falling from clouds?',
          ['Fog', 'Rain', 'Dew', 'Steam'],
          1,
          'Rain falls when tiny water drops in clouds join up and get too '
              'heavy to float.',
        ),
        _q(
          'rainbow',
          'What do you need to see a rainbow?',
          [
            'Sunlight and raindrops',
            'Snow and wind',
            'Thunder and clouds',
            'Moonlight and fog',
          ],
          0,
          'Raindrops split sunlight into its colours. You see a rainbow when '
              'the Sun is behind you and rain is in front.',
        ),
        _q(
          'ice',
          'What is frozen water called?',
          ['Steam', 'Sand', 'Ice', 'Salt'],
          2,
          'Water freezes into ice when it gets cold enough, at 0 degrees '
              'Celsius.',
        ),
        _q(
          'biggest_ocean',
          'Which is the biggest ocean?',
          ['The Atlantic', 'The Indian', 'The Arctic', 'The Pacific'],
          3,
          'The Pacific is the biggest and deepest ocean on Earth.',
        ),
        _q(
          'lightning_first',
          'In a storm, which do you notice first?',
          ['The thunder', 'The lightning flash', 'They always arrive together'],
          1,
          'Light travels much faster than sound, so you see the flash before '
              'you hear the thunder.',
        ),
      ],
    ),
    QuizLevel(
      id: 'earth_explorer',
      difficulty: QuizDifficulty.explorer,
      questions: [
        _q(
          'volcano',
          'What is a volcano?',
          [
            'A very tall tree',
            'A giant cloud',
            'An opening where melted rock comes out',
            'A frozen lake',
          ],
          2,
          'Deep underground, rock is so hot that it melts. A volcano is where '
              'it bursts out.',
        ),
        _q(
          'salty_sea',
          'Why is the sea salty?',
          [
            'Fish add salt to it',
            'Rivers carry salt from rocks into it',
            'People pour salt in',
            'Rain is very salty',
          ],
          1,
          'Rain wears away rocks and rivers carry tiny bits of salt to the '
              'sea. Over millions of years, the ocean became salty.',
        ),
        _q(
          'seasons',
          'What gives us the seasons?',
          [
            'Earth leans as it circles the Sun',
            'The Moon blocks the Sun',
            'Clouds move around',
            'The Sun switches off',
          ],
          0,
          'Earth leans over like a tilted spinning top. When your half leans '
              'towards the Sun, it is summer.',
        ),
        _q(
          'sahara',
          'Which is the largest hot desert in the world?',
          ['The Gobi', 'The Kalahari', 'The Mojave', 'The Sahara'],
          3,
          'The Sahara, in Africa, is the largest hot desert. It is almost as '
              'big as the United States.',
        ),
        _q(
          'tides',
          'What mainly causes the tides in the sea?',
          ["The Moon's gravity", 'Whales swimming', 'Boats', 'Fish'],
          0,
          "The Moon's gravity gently pulls on the oceans, so the sea rises and "
              'falls, usually twice a day.',
        ),
      ],
    ),
    QuizLevel(
      id: 'earth_expert',
      difficulty: QuizDifficulty.expert,
      questions: [
        _q(
          'water_states',
          'Which three forms can water take?',
          [
            'Hot, warm and cold',
            'Rain, snow and hail',
            'Solid, liquid and gas',
            'Salt, fresh and sea',
          ],
          2,
          'Water can be a solid (ice), a liquid (water) or a gas (water '
              'vapour).',
        ),
        _q(
          'core',
          'What is the centre of Earth called?',
          ['The crust', 'The core', 'The equator', 'The surface'],
          1,
          'The core is a giant ball of metal at the centre of Earth. It is '
              'about as hot as the surface of the Sun.',
        ),
        _q(
          'earthquakes',
          'What causes earthquakes?',
          [
            'Strong winds',
            'Heavy rain',
            'Big waves',
            'Giant plates of rock slipping',
          ],
          3,
          "Earth's outer shell is broken into giant plates. When they suddenly "
              'slip past each other, the ground shakes.',
        ),
        _q(
          'plants_gas',
          'Which gas do plants take in to make their food?',
          ['Carbon dioxide', 'Helium', 'Neon'],
          0,
          'Plants use sunlight, water and carbon dioxide to make food, and '
              'they give out oxygen.',
        ),
        _q(
          'everest',
          'What is the highest mountain above sea level?',
          ['Kilimanjaro', 'Mount Everest', 'Mont Blanc', 'Mount Fuji'],
          1,
          'Mount Everest, in the Himalayas, is the highest mountain above sea '
              'level, nearly 9 kilometres high.',
        ),
      ],
    ),
  ],
);
