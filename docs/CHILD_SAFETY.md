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

| Data | Why | Where |
| --- | --- | --- |
| IDs of completed missions and stories | Show progress | `LearnerProgress` via `ProgressRepository` |
| *Future:* settings (e.g. voice on/off) | Parent preferences | Local storage |
| *Future:* Creative Island creations | Child's own work | Local storage, deletable from Parent Zone |

Currently held **in memory only**; nothing is written to disk yet.

## Data we do not collect

- Names, birthdays, ages, photos, contacts, email or phone numbers.
- Precise or approximate location. No location permission is requested.
- Advertising IDs, analytics, tracking or fingerprinting.
- Voice recordings. Speech recognition returns text only. Audio is never
  saved, logged or uploaded by the app.
- Free-text typed by children, beyond what a feature needs at that moment.

## Permissions

- The main Android manifest requests **no permissions**. Debug and profile
  builds add `INTERNET` for Flutter tooling (hot reload) only. Check that
  release builds still have no `INTERNET` permission until a feature needs it.
- Microphone: requested only when the child or parent explicitly taps
  push-to-talk, never at launch (checked by a widget test). Denial must leave
  a fully working tap alternative.
- Each new permission must be listed here with its reason.

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
