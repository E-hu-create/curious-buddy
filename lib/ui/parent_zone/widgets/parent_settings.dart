import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/services/voice/text_to_speech_service.dart';
import '../../../domain/settings/display_settings.dart';
import '../../../domain/voice/buddy_listener.dart';
import '../../../domain/voice/buddy_voice.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/voice_speed_slider.dart';
import 'parent_section.dart';

/// Buddy's voice: on/off, speed, and automatic reading.
class VoiceSettingsSection extends StatelessWidget {
  const VoiceSettingsSection({super.key, required this.voice});

  final BuddyVoice voice;

  static const title = "Buddy's voice";
  static const talksTitle = 'Buddy talks';
  static const talksHelp =
      'When off, everything is still shown as text. Your child can also '
      'switch this on the Home screen.';
  static const soundsTitle = 'Sound effects';
  static const soundsHelp =
      'Short chimes for right answers and big moments. They never play over '
      "Buddy's voice, and follow the phone's media volume.";
  static const speedTitle = 'Speaking speed';
  static const autoReadTitle = 'Read aloud automatically';
  static const autoReadHelp =
      'On: Buddy reads new pages, questions and answers as they appear.\n'
      'Off: Buddy stays quiet until your child taps "Hear again" or a speaker '
      'button. Useful for children who prefer to read by themselves.';
  static const noEngine =
      'This phone has no text-to-speech voice ready, so Buddy shows text '
      'only. You can add one in the phone\'s Settings (search for '
      '"Text-to-speech").';

  static String speedLabel(SpeechSpeed speed) => VoiceSpeedSlider.label(speed);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => ParentSection(
        icon: Icons.record_voice_over_rounded,
        title: title,
        children: [
          if (voice.status == VoiceStatus.unavailable)
            const ParentNote(noEngine, bold: true),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(talksTitle, style: textTheme.titleMedium),
            subtitle: Text(talksHelp, style: textTheme.bodyMedium),
            value: !voice.isMuted,
            onChanged: (on) => unawaited(voice.setMuted(!on)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(soundsTitle, style: textTheme.titleMedium),
            subtitle: Text(soundsHelp, style: textTheme.bodyMedium),
            value: voice.soundsOn,
            onChanged: (on) => unawaited(voice.setSoundsOn(on)),
          ),
          const SizedBox(height: 8),
          Text(speedTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          VoiceSpeedSlider(voice: voice),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(autoReadTitle, style: textTheme.titleMedium),
            subtitle: Text(autoReadHelp, style: textTheme.bodyMedium),
            value: voice.autoRead,
            onChanged: (on) => unawaited(voice.setAutoRead(on)),
          ),
        ],
      ),
    );
  }
}

/// Talking to Buddy: the online-recognition setting.
class ListeningSettingsSection extends StatefulWidget {
  const ListeningSettingsSection({super.key, required this.listener});

  final BuddyListener listener;

  static const title = 'Listening';
  static const onlineTitle = 'Allow online voice recognition';
  static const onlineExplanation =
      'Off (recommended): Buddy only listens if this phone can turn speech '
      'into text on the device. Your child\'s voice does not leave the phone.\n\n'
      "On: if the phone can't do that, its speech recognition service "
      '(often Google) may send the audio to its servers to turn it into text, '
      "under that provider's privacy terms. That is online processing, not "
      'on-device.\n\n'
      'Either way, Curious Buddy only listens after your child taps Talk, '
      'and never saves or uploads recordings itself. The microphone '
      'permission can be removed at any time in the phone\'s Settings > Apps '
      '> Curious Buddy > Permissions.';
  static const onDeviceAvailable =
      'This phone can recognise speech on the device.';
  static const onDeviceUnavailable =
      "This phone can't recognise speech on the device, so talking to Buddy "
      'only works if online recognition is allowed.';

  @override
  State<ListeningSettingsSection> createState() =>
      _ListeningSettingsSectionState();
}

class _ListeningSettingsSectionState extends State<ListeningSettingsSection> {
  bool? _onDevice;

  @override
  void initState() {
    super.initState();
    unawaited(_checkOnDevice());
  }

  Future<void> _checkOnDevice() async {
    final onDevice = await widget.listener.supportsOnDevice();
    if (mounted) setState(() => _onDevice = onDevice);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onDevice = _onDevice;
    return ListenableBuilder(
      listenable: widget.listener,
      builder: (context, _) => ParentSection(
        icon: Icons.mic_none_rounded,
        title: ListeningSettingsSection.title,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ListeningSettingsSection.onlineTitle,
              style: textTheme.titleMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ListeningSettingsSection.onlineExplanation,
                style: textTheme.bodyMedium,
              ),
            ),
            value: widget.listener.allowOnline,
            onChanged: (allow) =>
                unawaited(widget.listener.setAllowOnline(allow)),
          ),
          if (onDevice != null) ...[
            const SizedBox(height: 8),
            Text(
              onDevice
                  ? ListeningSettingsSection.onDeviceAvailable
                  : ListeningSettingsSection.onDeviceUnavailable,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Display and accessibility.
class DisplaySettingsSection extends StatelessWidget {
  const DisplaySettingsSection({super.key, required this.display});

  final DisplaySettings display;

  static const title = 'Display';
  static const motionTitle = 'Calmer animations';
  static const motionHelp =
      'Buddy stays still instead of waving and bouncing. This is also on '
      'whenever the phone\'s own "Remove animations" setting is on.';
  static const textSize =
      "Text size follows the phone's font size (Settings > Display > Font "
      'size and style). Curious Buddy is tested at up to twice the normal '
      'size.';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: display,
      builder: (context, _) => ParentSection(
        icon: Icons.accessibility_new_rounded,
        title: title,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(motionTitle, style: textTheme.titleMedium),
            subtitle: Text(motionHelp, style: textTheme.bodyMedium),
            value: display.reduceMotion,
            onChanged: (on) => unawaited(display.setReduceMotion(on)),
          ),
          const SizedBox(height: 4),
          const ParentNote(textSize),
        ],
      ),
    );
  }
}
