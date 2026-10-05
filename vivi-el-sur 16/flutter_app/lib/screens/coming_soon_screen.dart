import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Lugar reservado para las secciones que todavía no están en esta versión.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: Color(0xFFE5EDFC), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppText.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: AppText.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
