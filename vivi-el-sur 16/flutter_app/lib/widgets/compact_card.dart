import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../theme/tokens.dart';
import 'rating_badge.dart';

/// Fila compacta: miniatura, título, lugar y puntaje.
class CompactCard extends StatelessWidget {
  const CompactCard({super.key, required this.experience, this.onTap, this.trailing});

  final Experience experience;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(experience.image, width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(experience.name, style: AppText.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(experience.place, style: AppText.caption),
                    const SizedBox(height: AppSpacing.xs),
                    RatingBadge(score: experience.score),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
