import 'package:flutter/widgets.dart';

import '../domain/voice/buddy_voice.dart';

/// Stops Buddy's voice whenever the user moves to another screen, so speech
/// from one screen never plays over another.
class VoiceNavigatorObserver extends NavigatorObserver {
  VoiceNavigatorObserver(this._voice);

  final BuddyVoice _voice;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The very first route is app start, not navigation away.
    if (previousRoute != null) _voice.stop().ignore();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _voice.stop().ignore();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _voice.stop().ignore();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _voice.stop().ignore();
}
