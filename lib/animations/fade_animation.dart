// lib/animations/fade_animation.dart
// FadeAnimation widget that wraps a child with FadeTransition + SlideTransition
// entering from the bottom. Auto-starts after an optional delay.

import 'package:flutter/material.dart';

/// A widget that animates its [child] into view using a combined
/// [FadeTransition] and [SlideTransition] (entering from below).
///
/// Usage:
/// ```dart
/// FadeAnimation(
///   delay: Duration(milliseconds: 200),
///   child: MyWidget(),
/// )
/// ```
class FadeAnimation extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Delay before the animation starts.
  final Duration delay;

  /// Total duration of the animation.
  final Duration duration;

  const FadeAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the AnimationController with the provided duration.
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Fade from transparent to opaque using a curved ease-out.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Slide from slightly below (0.15 of widget height) to natural position.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Start animation after the specified delay.
    _startAnimation();
  }

  /// Waits for [widget.delay] then forwards the animation controller.
  Future<void> _startAnimation() async {
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      await Future.delayed(widget.delay);
      // Guard against calling forward on a disposed controller.
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
