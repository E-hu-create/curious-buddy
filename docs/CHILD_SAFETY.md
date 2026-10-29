# Child Safety and Privacy

Curious Buddy is for children. These rules apply to every change. If a
feature cannot meet them, it needs an explicit decision and review before it
is built.

## Principles

1. **Collect as little as possible.** Store only what the app needs to work.
2. **Everything stays on the device** unless a reviewed requirement says
   otherwise.
3. **Parents decide.** Anything that changes data handling, enables a
   capability (like the microphone) or leaves the app goes through the
   Parent Zone.
4. **Fail safe.** When something breaks, the child continues with a simpler
   experience. They should not see errors meant for adults.

## Data we store (locally only)

This is the complete list of stored keys (audited in Phase 6). The Parent
Zone shows the same list to parents, with live values read from storage.

| Key | Data | Why | Reset by "Delete all progress" |
| --- | --- | --- | --- |
| `progress` | `LearnerProgress` JSON: IDs of completed missions and stories, best mission points, story ending IDs found, and the scene IDs of an unfinished story | Show progress, badges, endings found, and let the child continue a story | Deleted |
| `progress.corrupt_backup` | A copy of saved progress that could not be read (only exists if that ever happened) | Not silently losing a child's progress | Deleted |
| `voice.muted` | Voice on/off | Respect the choice to keep Buddy quiet | Kept, unless "Also restore default settings" is ticked |
| `voice.speed` | Speaking speed (slower / normal / faster) | Grown-up choice | Same as above |
| `voice.autoRead` | Read aloud automatically, or only when asked | Grown-up choice | Same as above |
| `voice.allowOnlineRecognition` | Allow online voice recognition, off by default | Grown-up choice about where speech is recognised | Same as above |
| `display.reduceMotion` | Calmer animations | Accessibility | Same as above |
| *Future:* Creative Island creations | Child's own work | | Must be added to the reset |

**Only in memory, never saved:** questions asked on Home and Buddy's
answers; words heard while talking (shown in the text box to check); a
mission in progress; the parent check and its pause after wrong answers;
whether the welcome was spoken this session; the last line Buddy said.

**Reset** (`ParentZoneViewModel.reset`) deletes `progress` and
`progress.corrupt_backup` through `ProgressRepository.clear`, then reads
storage back and only reports success if nothing is left. Optionally it
writes every setting back to its default. Any new stored data must be added
to this table, the Parent Zone overview and the reset.

Saved **on this phone only**, in the app's private storage
(`shared_preferences`). Android cloud backup is turned off for the app
(`allowBackup="false"`), so it is not copied to Google Drive or a new phone;
uninstalling the app deletes it. Conversations are never saved. The app
does not add its own encryption; it relies on Android keeping app-private
storage away from other apps.

## Data we do not collect

- Names, birthdays, ages, photos, contacts, email or phone numbers.
- Precise or approximate location. No location permission is requested.
- Advertising IDs, analytics, tracking or fingerprinting.
- Voice recordings. The app receives recognised text only; it never saves,
  logs or uploads audio. (Where the phone's recogniser sends audio is covered
  under "Voice input" below.)
- Free-text typed by children, beyond what a feature needs at that moment.

## Permissions

Release builds request exactly (verified in the merged manifest):

- `RECORD_AUDIO`: tap-to-talk. Requested only after the child taps Talk
  and agrees to "Can Buddy use the microphone?"; never at launch or in the
  background (widget tests check that launch and normal use make no
  recogniser calls). Denial leaves typing fully working.
- `INTERNET`: only so the phone's speech recogniser can work online **when
  a grown-up allows it** in the Parent Zone. The app itself makes no network
  calls, has no backend, analytics or ads.
- `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (added automatically by
  AndroidX via `flutter_tts`): private to this app, signature-protected,
  never shown to users, gives no access to user data.
- Each new permission must be listed here with its reason.

## Buddy's voice

- Uses the phone's own text-to-speech engine (e.g. Google or Samsung TTS).
  No paid voice service, API key or app-run server.
- Buddy only speaks the app's own scripted text, which is always also on
  screen. No child input is ever passed to the speech engine.
- Speaking aloud at launch is limited to one short welcome per app session.
  The "Voice off" button silences Buddy immediately.
- The speech engine belongs to the phone's maker. Some engines can use
  network voices if the device owner enables them in system settings; the
  app does not request this. Note this in the privacy policy before release.

## Talking with Buddy

- Answers come only from reviewed, offline content in the app
  (`curated_content.dart`). **There is no AI model, chatbot or network
  service.** Unknown questions get an honest "I don't know that one yet".
- Buddy is honest about what he is: a computer character, not a person,
  without real feelings, and able to make mistakes.
- A safety filter runs before any answer:
  - Personal information (phone numbers, emails, addresses, postcodes,
    passwords, full names, school names) gets "Let's keep that private!"
    and the child's message is **not shown or repeated**.
  - Self-harm, bullying, medical and off-limits topics (weapons, drugs,
    hacking, sexual content) redirect to a trusted grown-up. No
    instructions are given.
  - The filter is a conservative keyword list. It will miss things phrased
    unusually, which is acceptable only because every possible answer is
    pre-written and reviewed. **It is not sufficient for any open-ended
    response engine.**
- Buddy never asks for a name, address, school, password, location or
  contact details (enforced by tests over all content).
- Conversations are **not saved**: they live in memory and disappear when
  the app closes (tested).
- Buddy can suggest an activity, but only from a fixed list of in-app
  screens, and only opens it when the child taps.
- Recognised speech goes through the same safety filter as typed
  questions, and only after the child checks it and taps Ask.

## Voice input

- Explicit tap-to-talk only: one session per tap, 15 seconds max, never
  continuous, never in the background. Cancelled on Cancel, navigation,
  interruptions (calls, app switcher, screen off) and app close (tested).
- The child sees an explanation before Android's permission prompt and can
  say **Not now**. Denial is never re-prompted automatically.
- **Where the voice goes:** recognition is done by the phone's own
  recognition service, not by the app.
  - **Default (online not allowed):** on-device only. The app checks with
    Android that on-device recognition exists and otherwise refuses to
    listen, because the plugin alone would silently fall back to an
    online recogniser.
  - **Online allowed (grown-up setting):** the phone's recognition provider
    (often Google) may receive the audio, under its own privacy terms.
- The app receives text only and stores nothing (no audio, no transcripts).
- The Parent Zone's times-table check is a light gate for young children,
  not a security control.
- Details: [STAGE_B_VOICE_INPUT.md](STAGE_B_VOICE_INPUT.md). **A privacy
  and legal review is required before external testers use voice input.**

These are design principles, not a legal compliance claim. A proper
privacy and legal review is needed before release.

## Parent check

- A multiplication written in words ("What is nineteen times six?"), new
  every attempt; answers are 39 to 261. Three wrong answers in a row pause
  it for 60 seconds (in memory only, so restarting the app clears the
  pause).
- Asked every time the Parent Zone opens, and again if the app is hidden
  while it is open.
- Asks for nothing personal; no passwords or accounts.
- **Limits (shown to parents):** it stops younger children by accident; it
  cannot prove age or identity, and an older child who can multiply may
  pass. Destructive actions add a second step: typing DELETE.

## Still to resolve before external testers

- Privacy and legal review (for example COPPA, GDPR-K / UK Age Appropriate
  Design Code), including online voice recognition and the phone's
  text-to-speech engine. No compliance is claimed in the app.
- A privacy policy and parent-facing notice.
- The permanent application ID.
- Whether a stronger parent check is needed for stores' kids categories.

## No accounts, backend or AI yet

There is no account system, remote server, cloud storage, analytics or AI
service. Adding any of them requires:

1. A written requirement explaining why on-device is not enough.
2. A privacy review covering applicable law (e.g. COPPA in the US, GDPR-K /
   UK Age Appropriate Design Code), app store family policies (Google Play
   Families, Apple Kids category), and the provider's data retention and
   training terms.
3. A parental consent design.
4. An update to this document.

## Future requirements

- **Parent gate** before the Parent Zone, external links, purchases or
  settings (e.g. an adult-level question, not a simple tap).
- **Parental controls:** turn voice input on/off, reset progress, delete
  creations, view what is stored.
- **Content safety:** all narration and responses come from reviewed scripts.
  Any future generated response (`EducationalResponseProvider`) must be
  filtered, age-appropriate, on-topic, and fall back to a safe reply.
- **No external links or social features** reachable by a child without the
  parent gate.
- **Privacy policy** written before any store release.
- **Accessibility:** large touch targets, readable text, every voice feature
  has a visual/tap equivalent.
