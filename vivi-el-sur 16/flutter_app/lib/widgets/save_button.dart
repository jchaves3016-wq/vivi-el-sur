import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Marcador para guardar una experiencia en "Mi lista".
class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.experienceId});

  final String experienceId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final saved = state.isSaved(experienceId);

    return Semantics(
      button: true,
      toggled: saved,
      label: saved ? 'Quitar de Mi lista' : 'Guardar en Mi lista',
      child: GestureDetector(
        onTap: () => state.toggleSaved(experienceId),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            boxShadow: AppShadows.small,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
              key: ValueKey(saved),
              size: 17,
              color: saved ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
