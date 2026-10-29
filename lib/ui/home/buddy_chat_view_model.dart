import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/conversation/curated_content.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/voice/educational_response_provider.dart';
import '../../domain/voice/narrator.dart';

/// What Buddy is doing, shown by his expression and the bubble.
///
/// `listening` is deliberately absent: speech input is not implemented
/// (Stage B), and the UI must not pretend otherwise.
enum BuddyActivity { idle, thinking, speaking }

/// One question-and-answer exchange with Buddy at a time.
///
/// Nothing here is saved: the conversation lives only in memory and is gone
/// when the app closes.
class BuddyChatViewModel extends ChangeNotifier {
  BuddyChatViewModel({
    required EducationalResponseProvider responder,
    required BuddyVoice voice,
    required String greeting,
  }) : _responder = responder,
       _voice = voice,
       _message = greeting {
    _voice.addListener(notifyListeners);
  }

  static const thinkingMessage = 'Hmm, let me think...';
  static const errorMessage =
      'Oops! My thinking got tangled. Please try asking again.';
  static const maxQuestionLength = 200;

  final EducationalResponseProvider _responder;
  final BuddyVoice _voice;
  bool _disposed = false;

  /// What Buddy's bubble shows (and "Hear again" repeats).
  String get message => _thinking ? thinkingMessage : _message;
  String _message;

  /// The child's last question, or null if none yet or if it was hidden for
  /// privacy (see [questionHidden]).
  String? get youAsked => _questionHidden ? null : _youAsked;
  String? _youAsked;

  /// True when the last question contained personal information; the UI
  /// says so instead of showing it.
  bool get questionHidden => _questionHidden;
  bool _questionHidden = false;

  EducationalResponse? get response => _response;
  EducationalResponse? _response;

  bool get hadError => _hadError;
  bool _hadError = false;

  bool _thinking = false;

  BuddyActivity get activity => _thinking
      ? BuddyActivity.thinking
      : _voice.isSpeaking
      ? BuddyActivity.speaking
      : BuddyActivity.idle;

  /// False while an answer is being prepared, so repeated taps are ignored.
  bool get canAsk => !_thinking;

  List<String> get suggestions {
    final followUps = _response?.followUps ?? const [];
    return followUps.isNotEmpty ? followUps : starterPrompts;
  }

  /// Answers [question] and speaks the answer (unless the voice is off).
  /// Ignored if empty or if Buddy is still preparing the last answer.
  Future<void> ask(String question) async {
    var text = question.trim();
    if (text.isEmpty || _thinking) return;
    if (text.length > maxQuestionLength) {
      text = text.substring(0, maxQuestionLength);
    }

    _thinking = true;
    _hadError = false;
    _youAsked = text;
    _questionHidden = false;
    _response = null;
    // A new question cuts off whatever Buddy was saying.
    unawaited(_voice.stop());
    _notify();

    try {
      final response = await _responder.respond(
        EducationalPrompt(question: text),
      );
      _response = response;
      _message = response.text;
      _questionHidden = response.hideQuestion;
      if (response.hideQuestion) _youAsked = null;
    } on Exception {
      _message = errorMessage;
      _hadError = true;
    }
    _thinking = false;
    _notify();
    if (!_disposed) unawaited(_voice.say(_message));
  }

  /// Speaks the bubble's current text again.
  Future<NarrationOutcome> replay() => _voice.say(_message);

  Future<void> stopSpeaking() => _voice.stop();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(notifyListeners);
    super.dispose();
  }
}
