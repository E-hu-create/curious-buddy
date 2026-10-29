# Stage B: Tap-to-Talk Voice Input

**Status: implemented (awaiting review).** Approved decisions:
`speech_to_text` 7.4.0 with `RECORD_AUDIO` + `INTERNET` (no Bluetooth);
recognition **on-device only unless a grown-up allows online**; a privacy
review before anyone outside the team uses voice input.

## Package

| | |
| --- | --- |
| Package | [`speech_to_text`](https://pub.dev/packages/speech_to_text) **7.4.0**, pinned exactly (newest that resolves with Flutter 3.41.8 / Dart 3.11.5). |
| Licence | BSD 3-Clause. Free; no service fees or API keys. |
| Adds | `speech_to_text_platform_interface`, `speech_to_text_windows`, `json_annotation`, `plugin_platform_interface`, `web`. |
| How it works | Wraps Android's built-in `SpeechRecognizer`. The phone's recognition service does the recognition. |
| Only file importing it | `lib/data/services/voice/speech_to_text_recognition_service.dart` (`PluginSpeechEngine`). |

## Android

| Manifest entry | Why |
| --- | --- |
| `RECORD_AUDIO` | Microphone. Runtime permission; requested only after the child taps Talk and agrees to the explanation. |
| `INTERNET` | Only so the phone's recogniser can work online when a grown-up allows it. **Release builds now include `INTERNET`.** The app itself makes no network calls. |
| `<queries>` `android.speech.RecognitionService` | Find the recogniser on Android 11+. Not a permission. |

No Bluetooth permissions (`SpeechConfigOption.androidNoBluetooth`). Verified
in the merged debug **and release** manifests.

## Why "on-device only" needed extra code

The plugin's `onDevice: true` only *prefers* on-device recognition: in its
Android source (`createRecognizer`), if the phone has no on-device
recogniser it **silently falls back** to the default one, which may send
audio online. To honour "on-device only unless a grown-up allows online":

- `MainActivity.kt` answers `isOnDeviceAvailable` on the
  `curious_buddy/speech` channel using Android's
  `SpeechRecognizer.isOnDeviceRecognitionAvailable` (Android 12+).
- When online is not allowed and that returns false,
  `SpeechToTextRecognitionService.listen` **refuses to start** and returns
  `offlineUnavailable`. When it returns true, the plugin uses Android's
  `createOnDeviceSpeechRecognizer`, which does not use the network.
- If the on-device recogniser lacks an English language pack, the error is
  reported as `offlineUnavailable` too.

On the Samsung SM-A516U test phone, the configured on-device recogniser is
Google's Android System Intelligence
(`com.google.android.as/...AiAiSpeechRecognitionService`); the default
(online-capable) one is Google's (`com.google.android.tts`).

## Behaviour

1. Child taps **Talk to Buddy**.
2. If the microphone is not yet granted: **"Can Buddy use the
   microphone?"** explanation with **Not now** / **OK**. Only **OK** shows
   Android's prompt.
3. Buddy stops talking. **Listening...** card with the words appearing live,
   **Done** and **Cancel**; "Listening..." badge under Buddy, who looks
   curious. "Hear again", typing and ideas are disabled meanwhile.
4. Limits: 15 seconds; stops after 3 seconds of silence.
5. Words go into the text box with "Check your words, then tap Ask."
   **Nothing is sent until the child taps Ask.**
6. Listening is cancelled on: Cancel, navigating to another screen, the app
   becoming inactive or hidden (calls, app switcher, screen off), and app
   close. It never runs in the background and never starts by itself.

| Situation | What the child sees |
| --- | --- |
| Permission denied | "That's okay! You can type to Buddy instead. A grown-up can turn on the microphone ... in the phone's Settings." Never re-prompted automatically. |
| No on-device recogniser and online not allowed | "This phone can't listen without the internet. A grown-up can allow online listening in the Parent Zone. You can type instead!" |
| Nothing heard | "I didn't catch that. Tap Talk to try again, or type it!" |
| Network problem (online mode) | "Buddy couldn't hear you because the internet isn't working..." |
| No recogniser / not Android | "Talking isn't available on this phone. You can type to Buddy instead!" |

Android does not tell apps whether a denial was "don't ask again", so the
denied message always mentions Settings.

## Parent Zone (minimal)

"Grown-ups" opens a parent check (a times-table question, asked every
time; a light gate for young children, not a security control), then one
setting: **Allow online voice recognition**, off by default, with a plain
explanation of where audio may go, and whether this phone can recognise
speech on the device. The setting is saved on the phone and survives
restarts (Phase 3).

## Privacy summary

- Audio is handled by the phone's recognition service, not by the app. Off
  (default): only on-device. On: the provider (often Google) may receive
  audio under its own privacy terms.
- The app receives text only; it never saves, logs or uploads audio, and
  transcripts are not stored.
- **Not a compliance claim.** A privacy and legal review is required before
  external testers use voice input (agreed).
