# Dependencies

Exact versions are pinned in `pubspec.lock`, which is committed. Use
`flutter pub get --enforce-lockfile` to reproduce them.

## Current

| Package | Kind | Constraint | Locked | Why |
| --- | --- | --- | --- | --- |
| `flutter` | SDK | — | 3.41.8 | Framework |
| `cupertino_icons` | runtime | ^1.0.8 | 1.0.9 | iOS-style icons. From the template; **not used yet**. Candidate for removal if we never use Cupertino icons. 2.0.0 exists; do not upgrade without checking for breaking changes. |
| `flutter_tts` | runtime | ^4.2.5 | 4.2.5 | Buddy's voice via the device's built-in text-to-speech engine. MIT licence. Android min SDK 24. Declares no permissions; needs the `TTS_SERVICE` query in `AndroidManifest.xml` (added). Pulls in AndroidX core, which adds the app-private, signature-level `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (never shown to users). Wrapped by `FlutterTtsService`; no other file imports it. |
| `speech_to_text` | runtime | 7.4.0 (exact) | 7.4.0 | Tap-to-talk via Android's built-in recogniser. BSD 3-Clause. Newest version that resolves with Dart 3.11.5. Its own manifest declares no permissions; the app adds `RECORD_AUDIO`, `INTERNET` and the `RecognitionService` query, and opts out of Bluetooth. Its `onDevice` flag silently falls back online, so the app checks on-device availability itself (`MainActivity.kt`). Only `speech_to_text_recognition_service.dart` imports it. Adds `speech_to_text_platform_interface`, `speech_to_text_windows`, `json_annotation`, `plugin_platform_interface`, `web`. |
| `flutter_test` | dev, SDK | — | — | Unit and widget tests |
| `flutter_lints` | dev | ^6.0.0 | 6.0.0 | Recommended lint set (extended in `analysis_options.yaml`) |

There are no code-generation tools, network-service, analytics, advertising,
cloud or AI dependencies. Transitive packages are pinned by the Flutter SDK; their
newer versions shown by `flutter pub outdated` are not reachable and need no
action.

## Rules for adding a dependency

1. Need it: the job cannot reasonably be done with the SDK in under ~100
   lines.
2. Check on pub.dev: maintained (recent releases), verified publisher if
   possible, licence compatible (MIT/BSD/Apache), supports Android (and iOS
   if needed), and works with our Dart SDK constraint.
3. One package per job. No duplicates.
4. No analytics, advertising, crash-reporting-to-cloud, account, backend or
   AI API packages without an approved requirement and privacy review
   (see CHILD_SAFETY.md).
5. Avoid code generation unless the payoff is clear.
6. Add one dependency per commit. Run `tool\verify.ps1` and test on a device
   before committing.
7. Record it in the table above with the reason.
8. Never upgrade everything at once. Upgrade one package per commit and
   read its changelog.

## Expected future candidates (not added)

| Need | Likely candidate | Notes |
| --- | --- | --- |
| Persistent progress | `shared_preferences` | Official Flutter package. Implement `KeyValueStore` with it. |
| Navigation | `go_router` | Only if route guards or deep links are needed. |
| State sharing | `provider` | Only once several screens share state. |
