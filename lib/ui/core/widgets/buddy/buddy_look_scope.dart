import 'package:flutter/widgets.dart';

import '../../../../domain/wardrobe/buddy_wardrobe.dart';
import '../../../../domain/wardrobe/wardrobe.dart';

/// Gives every Buddy in the app the current outfit, and redraws them when it
/// changes.
class BuddyLookScope extends InheritedNotifier<BuddyWardrobe> {
  const BuddyLookScope({
    super.key,
    required BuddyWardrobe wardrobe,
    required super.child,
  }) : super(notifier: wardrobe);

  /// [BuddyLook.none] when there is no wardrobe above (e.g. in tests).
  static BuddyLook of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<BuddyLookScope>()
          ?.notifier
          ?.look ??
      BuddyLook.none;
}
