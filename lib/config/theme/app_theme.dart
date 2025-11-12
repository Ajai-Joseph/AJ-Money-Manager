import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Theme configuration for the Money Manager App
class AppTheme {
  // Light theme color scheme
  static ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFECEFF1), // Light grey container
    onPrimaryContainer: const Color(0xFF263238), // Dark grey text
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFCFD8DC), // Silver container
    onSecondaryContainer: const Color(0xFF37474F), // Dark blue grey text
    tertiary: AppColors.tertiaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFE0E0E0), // Light grey container
    onTertiaryContainer: const Color(0xFF424242), // Dark grey text
    error: AppColors.errorLight,
    onError: Colors.white,
    errorContainer: const Color(0xFFF9DEDC),
    onErrorContainer: const Color(0xFF410E0B),
    surface: AppColors.surfaceLight,
    onSurface: const Color(0xFF212121),
    onSurfaceVariant: const Color(0xFF616161),
    outline: AppColors.outlineLight,
    outlineVariant: const Color(0xFFE0E0E0),
    shadow: AppColors.shadowLight,
    inverseSurface: const Color(0xFF424242),
    onInverseSurface: const Color(0xFFFAFAFA),
    inversePrimary: AppColors.primaryDark,
  );
  
  // Dark theme color scheme
  static ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryDark,
    onPrimary: const Color(0xFF263238), // Dark grey
    primaryContainer: const Color(0xFF546E7A), // Blue grey
    onPrimaryContainer: const Color(0xFFECEFF1), // Light grey
    secondary: AppColors.secondaryDark,
    onSecondary: const Color(0xFF37474F), // Dark blue grey
    secondaryContainer: const Color(0xFF607D8B), // Slate grey
    onSecondaryContainer: const Color(0xFFCFD8DC), // Light grey
    tertiary: AppColors.tertiaryDark,
    onTertiary: const Color(0xFF424242), // Dark grey
    tertiaryContainer: const Color(0xFF78909C), // Medium grey
    onTertiaryContainer: const Color(0xFFE0E0E0), // Light grey
    error: AppColors.errorDark,
    onError: const Color(0xFF601410),
    errorContainer: const Color(0xFF8C1D18),
    onErrorContainer: const Color(0xFFF9DEDC),
    surface: AppColors.surfaceDark,
    onSurface: const Color(0xFFE0E0E0),
    onSurfaceVariant: const Color(0xFFBDBDBD),
    outline: AppColors.outlineDark,
    outlineVariant: const Color(0xFF616161),
    shadow: AppColors.shadowDark,
    inverseSurface: const Color(0xFFE0E0E0),
    onInverseSurface: const Color(0xFF424242),
    inversePrimary: AppColors.primaryLight,
  );
  
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.errorLight),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: AppTextStyles.bodyMedium,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 8,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.outlineLight,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.outlineLight,
      labelStyle: AppTextStyles.titleSmall,
      unselectedLabelStyle: AppTextStyles.titleSmall,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryLight, width: 3),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.outlineLight.withValues(alpha: 0.2),
      thickness: 1,
      space: 1,
    ),
  );
  
  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: const Color(0xFF263238),
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: const Color(0xFF263238),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2C2C2C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.errorDark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: AppTextStyles.bodyMedium,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 8,
      backgroundColor: const Color(0xFF2C2C2C),
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.outlineDark,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.outlineDark,
      labelStyle: AppTextStyles.titleSmall,
      unselectedLabelStyle: AppTextStyles.titleSmall,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryDark, width: 3),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.outlineDark.withValues(alpha: 0.2),
      thickness: 1,
      space: 1,
    ),
  );
  
  // Custom colors for income/expense
  static Color get incomeColor => AppColors.incomeColor;
  static Color get expenseColor => AppColors.expenseColor;
  static Color get balancePositiveColor => AppColors.balancePositive;
  static Color get balanceNegativeColor => AppColors.balanceNegative;
}
