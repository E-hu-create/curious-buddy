import 'dart:async';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/conversation/child_safety_filter.dart';
import 'package:curious_buddy/domain/conversation/curated_content.dart';
import 'package:curious_buddy/domain/conversation/curated_response_provider.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/domain/voice/educational_response_provider.dart';
import 'package:curious_buddy/ui/home/buddy_chat_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

const greeting = 'Hello!';

/// Answers only when told to, so tests can act while Buddy is "thinking".
class ManualResponder implements EducationalResponseProvider {
  final List<String> questions = [];
  Completer<EducationalResponse>? _pending;

  @override
  Future<EducationalResponse> respond(EducationalPrompt prompt) {
    questions.add(prompt.question);
    return (_pending = Completer()).future;
  }

  void answer(String text) =>
      _pending!.complete(EducationalResponse(text: text));
  void fail() => _pending!.completeError(Exception('provider broke'));
}

/// Remembers every key written.
class RecordingKeyValueStore extends InMemoryKeyValueStore {
  final List<String> writtenKeys = [];

  @override
  Future<void> write(String key, String value) {
    writtenKeys.add(key);
    return super.write(key, value);
  }
}

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late BuddyChatViewModel chat;

  BuddyChatViewModel build([EducationalResponseProvider? responder]) =>
      chat = BuddyChatViewModel(
        responder: responder ?? CuratedResponseProvider(),
        voice: voice,
        greeting: greeting,
      );

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
  });

  tearDown(() {
    chat.dispose();
    voice.dispose();
  });

  test('starts with the greeting and starter prompts', () {
    build();

    expect(chat.message, greeting);
    expect(chat.youAsked, isNull);
    expect(chat.suggestions, starterPrompts);
    expect(chat.activity, BuddyActivity.idle);
    expect(chat.canAsk, isTrue);
  });

  test('asking shows the question and answer and speaks the answer', () async {
    build();

    await chat.ask('  Why is the sky blue?  ');
    await pumpEventQueue();

    expect(chat.youAsked, 'Why is the sky blue?');
    expect(chat.message, contains('blue light'));
    expect(tts.spoken, [chat.message]);
    expect(chat.suggestions, contains('Why are sunsets orange?'));
  });

  test('empty questions are ignored', () async {
    final responder = ManualResponder();
    build(responder);

    await chat.ask('   ');

    expect(responder.questions, isEmpty);
    expect(chat.message, greeting);
  });

  test('shows a thinking state and ignores repeat submissions', () async {
    final responder = ManualResponder();
    build(responder);

    final first = chat.ask('Tell me an animal fact.');
    expect(chat.activity, BuddyActivity.thinking);
    expect(chat.message, BuddyChatViewModel.thinkingMessage);
    expect(chat.canAsk, isFalse);

    await chat.ask('Tell me an animal fact.');
    await chat.ask('Something else');
    expect(responder.questions, hasLength(1));

    responder.answer('Otters hold hands!');
    await first;
    expect(chat.canAsk, isTrue);
    expect(chat.message, 'Otters hold hands!');
  });

  test('a new question cuts off the answer being spoken', () async {
    tts.holdSpeech = true;
    build();
    await chat.ask('Tell me an animal fact.');
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);
    expect(chat.activity, BuddyActivity.speaking);

    await chat.ask('Why is the sky blue?');
    await pumpEventQueue();

    expect(tts.spoken, hasLength(2));
    expect(tts.spoken.last, contains('blue light'));
  });

  test('stopSpeaking stops Buddy immediately', () async {
    tts.holdSpeech = true;
    build();
    await chat.ask('Tell me an animal fact.');
    await pumpEventQueue();

    await chat.stopSpeaking();

    expect(tts.isSpeaking, isFalse);
    expect(chat.activity, BuddyActivity.idle);
  });

  test('replay speaks the current bubble again', () async {
    build();
    await chat.replay();
    expect(tts.spoken, [greeting]);

    await chat.ask('Why is the sky blue?');
    await pumpEventQueue();
    await chat.replay();

    expect(tts.spoken.last, chat.message);
    expect(tts.spoken, hasLength(3));
  });

  test('voice off: answers still appear but are not spoken', () async {
    build();
    await voice.setMuted(true);

    await chat.ask('Why is the sky blue?');
    await pumpEventQueue();

    expect(chat.message, contains('blue light'));
    expect(tts.spoken, isEmpty);
  });

  test('personal information is hidden and not repeated back', () async {
    build();

    await chat.ask('my phone number is 07700 900123');
    await pumpEventQueue();

    expect(chat.questionHidden, isTrue);
    expect(chat.youAsked, isNull);
    expect(chat.message, ChildSafetyFilter.personalInfoResponse.text);
    expect(tts.spoken.single, isNot(contains('07700')));
  });

  test('a failing provider shows a friendly error and recovers', () async {
    final responder = ManualResponder();
    build(responder);

    final asking = chat.ask('anything');
    responder.fail();
    await asking;

    expect(chat.hadError, isTrue);
    expect(chat.message, BuddyChatViewModel.errorMessage);
    expect(chat.canAsk, isTrue);

    final again = chat.ask('again');
    responder.answer('Fixed!');
    await again;
    expect(chat.hadError, isFalse);
    expect(chat.message, 'Fixed!');
  });

  test('long questions are trimmed to the maximum length', () async {
    final responder = ManualResponder();
    build(responder);

    final asking = chat.ask('a' * 500);
    responder.answer('ok');
    await asking;

    expect(
      responder.questions.single,
      hasLength(BuddyChatViewModel.maxQuestionLength),
    );
  });

  test('the conversation is never written to storage', () async {
    final recording = RecordingKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: recording);
    build();

    await chat.ask('Why is the sky blue?');
    await chat.ask('my address is 1 Oak Road');
    await chat.replay();
    await pumpEventQueue();

    expect(recording.writtenKeys, isEmpty);
  });

  test('an answer arriving after dispose does nothing', () async {
    final responder = ManualResponder();
    final disposable = BuddyChatViewModel(
      responder: responder,
      voice: voice,
      greeting: greeting,
    );
    build(); // for tearDown

    final asking = disposable.ask('hello');
    disposable.dispose();
    responder.answer('late');
    await asking;
    await pumpEventQueue();

    expect(tts.spoken, isEmpty);
  });
}
