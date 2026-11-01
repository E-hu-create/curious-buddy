/// How Buddy's text maps to recorded clips. Each sentence is recorded once,
/// so a line built from several sentences plays them in order. The recording
/// tool uses the same two functions, so names always match.
abstract final class VoiceClips {
  // After . ! or ?, with an optional closing quote, before a new sentence.
  // Titles keep their dot ("Dr. Ravi"), and "said Tessa" stays with its quote.
  static final _boundary = RegExp(
    r'(?<!\b(?:Dr|Mr|Mrs|Ms|St)\.)(?<=[.!?]["”]?)\s+(?=["“A-Z0-9])',
  );

  static List<String> sentences(String text) => [
    for (final part in text.trim().split(_boundary))
      if (part.trim().isNotEmpty) part.trim().replaceAll(RegExp(r'\s+'), ' '),
  ];

  /// A short, stable file name for [sentence] (FNV-1a, 64 bits).
  static String name(String sentence) {
    var high = 0xcbf29ce4;
    var low = 0x84222325;
    for (final unit in sentence.codeUnits) {
      low ^= unit;
      // Multiply by the FNV prime, 0x100000001b3, in 32-bit halves.
      final a = low * 0x1b3;
      final b = high * 0x1b3 + (low << 8) + (a ~/ 0x100000000);
      low = a & 0xffffffff;
      high = b & 0xffffffff;
    }
    return high.toRadixString(16).padLeft(8, '0') +
        low.toRadixString(16).padLeft(8, '0');
  }
}
