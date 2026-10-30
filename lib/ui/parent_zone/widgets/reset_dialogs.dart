import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';

import '../parent_zone_view_model.dart';
import 'data_overview.dart';
import 'parent_section.dart';

/// Step 1 of 2: what will be deleted and what is kept. Returns whether
/// settings should be restored too, or null if cancelled.
class ResetExplainDialog extends StatefulWidget {
  const ResetExplainDialog({super.key, required this.summary});

  final ActivitySummary? summary;

  static const title = 'Delete all progress?';
  static const deletesHeading = 'This deletes from this phone:';
  static const keepsHeading = 'This keeps:';
  static const keeps = [
    'All missions, stories, quizzes and activities, ready to play again '
        'from the start.',
    'Your settings, unless you tick the box below.',
  ];
  static const settingsToo = 'Also restore default settings';
  static const settingsDefaults =
      'Voice on, normal speed, reads automatically, sound effects on, '
      'on-device listening only, normal animations.';
  static const cannotUndo = 'This cannot be undone.';
  static const cancelLabel = 'Cancel';
  static const continueLabel = 'Continue';

  static List<String> deletes(ActivitySummary? s) => [
    s == null
        ? 'Mystery Missions results: solved cases, badges and points.'
        : 'Mystery Missions results: ${DataOverviewSection.missionsValue(s)}.',
    s == null
        ? 'Living Stories endings found.'
        : 'Living Stories: ${DataOverviewSection.storiesValue(s)}.',
    s == null
        ? 'Quiz Time stars and best scores.'
        : 'Quiz Time results: ${DataOverviewSection.quizValue(s)}.',
    s == null
        ? 'The place in any unfinished story.'
        : 'Place in unfinished stories: '
              '${DataOverviewSection.placesValue(s)}.',
    s == null
        ? 'Game Zone stars.'
        : 'Game Zone results: ${DataOverviewSection.gamesValue(s)}.',
    s == null
        ? "Buddy's outfit."
        : "Buddy's outfit: ${DataOverviewSection.outfitValue(s)}.",
    s == null
        ? 'Creative Island drawings and creatures.'
        : 'Creative Island creations: '
              '${DataOverviewSection.creationsValue(s)}.',
    'Any backup of unreadable progress or creations.',
  ];

  @override
  State<ResetExplainDialog> createState() => _ResetExplainDialogState();
}

class _ResetExplainDialogState extends State<ResetExplainDialog> {
  bool _settingsToo = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text(ResetExplainDialog.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(
              ResetExplainDialog.deletesHeading,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            ParentBullets(ResetExplainDialog.deletes(widget.summary)),
            Text(ResetExplainDialog.keepsHeading, style: textTheme.titleSmall),
            const SizedBox(height: 6),
            const ParentBullets(ResetExplainDialog.keeps),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(ResetExplainDialog.settingsToo),
              subtitle: const Text(ResetExplainDialog.settingsDefaults),
              value: _settingsToo,
              onChanged: (v) => setState(() => _settingsToo = v ?? false),
            ),
            const SizedBox(height: 4),
            const ParentNote(ResetExplainDialog.cannotUndo, bold: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(ResetExplainDialog.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_settingsToo),
          child: const Text(ResetExplainDialog.continueLabel),
        ),
      ],
    );
  }
}

/// Step 2 of 2: type DELETE to confirm. Returns true only when confirmed.
class ResetConfirmDialog extends StatefulWidget {
  const ResetConfirmDialog({super.key, required this.settingsToo});

  final bool settingsToo;

  static const title = 'Are you sure?';
  static const word = 'DELETE';
  static const instruction = 'To confirm, type $word below.';
  static const fieldLabel = 'Type $word';
  static const progressOnly =
      "Your child's progress will be deleted. Settings stay as they are.";
  static const withSettings =
      "Your child's progress will be deleted and every setting goes back to "
      'its default.';
  static const cancelLabel = 'Cancel';
  static const deleteLabel = 'Delete progress';

  @override
  State<ResetConfirmDialog> createState() => _ResetConfirmDialogState();
}

class _ResetConfirmDialogState extends State<ResetConfirmDialog> {
  final _typed = TextEditingController();

  bool get _confirmed =>
      _typed.text.trim().toUpperCase() == ResetConfirmDialog.word;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ResetConfirmDialog.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            ParentNote(
              widget.settingsToo
                  ? ResetConfirmDialog.withSettings
                  : ResetConfirmDialog.progressOnly,
            ),
            const ParentNote(ResetConfirmDialog.instruction),
            TextField(
              controller: _typed,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: ResetConfirmDialog.fieldLabel,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(ResetConfirmDialog.cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB3261E),
            foregroundColor: Colors.white,
          ),
          onPressed: _confirmed ? () => Navigator.of(context).pop(true) : null,
          child: const Text(ResetConfirmDialog.deleteLabel),
        ),
      ],
    );
  }
}
