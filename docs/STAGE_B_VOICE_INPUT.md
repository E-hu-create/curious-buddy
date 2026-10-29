# Stage B Proposal: Tap-to-Talk Voice Input

**Status: proposal, awaiting approval. Nothing here is implemented.** The
app currently has no speech recognition, requests no microphone
permission, and the "Talk to Buddy" button only explains that talking is
coming soon.

## Recommended package

| | |
| --- | --- |
| Package | [`speech_to_text`](https://pub.dev/packages/speech_to_text) by Corner Software Development Corp. |
| Version | **7.4.0**: newest that resolves with Flutter 3.41.8 / Dart 3.11.5 (checked with `flutter pub add speech_to_text --dry-run`; 7.5.0+ does not resolve). |
| Licence | BSD 3-Clause. Free; no service fees or API keys. |
| Adds | 5 small packages (`speech_to_text_platform_interface`, `speech_to_text_windows`, `json_annotation`, `plugin_platform_interface`, `web`). |
| How it works | Thin wrapper around Android's built-in `SpeechRecognizer`. It does not do recognition itself; the phone's recognition service does (on Samsung phones usually the Google app or Samsung's service). |
| Maintenance | Long-standing, widely used, regular releases. |

Alternatives considered: on-device engines such as Vosk need large language
model downloads (50 MB+) and native setup; cloud APIs (Google Cloud
Speech, etc.) need keys, a backend and fees. Both are out of scope for now.

## Android requirements

| Manifest entry | Why | Notes |
| --- | --- | --- |
| `RECORD_AUDIO` | Microphone access | A **runtime permission**: Android shows a system prompt. We request it only after the child taps Talk and sees our explanation. |
| `INTERNET` | The phone's recognizer may use online recognition | Release builds would gain `INTERNET` for the first time (debug builds already have it for tooling). The app itself still makes no network calls. |
| `BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_CONNECT` | Headset microphones | **Avoidable**: initialise with `SpeechConfigOption.androidNoBluetooth` and do not declare them. Recommended. |
| `<queries>` for `android.speech.RecognitionService` | Find the recognizer on Android 11+ | Not a permission. |

The plugin's own manifest declares no permissions; we would add only
`RECORD_AUDIO`, `INTERNET` and the query.

## Privacy: where the child's voice goes

- **Audio is processed by the phone's speech recognition service, not by
  this app.** On most Android phones that is Google's service. Unless
  on-device mode is used, **audio may be sent to the service provider's
  servers** to be transcribed, under that provider's privacy terms.
- `speech_to_text` offers `onDevice: true`. When the device has an offline
  language pack installed, recognition stays on the phone; when it does
  not, listening fails instead of going online. **Proposal:** try
  on-device first. If it is unavailable, show a parent-facing message
  explaining that online recognition would be used, and keep it off unless
  a grown-up enables it in the Parent Zone (Stage B+ / Phase 6).
- The app receives **text only**. It never saves, logs or uploads audio,
  and transcripts are not stored (same as typed questions today).
- Children's voice data is sensitive personal data under COPPA, GDPR and
  the UK Age Appropriate Design Code. **A proper privacy and legal review is
  needed before release.** This proposal is not a compliance claim.

## Proposed behaviour

1. Child taps **Talk to Buddy**.
2. First time only: a child-friendly explanation ("Buddy needs the
   microphone to hear you. A grown-up may need to say yes."), with **Not
   now** and **OK**. Only **OK** triggers Android's permission prompt.
3. Listening state: Buddy's ears/expression change, a clear "Listening..."
   badge and a big **Stop** button. Maximum 15 seconds; stops after 3
   seconds of silence.
4. Recognised words appear **in the text box for checking**. Nothing is
   sent until the child taps **Ask** (they can edit or clear first).
5. Listening stops on: Stop, Cancel, navigating away, the app being
   hidden/interrupted, a phone call, or the screen being disposed. It never
   runs in the background and never starts by itself.
6. Buddy stops speaking before listening starts (no talking over the child).

| Situation | What the child sees |
| --- | --- |
| Permission denied | "That's okay! You can type to Buddy instead." Text box focused. No repeat prompt. |
| Permanently denied | Same, plus a Parent Zone note explaining how to enable it in Settings. |
| No recogniser / no offline pack | Talk button shows "Not available on this phone"; typing still works. |
| Nothing heard / error | "I didn't catch that. Try again, or type it!" |

## Implementation outline (once approved)

- `SpeechToTextRecognitionService implements SpeechRecognitionService`
  (interface already exists) in `data/services/voice/`; only file to import
  the plugin.
- Listening state added to `BuddyChatViewModel` (`BuddyActivity.listening`).
- `VoiceNavigatorObserver` and the lifecycle listener also stop listening.
- Tests with a fake recogniser for every row of the table above, plus a
  widget test that permission is never requested before the explanation.

## Decisions needed from you

1. Approve `speech_to_text` 7.4.0 and the `RECORD_AUDIO` + `INTERNET`
   permissions (no Bluetooth permissions)?
2. On-device only, or allow online recognition when a grown-up enables it?
3. Is a privacy review planned before any external testers use voice input?
