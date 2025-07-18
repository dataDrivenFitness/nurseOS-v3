// lib/shared/widgets/animated_extended_fab.dart
import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/animation_tokens.dart';

/// A reusable animated FAB that transitions between extended and compact states
/// based on scroll position or external triggers.
///
/// Used in Patient List Screen and Available Shift Screen for consistent
/// animation behavior across the app.
class AnimatedExtendedFAB extends StatefulWidget {
  const AnimatedExtendedFAB({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = Icons.add,
    this.extendedWidth = 170.0,
    this.compactWidth = 56.0,
    this.scrollController,
    this.scrollThreshold = 100.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Callback when FAB is pressed
  final VoidCallback onPressed;

  /// Text label shown in extended state
  final String label;

  /// Icon shown in FAB (defaults to Icons.add)
  final IconData icon;

  /// Width when FAB is extended (defaults to 170.0)
  final double extendedWidth;

  /// Width when FAB is compact (defaults to 56.0)
  final double compactWidth;

  /// Optional scroll controller to trigger animations
  /// If null, FAB remains in extended state
  final ScrollController? scrollController;

  /// Scroll offset threshold to trigger compact mode
  final double scrollThreshold;

  /// Optional background color (uses theme primary if null)
  final Color? backgroundColor;

  /// Optional foreground color (uses theme onPrimary if null)
  final Color? foregroundColor;

  @override
  State<AnimatedExtendedFAB> createState() => _AnimatedExtendedFABState();
}

class _AnimatedExtendedFABState extends State<AnimatedExtendedFAB>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  // Animations
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabWidthAnimation;
  late Animation<double> _fabTextOpacityAnimation;

  // State
  bool _showCompactFab = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: AnimationTokens.medium, // 300ms from design tokens
      vsync: this,
    );

    // FAB scale animation (subtle scale down when compact)
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // FAB width animation
    _fabWidthAnimation = Tween<double>(
      begin: widget.extendedWidth,
      end: widget.compactWidth,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // FAB text opacity - fades out early in the animation
    _fabTextOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInCubic),
    ));
  }

  void _setupScrollListener() {
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController == null) return;

    final currentOffset = widget.scrollController!.offset;
    final bool shouldShowCompact = currentOffset > widget.scrollThreshold;

    if (shouldShowCompact != _showCompactFab) {
      setState(() {
        _showCompactFab = shouldShowCompact;
      });

      if (_showCompactFab) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fabAnimationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: SizedBox(
            width: _fabWidthAnimation.value,
            height: 56,
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: widget.backgroundColor ??
                  Theme.of(context).colorScheme.primary,
              foregroundColor: widget.foregroundColor ??
                  Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
              highlightElevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: _buildFABContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFABContent() {
    // Calculate current width progress (0.0 to 1.0)
    final widthProgress = (_fabWidthAnimation.value - widget.compactWidth) /
        (widget.extendedWidth - widget.compactWidth);

    // Only show text when there's actually enough room (65%+ width)
    final showText = widthProgress > 0.65 && _fabWidthAnimation.value > 115;

    return ClipRect(
      child: Padding(
        // ✅ Conservative padding to prevent overflow
        padding: EdgeInsets.symmetric(
          horizontal: showText ? 18 : 16, // Reduced from 20 to 18
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 24),
            // ✅ Only add spacing and text when we have sufficient width
            if (showText) ...[
              const SizedBox(width: 12),
              // ✅ Flexible text to prevent overflow
              Flexible(
                child: AnimatedOpacity(
                  opacity: _fabTextOpacityAnimation.value,
                  duration: AnimationTokens.short,
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
