import '../quiz/quiz.dart';

/// What everyone gets without paying. Everything else needs the one-time
/// full unlock. Buddy's answers, safety replies, Story Maker and Creative
/// Island are always free, so they are not listed here.
abstract final class FreeContent {
  /// The three starter stories.
  static const storyIds = {'forest_colours', 'luma_signal', 'tiny_inventor'};

  /// The three starter missions.
  static const missionIds = {
    'missing_moonstone',
    'wilting_garden',
    'mixed_up_signals',
  };

  /// Five games: Dino Discovery, Treasure Maze, and the Challenge Arena
  /// (Memory Match, Pattern Power and Spot the Change).
  static const gameIds = {'dino', 'maze', 'arena'};

  /// The starter level of every quiz topic.
  static bool quizLevel(QuizDifficulty difficulty) =>
      difficulty == QuizDifficulty.starter;
}
