import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'buddy_look_scope.dart';
import 'buddy_painter.dart';

export 'buddy_painter.dart' show BuddyMood;

/// Buddy, the Curious Buddy mascot. Waves once when shown and gets excited
/// when tapped.
///
/// Animations are one-shot (never looping) and are skipped entirely when the
/// device's "remove animations" accessibility setting is on.
class Buddy extends StatefulWidget {
  const Buddy({
    super.key,
    this.height = 132,
    this.mood = BuddyMood.happy,
    this.waveOnAppear = true,
  });

  final double height;
  final BuddyMood mood;
  final bool waveOnAppear;

  static const semanticLabel =
      'Buddy, a small teal creature with a yellow backpack';

  @override
  State<Buddy> createState() => _BuddyState();
}

class _BuddyState extends State<Buddy> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..addStatusListener(_onStatus);

  bool _started = false;
  bool _reacting = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.waveOnAppear && !_reduceMotion) _controller.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status.isCompleted && _reacting) setState(() => _reacting = false);
  }

  void _onTap() {
    if (_reduceMotion) {
      // No motion: toggle the excited face instead of animating.
      setState(() => _reacting = !_reacting);
      return;
    }
    setState(() => _reacting = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.height * BuddyPainter.aspectRatio;
    final look = BuddyLookScope.of(context);
    return Semantics(
      label: look.isEmpty
          ? Buddy.semanticLabel
          : '${Buddy.semanticLabel}, wearing '
                '${look.items.map((i) => i.title.toLowerCase()).join(' and ')}',
      image: true,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // Snap to exactly at rest once finished; sin(pi) is not quite 0.
            final t = _controller.isAnimating ? _controller.value : 0.0;
            final lift = (math.sin(math.pi * t) * 1.6).clamp(0.0, 1.0);
            final hop = math.sin(math.pi * t * 2).abs() * widget.height * 0.03;
            return Transform.translate(
              offset: Offset(0, -hop),
              child: CustomPaint(
                size: Size(width, widget.height),
                painter: BuddyPainter(
                  mood: _reacting ? BuddyMood.excited : widget.mood,
                  armLift: lift,
                  armSwing: math.sin(t * math.pi * 6) * lift,
                  look: look,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
