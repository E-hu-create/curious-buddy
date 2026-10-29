/// Boundary for anything that answers a child's question: scripted content
/// today, possibly an AI backend later (only after a privacy and safety
/// review; see docs/CHILD_SAFETY.md).
///
/// Interface only. No implementation exists yet.
abstract interface class EducationalResponseProvider {
  Future<EducationalResponse> respond(EducationalPrompt prompt);
}

class EducationalPrompt {
  const EducationalPrompt({required this.topicId, required this.question});

  /// Which mission or story the child is in, to keep answers on topic.
  final String topicId;

  /// The child's question as text. Never raw audio, never identity data.
  final String question;
}

class EducationalResponse {
  const EducationalResponse({required this.text, this.isFallback = false});

  final String text;

  /// True when the provider could not answer and returned a safe generic
  /// reply (e.g. "Let's ask a grown-up together!").
  final bool isFallback;
}
