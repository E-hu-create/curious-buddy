import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/repositories/creations_repository.dart';
import '../../domain/creative/creation.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import 'creative_view_models.dart';
import 'widgets/creative_art.dart';
import 'widgets/creative_controls.dart';

/// Creature Maker: pick parts by tapping, then save to the shelf.
class CreatureScreen extends StatefulWidget {
  const CreatureScreen({
    super.key,
    required this.voice,
    required this.creationsRepository,
    this.random,
  });

  final BuddyVoice voice;
  final CreationsRepository creationsRepository;

  /// Injected in tests for a predictable creature.
  final Random? random;

  static const title = 'Creature Maker';
  static const surpriseLabel = 'Surprise me';
  static const newNameLabel = 'New name';
  static const askBuddyLabel = 'Tell me a fact';
  static const saveLabel = 'Save my creature';
  static const makeAnother = 'Make another';
  static const shapeTitle = 'Shape';
  static const colourTitle = 'Colour';
  static const eyesTitle = 'Eyes';
  static const mouthTitle = 'Mouth';
  static const extraTitle = 'Extra';
  static const patternTitle = 'Pattern';

  @override
  State<CreatureScreen> createState() => _CreatureScreenState();
}

class _CreatureScreenState extends State<CreatureScreen> {
  late final CreatureViewModel _vm = CreatureViewModel(
    voice: widget.voice,
    creationsRepository: widget.creationsRepository,
    random: widget.random,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.narrateIntro();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(CreatureScreen.title, style: textTheme.titleMedium),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            final c = _vm.creature;
            final saved = _vm.saveStatus == CreationSaveStatus.saved;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      CreativeBuddyRow(vm: _vm),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppShapes.sticker(AppColors.brandBlueTint),
                        child: Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: CreationPicture(creation: c),
                            ),
                            Semantics(
                              header: true,
                              child: Text(
                                c.name,
                                style: textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!saved)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _vm.surprise,
                              icon: const Icon(Icons.casino_rounded),
                              label: const Text(CreatureScreen.surpriseLabel),
                            ),
                            OutlinedButton.icon(
                              onPressed: _vm.newName,
                              icon: const Icon(Icons.badge_rounded),
                              label: const Text(CreatureScreen.newNameLabel),
                            ),
                            if (_vm.canSpeak)
                              OutlinedButton.icon(
                                onPressed: _vm.askBuddy,
                                icon: const Icon(
                                  Icons.lightbulb_outline_rounded,
                                ),
                                label: const Text(CreatureScreen.askBuddyLabel),
                              ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      if (_vm.saveStatus != CreationSaveStatus.notSaved &&
                          _vm.saveStatus != CreationSaveStatus.saving) ...[
                        CreativeSaveNote(
                          status: _vm.saveStatus,
                          onAnother: _vm.startAgain,
                          anotherLabel: CreatureScreen.makeAnother,
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (!saved) ..._options(c),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _options(Creature c) => [
    _group(
      CreatureScreen.shapeTitle,
      CreatureBody.values,
      c.body,
      CreationDescriptions.bodyNames,
      _vm.setBody,
    ),
    CreativeOptionGroup(
      title: CreatureScreen.colourTitle,
      children: [
        // Navy (index 0) is the outline colour, so creatures skip it.
        for (var i = 1; i < CreativePalette.colors.length; i++)
          CreativeOption(
            label: CreativePalette.names[i],
            swatch: CreativePalette.colors[i],
            selected: c.colorIndex == i,
            onTap: () => _vm.setColor(i),
          ),
      ],
    ),
    const SizedBox(height: 12),
    _group(
      CreatureScreen.eyesTitle,
      CreatureEyes.values,
      c.eyes,
      CreationDescriptions.eyeNames,
      _vm.setEyes,
    ),
    _group(
      CreatureScreen.mouthTitle,
      CreatureMouth.values,
      c.mouth,
      CreationDescriptions.mouthNames,
      _vm.setMouth,
    ),
    _group(
      CreatureScreen.extraTitle,
      CreatureExtra.values,
      c.extra,
      CreationDescriptions.extraNames,
      _vm.setExtra,
    ),
    _group(
      CreatureScreen.patternTitle,
      CreaturePattern.values,
      c.pattern,
      CreationDescriptions.patternNames,
      _vm.setPattern,
    ),
    const SizedBox(height: 4),
    FilledButton.icon(
      onPressed: _vm.canSave ? () => unawaited(_vm.save()) : null,
      icon: const Icon(Icons.save_rounded),
      label: const Text(CreatureScreen.saveLabel),
    ),
  ];

  Widget _group<T>(
    String title,
    List<T> values,
    T selected,
    Map<T, String> names,
    ValueChanged<T> onPick,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: CreativeOptionGroup(
      title: title,
      children: [
        for (final v in values)
          CreativeOption(
            label: names[v]!,
            selected: v == selected,
            onTap: () => onPick(v),
          ),
      ],
    ),
  );
}
