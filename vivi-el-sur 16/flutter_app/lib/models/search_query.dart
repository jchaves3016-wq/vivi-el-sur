import 'experience.dart';

/// Lo que el buscador necesita saber: dónde, cuándo, qué y quiénes.
/// Los tres modos (paso a paso, texto libre y voz) terminan en este objeto.
class SearchQuery {
  const SearchQuery({
    this.where,
    this.season,
    this.duration,
    this.what = const {},
    this.adults = 2,
    this.kids = 0,
    this.babies = 0,
    this.withPet = false,
    this.withoutCar = false,
  });

  final String? where;
  final Season? season;
  final String? duration;
  final Set<String> what;
  final int adults;
  final int kids;
  final int babies;
  final bool withPet;
  final bool withoutCar;

  SearchQuery copyWith({
    String? where,
    Season? season,
    String? duration,
    Set<String>? what,
    int? adults,
    int? kids,
    int? babies,
    bool? withPet,
    bool? withoutCar,
  }) {
    return SearchQuery(
      where: where ?? this.where,
      season: season ?? this.season,
      duration: duration ?? this.duration,
      what: what ?? this.what,
      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      babies: babies ?? this.babies,
      withPet: withPet ?? this.withPet,
      withoutCar: withoutCar ?? this.withoutCar,
    );
  }

  /// Resumen de cada pregunta, para la tarjeta cerrada.
  String get whereLabel => where ?? 'Elegí un destino';

  String get whenLabel {
    final parts = [if (season != null) season!.label, if (duration != null) duration!];
    return parts.isEmpty ? 'Estación o fechas' : parts.join(' · ');
  }

  String get whatLabel => what.isEmpty ? 'Cualquier plan' : what.join(', ');

  String get whoLabel {
    final parts = [
      _plural(adults, 'adulto', 'adultos'),
      if (kids > 0) _plural(kids, 'niño', 'niños'),
      if (babies > 0) _plural(babies, 'bebé', 'bebés'),
    ];
    return parts.join(', ');
  }
}

String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// Destinos del buscador. Siguen la estrategia por fases:
/// solo se puede elegir lo que ya tiene oferta cargada.
class Destination {
  const Destination(this.name, this.detail, {this.phase});

  final String name;
  final String detail;

  /// Si no es nulo, el destino se anuncia pero todavía no se puede elegir.
  final String? phase;
}

const destinations = <Destination>[
  Destination('Cerca de mí', 'Usar mi ubicación'),
  Destination('Bariloche', 'Circuito Chico y Cerro Catedral'),
  Destination('Villa La Angostura', 'Corredor de los Lagos', phase: 'Fase 2'),
  Destination('San Martín de los Andes', 'Ruta de los 7 Lagos', phase: 'Fase 2'),
  Destination('El Bolsón', 'Corredor de los Lagos', phase: 'Fase 2'),
];

const durations = <String>['Un finde', 'Finde largo', 'Semana'];

const categories = <String, List<String>>{
  'Experiencias': ['Actividades', 'Aventura', 'Cultura', 'Temporadas', 'Vida nocturna'],
  'Alojamiento': ['Hotel', 'Apart hotel', 'Hostel', 'Camping', 'Casa o depto', 'Refugio'],
  'Gastronomía': ['Restaurantes', 'Cervecerías', 'Chocolaterías', 'Casas de té'],
};

/// Un dato entendido a partir de texto libre o de la voz.
class Understood {
  const Understood(this.label, this.value);

  final String label;
  final String value;
}

/// Texto libre → filtros.
/// Son reglas locales que ocupan el lugar del servicio de IA: sirven para
/// probar el flujo completo sin conexión y definen el contrato de la respuesta.
List<Understood> understand(String text) {
  final t = ' ${_plain(text)} ';
  if (t.trim().length < 6) return const [];
  bool has(List<String> words) => words.any(t.contains);

  final out = <Understood>[const Understood('Dónde', 'Bariloche')];

  final when = <String>[];
  for (final season in Season.values) {
    if (t.contains(_plain(season.label))) when.add(season.label);
  }
  if (has(['finde largo', 'fin de semana largo'])) {
    when.add('Finde largo');
  } else if (has(['finde', 'fin de semana'])) {
    when.add('Un finde');
  } else if (has(['semana'])) {
    when.add('Semana');
  }
  if (has(['sabado'])) {
    when.add('Este sábado');
  } else if (has(['domingo'])) {
    when.add('Este domingo');
  } else if (has([' hoy'])) {
    when.add('Hoy');
  }
  if (when.isNotEmpty) out.add(Understood('Cuándo', when.join(' · ')));

  final kids = has(['dos chicos', '2 chicos', 'dos ninos', '2 ninos'])
      ? 2
      : has(['chicos', 'ninos', 'hijos'])
          ? 1
          : 0;
  final adults = has(['somos dos', 'somos 2', 'en pareja', 'los dos'])
      ? 2
      : has(['solo ', 'sola '])
          ? 1
          : kids > 0
              ? 2
              : 0;
  if (adults > 0) {
    out.add(Understood('Quiénes', SearchQuery(adults: adults, kids: kids == 2 ? 2 : 0).whoLabel));
  }

  final how = [if (has(['sin auto'])) 'Sin auto', if (has(['mascota', 'perro'])) 'Con mascota'];
  if (how.isNotEmpty) out.add(Understood('Cómo', how.join(', ')));

  const topics = {
    'kayak': 'Kayak',
    'esqui': 'Nieve y esquí',
    'snowboard': 'Snowboard',
    'nieve': 'Nieve y esquí',
    'chocolate': 'Chocolaterías',
    'cervez': 'Cervecerías',
    'trekking': 'Trekking',
    'parapente': 'Parapente',
    'lluvia': 'Bajo techo',
    'tranquilo': 'Paseos tranquilos',
    'comer': 'Gastronomía',
  };
  final what = <String>{
    for (final entry in topics.entries)
      if (t.contains(entry.key)) entry.value,
  };
  if (what.isEmpty && kids > 0) what.add('Para chicos');
  if (what.isNotEmpty) out.add(Understood('Qué', what.join(', ')));

  return out;
}

/// Minúsculas y sin acentos, para comparar sin depender de cómo se escribió.
String _plain(String text) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  var out = text.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}
