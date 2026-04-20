import 'package:flutter/material.dart';

/// A shimmer-style skeleton loader that renders rounded rectangles to
/// represent loading content.
///
/// The animation pulses between two shades using a repeating animation,
/// giving a "breathing" effect commonly used as a loading placeholder.
///
/// Convenience factory constructors are provided for the most common shapes:
/// - [SkeletonLoader.profileCard]
/// - [SkeletonLoader.roomListItem]
/// - [SkeletonLoader.participantItem]
/// - [SkeletonLoader.rollHistoryItem]
///
/// Example – custom layout:
/// ```dart
/// SkeletonLoader(
///   child: Column(
///     children: [
///       SkeletonBox(height: 20, width: 200),
///       SizedBox(height: 8),
///       SkeletonBox(height: 14, width: double.infinity),
///     ],
///   ),
/// )
/// ```
class SkeletonLoader extends StatefulWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  // ---------------------------------------------------------------------------
  // Convenience constructors
  // ---------------------------------------------------------------------------

  /// Skeleton for a user profile header card.
  static Widget profileCard() => SkeletonLoader(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonCircle(size: 64),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(height: 18, width: 140),
                      const SizedBox(height: 8),
                      const SkeletonBox(height: 13, width: 100),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SkeletonBox(height: 13, width: double.infinity),
              const SizedBox(height: 6),
              const SkeletonBox(height: 13, width: 220),
            ],
          ),
        ),
      );

  /// Skeleton for a single room list tile.
  static Widget roomListItem() => SkeletonLoader(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const SkeletonCircle(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(height: 15, width: double.infinity),
                    const SizedBox(height: 6),
                    const SkeletonBox(height: 12, width: 120),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonBox(height: 28, width: 60, radius: 14),
            ],
          ),
        ),
      );

  /// Skeleton for a participant list tile.
  static Widget participantItem() => SkeletonLoader(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SkeletonCircle(size: 36),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonBox(height: 14, width: double.infinity)),
              const SizedBox(width: 8),
              const SkeletonBox(height: 22, width: 50, radius: 11),
            ],
          ),
        ),
      );

  /// Skeleton for a roll history tile.
  static Widget rollHistoryItem() => SkeletonLoader(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SkeletonBox(height: 40, width: 40, radius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(height: 14, width: 100),
                    const SizedBox(height: 6),
                    const SkeletonBox(height: 12, width: 160),
                  ],
                ),
              ),
              const SkeletonBox(height: 28, width: 44, radius: 6),
            ],
          ),
        ),
      );

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => _SkeletonScope(
        animationValue: _animation.value,
        child: child!,
      ),
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Inherited widget that passes the animation value down the tree
// ---------------------------------------------------------------------------

class _SkeletonScope extends InheritedWidget {
  final double animationValue;

  const _SkeletonScope({
    required this.animationValue,
    required super.child,
  });

  static _SkeletonScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();

  @override
  bool updateShouldNotify(_SkeletonScope old) =>
      old.animationValue != animationValue;
}

// ---------------------------------------------------------------------------
// Primitive skeleton shapes
// ---------------------------------------------------------------------------

/// A rectangular skeleton placeholder.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.height,
    required this.width,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return _SkeletonShape(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// A circular skeleton placeholder (e.g. avatar).
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return _SkeletonShape(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

class _SkeletonShape extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const _SkeletonShape({
    required this.height,
    required this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scope = _SkeletonScope.of(context);
    final t = scope?.animationValue ?? 0.5;

    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.onSurface.withOpacity(0.10);
    final highlight = colorScheme.onSurface.withOpacity(0.20);
    final color = Color.lerp(base, highlight, t)!;

    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
    );
  }
}
