# Viví el Sur — caso UX y build

¿Qué pasa si repensás un proyecto de 2018 con lo que sabés hoy? Una app para planificar el viaje al sur de la Argentina y moverse por cada ciudad estando ahí, diseñada por estación y llevada a código.

## Qué hay en este repositorio

| Carpeta | Contenido |
| --- | --- |
| `index.html` | La página del caso. |
| `css/app.css` | El sistema de la app: tokens y componentes, con los mismos nombres que en Figma. |
| `js/app.js` | El prototipo vivo: pantallas, estación del año y lista de guardados. |
| `css/styles.css`, `js/main.js` | Estilos e interacciones de la página del caso. |
| `flutter_app/` | La base del MVP en Flutter (etapa 1: Bariloche). |
| `process/` | Videos del proceso y la herramienta con la que se generan (`replay.html`). |

## Verlo

Es un sitio estático, sin dependencias ni paso de build.

```bash
python3 -m http.server 8000
# http://localhost:8000
```

Para publicarlo: **Settings → Pages → Deploy from a branch → `main` / root**.

## Créditos

Versión original (2018): Fernanda Elicetche, The8Agency.
Rediseño y build (2026): Jorgelina Chaves.
