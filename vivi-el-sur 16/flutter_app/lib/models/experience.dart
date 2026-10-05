/// Estaciones del año: la primera decisión de la app.
enum Season {
  invierno('Invierno', 'Nieve y esquí', 'este invierno'),
  primavera('Primavera', 'Flores y trekking', 'esta primavera'),
  verano('Verano', 'Playas y kayak', 'este verano'),
  otono('Otoño', 'Bosques color fuego', 'este otoño');

  const Season(this.label, this.subtitle, this.phrase);

  final String label;
  final String subtitle;

  /// Para armar "Recomendado para este invierno".
  final String phrase;
}

/// Una experiencia del ranking.
class Experience {
  const Experience({
    required this.id,
    required this.rank,
    required this.name,
    required this.place,
    required this.score,
    required this.image,
    required this.seasons,
  });

  final String id;
  final int rank;
  final String name;
  final String place;
  final double score;
  final String image;

  /// Estaciones en las que la experiencia se recomienda.
  final Set<Season> seasons;
}
