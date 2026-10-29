import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// How a child asks Buddy something: a talk button, a text box, and
/// suggested questions.
///
/// Talking is not available yet (Stage B). The talk button is an honest
/// placeholder: it explains that, points to typing, and never touches the
/// microphone.
class AskBuddyPanel extends StatefulWidget {
  const AskBuddyPanel({
    super.key,
    required this.enabled,
    required this.suggestions,
    required this.onAsk,
  });

  /// False while Buddy is preparing an answer.
  final bool enabled;
  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  static const talkLabel = 'Talk to Buddy';
  static const comingSoonTag = 'Coming soon';
  static const fieldHint = 'Type a question';
  static const askLabel = 'Ask';
  static const talkSoonTitle = 'Talking is coming soon!';
  static const talkSoonMessage =
      "Soon you'll be able to ask Buddy out loud. "
      "Before Buddy can use the microphone, you'll be asked first. "
      'For now, type your question or tap one of the ideas.';
  static const typeInsteadLabel = 'Type instead';
  static const maxLength = 200;

  @override
  State<AskBuddyPanel> createState() => _AskBuddyPanelState();
}

class _AskBuddyPanelState extends State<AskBuddyPanel> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSend => widget.enabled && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    final question = _controller.text;
    _controller.clear();
    _focus.unfocus();
    widget.onAsk(question);
  }

  Future<void> _explainTalking() async {
    final typeInstead = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AskBuddyPanel.talkSoonTitle),
        content: const Text(AskBuddyPanel.talkSoonMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AskBuddyPanel.typeInsteadLabel),
          ),
        ],
      ),
    );
    if (typeInstead == true && mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final field = TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: widget.enabled,
      maxLength: AskBuddyPanel.maxLength,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: (_) => _send(),
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: AskBuddyPanel.fieldHint,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.inkSoft,
          fontWeight: FontWeight.w500,
        ),
        counterText: '',
        filled: true,
        fillColor: AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _border(),
        enabledBorder: _border(),
        disabledBorder: _border(),
        focusedBorder: _border(AppColors.brandBlueDeep),
      ),
    );
    final ask = FilledButton(
      onPressed: _canSend ? _send : null,
      child: const Text(AskBuddyPanel.askLabel),
    );
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= 1.3 ||
        MediaQuery.sizeOf(context).width < 340;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShapes.sticker(AppColors.white, depth: 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _TalkButton(onPressed: _explainTalking),
          const SizedBox(height: 14),
          // Side by side normally; stacked with large text or on narrow
          // screens so the box keeps room to show what is typed.
          if (stacked) ...[
            field,
            const SizedBox(height: 8),
            ask,
          ] else
            Row(
              children: [
                Expanded(child: field),
                const SizedBox(width: 8),
                ask,
              ],
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in widget.suggestions)
                SuggestionButton(
                  label: suggestion,
                  onPressed: widget.enabled
                      ? () => widget.onAsk(suggestion)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border([Color color = AppColors.ink]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: AppShapes.outlineWidth),
      );
}

class _TalkButton extends StatelessWidget {
  const _TalkButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(72)),
      // Wraps so the tag drops below the label on narrow screens or with
      // large text instead of overflowing.
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: [
          const Row(
            mainAxisSize: .min,
            children: [
              Icon(Icons.mic_rounded, size: 30),
              SizedBox(width: 10),
              Flexible(child: Text(AskBuddyPanel.talkLabel)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sun,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Text(
              AskBuddyPanel.comingSoonTag,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A suggested question. Unlike a chip, its text wraps, so long ideas stay
/// readable with large system text.
class SuggestionButton extends StatelessWidget {
  const SuggestionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: AppColors.sunTint,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label, textAlign: TextAlign.start),
    );
  }
}
