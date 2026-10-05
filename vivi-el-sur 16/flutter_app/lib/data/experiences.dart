import '../models/experience.dart';

/// Contenido de la etapa 1 (Bariloche). Datos de muestra del prototipo.
/// Al escalar a otros destinos, esta lista pasa a venir de una API.
const experiences = <Experience>[
  Experience(
    id: 'snowboard',
    rank: 1,
    name: 'Snowboard',
    place: 'Cerro Catedral',
    score: 9.6,
    image: 'assets/images/ph-snowboard.webp',
    seasons: {Season.invierno},
  ),
  Experience(
    id: 'parapente',
    rank: 2,
    name: 'Parapente',
    place: 'Cerro Otto',
    score: 9.5,
    image: 'assets/images/ph-parapente.webp',
    seasons: {Season.primavera},
  ),
  Experience(
    id: 'kayak',
    rank: 3,
    name: 'Kayak',
    place: 'Lago Nahuel Huapi',
    score: 9.3,
    image: 'assets/images/ph-kayak.webp',
    seasons: {Season.verano},
  ),
  Experience(
    id: 'challhuaco',
    rank: 4,
    name: 'Valle del Challhuaco',
    place: 'Caminata entre lengas',
    score: 9.4,
    image: 'assets/images/th-challhuaco.webp',
    seasons: {Season.otono},
  ),
  Experience(
    id: 'circuito-chico',
    rank: 5,
    name: 'Circuito Chico',
    place: 'Miradores y bosques de otoño',
    score: 9.3,
    image: 'assets/images/th-circuito.webp',
    seasons: {Season.otono},
  ),
];
