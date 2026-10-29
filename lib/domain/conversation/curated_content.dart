import '../voice/educational_response_provider.dart';

/// Reviewed, offline answers Buddy can give today.
///
/// Content rules (checked by test/domain/conversation/curated_content_test):
/// * Short sentences that sound natural read aloud; at most ~60 words.
/// * Facts must be well established. Prefer "about" for rounded numbers.
/// * Buddy is honest: a computer character, not a person, sometimes wrong.
/// * Every action points at an existing screen in the app.
///
/// To add a topic: add a [CuratedTopic] below, with triggers a child might
/// actually say, then add a test question for it.
class CuratedTopic {
  const CuratedTopic({
    required this.id,
    required this.triggers,
    required this.answers,
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
  final BuddyAction? action;
  final String? actionLabel;
  final List<String> followUps;
}

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
          'I love sharing facts, but I can make mistakes. '
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
          'I know about animals, space, weather and nature. '
          'I can also take you to missions and stories!',
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
      "Quizzes are coming soon! I'm still writing the questions. "
          'You can peek at the quiz page, or ask me for a fact instead.',
    ],
    action: BuddyAction.startQuiz,
    actionLabel: 'Peek at quizzes',
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
      "Let's go! Adventures will live in Mystery Missions. "
          "They're still being built, but you can take a look.",
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
      'I love stories! Living Stories are where they will be. '
          "They're coming soon, but you can have a look now.",
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
      'Creative Island is where you will build and invent. '
          "It's still being made, but you can visit.",
    ],
    action: BuddyAction.openCreative,
    actionLabel: 'Visit Creative Island',
  ),
  CuratedTopic(
    id: 'discoveries',
    triggers: [
      ['my', 'progress'],
      ['my', 'discoveries'],
      ['what', 'have', 'i', 'done'],
    ],
    answers: [
      'Your discoveries will be saved in My Discoveries. '
          "It's coming soon!",
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
    answers: [
      'An octopus has three hearts and blue blood! '
          'Want to discover another ocean secret?',
      'Blue whales are the biggest animals that have ever lived. '
          'Even bigger than the largest dinosaurs!',
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
      ['dog'],
      ['cat'],
      ['bird'],
      ['insect'],
    ],
    answers: [
      'Sea otters hold hands while they sleep, so they do not drift apart!',
      'Butterflies taste with their feet. '
          'They stand on a flower to find out if it is tasty!',
      'A giraffe has seven bones in its neck. '
          'That is the same number as you!',
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
      'Honey can last for thousands of years without going bad!',
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
