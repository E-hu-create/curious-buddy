import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/voice/buddy_listener.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';

/// Grown-ups only. A simple parent check, then settings.
///
/// The check is asked again every time the screen opens. It is a light
/// gate for younger children, not a security control. More settings arrive
/// with the full Parent Zone (see docs/ROADMAP.md).
class ParentZoneScreen extends StatefulWidget {
  const ParentZoneScreen({super.key, required this.listener, this.random});

  final BuddyListener listener;

  /// Injected in tests for a predictable question.
  final Random? random;

  static const title = 'Parent Zone';
  static const gateIntro = 'Grown-ups only. Please answer to continue.';
  static const checkLabel = 'Continue';
  static const wrongAnswer = "That's not right. Please ask a grown-up.";
  static const onlineTitle = 'Allow online voice recognition';
  static const onlineExplanation =
      'Off (recommended): Buddy only listens if this phone can turn speech '
      'into text on the device. Your child\'s voice does not leave the phone.\n\n'
      "On: if the phone can't do that, its speech recognition service "
      '(often Google) may send the audio to its servers to turn it into text, '
      "under that provider's privacy terms.\n\n"
      'Either way, Curious Buddy only listens after your child taps Talk, '
      'and never saves or uploads recordings itself. This setting goes back '
      'to Off when the app restarts.';
  static const onDeviceAvailable =
      'This phone can recognise speech on the device.';
  static const onDeviceUnavailable =
      "This phone can't recognise speech on the device, so talking to Buddy "
      'only works if online recognition is allowed.';

  @override
  State<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends State<ParentZoneScreen> {
  late final Random _random = widget.random ?? Random();
  final _answer = TextEditingController();
  late int _a;
  late int _b;
  bool _unlocked = false;
  bool _wrong = false;
  bool? _onDevice;

  @override
  void initState() {
    super.initState();
    _newQuestion();
    unawaited(_checkOnDevice());
  }

  void _newQuestion() {
    _a = 6 + _random.nextInt(4);
    _b = 6 + _random.nextInt(4);
  }

  Future<void> _checkOnDevice() async {
    final onDevice = await widget.listener.supportsOnDevice();
    if (mounted) setState(() => _onDevice = onDevice);
  }

  void _check() {
    if (int.tryParse(_answer.text.trim()) == _a * _b) {
      setState(() => _unlocked = true);
    } else {
      setState(() {
        _wrong = true;
        _answer.clear();
        _newQuestion();
      });
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
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
                  if (_unlocked) _settings(textTheme) else _gate(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gate(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppShapes.sticker(AppColors.white, depth: 4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(ParentZoneScreen.gateIntro, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Text('What is $_a × $_b?', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _answer,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _check(),
            decoration: const InputDecoration(
              labelText: 'Answer',
              border: OutlineInputBorder(),
            ),
          ),
          if (_wrong) ...[
            const SizedBox(height: 8),
            Text(ParentZoneScreen.wrongAnswer, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _check,
            child: const Text(ParentZoneScreen.checkLabel),
          ),
        ],
      ),
    );
  }

  Widget _settings(TextTheme textTheme) {
    final onDevice = _onDevice;
    return ListenableBuilder(
      listenable: widget.listener,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(8),
        decoration: AppShapes.sticker(AppColors.white, depth: 4),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            SwitchListTile(
              title: Text(
                ParentZoneScreen.onlineTitle,
                style: textTheme.titleMedium,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  ParentZoneScreen.onlineExplanation,
                  style: textTheme.bodyMedium,
                ),
              ),
              value: widget.listener.allowOnline,
              onChanged: (allow) =>
                  unawaited(widget.listener.setAllowOnline(allow)),
            ),
            if (onDevice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  onDevice
                      ? ParentZoneScreen.onDeviceAvailable
                      : ParentZoneScreen.onDeviceUnavailable,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
