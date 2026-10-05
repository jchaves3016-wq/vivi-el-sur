import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Entrada única del buscador: abre la hoja de preguntas o, desde el
/// micrófono, el dictado.
class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.onTap, required this.onVoice});

  final VoidCallback onTap;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      elevation: 8,
      shadowColor: const Color(0x4D0D0A1A),
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
          child: Row(
            children: [
              const Icon(Icons.search, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('¿Qué querés hacer?', style: AppText.title.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Dónde · Cuándo · Quiénes', style: AppText.caption.copyWith(fontSize: 12.5)),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Buscar por voz',
                child: Material(
                  color: AppColors.textPrimary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onVoice,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.mic_none, size: 22, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
