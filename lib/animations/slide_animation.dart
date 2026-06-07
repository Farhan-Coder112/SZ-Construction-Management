// lib/animations/slide_animation.dart
// SlideAnimation widget that slides a child in from a given direction,
// combined with a fade-in effect.

import 'package:flutter/material.dart';

/// The direction from which the slide animation enters.
enum SlideDirection {
  /// Slides in from the left side.
  left,

  /// Slides in from the right side.
  right,

  /// Slides in from the top.
  top,

  /// Slides in from the bottom.
  bottom,
}

/// A widget that animates its [child] into view by sliding from the given
/// [direction], accompanied by a [FadeTransition].
///
/// Usage:
/// ```dart
/// SlideAnimation(
///   direction: SlideDirection.left,
///   delay: Duration(milliseconds: 300),
///   child: MyCard(),
/// )
/// ```
class SlideAnimation extends StatefulWidget {
  /// The widget to animate into view.
  final Widget child;

  /// The direction from which the child slides in.
  final SlideDirection direction;

  /// Delay before the animation begins.
  final Duration delay;

  /// Total duration of the slide + fade animation.
  final Duration duration;

  const SlideAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: _beginOffsetForDirection(widget.direction),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _startAnimation();
  }

  /// Returns the starting [Offset] based on the slide [direction].
  /// Uses a fractional offset — e.g. (–1, 0) means one full widget-width
  /// to the left of the natural position.
  Offset _beginOffsetForDirection(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-0.4, 0.0);
      case SlideDirection.right:
        return const Offset(0.4, 0.0);
      case SlideDirection.top:
        return const Offset(0.0, -0.4);
      case SlideDirection.bottom:
        return const Offset(0.0, 0.4);
    }
  }

  /// Waits for [widget.delay] then triggers the animation forward.
  Future<void> _startAnimation() async {
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      await Future.delayed(widget.delay);
      if (mounted) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
