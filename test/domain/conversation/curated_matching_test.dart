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

    test('"how big is the sun" admits it, then offers a space fact', () async {
      final response = await provider.respond(
        const EducationalPrompt(question: 'How big is the sun?'),
      );

      expect(response.text, startsWith(notSureLeadIn('space')));
    });

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
    expect(curatedTopics.length, greaterThanOrEqualTo(70));
  });
}
