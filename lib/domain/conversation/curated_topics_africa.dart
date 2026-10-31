part of 'curated_content.dart';

// Ghana and Africa, added after the content audit found none. Same rules as
// curated_content: short sentences, well-established facts, "about" for
// rounded numbers, honesty where a fact is debated (the Nile's length).
// The specific topics go before _moreTopics, so "tallest mountain in
// Africa" finds Kilimanjaro, not Everest. The broad "africa" topic goes
// last, so "do elephants live in Africa" still finds elephants.

/// Every Ghana and Africa topic, so the content review can list them in
/// their own section without renumbering the items before them.
const ghanaAfricaTopics = <CuratedTopic>[..._ghanaAfricaFirst, _africa];

const _ghanaAfricaFirst = <CuratedTopic>[
  CuratedTopic(
    id: 'kente',
    triggers: [
      ['kente'],
    ],
    answers: [
      'Kente is a famous, colourful cloth from Ghana, first woven by the '
          'Asante and Ewe peoples. Weavers make long, narrow strips on a '
          'loom, then sew them together. Each colour has a meaning, like gold '
          'for wealth and green for growth.',
    ],
    followUps: ['What are Adinkra symbols?', 'Tell me about Ghana.'],
  ),
  CuratedTopic(
    id: 'adinkra',
    triggers: [
      ['adinkra'],
      ['sankofa'],
    ],
    answers: [
      'Adinkra are symbols from Ghana, made by the Akan people, and each '
          'one has a meaning. Sankofa is a bird looking back over its '
          'shoulder. It means: learn from the past to build the future.',
    ],
    followUps: ['What is Kente cloth?', 'Can drums talk?'],
  ),
  CuratedTopic(
    id: 'talking_drums',
    triggers: [
      ['talking', 'drum'],
      ['drum', 'talk'],
    ],
    answers: [
      'In Ghana and other parts of West Africa, drummers can make drums '
          'talk! Languages like Twi go up and down in tone. The drums copy '
          'those ups and downs, so they can send names and messages.',
    ],
    followUps: ['Who is Ananse?', 'What is Kente cloth?'],
  ),
  CuratedTopic(
    id: 'ananse',
    triggers: [
      ['ananse'],
      ['anansi'],
    ],
    answers: [
      'Kwaku Ananse is a clever spider from Ghanaian folk tales, first told '
          'by the Akan people. He often uses tricks to win. In one tale, he '
          'wins all the stories in the world. That is why Akan folk tales '
          'are called Anansesem, spider stories!',
    ],
    action: BuddyAction.openStories,
    actionLabel: 'Open Living Stories',
    followUps: ['Can drums talk?', 'Tell me about Ghana.'],
  ),
  CuratedTopic(
    id: 'harmattan',
    triggers: [
      ['harmattan'],
    ],
    answers: [
      'The Harmattan is a dry, dusty wind. It blows from the Sahara Desert '
          'across West Africa, from about November to March. It can make the '
          'sky hazy, the mornings cool, and lips and skin dry!',
    ],
    followUps: ['Tell me about the Sahara.', 'What makes wind?'],
  ),
  CuratedTopic(
    id: 'mole_park',
    triggers: [
      ['mole', 'park'],
      ['mole', 'national'],
      ['ghana', 'animal'],
      ['ghana', 'wildlife'],
    ],
    answers: [
      "Mole National Park is Ghana's biggest wildlife park. Elephants, "
          'antelopes, warthogs and baboons live there. Visitors can watch '
          'elephants come to drink at the waterholes.',
    ],
    followUps: ['Tell me about Ghana.', 'Tell me an elephant fact.'],
  ),
  CuratedTopic(
    id: 'ghana',
    triggers: [
      ['ghana'],
      ['ghanaian'],
      ['accra'],
      ['nkrumah'],
      ['volta'],
      ['akosombo'],
      ['tema'],
      ['prime', 'meridian'],
      ['cocoa'],
      ['chocolate'],
    ],
    pinned: {
      'capital': 0,
      'accra': 0,
      'independence': 0,
      'independent': 0,
      'nkrumah': 0,
      'meridian': 1,
      'equator': 1,
      'longitude': 1,
      'tema': 1,
      'cocoa': 2,
      'chocolate': 2,
      'volta': 3,
      'akosombo': 3,
      'lake': 3,
      'dam': 3,
    },
    answers: [
      'Ghana is a country in West Africa, and its capital city is Accra. In '
          '1957, led by Kwame Nkrumah, Ghana became one of the first African '
          'countries to win independence.',
      'The Prime Meridian, the line of 0 degrees longitude, runs right '
          'through the city of Tema in Ghana! Out at sea, south of Ghana, it '
          'crosses the Equator.',
      'Ghana is one of the biggest cocoa growers in the world. Cocoa beans '
          'grow in pods on cocoa trees, and they are used to make chocolate!',
      'Lake Volta in Ghana is one of the biggest human-made lakes in the '
          'world. It formed when the Akosombo Dam was built across the Volta '
          'River. The dam makes electricity.',
    ],
    followUps: ['What is Kente cloth?', 'Who is Ananse?'],
  ),
  CuratedTopic(
    id: 'africa_places',
    triggers: [
      ['kilimanjaro'],
      ['nile'],
      ['sahara'],
      ['africa', 'mountain'],
      ['africa', 'river'],
      ['africa', 'desert'],
    ],
    pinned: {
      'kilimanjaro': 0,
      'mountain': 0,
      'tallest': 0,
      'highest': 0,
      'nile': 1,
      'river': 1,
      'longest': 1,
      'sahara': 2,
      'desert': 2,
    },
    answers: [
      'Mount Kilimanjaro in Tanzania is the tallest mountain in Africa, at '
          'almost 6 kilometres. It is a sleeping volcano. It has snow on top, '
          'even though it is near the Equator!',
      'The Nile is one of the two longest rivers in the world, at about '
          '6,650 kilometres. Scientists still debate whether the Nile or the '
          'Amazon is longer. It flows north into the Mediterranean Sea.',
      'The Sahara is the biggest hot desert in the world, almost as big as '
          'the United States! Thousands of years ago, parts of it were green, '
          'with lakes, hippos and crocodiles.',
    ],
    followUps: ['Tell me about Ghana.', 'What is the Harmattan?'],
  ),
  CuratedTopic(
    id: 'african_history',
    triggers: [
      ['mansa', 'musa'],
      ['mali', 'empire'],
      ['timbuktu'],
      ['great', 'zimbabwe'],
      ['africa', 'history'],
    ],
    pinned: {'mansa': 0, 'musa': 0, 'mali': 0, 'timbuktu': 1, 'zimbabwe': 2},
    answers: [
      'Mansa Musa ruled the Mali Empire in West Africa about 700 years ago. '
          'On his journey to Mecca in 1324, he carried so much gold that '
          'people talked about it for centuries. He is often called one of '
          'the richest people in history.',
      'Timbuktu, in Mali, was once a great city of learning. Scholars '
          'travelled there from far away. People wrote and kept thousands of '
          'books by hand, and many still survive today!',
      'Great Zimbabwe is a city of stone in southern Africa, built about 600 '
          'to 900 years ago. Its huge walls stand without any mortar holding '
          'the stones together! The country of Zimbabwe is named after it.',
    ],
    followUps: ['Who was Wangari Maathai?', 'Tell me about Ghana.'],
  ),
  CuratedTopic(
    id: 'wangari_maathai',
    triggers: [
      ['wangari'],
      ['maathai'],
    ],
    answers: [
      'Wangari Maathai from Kenya started the Green Belt Movement. It helped '
          'women plant tens of millions of trees across Kenya. In 2004, she '
          'became the first African woman to win the Nobel Peace Prize.',
    ],
    followUps: ['Tell me about Africa.', 'Why are leaves green?'],
  ),
];

const _africa = CuratedTopic(
  id: 'africa',
  triggers: [
    ['africa'],
    ['african', 'country'],
  ],
  answers: [
    'Africa is the second-biggest continent, with 54 countries. More than '
        'a thousand languages are spoken there!',
    'Scientists think the very first humans lived in Africa. Some of the '
        'oldest fossils of early humans have been found there.',
  ],
  followUps: [
    'What is the tallest mountain in Africa?',
    'Tell me about Ghana.',
  ],
);
