/// Why a voice operation could not complete. Shared by speech output and
/// speech input so the UI can respond consistently.
enum VoiceFailure {
  /// No engine on this device, or the feature is not implemented yet.
  unavailable,

  /// An engine exists but no voice for the requested language is installed.
  voiceNotInstalled,

  /// The child or parent declined microphone access.
  permissionDenied,

  /// Declined with "don't ask again"; only system settings can fix it.
  permissionPermanentlyDenied,

  /// The platform engine reported an error.
  platformError,
}
