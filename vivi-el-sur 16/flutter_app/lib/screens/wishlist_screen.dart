import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/compact_card.dart';
import 'detail_screen.dart';

/// Mi lista: las experiencias guardadas para el viaje.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key, required this.onExplore});

  /// Lleva al ranking cuando la lista está vacía.
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.wishlist;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE5EDFC),
                child: Icon(Icons.bookmark_border, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Tu lista está vacía', style: AppText.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tocá el marcador en cualquier experiencia para guardarla acá.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onExplore, child: const Text('Ver experiencias')),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text('Guardados para tu viaje', style: AppText.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(items.length == 1 ? '1 experiencia' : '${items.length} experiencias', style: AppText.caption),
        const SizedBox(height: AppSpacing.lg),
        for (final experience in items) ...[
          CompactCard(
            experience: experience,
            onTap: () => Navigator.of(context).push(DetailScreen.route(experience)),
            trailing: IconButton(
              tooltip: 'Quitar de Mi lista',
              onPressed: () => state.toggleSaved(experience.id),
              icon: const Icon(Icons.bookmark, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
