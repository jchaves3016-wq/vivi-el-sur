import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/compact_card.dart';
import '../widgets/search_pill.dart';
import '../widgets/season_card.dart';
import 'detail_screen.dart';
import 'search_sheet.dart';

/// Inicio: una foto del destino, el buscador en una sola píldora y, debajo,
/// la estación como primera decisión.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onShowRanking});

  /// Lleva al ranking: desde "Ver ranking" o al confirmar una búsqueda.
  final VoidCallback onShowRanking;

  Future<void> _openSearch(BuildContext context, {bool voice = false}) async {
    final confirmed = await Navigator.of(context).push(SearchSheet.route(startListening: voice));
    if (confirmed == true) onShowRanking();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recommended = state.recommended;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Hero(
          season: state.season,
          onSearch: () => _openSearch(context),
          onVoice: () => _openSearch(context, voice: true),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bariloche, estación por estación', style: AppText.h1),
              const SizedBox(height: 6),
              Text('Cada época del año, una forma distinta de vivirla', style: AppText.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        SizedBox(
          height: 204,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.xxl).copyWith(top: AppSpacing.lg, bottom: AppSpacing.lg),
            itemCount: Season.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final season = Season.values[index];
              return SeasonCard(
                season: season,
                selected: season == state.season,
                onTap: () => state.selectSeason(season),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Row(
            children: [
              Expanded(child: Text('Recomendado para ${state.season.phrase}', style: AppText.h1)),
              TextButton(onPressed: onShowRanking, child: const Text('Ver ranking')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl).copyWith(top: AppSpacing.md),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(state.season),
              children: [
                if (recommended.isEmpty)
                  Text('Pronto sumamos experiencias para ${state.season.phrase}.', style: AppText.caption),
                for (final experience in recommended) ...[
                  CompactCard(
                    experience: experience,
                    onTap: () => Navigator.of(context).push(DetailScreen.route(experience)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.season, required this.onSearch, required this.onVoice});

  final Season season;
  final VoidCallback onSearch;
  final VoidCallback onVoice;

  static const _shortcuts = {
    Season.invierno: ['Nieve y esquí', 'Chocolaterías', 'Cerca de mí', 'Con chicos'],
    Season.primavera: ['Trekking', 'Parapente', 'Cerca de mí', 'Casas de té'],
    Season.verano: ['Playas', 'Kayak', 'Cerca de mí', 'Cervecerías'],
    Season.otono: ['Lengas en otoño', 'Senderismo', 'Cerca de mí', 'Chocolaterías'],
  };

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Ocupa la primera pantalla completa, como en el diseño.
    final height = math.max(560.0, media.size.height - 96);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero-${season.name}.webp',
            fit: BoxFit.cover,
          ),
          // Velo para que el texto blanco se lea sobre cualquier foto.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .2, .4, .6, .78, 1],
                colors: [Color(0x6B140F1F), Color(0x00140F1F), Color(0x00140F1F), Color(0x80140F1F), Color(0xCC140F1F), Color(0xE0140F1F)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, media.padding.top + AppSpacing.lg, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Viví el Sur', style: AppText.display.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      _Glass(label: 'Bariloche · ${season.label}'),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'El sur cambia\ncon cada estación.',
                        style: AppText.display.copyWith(fontSize: 34, height: 1.04, fontWeight: FontWeight.w600, letterSpacing: -.8, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Encontrá qué hacer en Bariloche ${season.phrase}.',
                        style: AppText.body.copyWith(fontSize: 16, height: 1.4, color: Colors.white.withOpacity(.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SearchPill(onTap: onSearch, onVoice: onVoice),
                ),
                const SizedBox(height: AppSpacing.lg),
                // 44 px de alto: el mínimo cómodo para tocar sin errar.
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: _shortcuts[season]!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: onSearch,
                      child: _Glass(label: _shortcuts[season]![index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip translúcido para usar sobre la foto.
class _Glass extends StatelessWidget {
  const _Glass({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withOpacity(.4)),
      ),
      child: Text(label, style: AppText.bodyMedium.copyWith(fontSize: 13, color: Colors.white)),
    );
  }
}
