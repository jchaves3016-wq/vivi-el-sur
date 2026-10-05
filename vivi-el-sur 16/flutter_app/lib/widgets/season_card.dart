import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../theme/tokens.dart';

/// Tarjeta de estación. Seleccionada: borde azul + check.
class SeasonCard extends StatelessWidget {
  const SeasonCard({super.key, required this.season, required this.selected, required this.onTap});

  final Season season;
  final bool selected;
  final VoidCallback onTap;

  static const _gradients = {
    Season.invierno: [Color(0xFF8CB2EB), Color(0xFF334D8C)],
    Season.primavera: [Color(0xFF9ED18C), Color(0xFF4D8C6B)],
    Season.verano: [Color(0xFF66B8D9), Color(0xFF2E738C)],
    Season.otono: [Color(0xFFD98C47), Color(0xFF8C4733)],
  };

  static const _images = {
    Season.invierno: 'assets/images/se-invierno.webp',
    Season.primavera: 'assets/images/se-primavera.webp',
    Season.verano: 'assets/images/se-verano.webp',
    Season.otono: 'assets/images/se-otono.webp',
  };

  @override
  Widget build(BuildContext context) {
    final image = _images[season];

    return Semantics(
      button: true,
      selected: selected,
      label: '${season.label}: ${season.subtitle}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 130,
          height: 172,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: selected ? AppColors.primaryBlue : Colors.transparent, width: 3),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _gradients[season]!,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null) Image.asset(image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x80000000)],
                  ),
                ),
              ),
              Positioned(
                left: 9,
                right: 9,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(season.label, style: AppText.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(season.subtitle, style: AppText.overline.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: const CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
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
