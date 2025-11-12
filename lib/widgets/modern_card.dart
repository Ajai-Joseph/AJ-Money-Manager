import 'package:flutter/material.dart';

/// A modern card widget with elevation, border radius, and optional gradient support
/// Includes micro-interactions for better user feedback
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Border? border;
  final bool enableHoverEffect;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius = 16.0,
    this.color,
    this.gradient,
    this.onTap,
    this.border,
    this.enableHoverEffect = true,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableHoverEffect) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.gradient == null
            ? (widget.color ?? Theme.of(context).cardColor)
            : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border,
      ),
      child: widget.child,
    );

    final card = Material(
      elevation: widget.elevation ?? 2.0,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      color: Colors.transparent,
      child: widget.onTap != null
          ? InkWell(
              onTap: widget.onTap,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: cardContent,
            )
          : cardContent,
    );

    return Container(
      margin: widget.margin,
      child: widget.onTap != null && widget.enableHoverEffect
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: card,
            )
          : card,
    );
  }
}
