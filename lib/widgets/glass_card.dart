import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool hasShadow;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.hasShadow = true,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = widget.borderRadius ?? BorderRadius.circular(AppDimensions.radiusXL);

    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _hovered = false) : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark
                ? (_hovered ? AppColors.darkCardAlt : AppColors.darkCard)
                : (_hovered ? Colors.grey.shade50 : AppColors.lightCard),
            borderRadius: br,
            border: Border.all(
              color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: widget.hasShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: _hovered ? 20 : 12,
                      offset: Offset(0, _hovered ? 8 : 4),
                    ),
                  ]
                : null,
          ),
          padding: widget.padding ?? const EdgeInsets.all(AppDimensions.paddingL),
          child: widget.child,
        ),
      ),
    );
  }
}
