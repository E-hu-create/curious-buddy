import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/parent/parent_gate.dart';
import '../../domain/settings/display_settings.dart';
import '../../domain/voice/buddy_listener.dart';
import '../../domain/voice/buddy_voice.dart';
import '../core/themes/app_colors.dart';
import 'parent_zone_view_model.dart';
import 'widgets/data_overview.dart';
import 'widgets/parent_gate_view.dart';
import 'widgets/parent_section.dart';
import 'widgets/parent_settings.dart';
import 'widgets/reset_dialogs.dart';

/// Grown-ups only: a parent check, then settings, an overview of everything
/// saved on the phone, and a two-step reset.
///
/// The check is asked every time the screen opens, and again if the app is
/// hidden (for example, the phone is handed back to the child).
class ParentZoneScreen extends StatefulWidget {
  const ParentZoneScreen({
    super.key,
    required this.gate,
    required this.voice,
    required this.listener,
    required this.display,
    required this.progressRepository,
  });

  final ParentGate gate;
  final BuddyVoice voice;
  final BuddyListener listener;
  final DisplaySettings display;
  final ProgressRepository progressRepository;

  static const title = 'Parent Zone';
  static const backToBuddy = 'Back to Buddy';
  static const resetTitle = 'Delete progress';
  static const resetHelp =
      "Deletes your child's mission results, story endings and places in "
      'unfinished stories from this phone. Missions and stories stay '
      'playable. You will see exactly what is deleted and confirm twice.';
  static const resetLabel = 'Delete all progress...';
  static const resetting = 'Deleting...';
  static const resetDone =
      'Done. All progress was deleted from this phone. Missions and stories '
      'are ready to start fresh.';
  static const resetDoneSettings = 'Settings were restored to their defaults.';
  static const resetFailed =
      'Something went wrong, so some progress may still be saved. Please try '
      'again.';
  static const legalNote =
      'Curious Buddy is still in testing. Its privacy approach has not yet '
      'been reviewed by a lawyer, so it makes no claim of legal compliance.';

  @override
  State<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends State<ParentZoneScreen> {
  late final ParentZoneViewModel _vm = ParentZoneViewModel(
    progressRepository: widget.progressRepository,
    voice: widget.voice,
    listener: widget.listener,
    display: widget.display,
  );
  late final AppLifecycleListener _lifecycle;
  final _scroll = ScrollController();
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    // Lock again when the app is hidden, so a phone handed back to a child
    // does not stay unlocked.
    _lifecycle = AppLifecycleListener(onHide: _lock);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _vm.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _lock() {
    if (mounted && _unlocked) setState(() => _unlocked = false);
  }

  void _unlock() {
    setState(() => _unlocked = true);
    // Start the settings from the top, not where the check was scrolled.
    if (_scroll.hasClients) _scroll.jumpTo(0);
    unawaited(_vm.load());
  }

  void _backToBuddy() =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  Future<void> _reset() async {
    final settingsToo = await showDialog<bool>(
      context: context,
      builder: (_) => ResetExplainDialog(summary: _vm.summary),
    );
    if (settingsToo == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ResetConfirmDialog(settingsToo: settingsToo),
    );
    if (confirmed != true || !mounted) return;
    await _vm.reset(settingsToo: settingsToo);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      ParentZoneScreen.title,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_unlocked)
                    ListenableBuilder(
                      listenable: _vm,
                      builder: (context, _) => _unlockedBody(),
                    )
                  else
                    ParentGateView(gate: widget.gate, onPassed: _unlock),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _backToBuddy,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text(ParentZoneScreen.backToBuddy),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _unlockedBody() => Column(
    crossAxisAlignment: .stretch,
    children: [
      VoiceSettingsSection(voice: widget.voice),
      const SizedBox(height: 16),
      ListeningSettingsSection(listener: widget.listener),
      const SizedBox(height: 16),
      DisplaySettingsSection(display: widget.display),
      const SizedBox(height: 16),
      DataOverviewSection(vm: _vm),
      const SizedBox(height: 16),
      _resetSection(),
      const SizedBox(height: 16),
      const ParentNote(ParentZoneScreen.legalNote),
    ],
  );

  Widget _resetSection() {
    final status = _vm.resetStatus;
    return ParentSection(
      icon: Icons.delete_outline_rounded,
      title: ParentZoneScreen.resetTitle,
      color: AppColors.coralTint,
      children: [
        const ParentNote(ParentZoneScreen.resetHelp),
        if (status == ResetStatus.done) ...[
          ParentNote(ParentZoneScreen.resetDone, bold: true),
          if (_vm.lastResetIncludedSettings)
            const ParentNote(ParentZoneScreen.resetDoneSettings, bold: true),
        ],
        if (status == ResetStatus.failed)
          const ParentNote(ParentZoneScreen.resetFailed, bold: true),
        const SizedBox(height: 4),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB3261E),
            foregroundColor: Colors.white,
          ),
          onPressed: status == ResetStatus.resetting
              ? null
              : () => unawaited(_reset()),
          icon: const Icon(Icons.delete_forever_rounded),
          label: Text(
            status == ResetStatus.resetting
                ? ParentZoneScreen.resetting
                : ParentZoneScreen.resetLabel,
          ),
        ),
      ],
    );
  }
}
