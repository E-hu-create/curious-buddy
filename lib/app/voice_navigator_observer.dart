import 'package:flutter/widgets.dart';

import '../domain/voice/buddy_listener.dart';
import '../domain/voice/buddy_voice.dart';

/// Stops Buddy's voice and microphone whenever the user moves to another
/// screen, so speech never plays over another screen and the microphone is
/// never left open.
class VoiceNavigatorObserver extends NavigatorObserver {
  VoiceNavigatorObserver(this._voice, this._listener);

  final BuddyVoice _voice;
  final BuddyListener _listener;

  void _stopAll() {
    _listener.cancel().ignore();
    _voice.stop().ignore();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The very first route is app start, not navigation away. Dialogs (such
    // as the microphone explanation) are not screens and must not cut off
    // the flow that opened them.
    if (previousRoute != null && route is PageRoute) _stopAll();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _stopAll();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _stopAll();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stopAll();
}
