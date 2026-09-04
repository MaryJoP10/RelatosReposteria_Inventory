import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'relatos_colors.dart';
import 'relatos_spacing.dart';

abstract final class RelatosTheme {
  static ThemeData light() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: RelatosColors.onSurface,
      displayColor: RelatosColors.onSurface,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: RelatosColors.primary,
      onPrimary: RelatosColors.onPrimary,
      primaryContainer: RelatosColors.primaryContainer,
      onPrimaryContainer: RelatosColors.onPrimaryContainer,
      secondary: RelatosColors.secondary,
      onSecondary: RelatosColors.onSecondary,
      secondaryContainer: RelatosColors.secondaryContainer,
      onSecondaryContainer: RelatosColors.onSurface,
      tertiary: RelatosColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: RelatosColors.successContainer,
      onTertiaryContainer: RelatosColors.onSurface,
      error: RelatosColors.error,
      onError: Colors.white,
      errorContainer: RelatosColors.errorContainer,
      onErrorContainer: RelatosColors.onSurface,
      surface: RelatosColors.surface,
      onSurface: RelatosColors.onSurface,
      onSurfaceVariant: RelatosColors.onSurfaceVariant,
      outline: RelatosColors.outline,
      outlineVariant: RelatosColors.outlineVariant,
      surfaceContainerHighest: RelatosColors.surfaceContainer,
      inverseSurface: RelatosColors.onSurface,
      onInverseSurface: RelatosColors.surface,
      inversePrimary: RelatosColors.primaryContainer,
      shadow: const Color(0x1A3A322C),
      scrim: const Color(0x663A322C),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RelatosColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: RelatosColors.background,
        foregroundColor: RelatosColors.onSurface,
        elevation: RelatosElevation.none,
        scrolledUnderElevation: 0.4,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: RelatosColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: RelatosColors.surface,
        elevation: RelatosElevation.card,
        shadowColor: const Color(0x1A3A322C),
        shape: RoundedRectangleBorder(
          borderRadius: RelatosRadii.card,
          side: const BorderSide(color: RelatosColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, RelatosSpacing.touchTarget),
          backgroundColor: RelatosColors.primary,
          foregroundColor: RelatosColors.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: RelatosRadii.button),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, RelatosSpacing.touchTarget),
          foregroundColor: RelatosColors.onSurface,
          side: const BorderSide(color: RelatosColors.outline),
          shape: const RoundedRectangleBorder(borderRadius: RelatosRadii.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, RelatosSpacing.touchTarget),
          foregroundColor: RelatosColors.primaryDark,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RelatosColors.primary,
        foregroundColor: RelatosColors.onPrimary,
        elevation: RelatosElevation.raised,
        shape: RoundedRectangleBorder(borderRadius: RelatosRadii.button),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RelatosColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RelatosSpacing.lg,
          vertical: RelatosSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: RelatosRadii.button,
          borderSide: const BorderSide(color: RelatosColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RelatosRadii.button,
          borderSide: const BorderSide(color: RelatosColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RelatosRadii.button,
          borderSide: const BorderSide(color: RelatosColors.primaryDark, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RelatosColors.primaryContainer,
        selectedColor: RelatosColors.primary,
        labelStyle: textTheme.labelMedium,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: RelatosRadii.chip),
        padding: const EdgeInsets.symmetric(
          horizontal: RelatosSpacing.sm,
          vertical: RelatosSpacing.xs,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: RelatosColors.surface,
        indicatorColor: RelatosColors.primaryContainer,
        elevation: RelatosElevation.card,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? RelatosColors.onPrimaryContainer
                : RelatosColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? RelatosColors.primaryDark
                : RelatosColors.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: RelatosColors.surface,
        indicatorColor: RelatosColors.primaryContainer,
        selectedIconTheme: const IconThemeData(color: RelatosColors.primaryDark),
        unselectedIconTheme:
            const IconThemeData(color: RelatosColors.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: RelatosColors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: RelatosColors.onSurfaceVariant,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: RelatosColors.outlineVariant,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RelatosColors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: RelatosColors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: RelatosRadii.button),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: RelatosColors.surface,
        shape: RoundedRectangleBorder(borderRadius: RelatosRadii.card),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: RelatosColors.primaryDark,
        contentPadding: EdgeInsets.symmetric(horizontal: RelatosSpacing.lg),
        minVerticalPadding: RelatosSpacing.md,
      ),
    );
  }
}
