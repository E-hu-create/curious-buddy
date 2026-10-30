/// Mystery Missions content model. Pure data: no Flutter, no storage.
///
/// A [Mission] is a short case made of [MissionStage]s. Every stage has its
/// own clues to inspect, a challenge, progressive hints and an explanation,
/// so a child can always finish, with or without help.
library;

/// Which locally drawn cover a mission uses.
enum MissionArt {
  moonstone,
  garden,
  signals,
  puddle,
  lighthouse,
  postcards,
  beach,
  bread,
  orchard,
  shadow,
}

class Clue {
  const Clue({required this.id, required this.title, required this.text});

  final String id;

  /// Shown on the face-down card before it is inspected.
  final String title;
  final String text;
}

class Choice {
  const Choice({
    required this.id,
    required this.text,
    required this.feedback,
    this.correct = false,
  });

  final String id;
  final String text;
  final bool correct;

  /// Shown and spoken after picking this choice: why it fits, or why not.
  final String feedback;
}

/// One step of a mission. The subclasses are the mechanics.
sealed class MissionStage {
  const MissionStage({
    required this.id,
    required this.prompt,
    required this.hints,
    required this.explanation,
    this.clues = const [],
  });

  final String id;

  /// The question or task, shown at the top of the step.
  final String prompt;

  /// Optional evidence to inspect before answering.
  final List<Clue> clues;

  /// Revealed one at a time, from gentle nudge to strong help. Never the
  /// answer itself.
  final List<String> hints;

  /// Why the correct answer is right. Shown and spoken once solved.
  final String explanation;
}

/// Pick the one best answer.
final class ChoiceStage extends MissionStage {
  const ChoiceStage({
    required super.id,
    required super.prompt,
    required super.hints,
    required super.explanation,
    required this.choices,
    super.clues,
  });

  final List<Choice> choices;
}

/// Select every answer that fits (and none that don't).
final class MultiSelectStage extends MissionStage {
  const MultiSelectStage({
    required super.id,
    required super.prompt,
    required super.hints,
    required super.explanation,
    required this.choices,
    super.clues,
    this.missingFeedback = 'Good thinking! But there is more to spot.',
  });

  final List<Choice> choices;

  /// Shown when every pick is right but some correct ones are missing.
  final String missingFeedback;
}

/// Put pieces in the right order.
final class OrderStage extends MissionStage {
  const OrderStage({
    required super.id,
    required super.prompt,
    required super.hints,
    required super.explanation,
    required this.pieces,
    super.clues,
  });

  /// In the correct order. The screen shows them shuffled.
  final List<OrderPiece> pieces;
}

class OrderPiece {
  const OrderPiece({required this.id, required this.text});

  final String id;
  final String text;
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.tagline,
    required this.art,
    required this.intro,
    required this.objective,
    required this.stages,
    required this.solution,
    required this.badge,
  });

  final String id;
  final String title;

  /// One line for the mission card.
  final String tagline;
  final MissionArt art;

  /// The opening scene, narrated by Buddy.
  final String intro;

  /// What the child is trying to find out.
  final String objective;
  final List<MissionStage> stages;

  /// The case wrap-up on the completion screen.
  final String solution;

  /// Name of the badge earned for solving it.
  final String badge;
}
