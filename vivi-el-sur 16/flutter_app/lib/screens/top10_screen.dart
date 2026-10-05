import 'package:flutter/material.dart';

import '../data/experiences.dart';
import '../theme/tokens.dart';
import '../widgets/ranking_card.dart';
import 'detail_screen.dart';

/// Top 10 experiencias: el ranking elegido por los usuarios.
class Top10Screen extends StatelessWidget {
  const Top10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: experiences.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOP 10 EXPERIENCIAS', style: AppText.h1),
              const SizedBox(height: AppSpacing.xs),
              Text('Ranking elegido por los usuarios', style: AppText.caption),
            ],
          );
        }
        final experience = experiences[index - 1];
        return RankingCard(
          experience: experience,
          onTap: () => Navigator.of(context).push(DetailScreen.route(experience)),
        );
      },
    );
  }
}
