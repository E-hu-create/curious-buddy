/// Quiz Time content model: topics, levels and multiple-choice questions.
/// Pure data: no Flutter, no storage.
library;

enum QuizDifficulty { starter, explorer, expert }

class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerId,
    required this.explanation,
  });

  /// Writes a question briefly. Option ids are a, b, c, d in the order
  /// written; [answer] is the index of the correct one.
  factory QuizQuestion.fromList(
    String id,
    String prompt,
    List<String> options,
    int answer,
    String explanation,
  ) {
    const ids = ['a', 'b', 'c', 'd'];
    return QuizQuestion(
      id: id,
      prompt: prompt,
      options: [
        for (final (i, text) in options.indexed)
          QuizOption(id: ids[i], text: text),
      ],
      answerId: ids[answer],
      explanation: explanation,
    );
  }

  final String id;
  final String prompt;

  /// In the order written. Screens show them shuffled.
  final List<QuizOption> options;

  /// The id of the one correct option.
  final String answerId;

  /// One or two sentences on why, shown and read after every answer.
  final String explanation;

  QuizOption get answer => options.firstWhere((o) => o.id == answerId);

  QuizOption? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }
}

class QuizLevel {
  const QuizLevel({
    required this.id,
    required this.difficulty,
    required this.questions,
  });

  /// Unique across all topics, e.g. `space_starter`. Used in saved progress.
  final String id;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
}

class QuizTopic {
  const QuizTopic({
    required this.id,
    required this.title,
    required this.tagline,
    required this.levels,
  });

  final String id;
  final String title;
  final String tagline;

  /// Easiest first. Each level opens when the one before is passed.
  final List<QuizLevel> levels;
}
