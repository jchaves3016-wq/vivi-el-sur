/* ==========================================================================
   Viví el Sur — prototipo vivo
   Un solo estado (estación + lista de guardados) compartido por todos los
   teléfonos de la página. Las pantallas se arman con los componentes de app.css.
   ========================================================================== */
(function () {
  'use strict';

  /* Íconos ---------------------------------------------------------------- */
  const I = (name, cls = '') => `<svg class="ic ${cls}" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-${name}"/></svg>`;

  /* Datos ----------------------------------------------------------------- */
  const EXP = [
    { id: 'snowboard', n: 1, name: 'Snowboard', place: 'Cerro Catedral', score: '9.6', img: 'ph-snowboard.webp', thumb: 'ph-snowboard.webp' },
    { id: 'parapente', n: 2, name: 'Parapente', place: 'Cerro Otto', score: '9.5', img: 'ph-parapente.webp', thumb: 'ph-parapente.webp' },
    { id: 'kayak', n: 3, name: 'Kayak', place: 'Lago Nahuel Huapi', score: '9.3', img: 'ph-kayak.webp', thumb: 'ph-kayak.webp' }
  ];
  const SEASONS = {
    invierno:  { label: 'Invierno',  sub: 'Nieve y esquí',       img: 'se-invierno.webp',  de: 'este invierno',  meses: 'Junio a septiembre', quick: ['Nieve y esquí', 'Chocolaterías', 'Cerca de mí', 'Con chicos'],
                 sky: ['#FABF73', '#D98C8C', '#404D85'], m: ['#6E6A99', '#4A4A78', '#333D66'], sun: '#FDE38F',
                 recos: [['Cerro Catedral', 'Esquí y snowboard', '9.6', 'th-catedral.webp'], ['Cabañas Aikén', 'Alojamiento con hogar a leña', '9.3', 'th-aiken.webp']] },
    primavera: { label: 'Primavera', sub: 'Flores y trekking',   img: 'se-primavera.webp', de: 'esta primavera', meses: 'Septiembre a diciembre', quick: ['Trekking', 'Parapente', 'Cerca de mí', 'Casas de té'],
                 sky: ['#BFE3A6', '#E3F0C9', '#4F8F6B'], m: ['#86BA70', '#5E9B62', '#3F7A55'], sun: '#FFD3DF',
                 recos: [['Parapente', 'Cerro Otto', '9.5', 'ph-parapente.webp'], ['Villa Tacul', 'Circuito Chico', '9.4', 'th-tacul.webp']] },
    verano:    { label: 'Verano',    sub: 'Playas y kayak',      img: 'se-verano.webp',    de: 'este verano',    meses: 'Diciembre a marzo', quick: ['Playas', 'Kayak', 'Cerca de mí', 'Cervecerías'],
                 sky: ['#7CCBE6', '#CDEBF3', '#2E7A9D'], m: ['#5AA9C6', '#3F8DAE', '#2C6F8E'], sun: '#FDE38F',
                 recos: [['Kayak', 'Lago Nahuel Huapi', '9.3', 'ph-kayak.webp'], ['Villa Tacul', 'Lagos y playas', '9.4', 'th-tacul.webp']] },
    otono:     { label: 'Otoño',     sub: 'Bosques color fuego', img: 'se-otono.webp',                de: 'este otoño',     meses: 'Marzo a junio', quick: ['Lengas en otoño', 'Senderismo', 'Cerca de mí', 'Chocolaterías'],
                 sky: ['#F3C27A', '#E9A26B', '#7A4634'], m: ['#C97C4A', '#A45E3C', '#7B4330'], sun: '#FFE9B8',
                 recos: [['Valle del Challhuaco', 'Caminata entre lengas', '9.4', 'th-challhuaco.webp'], ['Circuito Chico', 'Miradores y bosques de otoño', '9.3', 'th-circuito.webp']] }
  };
  const PLACES = [
    { x: 78,  y: 170, name: 'Villa Tacul', score: '9.4', cat: 'Lagos y Playas', img: 'th-tacul.webp', text: 'Se ubica en el km 29 del Circuito Chico. Rodeada de bosques, ideal para pasar el día.' },
    { x: 175, y: 340, name: 'Playa del Centro', score: '9.1', cat: 'Lagos y Playas', img: 'th-playa.webp', text: 'A pasos del Centro Cívico, sobre el Nahuel Huapi. La más cercana para una tarde corta.' },
    { x: 310, y: 420, name: 'Cerro Runge', score: '9.0', cat: 'Cerros', img: 'th-runge.webp', text: 'Mirador natural sobre la ciudad y el lago, con sendero de baja dificultad.' }
  ];
  const PINS = [[70, 40], [40, 250], [255, 330], [230, 410], [355, 400], [340, 480]];

  /* Estado ---------------------------------------------------------------- */
  const newSearch = () => ({ mode: 'steps', open: 'where', where: '', season: '', dur: '', what: new Set(), adults: 2, kids: 0, babies: 0, pet: false, nocar: false, text: '', listening: false, heard: '' });
  const state = { season: 'invierno', saved: new Set(), place: 0, search: newSearch() };

  /* Buscador: destinos según las fases y categorías del sitio actual -------- */
  const DESTS = [['near', 'Cerca de mí', 'Usar mi ubicación', ''], ['pin', 'Bariloche', 'Circuito Chico y Cerro Catedral', ''], ['pin', 'Villa La Angostura', 'Corredor de los Lagos', 'Fase 2'], ['pin', 'San Martín de los Andes', 'Ruta de los 7 Lagos', 'Fase 2'], ['pin', 'El Bolsón', 'Corredor de los Lagos', 'Fase 2']];
  const DURS = ['Un finde', 'Finde largo', 'Semana'];
  const WHAT = [['Experiencias', ['Actividades', 'Aventura', 'Cultura', 'Temporadas', 'Vida nocturna']], ['Alojamiento', ['Hotel', 'Apart hotel', 'Hostel', 'Camping', 'Casa o depto', 'Refugio']], ['Gastronomía', ['Restaurantes', 'Cervecerías', 'Chocolaterías', 'Casas de té']]];
  const plural = (n, a, b) => n + ' ' + (n === 1 ? a : b);
  const whoText = (q) => [plural(q.adults, 'adulto', 'adultos'), q.kids ? plural(q.kids, 'niño', 'niños') : '', q.babies ? plural(q.babies, 'bebé', 'bebés') : ''].filter(Boolean).join(', ');

  /* Texto libre → filtros. Reglas locales que ocupan el lugar del servicio de IA. */
  function parse(text) {
    const t = ' ' + text.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '') + ' ';
    const has = (...w) => w.some((x) => t.includes(x));
    const out = [];
    if (t.trim().length < 6) return out;
    out.push(['Dónde', 'Bariloche']);
    const when = [];
    const se = Object.keys(SEASONS).find((k) => t.includes(k)); if (se) when.push(SEASONS[se].label);
    if (has('finde largo', 'fin de semana largo')) when.push('Finde largo'); else if (has('finde', 'fin de semana')) when.push('Un finde'); else if (has('semana')) when.push('Semana');
    if (has('sabado')) when.push('Este sábado'); else if (has('domingo')) when.push('Este domingo'); else if (has(' hoy')) when.push('Hoy');
    if (when.length) out.push(['Cuándo', when.join(' · ')]);
    const kids = has('dos chicos', '2 chicos', 'dos ninos', '2 ninos') ? 2 : has('chicos', 'ninos', 'hijos') ? 1 : 0;
    const adults = has('somos dos', 'somos 2', 'en pareja', 'los dos') ? 2 : has('solo ', 'sola ') ? 1 : has('somos cuatro', 'somos 4') ? 4 : kids ? 2 : 0;
    if (adults) out.push(['Quiénes', whoText({ adults, kids: kids === 2 ? 2 : 0, babies: 0 })]);
    const how = []; if (has('sin auto')) how.push('Sin auto'); if (has('mascota', 'perro')) how.push('Con mascota'); if (how.length) out.push(['Cómo', how.join(', ')]);
    const what = [['kayak', 'Kayak'], ['esqui', 'Nieve y esquí'], ['snowboard', 'Snowboard'], ['nieve', 'Nieve y esquí'], ['chocolate', 'Chocolaterías'], ['cervez', 'Cervecerías'], ['trekking', 'Trekking'], ['parapente', 'Parapente'], ['lluvia', 'Bajo techo'], ['tranquilo', 'Paseos tranquilos'], ['comer', 'Gastronomía']].filter(([k]) => t.includes(k)).map(([, v]) => v);
    if (!what.length && kids) what.push('Para chicos');
    if (what.length) out.push(['Qué', [...new Set(what)].join(', ')]);
    return out;
  }
  const listeners = [];
  const A = (window.__base || '') + 'assets/';

  /* Componentes ----------------------------------------------------------- */
  const saveBtn = (id) => `<button class="v-save ${state.saved.has(id) ? 'is-on' : ''}" data-c="SaveBadge" data-act="save" data-id="${id}" aria-pressed="${state.saved.has(id)}" aria-label="Guardar en Mi lista">${I('bookmark')}</button>`;
  const count = () => `<i class="v-count ${state.saved.size ? 'is-on' : ''}">${state.saved.size || ''}</i>`;
  const tabbar = (on) => `
    <nav class="v-tabbar" data-c="TabBar">
      ${[['home', 'compass', 'Explorar'], ['map', 'pin', 'Cerca'], ['wish', 'bookmark', 'Mi lista'], ['trip', 'briefcase', 'Mi viaje']].map(([s, ic, l]) =>
        `<button class="v-tab ${on === s ? 'is-on' : ''}" data-act="go" data-to="${s}"><span class="v-iconbtn">${I(ic)}${s === 'wish' ? count() : ''}</span>${l}</button>`).join('')}
    </nav>`;
  const chip = (t, on, attrs = '') => `<button class="v-opt ${on ? 'is-on' : ''}" data-c="OptionChip" ${attrs} aria-pressed="${!!on}">${t}</button>`;
  const compact = ([name, sub, score, img], extra = '') => `
    <button class="v-compact" data-c="CompactCard" ${extra}>
      <img src="${A + img}" alt="" loading="lazy">
      <div><p class="t-title">${name}</p><p class="t-caption c-2">${sub}</p><span class="v-rating" data-c="RatingBadge">${I('star', 'ic--fill')}${score}</span></div>
      ${I('chevron-right')}
    </button>`;

  const rank = (e) => `
            <article class="v-rank" data-c="RankingCard">
              <button class="v-rank__img" data-act="detail" data-id="${e.id}" style="display:block;width:100%" aria-label="Ver ${e.name}"><img src="${A + e.img}" alt="${e.name} en ${e.place}" loading="lazy"><span class="v-rank__badge">#${e.n}</span></button>
              ${saveBtn(e.id)}
              <div class="v-rank__info"><div><p class="t-h2">${e.name}</p><p class="t-caption c-3">${e.place}</p></div><div><span class="v-rating v-rating--blue" data-c="RatingBadge">${I('star', 'ic--fill')}${e.score}</span><span class="t-overline c-3">Puntos</span></div></div>
            </article>`;
  const season = (k) => { const v = SEASONS[k]; return `<button class="v-season v-season--${k} ${k === state.season ? 'is-on' : ''}" data-c="SeasonCard" data-act="season" data-season="${k}" aria-pressed="${k === state.season}">${v.img ? `<img src="${A + v.img}" alt="" loading="lazy">` : ''}<b>${v.label}</b><small>${v.sub}</small><i>${I('check')}</i></button>`; };

  /* Resultados: catálogo de muestra. Cada lugar declara con qué pedidos coincide. */
  const POOL = [
    { n: 'Kayak en el Nahuel Huapi', s: 'Salida guiada · 3 horas', sc: '9.3', img: 'ph-kayak.webp', tag: 'Para dos', k: ['kayak', 'playa', 'verano'] },
    { n: 'Villa Tacul', s: 'Playa y bosque · Circuito Chico', sc: '9.4', img: 'th-tacul.webp', tag: 'Aguas calmas', k: ['kayak', 'playa', 'verano', 'tranquilo'] },
    { n: 'Escuela de nieve para chicos', s: 'Cerro Catedral · desde 4 años', sc: '9.5', img: 'th-catedral.webp', tag: 'Para chicos', k: ['chicos', 'ninos', 'nieve'] },
    { n: 'Snowboard en Cerro Catedral', s: 'Clases y alquiler de equipo', sc: '9.6', img: 'ph-snowboard.webp', tag: 'Aventura', k: ['aventura', 'nieve', 'invierno', 'snowboard', 'esqui'] },
    { n: 'Paseo de chocolaterías', s: 'Calle Mitre · a pie desde el centro', sc: '9.2', img: 'se-invierno.webp', tag: 'Sin auto', k: ['chocolater', 'sin auto', 'bajo techo', 'invierno'] },
    { n: 'Parapente en Cerro Otto', s: 'Vuelo biplaza · 20 minutos', sc: '9.5', img: 'ph-parapente.webp', tag: 'Aventura', k: ['aventura', 'parapente', 'primavera'] },
    { n: 'Valle del Challhuaco', s: 'Caminata entre lengas', sc: '9.4', img: 'th-challhuaco.webp', tag: 'Senderismo', k: ['otono', 'trekking', 'tranquilo'] },
    { n: 'Circuito Chico', s: 'Miradores y bosques', sc: '9.3', img: 'th-circuito.webp', tag: 'Paseo', k: ['otono', 'primavera', 'tranquilo'] },
    { n: 'Cabañas Aikén', s: 'Alojamiento con hogar a leña', sc: '9.3', img: 'th-aiken.webp', tag: 'Alojamiento', k: ['hotel', 'casa', 'refugio'] }
  ];
  const plain = (t) => t.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  // Los tres modos terminan en la misma lista de filtros.
  const filters = (q) => q.mode === 'ia' ? parse(q.text)
    : [['Dónde', q.where || 'Bariloche'], ['Cuándo', [q.season && SEASONS[q.season].label, q.dur].filter(Boolean).join(' · ')], ['Qué', [...q.what].join(', ')], ['Quiénes', whoText(q)], ['Cómo', [q.nocar && 'Sin auto', q.pet && 'Con mascota'].filter(Boolean).join(', ')]].filter(([, v]) => v);
  const matches = (fs) => {
    const blob = plain(fs.map(([, v]) => v).join(' '));
    const ranked = POOL.map((p) => [p.k.filter((k) => blob.includes(k)).length, p]).filter(([n]) => n).sort((a, b) => b[0] - a[0]).map(([, p]) => p);
    return (ranked.length ? ranked : POOL).slice(0, 4);
  };

  /* Fotos que rota el teléfono del hero. Sin `season`, el texto queda neutro. */
  const SLIDES = [{ img: 'hero-invierno.webp', season: 'invierno' }, { img: 'hero-r-lupinos.webp', season: 'primavera' }, { img: 'hero-r-muelle.webp', season: 'verano' }, { img: 'hero-r-arrayanes.webp' }];
  const slideText = (x) => x.season ? ['Bariloche · ' + SEASONS[x.season].label, 'Encontrá qué hacer en Bariloche ' + SEASONS[x.season].de + '.'] : ['Bariloche', 'Encontrá qué hacer en Bariloche.'];

  /* Pantallas ------------------------------------------------------------- */
  const screens = {
    home(arg, el) {
      // Con data-slides el teléfono no sigue la estación elegida: rota sus propias fotos.
      const rot = el && el.hasAttribute('data-slides') ? SLIDES : null;
      const si = rot ? (+el.dataset.slide || 0) % rot.length : 0;
      const sk = rot ? (rot[si].season || 'primavera') : state.season;
      const s = SEASONS[sk];
      return `
      <div class="screen s-home s-home--${sk}">
        <div class="screen__scroll">
          <header class="s-home__hero">${rot ? rot.map((x, i) => `<i class="s-home__ph ${i === si ? 'is-on' : ''}" style="background-image:url(${A + x.img})"></i>`).join('') : ''}
            <div class="s-home__top"><b>Viví el Sur</b><span class="s-home__ctx">${rot ? slideText(rot[si])[0] : 'Bariloche · ' + s.label}</span></div>
            <div class="s-home__copy"><h3>El sur cambia<br>con cada estación.</h3><p>${rot ? slideText(rot[si])[1] : 'Encontrá qué hacer en Bariloche ' + s.de + '.'}</p></div>
            <div class="v-pill" data-c="SearchPill">
              <button class="v-pill__main" data-act="search">${I('search')}<span><b>¿Qué querés hacer?</b><small>Dónde · Cuándo · Quiénes</small></span></button>
              <button class="v-pill__mic" data-act="voice" aria-label="Buscar por voz">${I('mic')}</button>
            </div>
            <div class="s-home__quick">${s.quick.map((q) => `<button data-act="search">${q}</button>`).join('')}</div>
          </header>
          <div class="s-home__head"><h3 class="t-h1">Bariloche, estación por estación</h3><p class="t-body c-2">Cada época del año, una forma distinta de vivirla</p></div>
          <div class="s-home__seasons">
            ${Object.keys(SEASONS).map(season).join('')}
          </div>
          <div class="s-home__head s-home__head--row"><h3 class="t-h1">Recomendado para ${s.de}</h3><button class="t-label" data-act="go" data-to="top">Ver ranking</button></div>
          <div class="s-home__recos">${s.recos.map(r => compact(r)).join('')}</div>
        </div>
        ${tabbar('home')}
      </div>`;
    },

    search() {
      const q = state.search, ia = q.mode === 'ia';
      const sum = { where: q.where || 'Elegí un destino', when: [q.season && SEASONS[q.season].label, q.dur].filter(Boolean).join(' · ') || 'Estación o fechas', what: [...q.what].join(', ') || 'Cualquier plan', who: whoText(q) + (q.nocar ? ' · sin auto' : '') };
      const card = (k, label, title, body) => q.open === k
        ? `<section class="v-q is-open" data-c="QuestionCard" data-k="${k}"><h3>${title}</h3>${body}</section>`
        : `<button class="v-q" data-c="QuestionCard" data-act="sopen" data-k="${k}"><span>${label}</span><b>${sum[k]}</b></button>`;
      const where = `<div class="v-dest">${DESTS.map(([ic, n, d, tag]) => `<button class="${q.where === n ? 'is-on' : ''}" ${tag ? 'disabled' : `data-act="swhere" data-v="${n}"`}><i>${I(ic)}</i><span><b>${n}</b><small>${d}</small></span>${tag ? `<em>${tag}</em>` : ''}</button>`).join('')}</div><p class="v-q__note">Después, toda la Patagonia: El Calafate, Ushuaia, Puerto Madryn y Carretera Austral.</p>`;
      const when = `<div class="v-segm"><span class="is-on">Por estación</span><span>Fechas</span><span>Flexible</span></div>
        <div class="v-seas">${Object.keys(SEASONS).map((k) => `<button class="${q.season === k ? 'is-on' : ''}" data-act="sseason" data-v="${k}"><b>${SEASONS[k].label}</b><span>${SEASONS[k].sub}</span><small>${SEASONS[k].meses}</small></button>`).join('')}</div>
        <p class="v-q__label">¿Cuánto tiempo?</p><div class="v-opts">${DURS.map((d) => chip(d, q.dur === d, `data-act="sdur" data-v="${d}"`)).join('')}</div>`;
      const what = WHAT.map(([g, items]) => `<p class="v-q__label">${g}</p><div class="v-opts">${items.map((t) => chip(t, q.what.has(t), `data-act="swhat" data-v="${t}"`)).join('')}</div>`).join('');
      const who = [['adults', 'Adultos', '13 años o más'], ['kids', 'Niños', 'De 2 a 12 años'], ['babies', 'Bebés', 'Menos de 2 años']].map(([k, l, d]) => `<div class="v-step" data-c="Stepper"><span><b>${l}</b><small>${d}</small></span><div><button data-act="sstep" data-k="${k}" data-d="-1" aria-label="Menos ${l}">${I('minus')}</button><output>${q[k]}</output><button data-act="sstep" data-k="${k}" data-d="1" aria-label="Más ${l}">${I('plus')}</button></div></div>`).join('')
        + `<div class="v-opts">${chip('Con mascota', q.pet, 'data-act="sflag" data-k="pet"')}${chip('Sin auto', q.nocar, 'data-act="sflag" data-k="nocar"')}</div>`;
      const found = parse(q.listening ? q.heard : q.text);
      const under = found.length ? `<section class="v-under" data-c="Understood"><p class="v-under__t">${I('spark')}Así lo entendí</p><div>${found.map(([k, v]) => `<span><small>${k}</small><b>${v}</b>${I('close')}</span>`).join('')}</div><p class="v-q__note">Tocá un dato para corregirlo. Nada se busca hasta que confirmes.</p></section>` : '';
      const free = q.listening
        ? `<section class="v-listen" data-c="VoiceInput"><p>Escuchando</p><div class="v-wave">${'<i></i>'.repeat(17)}</div><blockquote>${q.heard ? '“' + q.heard + '…”' : 'Hablá como se lo contarías a alguien'}</blockquote></section>${under}`
        : `<section class="v-free" data-c="FreeText">${I('spark')}<textarea rows="3" placeholder="Contá qué querés hacer, con tus palabras" aria-label="Contá qué querés hacer">${q.text}</textarea></section>${under}
           ${q.text ? '' : `<div class="v-sugg"><p class="v-q__label">Probá con</p>${['Quiero hacer kayak el sábado, somos dos', 'Algo tranquilo para un día de lluvia', 'Un finde largo de invierno con dos chicos, sin auto'].map((t) => `<button data-act="ssugg">${t}</button>`).join('')}</div>`}`;
      return `
      <div class="screen s-search">
        <header class="s-search__top">
          <button class="v-round" data-act="go" data-to="home" aria-label="Cerrar">${I('close')}</button>
          <div class="v-mode" data-c="ModeToggle"><button class="${ia ? '' : 'is-on'}" data-act="smode" data-v="steps">Paso a paso</button><button class="${ia ? 'is-on' : ''}" data-act="smode" data-v="ia">${I('spark')}Con tus palabras</button></div>
        </header>
        <div class="screen__scroll s-search__body">
          ${ia ? free : card('where', 'Dónde', '¿Dónde?', where) + card('when', 'Cuándo', '¿Cuándo?', when) + card('what', 'Qué', '¿Qué querés hacer?', what) + card('who', 'Quiénes', '¿Quiénes viajan?', who)}
        </div>
        <footer class="s-search__bar">
          ${q.listening ? `<button class="s-search__link" data-act="smode" data-v="ia">Cancelar</button><button class="v-cta" data-act="sdone">${I('stop')}Listo</button>`
            : `${ia ? `<button class="v-round v-round--lg" data-act="voice" aria-label="Dictar">${I('mic')}</button>` : `<button class="s-search__link" data-act="sclear">Borrar todo</button>`}<button class="v-cta" data-act="sgo">${I('search')}Buscar</button>`}
        </footer>
      </div>`;
    },

    results() {
      const q = state.search, fs = filters(q), list = matches(fs);
      const where = (fs.find(([k]) => k === 'Dónde') || [, 'Bariloche'])[1], when = (fs.find(([k]) => k === 'Cuándo') || [, ''])[1];
      return `
      <div class="screen s-res">
        <header class="s-res__top">
          <button class="v-round" data-act="go" data-to="search" aria-label="Volver al buscador">${I('chevron-left')}</button>
          <button class="s-res__sum" data-c="QuerySummary" data-act="go" data-to="search">${I('search')}<span><b>${where}</b><small>${[when, fs.length + ' filtros'].filter(Boolean).join(' · ')}</small></span>${I('filter')}</button>
        </header>
        <div class="s-res__chips">${fs.filter(([k]) => k !== 'Dónde').map(([, v]) => v.split(/ · |, /).map((x) => `<span>${x}</span>`).join('')).join('')}</div>
        <div class="screen__scroll">
          <p class="s-res__count"><b>${list.length} lugares</b> coinciden con tu búsqueda</p>
          <div class="s-res__list">
            ${list.map((p, i) => `<article class="v-res" data-c="ResultCard" style="--i:${i}"><div class="v-res__img"><img src="${A + p.img}" alt="${p.n}" loading="lazy"><span>${p.tag}</span></div><div class="v-res__info"><div><p class="t-h2">${p.n}</p><p class="t-caption c-3">${p.s}</p></div><span class="v-rating v-rating--blue" data-c="RatingBadge">${I('star', 'ic--fill')}${p.sc}</span></div></article>`).join('')}
          </div>
        </div>
        ${tabbar('home')}
      </div>`;
    },

    trip() {
      return `
      <div class="screen s-wish">
        <header class="v-topbar" data-c="TopBar"><span class="v-iconbtn"></span><b class="t-h2">Mi viaje</b><span class="v-iconbtn"></span></header>
        <div class="screen__scroll"><div class="s-wish__empty"><span>${I('briefcase')}</span><p class="t-h2">Tu itinerario, día por día</p><p class="t-caption c-2">Todavía no está en esta versión. Mientras tanto, guardá experiencias en Mi lista.</p><button class="v-btn" data-act="go" data-to="wish">Ir a Mi lista</button></div></div>
        ${tabbar('trip')}
      </div>`;
    },

    top() {
      return `
      <div class="screen s-top">
        <header class="v-topbar" data-c="TopBar">
          <button class="v-iconbtn" data-act="go" data-to="home" aria-label="Volver a Explorar">${I('chevron-left')}</button>
          <span class="v-topbar__logo"><i></i><b>Viví el Sur</b></span>
          <span class="v-topbar__actions"><button class="v-iconbtn" data-act="search" aria-label="Buscar">${I('search')}</button><button class="v-iconbtn" data-act="go" data-to="wish" aria-label="Mi lista">${I('bookmark')}${count()}</button></span>
        </header>
        <div class="screen__scroll">
          <div class="s-top__head"><h3 class="t-h1">TOP 10 EXPERIENCIAS</h3><p class="t-caption c-3">Ranking elegido por los usuarios</p></div>
          <div class="s-top__list">
            ${EXP.map(rank).join('')}
          </div>
        </div>
        ${tabbar('home')}
      </div>`;
    },

    detail(id) {
      const e = EXP.find(x => x.id === id) || EXP[0];
      const on = state.saved.has(e.id);
      return `
      <div class="screen s-det">
        <header class="v-topbar" data-c="TopBar"><button class="v-iconbtn" data-act="go" data-to="top" aria-label="Volver">${I('chevron-left')}</button><b class="t-h2">${e.name}</b><span class="v-iconbtn">${I('map')}</span></header>
        <div class="screen__scroll">
          <div class="s-det__img"><img src="${A + (e.id === 'snowboard' ? 'ph-detalle.webp' : e.img)}" alt="${e.name}"></div>
          <div class="s-det__dots"><i></i><i></i><i></i></div>
          <div class="s-det__body">
            <div><p class="s-det__over">EXPERIENCIA · AVENTURA</p><h3 class="t-display">${e.name}</h3><p class="t-body c-3">${e.place}</p></div>
            <div class="s-det__row"><span class="s-det__ok">Excelente</span><span class="s-det__stars">${I('star', 'ic--fill').repeat(5)}</span><span class="t-caption c-3">2.657 opiniones</span></div>
            <div class="s-det__tags"><span>Dificultad: Media</span><span>Duración: 6hs</span></div>
            <p class="t-body" style="color:#404040">El equipo básico para practicarlo es la tabla, las fijaciones y las botas. Además el cerro cuenta con un área especialmente creada para que esquiadores y snowbordistas se animen a más.</p>
            <hr>
            <div class="s-det__acts">
              <button><span>${I('map')}</span>Mapa</button><button><span>${I('share')}</span>Compartir</button>
              <button class="${on ? 'is-on' : ''}" data-act="save" data-id="${e.id}" aria-pressed="${on}"><span>${I('bookmark')}</span>${on ? 'Guardado' : 'Guardar'}</button>
            </div>
            <hr>
            <h4 class="t-h2">Lo que dicen los viajeros frecuentes</h4>
            <div class="s-det__rev"><span class="v-avatar" data-c="Avatar">MP</span><div><p class="t-title">Martín P. <em>Viajero frecuente</em></p><p class="t-caption c-3">"La mejor bajada que hice en la Patagonia. Personal muy atento."</p></div></div>
            <div class="s-det__rev"><span class="v-avatar" style="background:#8CA6E0">CL</span><div><p class="t-title">Camila L. <em>Viajero frecuente</em></p><p class="t-caption c-3">"Alquilamos el equipo ahí mismo, todo muy ordenado."</p></div></div>
          </div>
        </div>
        <footer class="s-det__bar"><div><p class="t-overline c-3">Desde</p><p class="s-det__price"><b class="t-h1">$45.000</b><span class="t-caption c-3">/ persona</span></p></div><button class="v-btn v-btn--lg" data-c="Button" style="border-radius:8px">Reservar</button></footer>
      </div>`;
    },

    map() {
      const p = PLACES[state.place];
      return `
      <div class="screen s-map">
        <svg viewBox="0 0 390 844" aria-hidden="true">
          <path d="M290 40c-70 10-130 60-145 140-12 70 40 100 70 150 30 55 90 60 175 45V40z" fill="#92C6DE"/>
          <g fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round" stroke-dasharray="1 11"><path d="M0 418c50-6 100 2 150 20s110 8 160-2 60-4 80 2"/><path d="M148 440c-10 60-26 110-24 404"/><path d="M262 470c8 80 6 200 2 374"/></g>
          <g fill="#8FAE7C">${[[40, 470], [70, 520], [30, 560], [90, 600], [140, 640], [200, 700], [260, 650], [320, 600], [340, 520], [300, 470], [60, 700], [110, 760], [180, 780], [240, 760], [310, 720], [350, 650], [20, 640], [160, 540], [220, 590], [280, 540]].map(([x, y]) => `<circle cx="${x + 5}" cy="${y + 5}" r="5"/>`).join('')}</g>
        </svg>
        ${PINS.map(([x, y]) => `<span class="s-map__pin" style="left:${x}px;top:${y}px;pointer-events:none;opacity:.8"></span>`).join('')}
        ${PLACES.map((q, i) => `<button class="s-map__pin ${i === state.place ? 'is-on' : ''}" style="left:${q.x + 9}px;top:${q.y + 9}px" data-act="place" data-i="${i}" aria-label="${q.name}"></button>`).join('')}
        <div class="s-map__top"><span class="s-map__back">${I('chevron-left')}</span><span class="s-map__search">${I('search')}Buscar en el mapa</span></div>
        <div class="s-map__chips">${['Cerros', 'Lagos y Playas', 'Paseos', 'Circuitos'].map(c => `<button class="v-chip v-chip--float ${c === p.cat ? 'is-on' : ''}" data-c="Chip" data-act="pick">${c}</button>`).join('')}</div>
        <span class="s-map__off">${I('download')}Mapa guardado · sin conexión</span>
        <span class="s-map__toggle">${I('hamburger')}Ver como lista</span>
        <div class="s-map__place" data-c="PlaceCard">
          <div><img src="${A + p.img}" alt=""><div><p class="t-h2">${p.name}</p><p class="s-map__meta"><span class="v-rating">${I('star', 'ic--fill')}${p.score}</span><span class="c-3">·</span><span class="t-caption c-2">${p.cat}</span></p><p class="t-caption c-2">${p.text}</p></div></div>
          <button class="v-btn" data-c="Button">Ver más ${I('chevron-right')}</button>
        </div>
      </div>`;
    },

    wish() {
      const items = EXP.filter(e => state.saved.has(e.id));
      return `
      <div class="screen s-wish">
        <header class="v-topbar" data-c="TopBar"><button class="v-iconbtn" data-act="go" data-to="top" aria-label="Volver">${I('chevron-left')}</button><b class="t-h2">Mi lista</b><span class="v-iconbtn"></span></header>
        <div class="screen__scroll">
          <div class="s-wish__head"><h3 class="t-h1">Guardados para tu viaje</h3><p class="t-caption c-3">${items.length ? items.length + (items.length === 1 ? ' experiencia' : ' experiencias') : 'Todavía no guardaste nada'}</p></div>
          ${items.length ? `<div class="s-wish__list">${items.map(e => `<div class="s-wish__item">${compact([e.name, e.place, e.score, e.thumb], `data-act="detail" data-id="${e.id}"`)}<button class="s-wish__rm" data-act="save" data-id="${e.id}" aria-label="Quitar ${e.name}">${I('bookmark')}</button></div>`).join('')}</div>`
            : `<div class="s-wish__empty"><span>${I('bookmark')}</span><p class="t-h2">Tu lista está vacía</p><p class="t-caption c-2">Tocá el marcador en cualquier experiencia para guardarla acá.</p><button class="v-btn" data-act="go" data-to="top">Ver experiencias</button></div>`}
        </div>
        ${tabbar('wish')}
      </div>`;
    }
  };

  /* Render ---------------------------------------------------------------- */
  function render(el) {
    const [name, arg] = (el.dataset.screen || 'home').split(':');
    const sc = el.querySelector('.screen__scroll');
    const keep = sc && el.dataset.rendered === el.dataset.screen ? sc.scrollTop : 0;
    const hs = el.querySelector('.s-home__seasons');
    const keepX = hs ? hs.scrollLeft : 0;
    el.innerHTML = (screens[name] || screens.home)(arg, el);
    el.dataset.rendered = el.dataset.screen;
    const ns = el.querySelector('.screen__scroll'); if (ns) ns.scrollTop = keep || (name === 'home' && el.dataset.scroll ? el.querySelector('.s-home__hero').offsetHeight - 36 : 0);
    const nh = el.querySelector('.s-home__seasons'); if (nh) nh.scrollLeft = keepX;
  }
  const renderSearch = () => document.querySelectorAll('.app[data-screen="search"]').forEach(render);
  function renderAll() { document.querySelectorAll('.app[data-screen]').forEach(render); listeners.forEach(fn => fn(state)); }

  /* Eventos --------------------------------------------------------------- */
  document.addEventListener('click', (ev) => {
    const b = ev.target.closest('[data-act]'); if (!b) return;
    const host = b.closest('.app[data-screen]');
    const act = b.dataset.act;
    if (act === 'season') { api.setSeason(b.dataset.season); }
    else if (act === 'save') { api.toggleSave(b.dataset.id); }
    else if (act === 'place') { state.place = +b.dataset.i; renderAll(); }
    else if (act[0] === 's' && act !== 'season' && act !== 'save' && act !== 'search') {
      const q = state.search, v = b.dataset.v, k = b.dataset.k;
      if (act === 'sopen') q.open = k;
      else if (act === 'swhere') { q.where = v; q.open = 'when'; }
      else if (act === 'sseason') { q.season = v; api.setSeason(v); return; }
      else if (act === 'sdur') { q.dur = q.dur === v ? '' : v; if (q.season && q.dur) q.open = 'what'; }
      else if (act === 'swhat') { q.what.has(v) ? q.what.delete(v) : q.what.add(v); }
      else if (act === 'sstep') { q[k] = Math.max(k === 'adults' ? 1 : 0, Math.min(9, q[k] + +b.dataset.d)); }
      else if (act === 'sflag') { q[k] = !q[k]; }
      else if (act === 'sclear') { state.search = newSearch(); }
      else if (act === 'smode') { q.mode = v; q.listening = false; api.stopVoice(); }
      else if (act === 'ssugg') { q.text = b.textContent; }
      else if (act === 'sdone') { api.stopVoice(); q.text = q.heard; q.listening = false; }
      else if (act === 'sgo') { api.stopVoice(); q.listening = false; if (host && host.hasAttribute('data-nav')) api.go(host, 'results'); return; }
      renderSearch();
    }
    else if (act === 'search' || act === 'voice') {
      if (!host || !host.hasAttribute('data-nav')) return;
      if (act === 'voice') api.listen(); else if (state.search.listening) { api.stopVoice(); state.search.listening = false; }
      api.go(host, 'search');
    }
    else if (act === 'pick') { b.parentElement.querySelectorAll('.is-on').forEach(x => x.classList.remove('is-on')); b.classList.add('is-on'); }
    else if (host && host.hasAttribute('data-nav')) {
      if (act === 'go') api.go(host, b.dataset.to);
      if (act === 'detail') api.go(host, 'detail:' + b.dataset.id);
    }
  });

  // El texto libre se actualiza sin volver a dibujar el campo, para no perder el foco
  document.addEventListener('input', (ev) => {
    const ta = ev.target.closest('.v-free textarea'); if (!ta) return;
    state.search.text = ta.value;
    document.querySelectorAll('.app[data-screen="search"]').forEach((h) => { if (!h.contains(ta)) render(h); });
    const body = ta.closest('.s-search__body'), tmp = document.createElement('div');
    tmp.innerHTML = screens.search();
    const fresh = [...tmp.querySelector('.s-search__body').children].filter((c) => !c.classList.contains('v-free'));
    const sig = fresh.map((c) => c.outerHTML).join('');
    if (body.dataset.sig === sig) return;
    body.dataset.sig = sig;
    [...body.children].forEach((c) => { if (!c.classList.contains('v-free')) c.remove(); });
    fresh.forEach((c) => body.appendChild(c));
  });

  let voiceTimer = 0;
  const VOICE_SAMPLE = 'Quiero hacer kayak el sábado, somos dos';
  const api = {
    search: { reset() { state.search = newSearch(); renderSearch(); }, set(patch) { Object.assign(state.search, patch); renderSearch(); }, parse },
    // La voz está simulada: "escucha" una frase de ejemplo palabra por palabra.
    listen(phrase = VOICE_SAMPLE, speed = 170) {
      api.stopVoice();
      const q = state.search, words = phrase.split(' '); let i = 0;
      Object.assign(q, { mode: 'ia', listening: true, heard: '', text: '' }); renderSearch();
      voiceTimer = setInterval(() => { q.heard = words.slice(0, ++i).join(' '); renderSearch(); if (i >= words.length) api.stopVoice(); }, speed);
    },
    stopVoice() { clearInterval(voiceTimer); voiceTimer = 0; },
    slides: SLIDES,
    // Pasa a la foto i con fundido, sin redibujar la pantalla.
    slide(el, i) {
      i = ((i % SLIDES.length) + SLIDES.length) % SLIDES.length; el.dataset.slide = i;
      const ph = el.querySelectorAll('.s-home__ph'); if (!ph.length) return;
      ph.forEach((n, k) => n.classList.toggle('is-on', k === i));
      const [ctx, sub] = slideText(SLIDES[i]);
      el.querySelector('.s-home__ctx').textContent = ctx; el.querySelector('.s-home__copy p').textContent = sub;
      el.querySelectorAll('.s-home__quick button').forEach((b, k) => { b.textContent = SEASONS[SLIDES[i].season || 'primavera'].quick[k]; });
    },
    state, SEASONS, EXP, render, renderAll, parts: { rank, season, compact, tabbar, icon: I },
    onChange(fn) { listeners.push(fn); },
    setSeason(s) { if (!SEASONS[s]) return; state.season = s; renderAll(); },
    toggleSave(id) { state.saved.has(id) ? state.saved.delete(id) : state.saved.add(id); renderAll(); },
    go(host, to) { host.dataset.screen = to; render(host); host.dispatchEvent(new CustomEvent('screenchange', { bubbles: true, detail: to })); }
  };
  window.Vivi = api;
  document.addEventListener('DOMContentLoaded', renderAll);
})();
