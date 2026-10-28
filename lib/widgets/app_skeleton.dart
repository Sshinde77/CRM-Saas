import 'package:flutter/material.dart';

import '../theme/app_colors_ext.dart';

/// Shared animated loading placeholders for API-backed screens.
class AppSkeleton extends StatefulWidget {
  final Widget child;

  const AppSkeleton({super.key, required this.child});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(_controller.value);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.4 + value * 2.8, 0),
            end: Alignment(-0.4 + value * 2.8, 0),
            colors: [
              colors.shimmerBase,
              colors.shimmerHighlight,
              colors.shimmerBase,
            ],
            stops: const [0, .5, 1],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AppSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.shimmerBase,
        borderRadius: borderRadius,
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}

class AppPageSkeleton extends StatelessWidget {
  final int rows;
  final bool showHeader;

  const AppPageSkeleton({super.key, this.rows = 6, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              Row(
                children: [
                  const AppSkeletonBox(width: 150, height: 22),
                  const Spacer(),
                  AppSkeletonBox(
                    width: 92,
                    height: 36,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppSkeletonBox(height: 44),
              const SizedBox(height: 16),
            ],
            ...List.generate(
              rows,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const AppSkeletonBox(width: 42, height: 42),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonBox(height: 15),
                          SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: .62,
                            child: AppSkeletonBox(height: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppSkeletonBox(
                      width: index.isEven ? 72 : 54,
                      height: 28,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
