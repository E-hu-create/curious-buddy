import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/parent/parent_gate.dart';
import '../../core/themes/app_colors.dart';
import 'parent_section.dart';

/// The grown-up check. Calls [onPassed] when answered correctly.
class ParentGateView extends StatefulWidget {
  const ParentGateView({super.key, required this.gate, required this.onPassed});

  final ParentGate gate;
  final VoidCallback onPassed;

  static const heading = 'For grown-ups';
  static const purpose =
      'Here you can change how Buddy talks and listens, see exactly what '
      'Curious Buddy saves on this phone, and delete your child\'s progress.';
  static const instruction = 'Type the answer in numbers to continue.';
  static const answerLabel = 'Answer';
  static const checkLabel = 'Continue';
  static const wrongAnswer = "That's not right. Here is a new question.";
  static const aboutTitle = 'About this check';
  static const about =
      'It stops younger children from changing settings or deleting progress '
      'by accident. It cannot prove your age or who you are, and an older '
      'child who can multiply may get through. It is asked every time the '
      'Parent Zone opens. Curious Buddy never asks for your name, email, '
      'phone number or a password.';

  static String waitMessage(int seconds) =>
      'Too many wrong answers. Please wait $seconds seconds and try again.';
  static String attemptsLeft(int left) =>
      '$left ${left == 1 ? 'try' : 'tries'} left before a short pause.';

  @override
  State<ParentGateView> createState() => _ParentGateViewState();
}

class _ParentGateViewState extends State<ParentGateView> {
  final _answer = TextEditingController();
  bool _wrong = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    if (widget.gate.isLocked) _startTicking();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _answer.dispose();
    super.dispose();
  }

  /// Refresh the countdown each second while paused.
  void _startTicking() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (!widget.gate.isLocked) timer.cancel();
    });
  }

  void _check() {
    if (widget.gate.check(_answer.text)) {
      widget.onPassed();
      return;
    }
    setState(() {
      _wrong = true;
      _answer.clear();
    });
    if (widget.gate.isLocked) _startTicking();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gate = widget.gate;
    final wait = gate.waitRemaining;
    final locked = wait != null;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ParentSection(
          icon: Icons.lock_rounded,
          title: ParentGateView.heading,
          children: [
            Text(ParentGateView.purpose, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (locked)
              Text(
                ParentGateView.waitMessage((wait.inMilliseconds / 1000).ceil()),
                style: textTheme.titleMedium,
              )
            else ...[
              Text(gate.question, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(ParentGateView.instruction, style: textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _answer,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _check(),
                decoration: const InputDecoration(
                  labelText: ParentGateView.answerLabel,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_wrong) ...[
                const SizedBox(height: 8),
                Text(
                  '${ParentGateView.wrongAnswer} '
                  '${ParentGateView.attemptsLeft(gate.attemptsLeft)}',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _check,
                child: const Text(ParentGateView.checkLabel),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const ParentSection(
          icon: Icons.info_outline_rounded,
          title: ParentGateView.aboutTitle,
          color: AppColors.sunTint,
          children: [ParentNote(ParentGateView.about)],
        ),
      ],
    );
  }
}
