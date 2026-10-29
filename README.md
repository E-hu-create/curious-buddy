# Curious Buddy

A Flutter learning app for children aged 8–14. **Current state: voice
companion Stage A.** Home is built around Buddy: children type a question or
tap an idea, Buddy answers from reviewed offline content and reads the answer
aloud with the phone's built-in text-to-speech engine. Activities are
"coming soon" placeholders. There is no speech recognition, microphone use,
AI service or network functionality.

## Requirements

| Tool | Version verified |
| --- | --- |
| Flutter | 3.41.8 (stable) |
| Dart | 3.11.5 |
| Android SDK | platform 36, build-tools 36.1.0 |
| JDK used by Gradle | Android Studio bundled JBR 21 |
| Gradle / AGP / Kotlin | 8.14 / 8.11.1 / 2.2.20 |

Run `flutter doctor -v` to confirm your environment.

> **Java note:** the `java` on this machine's PATH is JDK 26, which Gradle 8.14
> does not support. Always build through `flutter` (it uses Android Studio's
> JDK 21). If you must run `android\gradlew` directly, first set
> `JAVA_HOME=C:\Program Files\Android\Android Studio\jbr`.

> **Memory note:** the Gradle heap is set to 3 GB (`org.gradle.jvmargs` in
> `android/gradle.properties`, down from the template's 8 GB) because the
> development machine has 6.4 GB RAM. Raise it only if a build fails with
> `OutOfMemoryError`.

## Setup

```powershell
flutter pub get
```

## Run

```powershell
flutter devices                 # list connected phones/emulators
flutter run -d <device-id>      # e.g. flutter run -d R5CR11YDNGH
```

## Quality checks

Run everything (dependencies, format, analyze, test, Android build):

```powershell
powershell -ExecutionPolicy Bypass -File tool\verify.ps1
powershell -ExecutionPolicy Bypass -File tool\verify.ps1 -SkipBuild   # faster
```

Or individually:

```powershell
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug       # output: build\app\outputs\flutter-apk\app-debug.apk
```

See [docs/TESTING.md](docs/TESTING.md) for conventions and the real-device checklist.

## Restoring a previous working version

The project is under Git. The tag `baseline-template` marks the untouched
`flutter create` project that was verified building.

```powershell
git log --oneline                       # find the commit you want
git switch -c recovery <commit-or-tag>  # inspect it on a new branch (safe)
git restore --source <commit> -- path\to\file   # restore one file
```

Avoid `git reset --hard` and `git clean`: they discard uncommitted work.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Dependencies](docs/DEPENDENCIES.md)
- [Testing](docs/TESTING.md)
- [Child safety and privacy](docs/CHILD_SAFETY.md)
- [Roadmap](docs/ROADMAP.md)
- [Buddy character model](docs/MASCOT.md)
- [Stage B voice input proposal](docs/STAGE_B_VOICE_INPUT.md)

To regenerate the Android launcher icons after changing Buddy:
`flutter test tool/generate_launcher_icons_test.dart`
