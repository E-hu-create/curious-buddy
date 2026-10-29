/// Boundary for anything that answers a child's question.
///
/// Today: reviewed, offline content (`CuratedResponseProvider`). A smarter
/// engine may replace it later, but only after the architecture and safety
/// review in docs/CHILD_SAFETY.md, and only behind this interface.
abstract interface class EducationalResponseProvider {
  Future<EducationalResponse> respond(EducationalPrompt prompt);
}

class EducationalPrompt {
  const EducationalPrompt({required this.question, this.topicId = 'home'});

  /// Where the child is asking from, to keep answers on topic.
  final String topicId;

  /// The child's question as text. Never raw audio, never identity data.
  final String question;
}

enum ResponseKind {
  /// A reviewed answer.
  answer,

  /// The provider honestly does not know; suggests things it can do.
  fallback,

  /// The question touched a safety rule; Buddy redirects to a grown-up or
  /// asks the child to keep something private.
  safety,
}

/// The only things Buddy may do besides talk. Each maps to an existing,
/// in-app screen; nothing opens the web, files, or device features.
enum BuddyAction {
  openMissions,
  openStories,
  openCreative,
  openDiscoveries,

  /// Placeholder: there is no quiz engine yet; opens a "coming soon" page.
  startQuiz,
}

class EducationalResponse {
  const EducationalResponse({
    required this.text,
    this.kind = ResponseKind.answer,
    this.topicId,
    this.action,
    this.actionLabel,
    this.followUps = const [],
    this.hideQuestion = false,
  });

  /// Short sentences, written to be heard as well as read.
  final String text;
  final ResponseKind kind;

  /// Which curated topic answered, if any (for tests and debugging only).
  final String? topicId;

  /// Optional activity Buddy offers to open. Never run automatically; the
  /// child must tap it.
  final BuddyAction? action;
  final String? actionLabel;

  /// Suggested next questions.
  final List<String> followUps;

  /// True when the question contained personal information, so the UI must
  /// not show or repeat it.
  final bool hideQuestion;

  bool get isFallback => kind == ResponseKind.fallback;
}
