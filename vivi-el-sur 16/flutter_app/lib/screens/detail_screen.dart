import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/rating_badge.dart';

/// Detalle de una experiencia, con la acción de guardar.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.experience});

  final Experience experience;

  static Route<void> route(Experience experience) =>
      MaterialPageRoute(builder: (_) => DetailScreen(experience: experience));

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final saved = state.isSaved(experience.id);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(title: Text(experience.name)),
      body: ListView(
        children: [
          Image.asset(experience.image, height: 230, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPERIENCIA · AVENTURA',
                  style: AppText.overline.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, letterSpacing: .4),
                ),
                const SizedBox(height: 5),
                Text(experience.name, style: AppText.display),
                Text(experience.place, style: AppText.body.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: AppSpacing.md),
                RatingBadge(score: experience.score, color: AppColors.primaryBlue),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => state.toggleSaved(experience.id),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 18),
                  label: Text(saved ? 'Guardado en Mi lista' : 'Guardar en Mi lista'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: saved ? AppColors.primaryBlue : AppColors.textPrimary,
                    side: BorderSide(color: saved ? AppColors.primaryBlue : AppColors.borderDefault),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    textStyle: AppText.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
          child: FilledButton(onPressed: () {}, child: const Text('Reservar')),
        ),
      ),
    );
  }
}
