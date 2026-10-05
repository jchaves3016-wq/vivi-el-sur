import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../theme/tokens.dart';
import 'rating_badge.dart';
import 'save_button.dart';

/// Card del ranking Top 10: foto a todo el ancho, puesto y marcador de guardado.
class RankingCard extends StatelessWidget {
  const RankingCard({super.key, required this.experience, this.onTap});

  final Experience experience;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Image.asset(experience.image, height: 170, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(top: 12, left: 12, child: _RankBadge(rank: experience.rank)),
              Positioned(top: 12, right: 12, child: SaveButton(experienceId: experience.id)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(experience.name, style: AppText.h2),
                      const SizedBox(height: 3),
                      Text(experience.place, style: AppText.caption),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingBadge(score: experience.score, color: AppColors.primaryBlue),
                    Text('Puntos', style: AppText.overline),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF252525), borderRadius: BorderRadius.circular(4)),
      child: Text(
        '#$rank',
        style: AppText.overline.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
