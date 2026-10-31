import 'quiz.dart';
import 'quiz_content.dart';

/// Every quiz topic in the app, starter ones first.
final allQuizTopics = <QuizTopic>[...starterQuizTopics, ...moreQuizTopics];

/// Six more topics, three levels each, five questions per level. As with the
/// starter quizzes: facts are well established, and wrong answers are clearly
/// wrong, not tricks.
final moreQuizTopics = <QuizTopic>[
  _dinosaurs,
  _oceans,
  _plants,
  _energy,
  _matter,
  _inventions,
];

final _q = QuizQuestion.fromList;

QuizLevel _level(
  String topic,
  QuizDifficulty difficulty,
  List<QuizQuestion> questions,
) => QuizLevel(
  id: '${topic}_${difficulty.name}',
  difficulty: difficulty,
  questions: questions,
);

// --------------------------------------------------------------- Dinosaurs

final _dinosaurs = QuizTopic(
  id: 'dinosaurs',
  title: 'Dinosaurs & Fossils',
  tagline: 'Giant creatures and the clues they left.',
  levels: [
    _level('dinosaurs', QuizDifficulty.starter, [
      _q(
        'fossil_scientist',
        'What do we call a scientist who studies fossils?',
        ['A chef', 'A palaeontologist', 'A pilot', 'A plumber'],
        1,
        'Palaeontologists study fossils to learn about life long ago.',
      ),
      _q(
        'triceratops_horns',
        'How many horns did Triceratops have on its face?',
        ['One', 'Two', 'Three', 'Ten'],
        2,
        'Its name means "three-horned face": two long horns above its eyes, '
            'and a short one on its nose.',
      ),
      _q(
        'stegosaurus_back',
        'Which dinosaur had big plates along its back?',
        ['Stegosaurus', 'Tyrannosaurus', 'Diplodocus', 'Allosaurus'],
        0,
        'Stegosaurus had tall bony plates on its back, and spikes on its tail.',
      ),
      _q(
        'what_is_fossil',
        'What is a fossil?',
        [
          'A kind of cloud',
          'A new type of plant',
          'A shiny metal',
          'The remains of ancient life in rock',
        ],
        3,
        'Fossils are the preserved remains or traces of living things from '
            'long ago, usually found in rock.',
      ),
      _q(
        'rex_food',
        'What did Tyrannosaurus eat?',
        ['Meat', 'Grass', 'Leaves', 'Seaweed'],
        0,
        'Tyrannosaurus was a huge meat eater, with teeth up to the length of '
            'a banana, roots included.',
      ),
    ]),
    _level('dinosaurs', QuizDifficulty.explorer, [
      _q(
        'first_period',
        'Which of these time periods came first?',
        ['Cretaceous', 'Jurassic', 'Triassic'],
        2,
        'The order is Triassic, then Jurassic, then Cretaceous. Dinosaurs '
            'first appeared in the Triassic.',
      ),
      _q(
        'living_relatives',
        'Which animals alive today are descended from dinosaurs?',
        ['Birds', 'Cats', 'Fish', 'Frogs'],
        0,
        'Birds evolved from small feathered dinosaurs, so in a way dinosaurs '
            'are still with us.',
      ),
      _q(
        'long_neck',
        'Which of these dinosaurs had a very long neck and tail?',
        ['Triceratops', 'Diplodocus', 'Stegosaurus', 'Ankylosaurus'],
        1,
        'Diplodocus was about 25 metres long, much of it neck and tail.',
      ),
      _q(
        'pteranodon_group',
        'What kind of animal was Pteranodon?',
        ['A flying reptile', 'A dinosaur', 'A bird', 'A bat'],
        0,
        'Pteranodon was a pterosaur, a flying reptile that lived alongside '
            'dinosaurs but was not one.',
      ),
      _q(
        'dinosaur_meaning',
        'What does the word "dinosaur" mean?',
        ['Fast runner', 'Old bird', 'Big tooth', 'Terrible lizard'],
        3,
        'The name was made in 1842 from Greek words meaning "terrible lizard".',
      ),
    ]),
    _level('dinosaurs', QuizDifficulty.expert, [
      _q(
        'dino_extinction_date',
        'About how long ago did the last non-bird dinosaurs die out?',
        [
          '66 million years ago',
          '66 thousand years ago',
          '6 thousand years ago',
          '6 billion years ago',
        ],
        0,
        'They died out about 66 million years ago, long before the first '
            'humans.',
      ),
      _q(
        'extinction_cause',
        'What do most scientists think caused that extinction?',
        [
          'A very long winter of snow',
          'A huge asteroid hitting Earth',
          'Too many flowers',
          'People hunting them',
        ],
        1,
        'A giant asteroid struck what is now Mexico. It changed the climate '
            'and helped end the age of dinosaurs.',
      ),
      _q(
        'mary_anning',
        'Who was the famous young fossil hunter from Lyme Regis, England?',
        ['Marie Curie', 'Ada Lovelace', 'Mary Anning', 'Jane Austen'],
        2,
        'Mary Anning found important fossils from the age of 12, including a '
            'huge ichthyosaur, over 200 years ago.',
      ),
      _q(
        'oldest_layers',
        'In undisturbed rock, where are the oldest layers usually found?',
        ['At the top', 'In the middle', 'On the side', 'At the bottom'],
        3,
        'New layers settle on top of older ones, so the lowest layers are '
            'usually the oldest.',
      ),
      _q(
        'coprolite',
        'What is a coprolite?',
        [
          'A fossil animal dropping',
          'A fossil dinosaur egg',
          'A fossil footprint',
          'A kind of crystal',
        ],
        0,
        'Coprolites are fossil droppings. They can show scientists what '
            'ancient animals ate!',
      ),
    ]),
  ],
);

// ------------------------------------------------------------------ Oceans

final _oceans = QuizTopic(
  id: 'oceans',
  title: 'Oceans',
  tagline: 'Whales, reefs and the deep blue sea.',
  levels: [
    _level('oceans', QuizDifficulty.starter, [
      _q(
        'ocean_cover',
        'About how much of Earth is covered by the ocean?',
        ['A tenth', 'A quarter', 'Half', 'Over two thirds'],
        3,
        'About 70 percent of Earth is covered by the ocean, which is why it '
            'looks blue from space.',
      ),
      _q(
        'largest_ocean',
        'Which is the largest ocean?',
        ['The Pacific', 'The Atlantic', 'The Indian', 'The Arctic'],
        0,
        'The Pacific is the largest and deepest ocean of all.',
      ),
      _q(
        'seahorse_dad',
        'Which seahorse parent carries the babies in a pouch?',
        ['The mother', 'The father', 'The grandmother', 'Neither of them'],
        1,
        'Seahorses are unusual: the female lays her eggs in a pouch on the male, '
            'and he carries them until they hatch.',
      ),
      _q(
        'sea_salty',
        'What does seawater taste like?',
        ['Sweet', 'Salty', 'Sour', 'Of nothing'],
        1,
        'Rivers carry tiny amounts of salts from rocks into the sea, and over '
            'time they have built up.',
      ),
      _q(
        'dolphin_breath',
        'How do dolphins breathe?',
        [
          'They do not breathe',
          'With gills underwater',
          'Through a blowhole at the surface',
          'Through their skin',
        ],
        2,
        'Dolphins are mammals, so they come up to breathe air through a '
            'blowhole on top of their heads.',
      ),
    ]),
    _level('oceans', QuizDifficulty.explorer, [
      _q(
        'great_barrier',
        'Which country is the Great Barrier Reef next to?',
        ['Australia', 'Canada', 'Egypt', 'Norway'],
        0,
        'The Great Barrier Reef lies off the coast of Australia, and it is the '
            'largest coral reef system in the world.',
      ),
      _q(
        'octopus_ink',
        'Why does an octopus squirt ink?',
        [
          'To write messages',
          'To clean its home',
          'To hide and escape',
          'To catch the sun',
        ],
        2,
        'The dark cloud confuses a predator, giving the octopus time to get '
            'away.',
      ),
      _q(
        'fish_gills',
        'What do most fish use to take oxygen from water?',
        ['Fins', 'Scales', 'Tails', 'Gills'],
        3,
        'As water flows over the gills, oxygen passes into the fish\'s blood.',
      ),
      _q(
        'coral_builders',
        'What are coral reefs built by?',
        [
          'Tiny animals called polyps',
          'Waves piling up sand',
          'Giant clams',
          'Fish carrying stones',
        ],
        0,
        'Coral polyps are tiny animals. They build hard skeletons that slowly '
            'grow into huge reefs.',
      ),
      _q(
        'shark_skeleton',
        'What is a shark\'s skeleton made of?',
        ['Solid bone', 'Wood', 'Cartilage', 'Shell'],
        2,
        'Sharks have skeletons of cartilage, the bendy material in your nose '
            'and ears.',
      ),
    ]),
    _level('oceans', QuizDifficulty.expert, [
      _q(
        'deepest_place',
        'What is the deepest known part of the ocean?',
        [
          'The Bermuda Triangle',
          'The Great Blue Hole',
          'The North Sea',
          'The Mariana Trench',
        ],
        3,
        'The Mariana Trench in the Pacific is about 11 kilometres deep at its '
            'lowest point.',
      ),
      _q(
        'bioluminescence',
        'What do we call it when living things make their own light?',
        ['Bioluminescence', 'Evaporation', 'Migration', 'Photosynthesis'],
        0,
        'Many deep-sea animals make their own light, using chemicals in their '
            'bodies.',
      ),
      _q(
        'ocean_oxygen',
        'About how much of our oxygen comes from tiny ocean life?',
        ['Almost none', 'About half', 'All of it'],
        1,
        'Plankton and other tiny ocean life make about half of the oxygen '
            'produced on Earth.',
      ),
      _q(
        'plankton',
        'What is plankton?',
        [
          'A type of whale',
          'Tiny drifting living things',
          'Ocean rock',
          'Sea ice',
        ],
        1,
        'Plankton are tiny living things that drift in the water, and they '
            'feed much of the sea.',
      ),
      _q(
        'whale_song_far',
        'Why can whales hear each other from so far away?',
        [
          'Water carries sound very well',
          'Whales shout through the air',
          'Fish pass on the message',
          'Waves carry the words',
        ],
        0,
        'Sound travels faster and further in water than in air, so low whale '
            'calls can cross huge distances.',
      ),
    ]),
  ],
);

// ------------------------------------------------------------------ Plants

final _plants = QuizTopic(
  id: 'plants',
  title: 'Plants & Bugs',
  tagline: 'Seeds, bees and tiny busy creatures.',
  levels: [
    _level('plants', QuizDifficulty.starter, [
      _q(
        'plants_need',
        'What do plants use to make their food?',
        ['Sunlight', 'Moonlight', 'Music', 'Sand'],
        0,
        'Plants use sunlight, water and air to make their own food.',
      ),
      _q(
        'insect_legs',
        'How many legs does an insect have?',
        ['Four', 'Six', 'Eight', 'Ten'],
        1,
        'All adult insects have six legs. Spiders have eight, so they are not '
            'insects.',
      ),
      _q(
        'caterpillar_becomes',
        'What does a caterpillar turn into?',
        ['A beetle', 'A worm', 'A butterfly or moth', 'A bee'],
        2,
        'A caterpillar forms a chrysalis or cocoon, and comes out as a '
            'butterfly or moth.',
      ),
      _q(
        'honey_maker',
        'Which insect makes honey?',
        ['The ant', 'The fly', 'The ladybird', 'The honeybee'],
        3,
        'Honeybees turn flower nectar into honey, and store it to eat in '
            'winter.',
      ),
      _q(
        'plant_roots',
        'Which part of a plant takes in water from the soil?',
        ['The petals', 'The roots', 'The seeds', 'The flowers'],
        1,
        'Roots hold the plant in the ground, and take in water and minerals.',
      ),
    ]),
    _level('plants', QuizDifficulty.explorer, [
      _q(
        'photosynthesis',
        'What is the name for how plants make food from sunlight?',
        ['Photosynthesis', 'Evaporation', 'Digestion', 'Hibernation'],
        0,
        'In photosynthesis, plants use sunlight to turn water and carbon '
            'dioxide into sugar.',
      ),
      _q(
        'plant_gas_in',
        'Which gas do plants take in from the air to make food?',
        ['Helium', 'Carbon dioxide', 'Neon', 'Hydrogen'],
        1,
        'Plants take in carbon dioxide through tiny holes in their leaves.',
      ),
      _q(
        'plant_gas_out',
        'Which useful gas do plants give out?',
        ['Steam', 'Smoke', 'Oxygen', 'Helium'],
        2,
        'Plants give out oxygen, which animals and people need to breathe.',
      ),
      _q(
        'pollination',
        'What is it called when pollen moves from flower to flower?',
        ['Migration', 'Erosion', 'Reflection', 'Pollination'],
        3,
        'Pollination lets flowers make seeds and fruit. Bees and other animals '
            'help carry the pollen.',
      ),
      _q(
        'insect_body',
        'How many main parts does an insect\'s body have?',
        ['Three', 'Five', 'One', 'Eight'],
        0,
        'An insect has a head, a thorax and an abdomen.',
      ),
    ]),
    _level('plants', QuizDifficulty.expert, [
      _q(
        'chlorophyll',
        'What makes leaves green?',
        ['Chlorophyll', 'Iron', 'Salt', 'Water'],
        0,
        'Chlorophyll is the green substance that plants use to capture energy '
            'from sunlight.',
      ),
      _q(
        'metamorphosis',
        'What is the big change from caterpillar to butterfly called?',
        ['Pollination', 'Hibernation', 'Metamorphosis', 'Erosion'],
        2,
        'In metamorphosis, an animal\'s body changes completely as it grows up.',
      ),
      _q(
        'mushroom_kingdom',
        'What kind of living thing is a mushroom?',
        ['A plant', 'A fungus', 'An animal', 'A bacterium'],
        1,
        'Mushrooms are fungi. They cannot make their own food from sunlight '
            'as plants do.',
      ),
      _q(
        'monarch_food',
        'What do monarch caterpillars feed on?',
        ['Grass', 'Oak leaves', 'Nectar', 'Milkweed'],
        3,
        'Monarch caterpillars eat only milkweed, so planting it helps these '
            'butterflies.',
      ),
      _q(
        'waggle',
        'How does a honeybee tell others where to find flowers?',
        [
          'It leaves written notes',
          'It does a waggle dance',
          'It sings a song',
          'It paints the hive',
        ],
        1,
        'The waggle dance shows other bees the direction of the flowers and '
            'how far away they are.',
      ),
    ]),
  ],
);

// ------------------------------------------------------------------ Energy

final _energy = QuizTopic(
  id: 'energy',
  title: 'Electricity & Energy',
  tagline: 'Circuits, sunshine and what makes things go.',
  levels: [
    _level('energy', QuizDifficulty.starter, [
      _q(
        'torch_power',
        'What usually powers a handheld torch?',
        ['A battery', 'A candle', 'A magnet', 'Water'],
        0,
        'A battery stores energy and pushes electricity around the circuit.',
      ),
      _q(
        'good_conductor',
        'Which of these lets electricity flow through it easily?',
        ['A rubber band', 'A wooden stick', 'A copper wire', 'A cotton sock'],
        2,
        'Metals like copper are good conductors, so they are used for wires.',
      ),
      _q(
        'solar_panel',
        'What do solar panels turn into electricity?',
        ['Wind', 'Sunlight', 'Rain', 'Sound'],
        1,
        'Solar panels capture energy from sunlight and turn it into '
            'electricity.',
      ),
      _q(
        'circuit_shape',
        'What does a circuit need for a bulb to light up?',
        [
          'A gap in the wire',
          'A wooden handle',
          'A very long wire',
          'A complete loop',
        ],
        3,
        'Electricity can only flow when the path makes a complete loop.',
      ),
      _q(
        'wind_power',
        'Which of these uses moving air to make electricity?',
        ['A wind turbine', 'A kettle', 'A candle', 'A mirror'],
        0,
        'Wind spins the turbine\'s blades, and that spins a generator.',
      ),
    ]),
    _level('energy', QuizDifficulty.explorer, [
      _q(
        'insulator',
        'Which of these is an electrical insulator?',
        ['Copper', 'Iron', 'Rubber', 'Aluminium'],
        2,
        'Insulators like rubber stop electricity flowing, so they are used to '
            'cover wires.',
      ),
      _q(
        'static',
        'Why can a balloon rubbed on your hair stick to a wall?',
        ['Static electricity', 'Glue on it', 'Gravity', 'Wind'],
        0,
        'Rubbing moves tiny charged particles called electrons, and the charge '
            'makes the balloon cling.',
      ),
      _q(
        'lightning_is',
        'What is lightning?',
        ['Burning gas', 'Hot rain', 'A flash of electricity', 'Sunlight'],
        2,
        'Lightning is a giant spark of electricity between clouds, or between '
            'a cloud and the ground.',
      ),
      _q(
        'switch_job',
        'What does a switch do in a circuit?',
        [
          'Makes the wire longer',
          'Stores the electricity',
          'Changes its colour',
          'Opens or closes the loop',
        ],
        3,
        'A switch makes a gap in the circuit, or closes it again, turning '
            'things off and on.',
      ),
      _q(
        'renewable',
        'Which of these is a renewable source of energy?',
        ['Coal', 'Sunlight', 'Oil', 'Natural gas'],
        1,
        'Renewable energy will not run out. Coal, oil and gas take millions of '
            'years to form.',
      ),
    ]),
    _level('energy', QuizDifficulty.expert, [
      _q(
        'electrons',
        'What tiny particles move through a wire to carry electricity?',
        ['Electrons', 'Sound waves', 'Dust specks', 'Water drops'],
        0,
        'Electric current in a wire is the flow of tiny particles called '
            'electrons.',
      ),
      _q(
        'volt_unit',
        'What do we use volts to measure?',
        ['Temperature', 'The push of electricity', 'Distance', 'Weight'],
        1,
        'Voltage is how strongly electricity is pushed around a circuit.',
      ),
      _q(
        'fossil_fuel',
        'Coal, oil and natural gas are called what?',
        ['Fossil fuels', 'Solar fuels', 'Wind fuels', 'Moon fuels'],
        0,
        'They formed from ancient living things, and burning them adds carbon '
            'dioxide to the air.',
      ),
      _q(
        'geothermal',
        'What is geothermal energy?',
        [
          'Energy from ocean waves',
          'Energy from the Moon',
          'Heat from inside the Earth',
          'Energy from plants',
        ],
        2,
        'Geothermal energy uses heat from deep underground, and it can warm '
            'homes or make electricity.',
      ),
      _q(
        'energy_change',
        'What happens to the energy a bulb uses?',
        [
          'It is destroyed',
          'It turns into water',
          'It goes back to the battery',
          'It changes into light and heat',
        ],
        3,
        'Energy cannot be made or destroyed. It only changes from one form to '
            'another.',
      ),
    ]),
  ],
);

// ------------------------------------------------------------------ Matter

final _matter = QuizTopic(
  id: 'matter',
  title: 'Matter & Materials',
  tagline: 'Solids, liquids, gases and what things are made of.',
  levels: [
    _level('matter', QuizDifficulty.starter, [
      _q(
        'three_states',
        'What are the three common states of matter?',
        [
          'Hot, warm and cold',
          'Solid, liquid and gas',
          'Big, medium and small',
          'Red, green and blue',
        ],
        1,
        'Most things around us are solids, liquids or gases.',
      ),
      _q(
        'ice_state',
        'Ice is water in which state?',
        ['Solid', 'Liquid', 'Gas'],
        0,
        'When water gets cold enough, it freezes into solid ice.',
      ),
      _q(
        'boil_becomes',
        'What does water turn into when it boils?',
        ['Ice', 'Salt', 'Sand', 'Steam'],
        3,
        'Boiling water turns into a gas called water vapour, or steam.',
      ),
      _q(
        'melting_word',
        'What do we call it when a solid turns into a liquid?',
        ['Freezing', 'Melting', 'Boiling', 'Sleeping'],
        1,
        'Melting happens when a solid warms up, like ice in the sun.',
      ),
      _q(
        'magnet_picks',
        'Which of these would a magnet pick up?',
        ['A wooden ruler', 'A paper clip', 'A plastic cup', 'A rubber'],
        1,
        'Magnets attract iron and steel, and many paper clips are made of '
            'steel.',
      ),
    ]),
    _level('matter', QuizDifficulty.explorer, [
      _q(
        'evaporation',
        'What is it called when liquid water turns into vapour?',
        ['Evaporation', 'Freezing', 'Melting', 'Pollination'],
        0,
        'Warmth gives water the energy to become a gas. That is how puddles '
            'disappear.',
      ),
      _q(
        'condensation',
        'Why do drops form on a cold glass on a warm day?',
        [
          'The glass is leaking',
          'Water vapour in the air condenses',
          'The drink is sweating',
          'It rained indoors',
        ],
        1,
        'Water vapour in the air cools on the cold glass, and turns back into '
            'liquid.',
      ),
      _q(
        'freezing_point',
        'At what temperature does pure water freeze?',
        ['100 °C', '50 °C', '0 °C', '-50 °C'],
        2,
        'Pure water freezes at 0 degrees Celsius.',
      ),
      _q(
        'boiling_point',
        'At sea level, at what temperature does water boil?',
        ['0 °C', '37 °C', '50 °C', '100 °C'],
        3,
        'Water boils at 100 degrees Celsius at sea level, and a little lower '
            'up a high mountain.',
      ),
      _q(
        'float_or_sink',
        'Which of these floats on water?',
        ['A stone', 'A wooden block', 'An iron nail', 'A glass marble'],
        1,
        'Most wood floats, because it is less dense than water.',
      ),
    ]),
    _level('matter', QuizDifficulty.expert, [
      _q(
        'atoms',
        'What are the tiny building blocks of all matter called?',
        ['Atoms', 'Cells', 'Grains', 'Crystals'],
        0,
        'Everything is made of atoms, far too small to see with your eyes.',
      ),
      _q(
        'water_formula',
        'Which two elements make up water?',
        [
          'Carbon and iron',
          'Gold and silver',
          'Hydrogen and oxygen',
          'Helium and neon',
        ],
        2,
        'Each water molecule, H2O, has two hydrogen atoms and one oxygen atom.',
      ),
      _q(
        'dissolve',
        'What happens to sugar when it is stirred into warm water?',
        [
          'It disappears forever',
          'It floats on top',
          'It turns into salt',
          'It dissolves',
        ],
        3,
        'The sugar is still there, spread out in the water. That is why the '
            'water tastes sweet.',
      ),
      _q(
        'most_of_air',
        'Which gas makes up most of the air?',
        ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Helium'],
        1,
        'Air is about 78 percent nitrogen and about 21 percent oxygen.',
      ),
      _q(
        'ice_floats',
        'Why does ice float on water?',
        [
          'It is less dense than water',
          'It is full of tiny holes',
          'It is pulled up by the Sun',
          'It is lighter in colour',
        ],
        0,
        'Water spreads out as it freezes, so ice is less dense than liquid '
            'water.',
      ),
    ]),
  ],
);

// -------------------------------------------------------------- Inventions

final _inventions = QuizTopic(
  id: 'inventions',
  title: 'Robots & Inventions',
  tagline: 'Clever ideas that changed the world.',
  levels: [
    _level('inventions', QuizDifficulty.starter, [
      _q(
        'first_plane',
        'Who made the first powered aeroplane flights in 1903?',
        [
          'The Wright brothers',
          'The Grimm brothers',
          'The Beatles',
          'The Romans',
        ],
        0,
        'Orville and Wilbur Wright flew at Kitty Hawk in the USA. The first '
            'flight lasted just 12 seconds.',
      ),
      _q(
        'robot_is',
        'What is a robot?',
        [
          'A kind of animal',
          'A kind of plant',
          'A machine that follows instructions',
          'A type of cloud',
        ],
        2,
        'Robots are machines that are programmed to carry out tasks.',
      ),
      _q(
        'code_is',
        'What do we call instructions written for a computer?',
        ['A recipe', 'A poem', 'A letter', 'Code'],
        3,
        'Code tells a computer exactly what to do, one step at a time.',
      ),
      _q(
        'telephone',
        'Who is best known for inventing the telephone?',
        ['Alexander Graham Bell', 'Isaac Newton', 'Albert Einstein'],
        0,
        'Alexander Graham Bell was awarded a patent for the telephone in 1876.',
      ),
      _q(
        'wheel_help',
        'Why are wheels so useful?',
        [
          'They make things heavier',
          'They make things easier to move',
          'They keep things cold',
          'They make things louder',
        ],
        1,
        'Wheels reduce friction with the ground, so heavy loads roll easily.',
      ),
    ]),
    _level('inventions', QuizDifficulty.explorer, [
      _q(
        'printing_press',
        'What did Johannes Gutenberg\'s printing press help to make?',
        ['Cars', 'Clocks', 'Books', 'Planes'],
        2,
        'Printing with movable type, from about 1450 in Europe, made books far '
            'cheaper and more common.',
      ),
      _q(
        'sensor',
        'What does a sensor do for a robot?',
        [
          'Gives it information about its surroundings',
          'Makes it heavier',
          'Paints it',
          'Gives it a name',
        ],
        0,
        'Sensors detect things like light, touch and distance, so a robot can '
            'react.',
      ),
      _q(
        'mars_rover',
        'What does a rover do on Mars?',
        [
          'Carries people',
          'Grows food',
          'Plays music',
          'Explores and studies the surface',
        ],
        3,
        'Rovers are robots controlled from Earth. They drive around, take '
            'pictures and study rocks.',
      ),
      _q(
        'ada',
        'Who is often called the first computer programmer?',
        ['Ada Lovelace', 'Marie Curie', 'Rosalind Franklin', 'Amelia Earhart'],
        0,
        'In the 1840s, Ada Lovelace wrote out steps for a machine that had not '
            'even been built.',
      ),
      _q(
        'bicycle_gear',
        'What do the gears on a bicycle help you do?',
        [
          'Steer the bike',
          'Stop the bike',
          'Pedal more easily up hills',
          'Light the road',
        ],
        2,
        'Gears change how far the wheel turns for each push of the pedals.',
      ),
    ]),
    _level('inventions', QuizDifficulty.expert, [
      _q(
        'binary',
        'Which two digits do computers use to store information?',
        ['0 and 1', '1 and 2', '5 and 10', '8 and 9'],
        0,
        'This is the binary system. Everything a computer stores is made of '
            'zeros and ones.',
      ),
      _q(
        'algorithm',
        'What is an algorithm?',
        [
          'A kind of robot',
          'A set of steps to solve a problem',
          'A computer screen',
          'A musical note',
        ],
        1,
        'An algorithm is a clear list of steps. A recipe is a kind of '
            'algorithm too!',
      ),
      _q(
        'bug_is',
        'What is a "bug" in computer code?',
        ['An insect', 'A fast program', 'A mistake', 'A password'],
        2,
        'A bug is a mistake that stops code working as planned. Finding it is '
            'called debugging.',
      ),
      _q(
        'web_inventor',
        'Who invented the World Wide Web?',
        ['Tim Berners-Lee', 'Thomas Edison', 'Nikola Tesla', 'Galileo'],
        0,
        'Tim Berners-Lee came up with the Web in 1989, while working in '
            'Switzerland.',
      ),
      _q(
        'turing',
        'Which British mathematician helped found computer science?',
        [
          'Charles Dickens',
          'William Shakespeare',
          'Isaac Newton',
          'Alan Turing',
        ],
        3,
        'Alan Turing described how a general computing machine could work, and '
            'helped crack codes in wartime.',
      ),
    ]),
  ],
);
