import 'mission.dart';

/// The three starter missions. Fictional places and people, no scary or
/// dangerous situations, real science where science is taught. Every answer
/// follows from the clues on screen; test/domain/missions checks the rules.
const starterMissions = <Mission>[_moonstone, _garden, _signals];

// ---------------------------------------------------------------- Mission 1

const _moonstone = Mission(
  id: 'missing_moonstone',
  title: 'The Missing Moonstone',
  tagline: 'Compare the clues and find out where the gem went.',
  art: MissionArt.moonstone,
  intro:
      'Welcome to the Starlight Museum! This morning, the famous Glowing '
      'Moonstone was missing from its glass case. Nobody was hurt, and the '
      'doors were locked all night. Let us look at the evidence carefully.',
  objective: 'Work out what really happened to the Glowing Moonstone.',
  badge: 'Moonstone Sleuth',
  solution:
      'Dr. Ravi popped back to the museum at 8:15 pm, took the silver key and '
      'polished the moonstone in his office for the big exhibition. He forgot '
      'his quick visit when he said he left at 5 pm. The moonstone is safe '
      'and sparkling! Checking statements against evidence solved the case.',
  stages: [
    ChoiceStage(
      id: 'how_opened',
      prompt: 'How was the moonstone taken out of its case?',
      clues: [
        Clue(
          id: 'glass',
          title: 'The glass case',
          text: 'The glass case is not broken or scratched at all.',
        ),
        Clue(
          id: 'lock',
          title: 'The lock',
          text: 'The case only opens with the museum\'s silver key.',
        ),
        Clue(
          id: 'key_room',
          title: 'Where the key lives',
          text: 'The silver key hangs in the staff room. Only staff can go in.',
        ),
      ],
      choices: [
        Choice(
          id: 'broke_glass',
          text: 'Someone broke the glass to grab it.',
          feedback:
              'The glass is not broken or scratched, so that cannot be it.',
        ),
        Choice(
          id: 'used_key',
          text: 'Someone opened the case with the silver key.',
          correct: true,
          feedback:
              'Yes! The case is not broken and only the silver key opens it.',
        ),
        Choice(
          id: 'rolled_out',
          text: 'The moonstone rolled out by itself.',
          feedback: 'A closed, locked case cannot let a gem roll out.',
        ),
      ],
      hints: [
        'Inspect every clue. What is true about the glass?',
        'If the glass is fine, how else could the case be opened?',
      ],
      explanation:
          'The glass is unbroken and the case needs the silver key, so someone '
          'with the key opened it. That points to a member of staff.',
    ),
    ChoiceStage(
      id: 'odd_statement',
      prompt:
          'Three staff members made statements. Which one does not match '
          'the evidence?',
      clues: [
        Clue(
          id: 'sign_in',
          title: 'The staff sign-in book',
          text: 'The sign-in book says: "Dr. Ravi, 8:15 pm, took silver key".',
        ),
        Clue(
          id: 'camera',
          title: 'The hall camera',
          text:
              'The camera shows a light switched on in the Moon Hall at '
              '8:20 pm.',
        ),
      ],
      choices: [
        Choice(
          id: 'guard',
          text:
              'Guard Gus: "I locked the front doors at 6 pm. Nobody broke '
              'in."',
          feedback:
              'Gus\'s statement fits: the doors stayed locked and nothing was '
              'broken.',
        ),
        Choice(
          id: 'cleaner',
          text: 'Cleaner Coco: "At 7 pm the moonstone was still in its case."',
          feedback:
              'Coco\'s statement fits too: the key was taken later, at 8:15 pm.',
        ),
        Choice(
          id: 'curator',
          text:
              'Dr. Ravi: "I left at 5 pm and did not come back until '
              'morning."',
          correct: true,
          feedback:
              'Well spotted! The sign-in book says Dr. Ravi took the key at '
              '8:15 pm.',
        ),
      ],
      hints: [
        'Compare each statement with the times in the clues.',
        'Who does the sign-in book mention, and at what time?',
      ],
      explanation:
          'The sign-in book shows Dr. Ravi took the key at 8:15 pm, but he '
          'said he never came back. A statement that clashes with evidence '
          'is worth looking into. It does not always mean someone is fibbing; '
          'people can forget!',
    ),
    MultiSelectStage(
      id: 'supporting_clues',
      prompt:
          'Select every clue that supports the idea that Dr. Ravi took the '
          'moonstone.',
      clues: [
        Clue(
          id: 'calendar',
          title: 'Dr. Ravi\'s calendar',
          text:
              'A note on Dr. Ravi\'s calendar says: "Polish the moonstone '
              'before the big exhibition!"',
        ),
        Clue(
          id: 'cloth',
          title: 'By the case',
          text:
              'A polishing cloth with sparkly blue dust lies beside the case.',
        ),
      ],
      choices: [
        Choice(
          id: 'sign_in_pick',
          text: 'The sign-in book shows he took the silver key at 8:15 pm.',
          correct: true,
          feedback: 'That links Dr. Ravi to the key.',
        ),
        Choice(
          id: 'calendar_pick',
          text: 'His calendar says to polish the moonstone.',
          correct: true,
          feedback: 'That gives him a reason to take it.',
        ),
        Choice(
          id: 'cloth_pick',
          text: 'A polishing cloth with blue sparkly dust was by the case.',
          correct: true,
          feedback: 'That shows someone was polishing the gem.',
        ),
        Choice(
          id: 'cupcakes',
          text: 'The museum café sold 40 cupcakes yesterday.',
          feedback:
              'The cupcakes are true, but they tell us nothing about the '
              'moonstone.',
        ),
        Choice(
          id: 'rain',
          text: 'It rained in the afternoon.',
          feedback: 'The rain has nothing to do with who opened the case.',
        ),
      ],
      missingFeedback:
          'Every clue you picked helps! But one or more helpful clues are '
          'still not selected.',
      hints: [
        'A helpful clue must connect Dr. Ravi to the key, the gem or a reason.',
        'Three clues help. Two are true, but have nothing to do with the case.',
      ],
      explanation:
          'The key record, the calendar note and the polishing cloth all point '
          'to Dr. Ravi polishing the moonstone. The cupcakes and the rain are '
          'true but irrelevant. Good detectives ignore clues that do not help.',
    ),
    ChoiceStage(
      id: 'best_explanation',
      prompt: 'Which explanation fits all the evidence best?',
      choices: [
        Choice(
          id: 'polishing',
          text:
              'Dr. Ravi took the moonstone to polish it, and forgot to say '
              'he came back.',
          correct: true,
          feedback: 'Case closed! Every clue fits this explanation.',
        ),
        Choice(
          id: 'gus_cafe',
          text: 'Guard Gus hid the moonstone in the café.',
          feedback:
              'No clue links Gus or the café to the moonstone or the key.',
        ),
        Choice(
          id: 'bird',
          text: 'A bird flew in and carried it away.',
          feedback:
              'The doors were locked and the case needs a key, so a bird '
              'could not get it.',
        ),
      ],
      hints: [
        'The best explanation uses every important clue and clashes with none.',
        'Think about the key, the calendar and the cloth together.',
      ],
      explanation:
          'Only the polishing explanation fits the key record, the calendar, '
          'the cloth, the camera light and the unbroken case.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 2

const _garden = Mission(
  id: 'wilting_garden',
  title: 'The Secret of the Wilting Garden',
  tagline: 'Use real plant science to save the flower beds.',
  art: MissionArt.garden,
  intro:
      'The Sunnyside Community Garden has three flower beds. Two are doing '
      'fine, but the plants in Bed B are drooping and turning yellow, even '
      'though they get the most water. Let us investigate like scientists!',
  objective: 'Find out why Bed B is wilting, and how to help it.',
  badge: 'Garden Scientist',
  solution:
      'Bed B was being watered four times a day. The soil stayed soggy, so '
      'the roots could not get the air they need, and damaged roots cannot '
      'take up water well. Watering only when the top of the soil feels dry '
      'will help Bed B recover. Too much of a good thing can be a problem!',
  stages: [
    MultiSelectStage(
      id: 'plant_needs',
      prompt: 'First, what do plants need to grow well? Select all that apply.',
      choices: [
        Choice(
          id: 'sunlight',
          text: 'Sunlight',
          correct: true,
          feedback: 'Plants use sunlight to make their food.',
        ),
        Choice(
          id: 'water',
          text: 'Water',
          correct: true,
          feedback: 'Plants need water, but the right amount.',
        ),
        Choice(
          id: 'air',
          text: 'Air',
          correct: true,
          feedback: 'Leaves and roots both need air.',
        ),
        Choice(
          id: 'nutrients',
          text: 'Nutrients from the soil',
          correct: true,
          feedback: 'Soil gives plants minerals they need.',
        ),
        Choice(
          id: 'sweets',
          text: 'Sweets and juice',
          feedback:
              'Plants make their own sugar from sunlight. No sweets '
              'needed!',
        ),
        Choice(
          id: 'darkness',
          text: 'Darkness all day long',
          feedback: 'Without light, plants cannot make food.',
        ),
      ],
      missingFeedback:
          'Everything you picked is right! But plants need a few more things.',
      hints: [
        'Think about what a plant takes in through its leaves and its roots.',
        'There are four correct answers.',
      ],
      explanation:
          'Plants need sunlight, water, air and nutrients from the soil. Both '
          'the leaves and the roots need air.',
    ),
    ChoiceStage(
      id: 'compare_beds',
      prompt: 'Beds A and B are side by side. What is different about Bed B?',
      clues: [
        Clue(
          id: 'bed_a',
          title: 'Bed A observations',
          text:
              'Full sun. Watered once a day. Soil feels damp. Plants are '
              'green and strong.',
        ),
        Clue(
          id: 'bed_b',
          title: 'Bed B observations',
          text:
              'Full sun. Watered four times a day. Soil is soggy with '
              'puddles. Leaves droop and turn yellow.',
        ),
        Clue(
          id: 'seeds',
          title: 'Seed packets',
          text:
              'Beds A and B were planted with the same seeds on the same day.',
        ),
      ],
      choices: [
        Choice(
          id: 'more_water',
          text: 'Bed B gets much more water, and its soil is soggy.',
          correct: true,
          feedback: 'Yes! That is the big difference between the two beds.',
        ),
        Choice(
          id: 'less_sun',
          text: 'Bed B gets less sunlight.',
          feedback:
              'Both beds are in full sun, so light is not the difference.',
        ),
        Choice(
          id: 'different_seeds',
          text: 'Bed B has different seeds.',
          feedback: 'The seed packets show both beds have the same seeds.',
        ),
      ],
      hints: [
        'Scientists compare things that are the same and things that differ.',
        'Sun and seeds are the same in both beds. What is left?',
      ],
      explanation:
          'The sun and the seeds are the same, so the only big difference is '
          'the water. Comparing like this is called a fair test.',
    ),
    OrderStage(
      id: 'cause_chain',
      prompt:
          'Put the steps in order to show how too much water makes plants '
          'wilt.',
      clues: [
        Clue(
          id: 'roots_note',
          title: 'Gardener\'s note',
          text:
              'Roots need air as well as water. Soil normally has tiny air '
              'spaces between its grains.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'water_again', text: 'Water is added again and again.'),
        OrderPiece(id: 'soggy', text: 'The soil fills up and stays soggy.'),
        OrderPiece(id: 'no_air', text: 'The roots cannot get enough air.'),
        OrderPiece(
          id: 'roots_weak',
          text: 'Weak roots cannot take up water well.',
        ),
        OrderPiece(id: 'droop', text: 'The leaves droop and turn yellow.'),
      ],
      hints: [
        'Start with what the gardener does, and end with what we can see.',
        'Read the gardener\'s note: water fills the air spaces in the soil.',
      ],
      explanation:
          'Too much water fills the air spaces in the soil. The roots cannot '
          'breathe, so they cannot take up water well, and the plant wilts, '
          'even though it is surrounded by water!',
    ),
    ChoiceStage(
      id: 'best_fix',
      prompt: 'What is the best way to help Bed B?',
      clues: [
        Clue(
          id: 'bed_c',
          title: 'Bed C observations',
          text:
              'Shady, under a big tree. Watered once a day. Plants are pale '
              'with long, thin stems.',
        ),
      ],
      choices: [
        Choice(
          id: 'water_less',
          text: 'Water less often, only when the top of the soil feels dry.',
          correct: true,
          feedback:
              'Exactly! That lets air back into the soil around the roots.',
        ),
        Choice(
          id: 'water_more',
          text: 'Water even more, to stop the drooping.',
          feedback: 'More water would keep the soil soggy and make it worse.',
        ),
        Choice(
          id: 'move_shade',
          text: 'Move the plants into the shade.',
          feedback:
              'Bed C shows shade makes plants pale and thin. Bed B needs its '
              'sunshine.',
        ),
      ],
      hints: [
        'Fix the cause, not just the drooping you can see.',
        'Bed C shows what happens to plants without enough light.',
      ],
      explanation:
          'Watering only when the soil starts to dry lets air reach the roots '
          'again, while Bed B keeps its sunshine.',
    ),
  ],
);

// ---------------------------------------------------------------- Mission 3

const _signals = Mission(
  id: 'mixed_up_signals',
  title: 'The Case of the Mixed-Up Signals',
  tagline: 'Crack patterns and codes to rebuild a message.',
  art: MissionArt.signals,
  intro:
      'At Polar Star Research Station, the radio is crackling! A weather '
      'balloon is sending a message, but it arrives scrambled. The scientists '
      'need a sharp pattern-spotter. Ready to decode it?',
  objective: 'Restore the balloon\'s message, one puzzle at a time.',
  badge: 'Signal Decoder',
  solution:
      'The full message reads: "Balloon is landing safely. Coming HOME!" '
      'You spotted a repeating pattern, a doubling number pattern, used logic '
      'to order the words, and cracked a shift code. The scientists can '
      'collect their balloon. Brilliant decoding!',
  stages: [
    ChoiceStage(
      id: 'beep_pattern',
      prompt:
          'The signal repeats a pattern: beep, beep, boop, beep, beep, '
          'boop, beep, beep, ... What comes next?',
      choices: [
        Choice(
          id: 'beep',
          text: 'beep',
          feedback: 'Two beeps have just played. What follows two beeps?',
        ),
        Choice(
          id: 'boop',
          text: 'boop',
          correct: true,
          feedback: 'Yes! The pattern is beep, beep, boop, again and again.',
        ),
        Choice(
          id: 'buzz',
          text: 'buzz',
          feedback: 'A buzz never appears in the signal, so it cannot be next.',
        ),
      ],
      hints: [
        'Try splitting the signal into groups of three.',
        'Each group is beep, beep, then something else.',
      ],
      explanation:
          'The signal repeats the group "beep, beep, boop". After two beeps '
          'always comes a boop.',
    ),
    ChoiceStage(
      id: 'number_pattern',
      prompt:
          'The balloon sends height readings: 3, 6, 12, 24, ... '
          'What number comes next?',
      choices: [
        Choice(
          id: 'n30',
          text: '30',
          feedback: 'Adding 6 works once, but not from 6 to 12.',
        ),
        Choice(
          id: 'n36',
          text: '36',
          feedback: 'Adding 12 works from 12 to 24, but not from 3 to 6.',
        ),
        Choice(
          id: 'n48',
          text: '48',
          correct: true,
          feedback: 'Correct! Each number is double the one before.',
        ),
      ],
      hints: [
        'How do you get from 3 to 6? Does that same rule work for 6 to 12?',
        'Try multiplying instead of adding.',
      ],
      explanation:
          'Each reading doubles: 3, 6, 12, 24, so the next is 24 times 2, '
          'which is 48. Check a rule on every step, not just one.',
    ),
    OrderStage(
      id: 'word_order',
      prompt:
          'Four words arrived out of order. Use the clues to put them in '
          'the right order.',
      clues: [
        Clue(
          id: 'capital',
          title: 'Clue 1',
          text:
              'The message starts with the only word that has a capital '
              'letter.',
        ),
        Clue(
          id: 'after',
          title: 'Clue 2',
          text: 'The word "is" comes straight after the first word.',
        ),
        Clue(
          id: 'last',
          title: 'Clue 3',
          text: 'The word "safely" is the very last word.',
        ),
      ],
      pieces: [
        OrderPiece(id: 'balloon', text: 'Balloon'),
        OrderPiece(id: 'is', text: 'is'),
        OrderPiece(id: 'landing', text: 'landing'),
        OrderPiece(id: 'safely', text: 'safely'),
      ],
      hints: [
        'Use the clues one at a time. Which word has a capital letter?',
        'Once three words are placed, only one spot is left for the last word.',
      ],
      explanation:
          '"Balloon" has the capital, "is" comes next, and "safely" is last, '
          'so "landing" fills the gap: Balloon is landing safely.',
    ),
    ChoiceStage(
      id: 'shift_code',
      prompt:
          'The last word is in a shift code: each letter was moved one '
          'step forward in the alphabet. The code word is IPNF. What does it '
          'say?',
      clues: [
        Clue(
          id: 'code_example',
          title: 'Code example',
          text:
              'In this code, A becomes B, B becomes C, and so on. So CAT '
              'would be sent as DBU.',
        ),
      ],
      choices: [
        Choice(
          id: 'home',
          text: 'HOME',
          correct: true,
          feedback: 'Cracked it! I to H, P to O, N to M, F to E.',
        ),
        Choice(
          id: 'hope',
          text: 'HOPE',
          feedback: 'Close! But HOPE would be sent as IPQF, not IPNF.',
        ),
        Choice(
          id: 'gold',
          text: 'GOLD',
          feedback: 'GOLD would be sent as HPME. Try moving each letter back.',
        ),
      ],
      hints: [
        'To decode, move each letter one step back in the alphabet.',
        'The letter before I is H. What comes before P?',
      ],
      explanation:
          'Moving each letter of IPNF one step back gives H, O, M, E: HOME.',
    ),
  ],
);
