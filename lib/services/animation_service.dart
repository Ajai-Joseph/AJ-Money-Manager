import 'package:flutter/material.dart';

/// Service class providing reusable animation utilities for the app
class AnimationService {
  // Animation duration constants
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration fastDuration = Duration(milliseconds: 200);

  // Animation curve constants
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  /// Creates a slide animation from the specified direction
  /// 
  /// [controller] - The animation controller
  /// [index] - The index for staggered animations (optional)
  /// [direction] - The direction to slide from (default: bottom)
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    int index = 0,
    SlideDirection direction = SlideDirection.bottom,
  }) {
    final delay = index * 0.05; // 50ms delay between items
    final start = delay.clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);

    Offset beginOffset;
    switch (direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1.0, 0.0);
        break;
      case SlideDirection.top:
        beginOffset = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottom:
        beginOffset = const Offset(0.0, 1.0);
        break;
    }

    return Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: smoothCurve),
      ),
    );
  }

  /// Creates a fade animation
  /// 
  /// [controller] - The animation controller
  /// [index] - The index for staggered animations (optional)
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    int index = 0,
  }) {
    final delay = index * 0.05; // 50ms delay between items
    final start = delay.clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);

    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: defaultCurve),
      ),
    );
  }

  /// Creates a scale animation
  /// 
  /// [controller] - The animation controller
  /// [index] - The index for staggered animations (optional)
  /// [beginScale] - The starting scale value (default: 0.8)
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    int index = 0,
    double beginScale = 0.8,
  }) {
    final delay = index * 0.05; // 50ms delay between items
    final start = delay.clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);

    return Tween<double>(
      begin: beginScale,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: bounceCurve),
      ),
    );
  }

  /// Creates a combined fade and slide animation for staggered lists
  /// 
  /// [controller] - The animation controller
  /// [index] - The index of the item in the list
  /// [direction] - The direction to slide from
  static StaggeredAnimation createStaggeredAnimation(
    AnimationController controller,
    int index, {
    SlideDirection direction = SlideDirection.bottom,
  }) {
    return StaggeredAnimation(
      slideAnimation: createSlideAnimation(
        controller,
        index: index,
        direction: direction,
      ),
      fadeAnimation: createFadeAnimation(controller, index: index),
    );
  }

  /// Creates a rotation animation
  /// 
  /// [controller] - The animation controller
  /// [turns] - Number of full rotations (default: 0.25 for 90 degrees)
  static Animation<double> createRotationAnimation(
    AnimationController controller, {
    double turns = 0.25,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: turns,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: defaultCurve,
      ),
    );
  }

  /// Creates a size animation
  /// 
  /// [controller] - The animation controller
  /// [beginSize] - The starting size
  /// [endSize] - The ending size
  static Animation<Size?> createSizeAnimation(
    AnimationController controller,
    Size beginSize,
    Size endSize,
  ) {
    return SizeTween(
      begin: beginSize,
      end: endSize,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: smoothCurve,
      ),
    );
  }
}

/// Enum for slide animation directions
enum SlideDirection {
  left,
  right,
  top,
  bottom,
}

/// Container class for staggered animations
class StaggeredAnimation {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  StaggeredAnimation({
    required this.slideAnimation,
    required this.fadeAnimation,
  });
}

/// Widget builder for staggered list animations
class StaggeredListAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final SlideDirection direction;
  final Duration delay;

  const StaggeredListAnimation({
    super.key,
    required this.child,
    required this.index,
    this.direction = SlideDirection.bottom,
    this.delay = Duration.zero,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationService.defaultDuration,
      vsync: this,
    );

    _slideAnimation = AnimationService.createSlideAnimation(
      _controller,
      index: widget.index,
      direction: widget.direction,
    );

    _fadeAnimation = AnimationService.createFadeAnimation(
      _controller,
      index: widget.index,
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget builder for fade animations
class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = AnimationService.defaultDuration,
    this.delay = Duration.zero,
    this.curve = AnimationService.defaultCurve,
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Widget builder for scale animations
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = AnimationService.defaultDuration,
    this.delay = Duration.zero,
    this.curve = AnimationService.bounceCurve,
    this.beginScale = 0.8,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
