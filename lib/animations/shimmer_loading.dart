// lib/animations/shimmer_loading.dart
// Shimmer skeleton loading widgets for placeholder UI during data fetching.
// Exports ShimmerBox (single placeholder block) and ShimmerContainer
// (a stacked list of ShimmerBox items for list skeletons).

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerBox
// ─────────────────────────────────────────────────────────────────────────────

/// A single animated shimmer placeholder rectangle.
///
/// Animates a horizontal gradient sweep from left to right to simulate
/// a "loading" skeleton effect.
///
/// [isDark] selects the appropriate base colors for dark or light themes.
class ShimmerBox extends StatefulWidget {
  /// Width of the placeholder box. If null, fills available width.
  final double? width;

  /// Height of the placeholder box.
  final double height;

  /// Corner radius of the box.
  final double borderRadius;

  /// Use dark-mode shimmer colors when true.
  final bool isDark;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius = 8.0,
    this.isDark = false,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(); // Loop indefinitely.

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Choose base shimmer colors based on theme.
    final Color baseColor =
        widget.isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE0E0E0);
    final Color highlightColor =
        widget.isDark ? const Color(0xFF3D3D5C) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              // Shift the gradient position based on animation value.
              begin: Alignment(_animation.value - 1, 0.0),
              end: Alignment(_animation.value + 1, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerContainer
// ─────────────────────────────────────────────────────────────────────────────

/// A pre-built shimmer skeleton for list items. Stacks multiple [ShimmerBox]
/// elements to mimic a list of loading cards.
///
/// Each "item" renders a title line + two subtitle lines separated by spacing,
/// with a circular avatar placeholder on the left.
///
/// [itemCount]  : How many skeleton list items to show.
/// [isDark]     : Pass through to [ShimmerBox] for theme-correct colors.
/// [itemHeight] : Approximate height for the card container of each item.
class ShimmerContainer extends StatelessWidget {
  final int itemCount;
  final bool isDark;
  final double itemHeight;

  const ShimmerContainer({
    super.key,
    this.itemCount = 5,
    this.isDark = false,
    this.itemHeight = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(itemCount, (index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular avatar placeholder.
              ShimmerBox(
                width: 46,
                height: 46,
                borderRadius: 23,
                isDark: isDark,
              ),
              const SizedBox(width: 12),

              // Title + subtitle lines.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line — full width.
                    ShimmerBox(height: 14, borderRadius: 7, isDark: isDark),
                    const SizedBox(height: 8),
                    // First subtitle line — 70 % width.
                    Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: ShimmerBox(
                            height: 11,
                            borderRadius: 5.5,
                            isDark: isDark,
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Second subtitle line — 50 % width.
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ShimmerBox(
                            height: 11,
                            borderRadius: 5.5,
                            isDark: isDark,
                          ),
                        ),
                        const Spacer(flex: 5),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Trailing action placeholder.
              ShimmerBox(
                width: 32,
                height: 32,
                borderRadius: 8,
                isDark: isDark,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerCard  (helper — single full-width card placeholder)
// ─────────────────────────────────────────────────────────────────────────────

/// A full-width shimmer card placeholder useful for dashboard stat tiles
/// or detail screens.
class ShimmerCard extends StatelessWidget {
  final double height;
  final bool isDark;

  const ShimmerCard({
    super.key,
    this.height = 120.0,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ShimmerBox(height: 16, borderRadius: 8, isDark: isDark),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 6,
                child:
                    ShimmerBox(height: 30, borderRadius: 6, isDark: isDark),
              ),
              const Spacer(flex: 4),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 4,
                child:
                    ShimmerBox(height: 12, borderRadius: 6, isDark: isDark),
              ),
              const Spacer(flex: 6),
            ],
          ),
        ],
      ),
    );
  }
}
