import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // === Mindful Canvas "Mint & Stone" Palette ===

  // Primary - Forest Green
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryDim = Color(0xFF1F5E44);
  static const Color primaryContainer = Color(0xFFB1F0CE);
  static const Color onPrimaryContainer = Color(0xFF1D5C42);

  // Secondary
  static const Color secondary = Color(0xFF426658);
  static const Color secondaryContainer = Color(0xFFC4EBD9);

  // Tertiary
  static const Color tertiary = Color(0xFF56634A);
  static const Color tertiaryContainer = Color(0xFFEFFFDE);

  // Surfaces (Tonal Architecture)
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F4F5);
  static const Color surfaceContainer = Color(0xFFEBEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE5E9EB);
  static const Color surfaceContainerHighest = Color(0xFFDEE3E6);

  // Text Colors
  static const Color onSurface = Color(0xFF2D3335);
  static const Color onSurfaceVariant = Color(0xFF5A6062);

  // Outline
  static const Color outline = Color(0xFF767C7E);
  static const Color outlineVariant = Color(0xFFADB3B5);

  // Brand Accent
  static const Color brandAccent = Color(0xFF006A6A);

  // Error
  static const Color error = Color(0xFFA83836);
  static const Color errorContainer = Color(0xFFFA746F);

  // Semantic
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFF59E0B);

  // Category Default Colors
  static const Color categoryExercise = Color(0xFFEF4444);
  static const Color categoryStudy = Color(0xFF3B82F6);
  static const Color categoryWork = Color(0xFFF59E0B);
  static const Color categoryLife = Color(0xFF10B981);
  static const Color categoryEtc = Color(0xFF8B5CF6);

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? onSurface : const Color(0xFFF1F4F5);
    final dimColor = brightness == Brightness.light ? onSurfaceVariant : const Color(0xFF9CA3AF);

    return TextTheme(
      // Manrope for display/headline
      displayLarge: GoogleFonts.manrope(
        fontSize: 48, fontWeight: FontWeight.w200, color: color,
        letterSpacing: -1.5, height: 1.1,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 36, fontWeight: FontWeight.w300, color: color,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 28, fontWeight: FontWeight.w700, color: color,
        letterSpacing: -0.5, height: 1.2,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24, fontWeight: FontWeight.w500, color: color,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20, fontWeight: FontWeight.w700, color: color,
        letterSpacing: -0.2,
      ),
      // Inter for body/label
      titleLarge: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: dimColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: dimColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: dimColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600, color: dimColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700, color: dimColor,
        letterSpacing: 1.5,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Color(0xFFE6FFEE),
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: Color(0xFFE5FFF1),
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        error: error,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainer: surfaceContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface.withValues(alpha: 0.8),
        foregroundColor: brandAccent,
        titleTextStyle: GoogleFonts.manrope(
          color: brandAccent,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: onSurfaceVariant.withValues(alpha: 0.7), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: onPrimaryContainer,
              letterSpacing: 1.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: onSurfaceVariant.withValues(alpha: 0.7),
            letterSpacing: 1.2,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: const Color(0xFFE6FFEE),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
        space: 12,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryContainer.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryContainer;
            }
            return surfaceContainerLowest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return onPrimaryContainer;
            }
            return onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFFE6FFEE);
          return outlineVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceContainerHighest;
        }),
      ),
    );
  }

  static ThemeData darkTheme() {
    const darkBg = Color(0xFF0C0F10);
    const darkSurface = Color(0xFF1A1C1E);
    const darkCard = Color(0xFF22252A);
    const darkBorder = Color(0xFF2E3238);
    const darkText = Color(0xFFF1F4F5);
    const darkTextDim = Color(0xFF9CA3AF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFB1F0CE),
        onPrimary: Color(0xFF003737),
        primaryContainer: Color(0xFF005050),
        onPrimaryContainer: Color(0xFFB1F0CE),
        secondary: darkTextDim,
        onSecondary: darkBg,
        surface: darkSurface,
        onSurface: darkText,
        onSurfaceVariant: darkTextDim,
        error: Color(0xFFFA746F),
        outline: darkBorder,
        outlineVariant: Color(0xFF2E3238),
        surfaceContainerHighest: darkCard,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFB1F0CE),
        titleTextStyle: GoogleFonts.manrope(
          color: const Color(0xFFB1F0CE),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF005050),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFB1F0CE), size: 24);
          }
          return const IconThemeData(color: Color(0xFF6B7280), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: const Color(0xFFB1F0CE),
              letterSpacing: 1.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: const Color(0xFF6B7280),
            letterSpacing: 1.2,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFB1F0CE),
        foregroundColor: const Color(0xFF003737),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorder.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        side: BorderSide(color: darkBorder.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: darkTextDim),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
        space: 12,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF005050)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF005050);
            }
            return darkCard;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFB1F0CE);
            }
            return darkTextDim;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: darkBorder.withValues(alpha: 0.5)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFB1F0CE),
        linearTrackColor: darkCard,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF003737);
          return const Color(0xFF6B7280);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFFB1F0CE);
          return darkCard;
        }),
      ),
    );
  }
}
