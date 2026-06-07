// lib/animations/stagger_animation.dart
// StaggerAnimation widget that renders a list of children in a Column,
// each wrapped in a FadeAnimation with increasing delays to create a
// staggered entrance effect.

import 'package:flutter/material.dart';
import 'fade_animation.dart';

/// Renders [children] in a [Column], staggering each child's entrance
/// animation by [staggerDelay] milliseconds.
///
/// [baseDelay]    : Initial delay before the first child animates.
/// [staggerDelay] : Additional delay added per child (default 100 ms).
/// [duration]     : Duration of each individual child animation.
/// [mainAxisAlignment], [crossAxisAlignment] : Passed through to [Column].
///
/// Usage:
/// ```dart
/// StaggerAnimation(
///   staggerDelay: Duration(milliseconds: 80),
///   baseDelay: Duration(milliseconds: 200),
///   children: [
///     StatCard(...),
///     ProjectListTile(...),
///     SummaryChart(...),
///   ],
/// )
/// ```
class StaggerAnimation extends StatelessWidget {
  /// The list of widgets to display with staggered entrance animations.
  final List<Widget> children;

  /// The delay increment between consecutive children.
  final Duration staggerDelay;

  /// The starting delay applied to the very first child.
  final Duration baseDelay;

  /// The animation duration applied to each child individually.
  final Duration duration;

  /// Column main-axis alignment.
  final MainAxisAlignment mainAxisAlignment;

  /// Column cross-axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Column main-axis size.
  final MainAxisSize mainAxisSize;

  const StaggerAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.baseDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap each child in FadeAnimation, incrementing the delay per index.
    final animatedChildren = children.asMap().entries.map((entry) {
      final int index = entry.key;
      final Widget child = entry.value;

      final delay = Duration(
        milliseconds:
            baseDelay.inMilliseconds + staggerDelay.inMilliseconds * index,
      );

      return FadeAnimation(
        key: ValueKey(index),
        delay: delay,
        duration: duration,
        child: child,
      );
    }).toList();

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: animatedChildren,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StaggerGrid — same concept but wraps children in a Wrap instead of Column.
// Useful for dashboard stat cards laid out in a responsive grid.
// ─────────────────────────────────────────────────────────────────────────────

/// Renders [children] in a [Wrap], staggering each child's entrance animation.
///
/// Useful for grid-style layouts (e.g. dashboard stat tiles) where items
/// wrap to the next line based on available width.
class StaggerGrid extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration baseDelay;
  final Duration duration;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;

  const StaggerGrid({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.baseDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.spacing = 12.0,
    this.runSpacing = 12.0,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final animatedChildren = children.asMap().entries.map((entry) {
      final int index = entry.key;
      final Widget child = entry.value;

      final delay = Duration(
        milliseconds:
            baseDelay.inMilliseconds + staggerDelay.inMilliseconds * index,
      );

      return FadeAnimation(
        key: ValueKey(index),
        delay: delay,
        duration: duration,
        child: child,
      );
    }).toList();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      children: animatedChildren,
    );
  }
}
