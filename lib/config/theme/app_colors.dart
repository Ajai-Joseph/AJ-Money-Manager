import 'package:flutter/material.dart';

/// Custom color palettes for the Money Manager App
class AppColors {
  // Primary colors - Grey-Silver theme
  static const Color primaryLight = Color(0xFF546E7A); // Blue grey
  static const Color primaryDark = Color(0xFFB0BEC5); // Light blue grey
  
  static const Color secondaryLight = Color(0xFF78909C); // Medium grey
  static const Color secondaryDark = Color(0xFFCFD8DC); // Light grey
  
  static const Color tertiaryLight = Color(0xFF90A4AE); // Silver grey
  static const Color tertiaryDark = Color(0xFFECEFF1); // Very light grey
  
  // Surface colors
  static const Color surfaceLight = Color(0xFFF5F5F6); // Light grey
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark grey
  
  static const Color backgroundLight = Color(0xFFFAFAFA); // Very light grey
  static const Color backgroundDark = Color(0xFF121212); // Almost black
  
  // Income/Expense specific colors
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color incomeColorLight = Color(0xFF81C784);
  static const Color incomeColorDark = Color(0xFF66BB6A);
  
  static const Color expenseColor = Color(0xFFF44336);
  static const Color expenseColorLight = Color(0xFFE57373);
  static const Color expenseColorDark = Color(0xFFEF5350);
  
  // Balance colors
  static const Color balancePositive = Color(0xFF607D8B); // Blue grey
  static const Color balanceNegative = Color(0xFF757575); // Medium grey
  
  // Chart colors - Grey-Silver palette
  static const List<Color> chartColors = [
    Color(0xFF546E7A), // Blue grey
    Color(0xFF78909C), // Medium grey
    Color(0xFF90A4AE), // Silver grey
    Color(0xFF607D8B), // Slate grey
    Color(0xFFB0BEC5), // Light blue grey
    Color(0xFF757575), // Medium grey
    Color(0xFF9E9E9E), // Grey
    Color(0xFFBDBDBD), // Light grey
    Color(0xFF455A64), // Dark blue grey
    Color(0xFF37474F), // Very dark grey
    Color(0xFFCFD8DC), // Pale grey
    Color(0xFFECEFF1), // Very light grey
  ];
  
  // Gradient colors
  static const List<Color> incomeGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];
  
  static const List<Color> expenseGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];
  
  static const List<Color> primaryGradient = [
    Color(0xFF546E7A),
    Color(0xFF90A4AE),
  ];
  
  // Error colors
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFF2B8B5);
  
  // Outline colors
  static const Color outlineLight = Color(0xFFBDBDBD);
  static const Color outlineDark = Color(0xFF616161);
  
  // Shadow colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
}
