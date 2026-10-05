# Viví el Sur — base del MVP (Flutter)

Fase 1 de la app: Bariloche, con estación del año, buscador y lista de guardados.

> Este código todavía no se compiló ni se probó en un dispositivo: el entorno donde se escribió no tiene el SDK de Flutter. Antes de mostrarlo, corré `flutter analyze` y `flutter run`.

## Cómo correrlo

```bash
flutter create . --platforms=ios,android,web   # genera las carpetas de plataforma
flutter pub get
flutter run
```

## Estructura

- `lib/theme/tokens.dart` — colores, espaciado, radios, sombras y tipografía. Mismos nombres y valores que en Figma.
- `lib/state/app_state.dart` — estación elegida, lista de guardados y búsqueda en curso (`ChangeNotifier`).
- `lib/models/search_query.dart` — los cuatro filtros del buscador, los destinos por fase y `understand()`, que traduce texto libre a filtros.
- `lib/widgets/` — `RankingCard`, `SeasonCard`, `CompactCard`, `SaveButton`, `RatingBadge`, `SearchPill`.
- `lib/screens/` — Inicio, Buscador (`search_sheet.dart`), Top 10, Detalle y Mi lista. Cerca y Mi viaje son pantallas reservadas.

## El buscador

Tres modos que terminan en el mismo `SearchQuery`:

- **Paso a paso**: Dónde, Cuándo, Qué y Quiénes, una pregunta abierta por vez.
- **Con tus palabras**: texto libre. Hoy lo interpreta `understand()` con reglas locales; ese es el lugar donde se conecta el servicio de IA.
- **Por voz**: la interfaz de dictado está completa, pero la transcripción es una frase de ejemplo. Falta conectar un paquete de reconocimiento de voz (por ejemplo `speech_to_text`) en `_listen()`.

La búsqueda confirmada lleva al ranking; todavía no filtra resultados.

## Pendiente

- Conectar la IA y el reconocimiento de voz reales.
- Filtrar resultados con el `SearchQuery`.
- Persistir la lista entre sesiones.
- Mapa descargable para usar sin señal.
- Contenido de los próximos destinos.
