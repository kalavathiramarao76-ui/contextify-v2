import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerBase = theme.colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score ring placeholder
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shimmerBase,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Card placeholders
        _ShimmerCard(height: 100, color: shimmerBase),
        const SizedBox(height: 12),
        _ShimmerCard(height: 80, color: shimmerBase),
        const SizedBox(height: 12),
        _ShimmerCard(height: 120, color: shimmerBase),
        const SizedBox(height: 12),
        _ShimmerCard(height: 60, color: shimmerBase),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: theme.colorScheme.surfaceContainerHighest,
        );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  final Color color;

  const _ShimmerCard({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}
