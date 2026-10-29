/// Why a voice operation could not complete. Shared by speech output and
/// speech input so the UI can respond consistently.
enum VoiceFailure {
  /// No engine on this device, or the feature is not implemented yet.
  unavailable,

  /// An engine exists but no voice for the requested language is installed.
  voiceNotInstalled,

  /// The child or parent declined microphone access.
  permissionDenied,

  /// The platform engine reported an error.
  platformError,

  /// Online recognition is not allowed and this phone cannot recognise
  /// speech on the device.
  offlineUnavailable,

  /// Recognition needed the network and it was unavailable.
  network,
}
