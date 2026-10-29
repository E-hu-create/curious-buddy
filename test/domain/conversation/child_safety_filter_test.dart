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
}
