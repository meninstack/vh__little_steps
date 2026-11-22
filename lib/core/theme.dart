import 'package:material_ui/material_ui.dart';

import '../data/card_catalog.dart';

abstract final class AppColors {
  static const Color background = Color(0xFFFFF7E8);
  static const Color ink = Color(0xFF2B2D42);
  static const Color inkSoft = Color(0xFF6B6F85);
  static const Color primary = Color(0xFF4F6DF5);
  static const Color star = Color(0xFFFFB703);
  static const Color starOff = Color(0xFFE4E6EF);
  static const Color done = Color(0xFF2EB67D);
  static const Color doneSurface = Color(0xFFDDF6E8);
  static const Color outline = Color(0xFFE9E2D3);
}

/// Widths at which the layout changes shape.
abstract final class Breakpoints {
  /// Task cards switch from a list to a grid.
  static const double grid = 600;

  /// Routines move from a top strip to a side rail.
  static const double rail = 840;
}

/// Background tint of a task card. Each built-in group has its own colour so
/// a child can tell parts of the day apart before reading anything.
Color cardTint(CardGroup? group) => switch (group) {
  CardGroup.morning => const Color(0xFFFFEDBF),
  CardGroup.school => const Color(0xFFD9E8FF),
  CardGroup.care => const Color(0xFFD5F3E4),
  CardGroup.home => const Color(0xFFE9DEFF),
  CardGroup.outside => const Color(0xFFFFDFC4),
  CardGroup.manners => const Color(0xFFCDEEF3),
  null => const Color(0xFFFFDDE8),
};

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    surface: Colors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
  );

  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.background,
  );

  final textTheme = base.textTheme
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
      .copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      );

  // Styles read from ThemeData at this point have no font size yet (sizes are
  // merged in per locale later), so every style handed to a component theme
  // below sets its own.
  const buttonShape = StadiumBorder();
  const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 22),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 22),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
      unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
      dividerColor: AppColors.outline,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
