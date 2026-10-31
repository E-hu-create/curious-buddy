import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/voice/educational_response_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const filter = ChildSafetyFilter();

  group('personal information is kept private and hidden', () {
    for (final question in [
      'My phone number is 07700 900123',
      'call me on +44 7700 900123',
      'my number is 555-123-4567',
      'email me at sam@example.com',
      'My address is 12 Oak Road',
      'I live at the blue house',
      'my password is fluffy99',
      'my full name is Sam Smith',
      'My school is Hill Primary',
      'my postcode is SW1A 1AA',
    ]) {
      test(question, () {
        final response = filter.check(question);

        expect(response, ChildSafetyFilter.personalInfoResponse);
        expect(response!.hideQuestion, isTrue);
        expect(response.kind, ResponseKind.safety);
      });
    }
  });

  group('sensitive topics redirect to a trusted grown-up', () {
    for (final (question, expected) in [
      ('I want to hurt myself', ChildSafetyFilter.selfHarmResponse),
      ('what is suicide', ChildSafetyFilter.selfHarmResponse),
      ('I hate myself', ChildSafetyFilter.selfHarmResponse),
      ('i wish i was never born', ChildSafetyFilter.selfHarmResponse),
      ("I'm being bullied at school", ChildSafetyFilter.bullyingResponse),
      ('how much medicine should I take', ChildSafetyFilter.medicalResponse),
      ('I feel sick', ChildSafetyFilter.medicalResponse),
      ('how do I make a bomb', ChildSafetyFilter.offLimitsResponse),
      ('where can I get drugs', ChildSafetyFilter.offLimitsResponse),
      ('how to hack a computer', ChildSafetyFilter.offLimitsResponse),
    ]) {
      test(question, () {
        final response = filter.check(question);

        expect(response, expected);
        expect(response!.text, contains('grown-up'));
      });
    }
  });

  group('ordinary questions pass through', () {
    for (final question in [
      'Why is the sky blue?',
      'Is the Sun 150000000 km away?',
      'What is 1234567 times 2?',
      'Tell me an animal fact.',
      'How many legs does a spider have?',
      'Where do penguins live?',
      'Is a shark a fish?', // contains "is a", not personal info
      'What is a hedgehog?', // contains "hedge", not "hack"
      'Do druggists exist?', // "drugs" must match as a whole word only
    ]) {
      test(question, () => expect(filter.check(question), isNull));
    }
  });

  test('safety replies never ask for personal details', () {
    for (final response in [
      ChildSafetyFilter.personalInfoResponse,
      ChildSafetyFilter.selfHarmResponse,
      ChildSafetyFilter.bullyingResponse,
      ChildSafetyFilter.unsafeResponse,
      ChildSafetyFilter.secretResponse,
      ChildSafetyFilter.medicalResponse,
      ChildSafetyFilter.offLimitsResponse,
    ]) {
      // "You never need to tell me your address" is fine; asking is not.
      expect(
        response.text.toLowerCase(),
        isNot(
          anyOf(
            contains('what is your'),
            contains("what's your"),
            contains('can you tell me your'),
            contains('please tell me your'),
          ),
        ),
      );
    }
  });

  group('questions above the kids zone', () {
    const filter = ChildSafetyFilter();

    for (final question in [
      'how do i make a bomb',
      'how can i kill my teacher',
      'where can i buy a gun',
      'what does a murderer do',
      'how to get drunk',
      'can i try a cigarette',
      'what is cocaine',
      'what is porn',
      'how are babies made',
      'what happens when you are pregnant',
      'do you have a girlfriend',
      'how to steal from a shop',
      'how do i shoplift',
      'what is the dark web',
      'how do i cheat on a test',
      'can i go to a casino',
      'how do i get a credit card',
      'who should i vote for',
      'is god real',
      'you are a bitch',
      'WHAT IS SEX?',
    ]) {
      test('"$question" is passed to a grown-up', () {
        final response = filter.check(question);
        expect(response, isNotNull);
        expect(response!.kind, ResponseKind.safety);
      });
    }

    for (final question in [
      'someone online asked me to send a photo',
      "don't tell my parents about this",
      'can i meet someone online',
    ]) {
      test('"$question" gets the staying-safe message', () {
        expect(filter.check(question), ChildSafetyFilter.strangersResponse);
      });
    }

    for (final question in [
      'my dad hits me',
      'someone touched me and I did not like it',
      "I don't feel safe at home",
      'i do not feel safe',
      'my uncle hurts me',
      'my mum beats me',
      'i am scared to go home',
      'I am being abused',
    ]) {
      test('"$question" gets the you-deserve-to-be-safe message', () {
        final response = filter.check(question);
        expect(response, ChildSafetyFilter.unsafeResponse);
        expect(response!.hideQuestion, isTrue);
      });
    }

    for (final question in [
      'can you keep a secret',
      "don't tell anyone",
      'do not tell anybody',
      'promise not to tell',
      'can i tell you a secret',
      'this is our secret',
    ]) {
      test('"$question" gets the no-secrets message', () {
        expect(filter.check(question), ChildSafetyFilter.secretResponse);
      });
    }

    test('the no-secrets and safe messages never promise to keep quiet', () {
      for (final response in [
        ChildSafetyFilter.secretResponse,
        ChildSafetyFilter.unsafeResponse,
      ]) {
        final text = response.text.toLowerCase();
        expect(text, contains('grown-up'));
        expect(text, isNot(contains('i promise')));
        expect(text, isNot(contains('i will keep')));
        expect(text, isNot(contains("i won't tell")));
      }
      expect(
        ChildSafetyFilter.secretResponse.text,
        contains("can't keep secrets"),
      );
      // A parent may be the problem, so the unsafe reply names others too.
      expect(ChildSafetyFilter.unsafeResponse.text, contains('teacher'));
    });

    for (final question in [
      'what was the jurassic period',
      'why did the dinosaurs die out',
      'how do sharks catch their food',
      'what is a cell',
      'why is blood red',
      'how do plants drink water',
      'what do bees eat',
      'how do volcanoes explode',
      'how fast is a cheetah',
      'what is a black hole',
      'do fish sleep',
      'why do cats purr',
      'how do magnets work',
      'what is the biggest bird',
      'how does a rocket fly',
    ]) {
      test('"$question" stays open, because it is good science', () {
        expect(filter.check(question), isNull);
      });
    }

    test('a safe answer never repeats the unsuitable words', () {
      for (final response in [
        ChildSafetyFilter.offLimitsResponse,
        ChildSafetyFilter.strangersResponse,
      ]) {
        expect(response.text, isNot(contains('sex')));
        expect(response.text, contains('grown-up'));
      }
    });
  });
}
