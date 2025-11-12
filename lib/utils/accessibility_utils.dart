import 'package:flutter/material.dart';

/// Accessibility utilities for ensuring WCAG compliance
class AccessibilityUtils {
  /// Minimum touch target size (48x48 dp) as per Material Design guidelines
  static const double minTouchTargetSize = 48.0;
  
  /// Recommended touch target size for better usability
  static const double recommendedTouchTargetSize = 56.0;
  
  /// Minimum spacing between touch targets
  static const double minTouchTargetSpacing = 8.0;
  
  /// Check if a widget meets minimum touch target size
  static bool meetsMinTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }
  
  /// Wrap a widget to ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width ?? minTouchTargetSize,
      height: height ?? minTouchTargetSize,
      child: Center(child: child),
    );
  }
  
  /// Create a semantic label for currency amounts
  static String currencySemanticLabel(double amount, {String currency = 'Rupees'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final rupees = absAmount.floor();
    final paise = ((absAmount - rupees) * 100).round();
    
    String label = '';
    if (isNegative) {
      label += 'Minus ';
    }
    label += '$rupees $currency';
    if (paise > 0) {
      label += ' and $paise paise';
    }
    return label;
  }
  
  /// Create a semantic label for dates
  static String dateSemanticLabel(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  /// Create a semantic label for transaction type
  static String transactionTypeSemanticLabel(String type) {
    return type.toLowerCase() == 'income' 
        ? 'Income transaction' 
        : 'Expense transaction';
  }
  
  /// Get contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Check if color contrast meets WCAG AA standard (4.5:1 for normal text)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }
  
  /// Check if color contrast meets WCAG AAA standard (7:1 for normal text)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }
  
  /// Check if color contrast meets WCAG AA for large text (3:1)
  static bool meetsWCAGAALargeText(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 3.0;
  }
}

/// Extension for adding semantic labels to widgets
extension AccessibleWidget on Widget {
  /// Wrap widget with Semantics for screen readers
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? link,
    bool? enabled,
    bool? checked,
    bool? selected,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      enabled: enabled,
      checked: checked,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: this,
    );
  }
  
  /// Exclude widget from semantics tree
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }
  
  /// Merge semantics of child widgets
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}
