import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  // Mobile breakpoint (phones)
  static const double mobile = 600;
  
  // Tablet breakpoint
  static const double tablet = 900;
  
  // Desktop breakpoint
  static const double desktop = 1200;
}

/// Extension on BuildContext for responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get the screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get the screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobile;
  
  /// Check if device is tablet (600 <= width < 900)
  bool get isTablet => screenWidth >= ResponsiveBreakpoints.mobile && 
                       screenWidth < ResponsiveBreakpoints.tablet;
  
  /// Check if device is desktop (width >= 900)
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.tablet;
  
  /// Check if device is small screen (width < 360)
  bool get isSmallScreen => screenWidth < 360;
  
  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48.0);
    }
  }
  
  /// Get responsive card margin
  EdgeInsets get responsiveCardMargin {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    }
  }
  
  /// Get responsive grid cross axis count
  int get gridCrossAxisCount {
    if (isMobile) {
      return 2;
    } else if (isTablet) {
      return 3;
    } else {
      return 4;
    }
  }
  
  /// Get responsive font size multiplier
  double get fontSizeMultiplier {
    if (isSmallScreen) {
      return 0.9;
    } else if (isMobile) {
      return 1.0;
    } else if (isTablet) {
      return 1.1;
    } else {
      return 1.2;
    }
  }
  
  /// Get responsive icon size
  double get iconSize {
    if (isSmallScreen) {
      return 20.0;
    } else if (isMobile) {
      return 24.0;
    } else {
      return 28.0;
    }
  }
  
  /// Get responsive card width for centered layouts
  double get maxCardWidth {
    if (isMobile) {
      return screenWidth;
    } else if (isTablet) {
      return 600;
    } else {
      return 800;
    }
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.tablet && desktop != null) {
          return desktop!(context, constraints);
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile && tablet != null) {
          return tablet!(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

/// Responsive value selector
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    } else if (context.isTablet && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
