import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/domain/conversation/curated_response_provider.dart';
import 'package:curious_buddy/domain/voice/educational_response_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CuratedResponseProvider provider;

  setUp(() => provider = CuratedResponseProvider());

  Future<String?> topicFor(String question) async =>
      (await provider.respond(EducationalPrompt(question: question))).topicId;

  group('real questions reach the right topic', () {
    for (final (question, topic) in [
      // Animals
      ('Why do cats purr?', 'cats'),
      ('tell me about kittens', 'cats'),
      ('Can dogs smell really well?', 'dogs'),
      ('How big was T rex?', 't_rex'),
      ('when did the dinosaurs die', 'dinosaurs'),
      ('Can elephants jump?', 'elephants'),
      ('how tall are giraffes', 'giraffes'),
      ('Can penguins fly?', 'penguins'),
      ('Do dolphins sleep?', 'dolphins'),
      ('do jellyfish have brains', 'jellyfish'),
      ('How do bees make honey?', 'bees'),
      ('how strong are ants', 'ants'),
      ('Are spiders insects?', 'spiders'),
      ('Can bats see in the dark?', 'bats'),
      ('why do owls turn their heads', 'owls'),
      ('Do frogs drink water?', 'frogs'),
      ('how do snakes smell', 'snakes'),
      ('Why do chameleons change colour?', 'chameleons'),
      ("What's the fastest animal?", 'cheetahs'),
      // Space
      ('How many planets are there?', 'how_many_planets'),
      ('Why is Mars red?', 'mars'),
      ("What are Saturn's rings made of?", 'saturn'),
      ('What is a black hole?', 'black_hole'),
      ('How do astronauts sleep in space?', 'astronauts'),
      ('What is gravity?', 'gravity'),
      ('Why does the moon change shape?', 'moon_phases'),
      ('What is a star?', 'what_is_star'),
      ('How fast is light?', 'light_speed'),
      // Earth and weather
      ('What makes thunder?', 'thunder'),
      ('Why does it rain?', 'rain'),
      ('How does snow form?', 'snow'),
      ('How do volcanoes work?', 'volcanoes'),
      ('Why do earthquakes happen?', 'earthquakes'),
      ('What are tides?', 'tides'),
      ('How do plants eat?', 'plants'),
      // Body
      ('How many times does my heart beat?', 'heart'),
      ('How many bones do we have?', 'bones'),
      ('How does my brain work?', 'brain'),
      ('Why do we need sleep?', 'sleep'),
      ('Why do we yawn?', 'yawn'),
      ('Why do I get hiccups?', 'hiccups'),
      // Science, history, fun
      ('How do magnets work?', 'magnets'),
      ('Why do boats float?', 'float'),
      ('Why does ice melt?', 'water_states'),
      ('How do computers work?', 'computers'),
      ('What is the biggest number?', 'biggest_number'),
      ('Who built the pyramids?', 'pyramids'),
      ('Tell me a joke!', 'jokes'),
      // Existing topics still reached
      ('Why is the sky blue?', 'sky_blue'),
      ('Why do stars twinkle?', 'stars_twinkle'),
      ('Tell me an ocean fact.', 'ocean_fact'),
      ('Tell me a space fact.', 'space_fact'),
      ('Tell me an animal fact.', 'animal_fact'),
      ('Teach me something amazing.', 'amazing'),
    ]) {
      test(question, () async => expect(await topicFor(question), topic));
    }
  });

  group('third batch: 50 more real questions', () {
    for (final (question, topic) in [
      ('how do fish breathe', 'fish'),
      ('what do pandas eat', 'pandas'),
      ('how do planes fly', 'planes'),
      ('who invented the light bulb', 'light_bulb'),
      ('how loud is a lion\x27s roar', 'lions'),
      ('why do tigers have stripes', 'tigers'),
      ('what colour is a polar bear\x27s skin', 'polar_bears'),
      ('how big is a baby kangaroo', 'kangaroos'),
      ('do crocodiles have tongues', 'crocodiles'),
      ('can horses sleep standing up', 'horses'),
      ('how many stomachs does a cow have', 'cows'),
      ('how do birds fly', 'birds'),
      ('how do worms breathe', 'worms'),
      ('how well can eagles see', 'eagles'),
      ('why can parrots talk', 'parrots'),
      ('how do rockets work', 'rockets'),
      ('what is electricity', 'electricity'),
      ('how do batteries work', 'batteries'),
      ('what is the internet', 'internet'),
      ('how do mobile phones work', 'phones'),
      ('what is sound', 'sound'),
      ('what is an echo', 'echo'),
      ('why does ice float', 'float'),
      ('why is the sea blue', 'sea_blue'),
      ('what makes wind', 'wind'),
      ('how are mountains made', 'mountains'),
      ('what is a desert', 'deserts'),
      ('what lives in the rainforest', 'rainforests'),
      ('what is in the middle of the earth', 'earth_core'),
      ('what makes waves', 'waves'),
      ('how big is the sun', 'sun_size'),
      ('how far away is the sun', 'sun_distance'),
      ('how old is the earth', 'earth_age'),
      ('why does the moon follow our car', 'moon_follows'),
      ('what is the biggest planet', 'jupiter'),
      ('is pluto a planet', 'pluto'),
      ('what is a comet', 'comets'),
      ('are aliens real', 'aliens'),
      ('who was the first person on the moon', 'moon_landing'),
      ('who invented the telephone', 'telephone'),
      ('why do we sneeze', 'sneeze'),
      ('why do we need water', 'body_water'),
      ('how many teeth do we have', 'teeth'),
      ('why do we blink', 'blink'),
      ('why do we get goosebumps', 'goosebumps'),
      ('why do my fingers wrinkle in the bath', 'wrinkly_fingers'),
      ('how many taste buds do i have', 'taste_buds'),
      ('tell me a riddle', 'riddles'),
      ('i\x27m sad', 'feelings'),
      ('i feel lonely', 'feelings'),
    ]) {
      test(question, () async {
        final response = await provider.respond(
          EducationalPrompt(question: question),
        );
        expect(response.topicId, topic);
        expect(response.isFallback, isFalse, reason: 'answers directly');
      });
    }
  });

  group('specific topics win over broad ones', () {
    test('octopus hearts goes to the ocean, not the human heart', () async {
      expect(
        await topicFor('Why does an octopus have three hearts?'),
        'ocean_fact',
      );
    });

    test('why stars twinkle beats "what is a star"', () async {
      expect(await topicFor('why do the stars twinkle'), 'stars_twinkle');
    });

    test('rainbows are not rain', () async {
      expect(await topicFor('how are rainbows made'), 'rainbow');
    });

    test('frogs drinking water stay with frogs, not body water', () async {
      expect(await topicFor('why do frogs drink water'), 'frogs');
    });

    test('T. rex teeth stay with T. rex, not human teeth', () async {
      expect(await topicFor('how big were t rex teeth'), 't_rex');
    });

    test('"sad" in a joke request is not a feelings reply', () async {
      expect(await topicFor('tell me a joke about a sad maths book'), 'jokes');
    });

    test('a phone number is still caught by the safety filter', () async {
      final response = await provider.respond(
        const EducationalPrompt(question: 'how do phones work 07700 900123'),
      );
      expect(response.hideQuestion, isTrue);
    });

    // A child who shares a feeling gets the feelings reply, even when the
    // message also says hello, asks for help or names another topic.
    for (final question in [
      "Help, I'm scared",
      "Hi Buddy, I'm sad",
      "I'm sad my cat died",
      'hey i feel lonely',
      "i'm worried about the volcano test",
    ]) {
      test('"$question" gets the feelings reply first', () async {
        expect(await topicFor(question), 'feelings');
      });
    }

    // Saying you are not safe, or asking Buddy to keep a secret, must never
    // get "I don't know that one yet".
    for (final question in [
      'my dad hits me',
      'someone touched me',
      "I don't feel safe",
      'can you keep a secret',
      "don't tell anyone",
    ]) {
      test('"$question" gets a safety reply, not "I don\'t know"', () async {
        final response = await provider.respond(
          EducationalPrompt(question: question),
        );
        expect(response.kind, ResponseKind.safety);
        expect(response.text, contains('grown-up'));
      });
    }

    test('feelings replies point to a trusted grown-up', () async {
      final response = await provider.respond(
        const EducationalPrompt(question: "I'm sad"),
      );
      expect(response.text, contains('grown-up you trust'));
    });
  });

  group('forgiving matching', () {
    for (final (question, topic) in [
      ('tell me about dinosuars', 'dinosaurs'), // swapped letters
      ('do girafes sleep', 'giraffes'), // missing letter
      ('elephnat facts', 'elephants'), // swapped letters
      ('BUTTERFLIES?!', 'butterflies'), // plural "-ies" + shouting
      ("what's a giraffe's tongue like", 'giraffes'), // possessive
    ]) {
      test(question, () async => expect(await topicFor(question), topic));
    }
  });

  group('typo forgiveness does not misfire', () {
    for (final (typed, wanted) in [
      ('plant', 'planet'), // short words need exact matches
      ('train', 'brain'),
      ('snack', 'snake'),
      ('cat', 'bat'),
    ]) {
      test('"$typed" is not "$wanted"', () {
        expect(CuratedResponseProvider.isNearMiss(typed, wanted), isFalse);
      });
    }

    test('trains are not brains', () async {
      expect(await topicFor('how do trains work'), isNot('brain'));
    });

    test('plants are not planets', () async {
      expect(await topicFor('how many plants are there'), 'plants');
    });
  });

  group('pinned answers really answer the question', () {
    Future<String> textFor(String q) async =>
        (await provider.respond(EducationalPrompt(question: q))).text;

    test('"why do cats purr" gets the purr answer every time', () async {
      for (var i = 0; i < 4; i++) {
        expect(await textFor('why do cats purr'), contains('purr'));
      }
    });

    for (final (question, expected) in [
      ('can dogs see colours', 'blues and yellows'),
      ('can elephants jump', "can't jump"),
      ('how do bees make honey', 'nectar'),
      ('why does an octopus have three hearts', 'three hearts'),
      ('can penguins fly', "can't fly"),
      ('why is mars red', 'iron'),
      ('what is the biggest animal', 'blue whale'),
    ]) {
      test(
        question,
        () async => expect(await textFor(question), contains(expected)),
      );
    }
  });

  group('honest lead-in when only the subject matched', () {
    test('a specific question gets "not sure" plus a fact', () async {
      final response = await provider.respond(
        const EducationalPrompt(question: 'What do snakes eat?'),
      );

      expect(response.text, startsWith(notSureLeadIn('snake')));
      expect(response.kind, ResponseKind.fallback);
    });

    test(
      '"how hot is Jupiter" admits it, then offers a Jupiter fact',
      () async {
        final response = await provider.respond(
          const EducationalPrompt(question: 'How hot is Jupiter?'),
        );

        expect(response.text, startsWith(notSureLeadIn('Jupiter')));
      },
    );

    test('a fact request needs no lead-in', () async {
      for (final question in [
        'Tell me about snakes.',
        'Tell me a dog fact.',
        'something cool about owls',
      ]) {
        final response = await provider.respond(
          EducationalPrompt(question: question),
        );
        expect(
          response.text,
          isNot(startsWith("I'm not sure")),
          reason: question,
        );
        expect(response.kind, ResponseKind.answer, reason: question);
      }
    });

    test('topics that answer a concept never get a lead-in', () async {
      final response = await provider.respond(
        const EducationalPrompt(question: 'How does gravity work?'),
      );

      expect(response.text, isNot(startsWith("I'm not sure")));
    });

    test('lead-in answers still read well aloud (≤ 60 words)', () {
      for (final topic in curatedTopics.where((t) => t.subject != null)) {
        for (final answer in topic.answers) {
          final words = (notSureLeadIn(topic.subject!) + answer).split(' ');
          expect(words.length, lessThanOrEqualTo(60), reason: topic.id);
        }
      }
    });

    test('pinned indexes point at real answers', () {
      for (final topic in curatedTopics) {
        for (final index in topic.pinned.values) {
          expect(index, lessThan(topic.answers.length), reason: topic.id);
        }
      }
    });
  });

  test('"planes" is not "planet"', () async {
    expect(CuratedResponseProvider.isNearMiss('planes', 'planet'), isFalse);
    expect(await topicFor('how do planes fly'), isNot('space_fact'));
  });

  test('unknown questions still fall back honestly', () async {
    final response = await provider.respond(
      const EducationalPrompt(question: 'What is the capital of Mongolia?'),
    );

    expect(response, fallbackAnswer);
  });

  test('library size', () {
    // Guards against accidentally dropping topics.
    expect(curatedTopics.length, greaterThanOrEqualTo(119));
  });
}
