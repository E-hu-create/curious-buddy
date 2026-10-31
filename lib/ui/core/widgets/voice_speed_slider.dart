import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/services/voice/text_to_speech_service.dart';
import '../../../domain/voice/buddy_voice.dart';
import '../themes/app_colors.dart';

/// Slides Buddy's voice slower or faster. Children use it from Home and
/// grown-ups from the Parent Zone; the choice is saved. Letting go plays a
/// short line, so the new speed can be heard.
class VoiceSpeedSlider extends StatelessWidget {
  const VoiceSpeedSlider({super.key, required this.voice});

  final BuddyVoice voice;

  static const slowLabel = 'Slow';
  static const fastLabel = 'Fast';
  static const semanticLabel = 'Voice speed';
  static const sample = 'This is how I sound now.';

  static String label(SpeechSpeed speed) => switch (speed) {
    SpeechSpeed.slowest => 'Very slow',
    SpeechSpeed.slower => 'Slower',
    SpeechSpeed.normal => 'Normal',
    SpeechSpeed.faster => 'Faster',
    SpeechSpeed.fastest => 'Very fast',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Slider(
            value: voice.speed.index.toDouble(),
            max: SpeechSpeed.values.length - 1,
            divisions: SpeechSpeed.values.length - 1,
            label: label(voice.speed),
            semanticFormatterCallback: (value) =>
                '$semanticLabel: ${label(SpeechSpeed.values[value.round()])}',
            onChanged: (value) =>
                unawaited(voice.setSpeed(SpeechSpeed.values[value.round()])),
            onChangeEnd: (_) => unawaited(voice.say(sample, requested: true)),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_walk_rounded,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 4),
                  Text(slowLabel, style: textTheme.bodyMedium),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fastLabel, style: textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  const Icon(Icons.rocket_launch_rounded, color: AppColors.ink),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The child's way to the slider, from Home.
Future<void> showVoiceSpeedSheet(BuildContext context, BuddyVoice voice) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                VoiceSpeedSlider.semanticLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Slide to make Buddy talk slower or faster.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              VoiceSpeedSlider(voice: voice),
            ],
          ),
        ),
      ),
    );
