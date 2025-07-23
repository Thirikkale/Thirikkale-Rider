import 'package:flutter/material.dart';

/// Modern loading overlay widget with customizable styles and animations
class ModernLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? indicatorSize;
  final bool showMessage;
  final LoadingStyle style;
  final Color? overlayColor;
  final double? overlayOpacity;
  final BorderRadius? containerBorderRadius;
  final EdgeInsets? containerPadding;
  final TextStyle? messageTextStyle;
  final double? messageSpacing;

  const ModernLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorSize = 60.0,
    this.showMessage = true,
    this.style = LoadingStyle.circular,
    this.overlayColor,
    this.overlayOpacity = 0.7,
    this.containerBorderRadius,
    this.containerPadding,
    this.messageTextStyle,
    this.messageSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color:
                overlayColor ?? Colors.black.withOpacity(overlayOpacity ?? 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernLoadingIndicator(
                    size: indicatorSize ?? 50.0,
                    color: indicatorColor ?? Theme.of(context).primaryColor,
                    style: style,
                  ),
                  if (showMessage && message != null) ...[
                    SizedBox(height: messageSpacing),
                    Text(
                      message!,
                      style:
                          messageTextStyle ??
                          Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Modern loading indicator with multiple animation styles
class ModernLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final LoadingStyle style;
  final Duration? animationDuration;

  const ModernLoadingIndicator({
    super.key,
    required this.size,
    required this.color,
    this.style = LoadingStyle.circular,
    this.animationDuration,
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case LoadingStyle.circular:
        return _buildCircularLoader();
      case LoadingStyle.dots:
        return _buildDotsLoader(sizeOverride: widget.size * 1.2); 
      case LoadingStyle.wave:
        return _buildWaveLoader();
    }
  }

  Widget _buildCircularLoader() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: 4.0,
        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        backgroundColor: widget.color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildDotsLoader({double? sizeOverride}) {
    final double size = sizeOverride ?? widget.size;
    return SizedBox(
      width: widget.size,
      height: widget.size / 3,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final delay = index * 0.3;
              final animValue = (_animation.value + delay) % 1.0;
              final bounce = (1 - (2 * animValue - 1).abs()).clamp(0.0, 1.0);
              final scale = 0.5 + (0.5 * bounce);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size / 6,
                    height: size / 6,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.7 + (0.3 * bounce)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3 * bounce),
                          blurRadius: 4.0 * bounce,
                          spreadRadius: 1.0 * bounce,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildWaveLoader() {
    return SizedBox(
      width: widget.size,
      height: widget.size / 2,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.1;
              final animValue = (_animation.value + delay) % 1.0;
              final height =
                  widget.size /
                  2 *
                  (0.3 + 0.7 * (1 - (2 * animValue - 1).abs()));

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: widget.size / 12,
                height: height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size / 24),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Available loading animation styles
enum LoadingStyle { circular, dots, wave }

/// Extension method for easy usage with any widget
extension ModernLoadingOverlayExtension on Widget {
  Widget withModernLoadingOverlay({
    required bool isLoading,
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
    double? indicatorSize,
    bool showMessage = true,
    LoadingStyle style = LoadingStyle.circular,
    Color? overlayColor,
    double? overlayOpacity,
    BorderRadius? containerBorderRadius,
    EdgeInsets? containerPadding,
    TextStyle? messageTextStyle,
    double? messageSpacing,
  }) {
    return ModernLoadingOverlay(
      isLoading: isLoading,
      message: message,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      indicatorSize: indicatorSize,
      showMessage: showMessage,
      style: style,
      overlayColor: overlayColor,
      overlayOpacity: overlayOpacity,
      containerBorderRadius: containerBorderRadius,
      containerPadding: containerPadding,
      messageTextStyle: messageTextStyle,
      messageSpacing: messageSpacing,
      child: this,
    );
  }
}
