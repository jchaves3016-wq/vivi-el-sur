import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Estrella + puntaje.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.score, this.color = AppColors.accentAmber});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 15, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(score.toStringAsFixed(1), style: AppText.title),
      ],
    );
  }
}
