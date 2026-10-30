import 'package:flutter/material.dart';

import '../../../domain/settings/display_settings.dart';
import '../../../domain/voice/buddy_listener.dart';
import '../../../domain/voice/buddy_voice.dart';
import '../../core/themes/app_colors.dart';
import '../parent_zone_view_model.dart';
import 'parent_section.dart';
import 'parent_settings.dart';

/// "What's saved on this phone": every record Curious Buddy keeps, read
/// live from storage, plus what is only in memory and what never leaves.
class DataOverviewSection extends StatelessWidget {
  const DataOverviewSection({super.key, required this.vm});

  final ParentZoneViewModel vm;

  static const title = "What's saved on this phone";
  static const intro =
      'This is everything Curious Buddy keeps after it closes. It is read '
      'from the phone just now.';
  static const loadError =
      "Curious Buddy couldn't read its saved data just now. Please close "
      'the Parent Zone and open it again.';
  static const deleted = 'Deleted by "Delete all progress"';
  static const kept =
      'Kept by "Delete all progress", unless you also restore default '
      'settings';

  static const missionsTitle = 'Mystery Missions results';
  static const missionsWhy =
      'Shows solved cases, badges and points, and keeps the best score when '
      'a case is replayed.';
  static const storiesTitle = 'Living Stories endings';
  static const storiesWhy =
      'Shows which stories are finished and which endings have been found.';
  static const quizTitle = 'Quiz Time results';
  static const quizWhy =
      'Shows stars and best scores, and which quiz levels are open.';
  static const gamesTitle = 'Game Zone results';
  static const gamesWhy =
      'Shows stars, and which game levels are open. Quick Create drawings are '
      'saved as creations.';
  static const outfitTitle = "Buddy's outfit";
  static const outfitWhy =
      'What your child chose for Buddy to wear. What they have earned is '
      'worked out from their progress, not saved separately.';
  static const creationsTitle = 'Creative Island creations';
  static const creationsWhy =
      'Your child\'s drawings and creatures, shown on their shelf. Creatures '
      'only have names from a fixed list; nothing is typed in.';
  static const creationsBackupTitle = 'Backup of unreadable creations';
  static const placesTitle = 'Place in unfinished stories';
  static const placesWhy =
      'Lets your child continue a story from the page they stopped on.';
  static const backupTitle = 'Backup of unreadable progress';
  static const backupWhy =
      'Only made if saved progress was ever damaged, so it is not silently '
      'lost.';
  static const settingsTitle = 'Settings';
  static const settingsWhy = 'Remembers the choices on this page.';

  static const memoryTitle = 'Only kept while the app is open (never saved)';
  static const memoryItems = [
    "Questions your child asks Buddy and Buddy's answers.",
    'Words heard while your child talks to Buddy. They are put in the '
        'text box to check, and never saved.',
    'A mission in progress (leaving restarts the case).',
    'This parent check and its pause after wrong answers.',
  ];

  static const neverTitle = 'Never collected';
  static const never =
      'Names, ages, birthdays, photos, contacts, location, voice recordings '
      'or accounts. Curious Buddy has no sign-in.';

  static const whereTitle = 'Where it is kept';
  static const where =
      "In Curious Buddy's private app storage on this phone, which other "
      'apps cannot normally read. Curious Buddy does not add its own encryption. '
      'Android cloud backup is turned off for this app, so it is not copied '
      'to a Google account. Curious Buddy also asks Android to leave it out '
      'of phone-to-phone transfers, but some phone makers may still copy it. '
      "Uninstalling the app, or the phone's Settings > Apps > Curious Buddy > "
      'Storage > Clear data, also deletes it.';

  static const sentTitle = 'Does anything leave the phone?';
  static const sent =
      'Curious Buddy has no servers, analytics, ads or accounts, and sends '
      'none of the saved data above anywhere. Buddy\'s answers come from '
      'reviewed content inside the app.';
  static const sentServices = [
    "Buddy's voice uses the phone's own text-to-speech engine (from "
        'Samsung or Google), which follows its maker\'s terms.',
    'With online voice recognition off, listening only works if the phone '
        'can do it on the device. With it on, the phone\'s recognition '
        'service (often Google) may send your child\'s voice to its servers.',
  ];

  static String missionsValue(ActivitySummary s) =>
      '${_count(s.missionsSolved, 'case')} solved, '
      '${s.missionPoints} points';
  static String storiesValue(ActivitySummary s) =>
      '${_count(s.storiesFinished, 'story', 'stories')} finished, '
      '${_count(s.endingsFound, 'ending')} found';
  static String quizValue(ActivitySummary s) =>
      '${_count(s.quizLevelsDone, 'level')} played, '
      '${_count(s.quizBestCorrect, 'right answer')} at best';
  static String gamesValue(ActivitySummary s) =>
      '${_count(s.gameLevelsPlayed, 'level')} played, '
      '${_count(s.gameStars, 'star')}';
  static String outfitValue(ActivitySummary s) =>
      '${_count(s.outfitItems, 'item')} worn';
  static String creationsValue(ActivitySummary s) =>
      '${_count(s.drawings, 'drawing')}, ${_count(s.creatures, 'creature')}';
  static String placesValue(ActivitySummary s) =>
      '${_count(s.storiesInProgress, 'story', 'stories')} in progress';
  static String backupValue(ActivitySummary s) =>
      s.hasBackup ? 'One copy kept' : 'None';
  static String settingsValue(
    BuddyVoice voice,
    BuddyListener listener,
    DisplaySettings display,
  ) => [
    voice.isMuted ? 'Voice off' : 'Voice on',
    '${VoiceSettingsSection.speedLabel(voice.speed).toLowerCase()} speed',
    voice.autoRead ? 'reads automatically' : 'reads when asked',
    voice.soundsOn ? 'sound effects on' : 'sound effects off',
    listener.allowOnline ? 'online recognition allowed' : 'on-device only',
    display.reduceMotion ? 'calmer animations' : 'normal animations',
  ].join(', ');

  static String _count(int n, String one, [String? many]) =>
      '$n ${n == 1 ? one : (many ?? '${one}s')}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = vm.summary;
    return ListenableBuilder(
      listenable: Listenable.merge([vm.voice, vm.listener, vm.display]),
      builder: (context, _) => ParentSection(
        icon: Icons.inventory_2_outlined,
        title: title,
        children: [
          const ParentNote(intro),
          if (vm.status == SummaryStatus.loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Reading saved data',
                ),
              ),
            )
          else if (summary == null)
            const ParentNote(loadError, bold: true)
          else ...[
            _Record(
              title: missionsTitle,
              value: missionsValue(summary),
              why: missionsWhy,
              reset: deleted,
            ),
            _Record(
              title: storiesTitle,
              value: storiesValue(summary),
              why: storiesWhy,
              reset: deleted,
            ),
            _Record(
              title: quizTitle,
              value: quizValue(summary),
              why: quizWhy,
              reset: deleted,
            ),
            _Record(
              title: placesTitle,
              value: placesValue(summary),
              why: placesWhy,
              reset: deleted,
            ),
            _Record(
              title: gamesTitle,
              value: gamesValue(summary),
              why: gamesWhy,
              reset: deleted,
            ),
            _Record(
              title: outfitTitle,
              value: outfitValue(summary),
              why: outfitWhy,
              reset: deleted,
            ),
            _Record(
              title: creationsTitle,
              value: creationsValue(summary),
              why: creationsWhy,
              reset: deleted,
            ),
            _Record(
              title: backupTitle,
              value: backupValue(summary),
              why: backupWhy,
              reset: deleted,
            ),
            if (summary.hasCreationsBackup)
              const _Record(
                title: creationsBackupTitle,
                value: 'One copy kept',
                why: backupWhy,
                reset: deleted,
              ),
          ],
          _Record(
            title: settingsTitle,
            value: settingsValue(vm.voice, vm.listener, vm.display),
            why: settingsWhy,
            reset: kept,
          ),
          const SizedBox(height: 8),
          Text(memoryTitle, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          const ParentBullets(memoryItems),
          Text(neverTitle, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          const ParentNote(never),
          Text(whereTitle, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          const ParentNote(where),
          Text(sentTitle, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          const ParentNote(sent),
          const ParentBullets(sentServices),
        ],
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({
    required this.title,
    required this.value,
    required this.why,
    required this.reset,
  });

  final String title;
  final String value;
  final String why;
  final String reset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(why, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            reset,
            style: textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
