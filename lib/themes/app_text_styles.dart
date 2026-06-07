// lib/themes/app_text_styles.dart
// SZ Construction Management - Typography System
// All text styles use the "Inter" font family for a modern SaaS look.
// Make sure 'inter' is declared in pubspec.yaml under flutter > fonts.

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised typography for the SZ Construction Management app.
/// Follows Material 3 type-scale naming conventions while adding
/// project-specific convenience styles.
class AppTextStyles {
  // ─────────────────────────────────────────────
  // Private constructor — static-only class
  // ─────────────────────────────────────────────
  AppTextStyles._();

  // ─────────────────────────────────────────────
  // Font Family
  // ─────────────────────────────────────────────

  static const String _fontFamily = 'Inter';

  // ─────────────────────────────────────────────
  // Display Styles  (hero text, splash screens)
  // ─────────────────────────────────────────────

  /// Display Large — 57 sp, W300, used for splash/hero headline
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium — 45 sp, W300, major landing sections
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small — 36 sp, W400, page-level hero text
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ─────────────────────────────────────────────
  // Heading Styles  (section & card titles)
  // ─────────────────────────────────────────────

  /// Heading Large — 32 sp, W600, page/section titles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
  );

  /// Heading Medium — 24 sp, W600, card / dialog titles
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.33,
  );

  /// Heading Small — 20 sp, W600, sub-section titles
  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.40,
  );

  // ─────────────────────────────────────────────
  // Title Styles  (Material 3 equivalents)
  // ─────────────────────────────────────────────

  /// Title Large — 22 sp, W500, list item primary text
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium — 16 sp, W500, component labels
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );

  /// Title Small — 14 sp, W500, compact component labels
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ─────────────────────────────────────────────
  // Body Styles  (paragraph and table content)
  // ─────────────────────────────────────────────

  /// Body Large — 16 sp, W400, primary reading text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  /// Body Medium — 14 sp, W400, standard body / table cells
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small — 12 sp, W400, secondary info, captions
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ─────────────────────────────────────────────
  // Label Styles  (buttons, tabs, chips, badges)
  // ─────────────────────────────────────────────

  /// Label Large — 14 sp, W600, button text
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium — 12 sp, W600, tab / chip label
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small — 11 sp, W600, badge, overline
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ─────────────────────────────────────────────
  // Numeric / Stat Styles  (KPI cards)
  // ─────────────────────────────────────────────

  /// Large KPI number — 40 sp, W700
  static const TextStyle statLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.10,
  );

  /// Medium KPI number — 28 sp, W700
  static const TextStyle statMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.14,
  );

  /// Small KPI number — 20 sp, W700
  static const TextStyle statSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.20,
  );

  // ─────────────────────────────────────────────
  // Sidebar / Navigation Styles
  // ─────────────────────────────────────────────

  /// Sidebar nav item label — 14 sp, W500
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Sidebar section header — 11 sp, W600, uppercase tracking
  static const TextStyle navSectionHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.45,
  );

  // ─────────────────────────────────────────────
  // Table / Data-Grid Styles
  // ─────────────────────────────────────────────

  /// Table column header — 13 sp, W600
  static const TextStyle tableHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.38,
  );

  /// Table cell — 13 sp, W400
  static const TextStyle tableCell = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.38,
  );

  // ─────────────────────────────────────────────
  // Code / Monospace
  // ─────────────────────────────────────────────

  /// Monospace style for IDs, codes, reference numbers
  static const TextStyle mono = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  // ─────────────────────────────────────────────
  // Convenience Factory Methods
  // ─────────────────────────────────────────────

  /// Returns [headingLarge] with the given [color].
  static TextStyle heading(Color color, {double? fontSize, FontWeight? weight}) {
    return headingLarge.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  /// Returns [bodyMedium] with the given [color].
  static TextStyle body(Color color, {double? fontSize, FontWeight? weight}) {
    return bodyMedium.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  /// Returns [labelLarge] with the given [color].
  static TextStyle label(Color color, {double? fontSize, FontWeight? weight}) {
    return labelLarge.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  /// Returns [titleMedium] with the given [color].
  static TextStyle title(Color color, {double? fontSize, FontWeight? weight}) {
    return titleMedium.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  /// Returns [bodySmall] with the given [color].
  static TextStyle caption(Color color, {double? fontSize, FontWeight? weight}) {
    return bodySmall.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  /// Returns [statLarge] with the given [color].
  static TextStyle stat(Color color, {double? fontSize, FontWeight? weight}) {
    return statLarge.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  // ─────────────────────────────────────────────
  // Theme-aware helpers
  // ─────────────────────────────────────────────

  /// Primary heading style adapted for the current [isDark] theme.
  static TextStyle headingPrimary({required bool isDark}) {
    return headingLarge.copyWith(
      color: AppColors.textPrimary(isDark: isDark),
    );
  }

  /// Body style adapted for the current [isDark] theme.
  static TextStyle bodyPrimary({required bool isDark}) {
    return bodyMedium.copyWith(
      color: AppColors.textPrimary(isDark: isDark),
    );
  }

  /// Secondary body style adapted for the current [isDark] theme.
  static TextStyle bodySecondary({required bool isDark}) {
    return bodyMedium.copyWith(
      color: AppColors.textSecondary(isDark: isDark),
    );
  }

  // ─────────────────────────────────────────────
  // Material 3 TextTheme helper
  // ─────────────────────────────────────────────

  /// Builds a full [TextTheme] object compatible with Material 3, using
  /// [textColor] as the base color. Suitable for passing to ThemeData.
  static TextTheme toTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: textColor),
      displayMedium: displayMedium.copyWith(color: textColor),
      displaySmall: displaySmall.copyWith(color: textColor),
      headlineLarge: headingLarge.copyWith(color: textColor),
      headlineMedium: headingMedium.copyWith(color: textColor),
      headlineSmall: headingSmall.copyWith(color: textColor),
      titleLarge: titleLarge.copyWith(color: textColor),
      titleMedium: titleMedium.copyWith(color: textColor),
      titleSmall: titleSmall.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      bodySmall: bodySmall.copyWith(color: textColor),
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium.copyWith(color: textColor),
      labelSmall: labelSmall.copyWith(color: textColor),
    );
  }
}
