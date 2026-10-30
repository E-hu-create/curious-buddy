import '../../app/routes.dart';
import '../../domain/voice/educational_response_provider.dart';

/// The only places a [BuddyAction] can take the child. Exhaustive on
/// purpose: adding an action without a screen will not compile.
String routeForAction(BuddyAction action) => switch (action) {
  BuddyAction.openMissions => Routes.missions,
  BuddyAction.openStories => Routes.stories,
  BuddyAction.openCreative => Routes.creative,
  BuddyAction.openDiscoveries => Routes.discoveries,
  BuddyAction.startQuiz => Routes.quiz,
  BuddyAction.openWardrobe => Routes.wardrobe,
  BuddyAction.openGames => Routes.games,
};
