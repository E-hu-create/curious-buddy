import '../voice/educational_response_provider.dart';

part 'curated_topics_africa.dart';
part 'curated_topics_extra.dart';
part 'curated_topics_more.dart';

/// Reviewed, offline answers Buddy can give today.
///
/// Content rules (checked by test/domain/conversation/curated_*_test):
/// * Short sentences that sound natural read aloud; at most ~60 words.
/// * Facts must be well established. Prefer "about" for rounded numbers.
/// * Buddy is honest: a computer character, not a person, sometimes wrong.
/// * Every action points at an existing screen in the app.
///
/// To add a topic: add a [CuratedTopic] below, with triggers a child might
/// actually say, then add a test question for it in
/// curated_matching_test.dart.
class CuratedTopic {
  const CuratedTopic({
    required this.id,
    required this.triggers,
    required this.answers,
    this.subject,
    this.pinned = const {},
    this.action,
    this.actionLabel,
    this.followUps = const [],
  });

  final String id;

  /// The topic matches when *all* words of *any* trigger appear in the
  /// question (whole words, any order).
  final List<List<String>> triggers;

  /// Rotated in order so repeated questions get fresh answers.
  final List<String> answers;

  /// Set for "facts about a subject" topics (e.g. 'dog'). When a specific
  /// question matches only the subject and no [pinned] answer, Buddy says
  /// honestly that he is not sure of that exact answer and offers a
  /// [subject] fact instead.
  final String? subject;

  /// Question word → index in [answers] that actually answers it, e.g.
  /// `{'purr': 0}` so "why do cats purr" always gets the purr answer.
  final Map<String, int> pinned;

  final BuddyAction? action;
  final String? actionLabel;
  final List<String> followUps;
}

/// Words that mean "just tell me something", so a subject fact is the right
/// reply and needs no "not sure" lead-in.
const factRequestWords = {
  'fact',
  'facts',
  'tell',
  'about',
  'something',
  'another',
  'more',
  'cool',
  'fun',
  'interesting',
  'amazing',
};

/// Words that mark a specific question.
const questionWords = {
  'how',
  'why',
  'what',
  "what's",
  'when',
  'where',
  'who',
  'which',
  'can',
  'do',
  'does',
  'did',
  'is',
  'are',
  'will',
  'could',
  'would',
};

/// The only words where a one-letter typo is forgiven: long, distinctive
/// names children often misspell. Ordinary words ("planets", "seasons")
/// must match exactly, or look-alikes ("planes", "reasons") would misfire.
const typoTolerantWords = {
  'astronaut',
  'butterfly',
  'caterpillar',
  'chameleon',
  'cheetah',
  'chrysalis',
  'diaphragm',
  'dinosaur',
  'dolphin',
  'earthquake',
  'elephant',
  'giraffe',
  'gravity',
  'hiccup',
  'jellyfish',
  'lightning',
  'penguin',
  'photosynthesis',
  'pyramid',
  'rainbow',
  'skeleton',
  'snowflake',
  'spider',
  'tyrannosaurus',
  'volcano',
};

String notSureLeadIn(String subject) =>
    "I'm not sure about that exact question yet. "
    "Here's a $subject fact instead! ";

/// Shown on Home before the child has asked anything.
const starterPrompts = [
  'Teach me something amazing.',
  'Why is the sky blue?',
  'Tell me an animal fact.',
  "Let's play a quiz.",
  'Take me on an adventure.',
];

const fallbackAnswer = EducationalResponse(
  text:
      "Hmm, I don't know that one yet. "
      'I only know some topics so far, and I am still learning. '
      'Try asking me about animals, space, or why the sky is blue!',
  kind: ResponseKind.fallback,
  followUps: [
    'Tell me an animal fact.',
    'Tell me a space fact.',
    'Why is the sky blue?',
  ],
);

/// Checked top to bottom; the first match wins, so specific questions come
/// before broad ones.
const curatedTopics = <CuratedTopic>[
  // ---------------------------------------------------------- about Buddy
  CuratedTopic(
    id: 'about_buddy',
    triggers: [
      ['who', 'are', 'you'],
      ['are', 'you', 'real'],
      ['are', 'you', 'human'],
      ['are', 'you', 'a', 'person'],
      ['are', 'you', 'alive'],
      ['are', 'you', 'my', 'friend'],
      ['do', 'you', 'have', 'feelings'],
      ['are', 'you', 'ai'],
      ['are', 'you', 'a', 'robot'],
    ],
    answers: [
      "I'm Buddy, a computer character in this app. "
          "I'm not a person, and I don't have real feelings. "
          'Sharing facts is what I do best, but I can make mistakes. '
          "So it's smart to check big things with a grown-up!",
    ],
    followUps: ['Teach me something amazing.', 'What can you do?'],
  ),
  CuratedTopic(
    id: 'help',
    triggers: [
      ['what', 'can', 'you', 'do'],
      ['help'],
      ['how', 'does', 'this', 'work'],
    ],
    answers: [
      'You can type a question, or tap one of the ideas. '
          'I know about animals, space, weather, nature, your body and '
          'science. I can tell jokes, too! '
          'And I can take you to missions and stories!',
    ],
    followUps: [
      'Tell me an animal fact.',
      'Tell me a space fact.',
      'Take me on an adventure.',
    ],
  ),
  CuratedTopic(
    id: 'hello',
    triggers: [
      ['hi'],
      ['hello'],
      ['hey'],
      ['good', 'morning'],
      ['good', 'afternoon'],
    ],
    answers: [
      'Hi there! What would you like to discover today?',
      'Hello again! Ask me anything about animals, space or nature.',
    ],
    followUps: starterPrompts,
  ),
  CuratedTopic(
    id: 'thanks',
    triggers: [
      ['thank', 'you'],
      ['thanks'],
    ],
    answers: ["You're welcome! Want to discover something else?"],
    followUps: ['Teach me something amazing.', 'Tell me an animal fact.'],
  ),

  // ------------------------------------------------------------ activities
  CuratedTopic(
    id: 'quiz',
    triggers: [
      ['quiz'],
      ['test', 'me'],
      ['trivia'],
    ],
    answers: [
      "Let's do it! Quiz Time has topics from space and dinosaurs to "
          'oceans, robots and your amazing body. Each right answer helps you '
          'earn stars.',
    ],
    action: BuddyAction.startQuiz,
    actionLabel: 'Play Quiz Time',
    followUps: ['Teach me something amazing.', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'adventure',
    triggers: [
      ['adventure'],
      ['mission'],
      ['missions'],
      ['explore'],
      ['mystery'],
    ],
    answers: [
      "Let's go! Mystery Missions has lots of detective cases to crack. "
          'Inspect the clues, and ask me for a hint if you get stuck.',
    ],
    action: BuddyAction.openMissions,
    actionLabel: 'Open Mystery Missions',
    followUps: ['Tell me an ocean fact.', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'story',
    triggers: [
      ['story'],
      ['stories'],
    ],
    answers: [
      'Stories are great! In Living Stories, you choose what happens next, '
          'and every choice leads somewhere different. I will read it to you.',
    ],
    action: BuddyAction.openStories,
    actionLabel: 'Open Living Stories',
    followUps: ['Teach me something amazing.'],
  ),
  CuratedTopic(
    id: 'creative',
    triggers: [
      ['draw'],
      ['drawing'],
      ['paint'],
      ['build'],
      ['invent'],
      ['create'],
      ['creative'],
    ],
    answers: [
      'Creative Island is open! You can draw a picture or build your own '
          'creature, and save them on your shelf.',
    ],
    action: BuddyAction.openCreative,
    actionLabel: 'Visit Creative Island',
  ),
  CuratedTopic(
    id: 'games',
    triggers: [
      ['game'],
      ['games'],
      ['challenge'],
      ['arena'],
    ],
    answers: [
      "Let's play! The Game Zone has lots of games, like Dino Discovery, "
          'Treasure Maze, Code the Robot and Word Builder, and more.',
    ],
    action: BuddyAction.openGames,
    actionLabel: 'Open the Game Zone',
    followUps: ["Let's play a quiz."],
  ),
  CuratedTopic(
    id: 'wardrobe',
    triggers: [
      ['wardrobe'],
      ['outfit'],
      ['dress', 'up'],
      ['clothes'],
    ],
    answers: [
      'Ooh, dressing up is fun! Everything you do earns me something new to '
          'wear. Pick my outfit in my wardrobe!',
    ],
    action: BuddyAction.openWardrobe,
    actionLabel: "Open Buddy's Wardrobe",
  ),
  CuratedTopic(
    id: 'discoveries',
    triggers: [
      ['my', 'progress'],
      ['my', 'discoveries'],
      ['what', 'have', 'i', 'done'],
    ],
    answers: [
      'My Discoveries is your explorer journal! It shows your badges, story '
          'discoveries, quiz stars and creations.',
    ],
    action: BuddyAction.openDiscoveries,
    actionLabel: 'Open My Discoveries',
  ),

  // --------------------------------------------------------- why questions
  CuratedTopic(
    id: 'sky_blue',
    triggers: [
      ['sky', 'blue'],
    ],
    answers: [
      'Sunlight looks white, but it is made of many colours. '
          'When it hits the air, blue light gets bounced around the most. '
          'So blue light comes at us from all over the sky!',
    ],
    followUps: ['Why are sunsets orange?', 'How do rainbows form?'],
  ),
  CuratedTopic(
    id: 'sunset',
    triggers: [
      ['sunset'],
      ['sunsets'],
    ],
    answers: [
      'At sunset, sunlight travels through much more air to reach you. '
          'Most of the blue light gets scattered away on the trip. '
          'The reds and oranges make it through!',
    ],
    followUps: ['Why is the sky blue?', 'How do rainbows form?'],
  ),
  CuratedTopic(
    id: 'rainbow',
    triggers: [
      ['rainbow'],
      ['rainbows'],
    ],
    answers: [
      'A rainbow appears when sunlight shines through raindrops. '
          'Each drop bends the light and splits it into colours. '
          'Red, orange, yellow, green, blue, indigo and violet!',
    ],
    followUps: ['Why is the sky blue?', 'Why do stars twinkle?'],
  ),
  CuratedTopic(
    id: 'stars_twinkle',
    triggers: [
      ['stars', 'twinkle'],
      ['star', 'twinkle'],
    ],
    answers: [
      'Stars twinkle because their light passes through moving air. '
          'The air bends the light a tiny bit, again and again. '
          'Out in space, stars would not twinkle at all!',
    ],
    followUps: ['Tell me a space fact.', 'How hot is the Sun?'],
  ),
  CuratedTopic(
    id: 'seasons',
    triggers: [
      ['seasons'],
      ['why', 'summer'],
      ['why', 'winter'],
    ],
    answers: [
      "Earth is tilted, like a spinning top that's leaning over. "
          'When your half leans towards the Sun, it is summer. '
          'When it leans away, it is winter!',
    ],
    followUps: ['Tell me a space fact.', 'How far away is the Moon?'],
  ),
  CuratedTopic(
    id: 'ocean_salty',
    triggers: [
      ['ocean', 'salty'],
      ['sea', 'salty'],
    ],
    answers: [
      'Rain slowly wears away rocks and carries tiny bits of salt into rivers. '
          'Rivers carry that salt to the sea. '
          'Over millions of years, the ocean became salty!',
    ],
    followUps: ['Tell me an ocean fact.', 'Why is the sky blue?'],
  ),
  CuratedTopic(
    id: 'leaves',
    triggers: [
      ['leaves', 'change'],
      ['leaves', 'colour'],
      ['leaves', 'color'],
      ['leaves', 'fall'],
    ],
    answers: [
      'Leaves are green because of a helper called chlorophyll. '
          'In autumn, trees stop making it. '
          'Then the yellows and oranges hiding underneath can show!',
    ],
    followUps: ['Tell me an animal fact.', 'How do rainbows form?'],
  ),

  // Ghana and Africa, before the broad mountain, desert and animal topics.
  ..._ghanaAfricaFirst,

  // More specific topics (animals, space, Earth, body, science, jokes).
  ..._moreTopics,
  ..._extraTopics,
  _africa, // after the animal topics, so "elephants in Africa" stays there
  // ----------------------------------------------------------------- space
  CuratedTopic(
    id: 'moon_distance',
    triggers: [
      ['far', 'moon'],
      ['distance', 'moon'],
    ],
    answers: [
      'The Moon is about 384,000 kilometres away. '
          'Driving there in a car would take about six months, nonstop!',
    ],
    followUps: ['How hot is the Sun?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'sun_hot',
    triggers: [
      ['hot', 'sun'],
      ['temperature', 'sun'],
    ],
    answers: [
      "The Sun's surface is about 5,500 degrees Celsius. "
          'Its centre is much hotter, about 15 million degrees!',
    ],
    followUps: ['How far away is the Moon?', 'Tell me a space fact.'],
  ),
  CuratedTopic(
    id: 'space_fact',
    triggers: [
      ['space'],
      ['planet'],
      ['planets'],
      ['star'],
      ['stars'],
      ['moon'],
      ['sun'],
    ],
    subject: 'space',
    answers: [
      'A day on Venus is longer than its whole year! '
          'Venus spins very slowly, so one turn takes longer than one trip '
          'around the Sun.',
      'Jupiter is so big that more than a thousand Earths could fit inside it!',
      "There's no wind on the Moon. "
          'So astronaut footprints there could last for millions of years.',
    ],
    followUps: ['Tell me another space fact.', 'Why do stars twinkle?'],
  ),

  // --------------------------------------------------------------- animals
  CuratedTopic(
    id: 'ocean_fact',
    triggers: [
      ['ocean'],
      ['sea'],
      ['octopus'],
      ['whale'],
      ['shark'],
    ],
    subject: 'ocean',
    pinned: {'octopus': 0, 'heart': 0, 'whale': 1, 'shark': 2},
    answers: [
      'An octopus has three hearts and blue blood! '
          'Want to discover another ocean secret?',
      'Whales are mammals, not fish. '
          'They swim up to the surface to breathe air, through a blowhole!',
      'Sharks have been around for longer than trees. '
          'Sharks are over 400 million years old!',
    ],
    followUps: ['Tell me another ocean fact.', 'Take me on an adventure.'],
  ),
  CuratedTopic(
    id: 'animal_fact',
    triggers: [
      ['animal'],
      ['animals'],
      ['bird'],
      ['insect'],
    ],
    subject: 'animal',
    answers: [
      'Sea otters hold hands while they sleep, so they do not drift apart!',
      "A shrimp's heart is in its head!",
      'Wombats make poo shaped like little cubes!',
      'Hummingbirds can fly backwards. '
          'No other bird can do that so well!',
      'Koalas can sleep for up to 20 hours a day!',
    ],
    followUps: ['Tell me another animal fact.', 'Tell me an ocean fact.'],
  ),

  // --------------------------------------------------------- amazing facts
  CuratedTopic(
    id: 'amazing',
    triggers: [
      ['amazing'],
      ['bored'],
      ['fact'],
      ['facts'],
      ['teach', 'me'],
      ['something', 'cool'],
      ['fun', 'fact'],
      ['surprise', 'me'],
    ],
    answers: [
      "I've got an idea! Did you know that an octopus has three hearts? "
          'Want to discover another amazing animal fact, or go on an ocean '
          'adventure?',
      'Lightning is hotter than the surface of the Sun! '
          'A bolt can reach about 30,000 degrees Celsius.',
      'Bananas are berries, but strawberries are not! '
          'Scientists sort fruit by how they grow from the flower.',
      'There are more trees on Earth than stars in our galaxy!',
      'A group of flamingos is called a flamboyance!',
    ],
    action: BuddyAction.openMissions,
    actionLabel: 'Go on an adventure',
    followUps: [
      'Tell me another amazing fact.',
      'Tell me an animal fact.',
      'Tell me a space fact.',
    ],
  ),
];
