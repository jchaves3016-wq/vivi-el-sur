/* ==========================================================================
   Viví el Sur — interacciones de la página del caso
   ========================================================================== */
(function () {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const V = window.Vivi;

  /* Aparición al hacer scroll -------------------------------------------- */
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); } });
  }, { rootMargin: '0px 0px -8% 0px', threshold: .08 });
  // Las placas cargan en secuencia: se marcan al entrar y, al terminar, se liberan los retardos
  const pio = new IntersectionObserver((entries) => {
    entries.forEach((e) => { if (e.isIntersecting) { const t = e.target; t.classList.add('is-in'); pio.unobserve(t); setTimeout(() => t.classList.add('is-done'), 2400); } });
  }, { threshold: .22 });
  $$('.plate.rv').forEach((el) => pio.observe(el));
  $$('.rv:not(.plate)').forEach((el) => {
    const sibs = [...el.parentElement.children].filter((c) => c.classList.contains('rv'));
    el.style.setProperty('--d', Math.min(sibs.indexOf(el), 5) * 0.08 + 's');
    io.observe(el);
  });

  /* Frase que se enciende palabra por palabra ---------------------------- */
  const st = $('[data-words]');
  let words = [];
  if (st && !reduce) {
    st.innerHTML = st.textContent.trim().split(/\s+/).map((w) => `<span>${w}</span>`).join(' ');
    words = $$('span', st);
  }

  /* Parallax -------------------------------------------------------------- */
  const pars = $$('[data-par]').map((el) => ({ el, k: parseFloat(el.dataset.par), kx: parseFloat(el.dataset.parx) || 0 }));
  let ticking = false;
  function frame() {
    ticking = false;
    const vh = innerHeight;
    if (!reduce) {
      pars.forEach(({ el, k, kx }) => {
        const r = el.parentElement.getBoundingClientRect();
        if (r.bottom < -200 || r.top > vh + 200) return;
        const d = r.top + r.height / 2 - vh / 2;
        el.style.transform = `translate3d(${(d * kx).toFixed(1)}px, ${(d * k).toFixed(1)}px, 0)`;
      });
    }
    if (words.length) {
      const r = st.getBoundingClientRect();
      const p = Math.min(1, Math.max(0, (vh * 0.86 - r.top) / (r.height + vh * 0.36)));
      const n = Math.round(p * words.length);
      words.forEach((w, i) => w.classList.toggle('is-lit', i < n));
    }
  }
  addEventListener('scroll', () => { if (!ticking) { ticking = true; requestAnimationFrame(frame); } }, { passive: true });
  addEventListener('resize', frame);
  frame();

  /* Comparador 2018 / hoy ------------------------------------------------- */
  const cmp = $('#cmp');
  if (cmp) {
    const ph = $('.cmp__ph', cmp), range = $('.cmp__range', cmp);
    const set = () => { ph.style.setProperty('--pos', range.value + '%'); ph.style.setProperty('--p', range.value / 100); };
    range.addEventListener('input', set); set();
  }

  /* Movimiento con el cursor: capas con profundidad y teléfono en 3D ------- */
  function tilt(host) {
    if (!host || reduce) return;
    $$('[data-depth]', host).forEach((el) => el.style.setProperty('--dp', el.dataset.depth));
    let tx = 0, ty = 0, x = 0, y = 0, raf = 0;
    const loop = () => {
      x += (tx - x) * 0.14; y += (ty - y) * 0.14;
      host.style.setProperty('--mx', x.toFixed(3)); host.style.setProperty('--my', y.toFixed(3));
      raf = Math.abs(tx - x) > 0.002 || Math.abs(ty - y) > 0.002 ? requestAnimationFrame(loop) : 0;
    };
    const kick = () => { if (!raf) raf = requestAnimationFrame(loop); };
    host.addEventListener('pointermove', (e) => {
      if (e.pointerType === 'touch') return;
      const r = host.getBoundingClientRect();
      tx = ((e.clientX - r.left) / r.width - 0.5) * 2; ty = ((e.clientY - r.top) / r.height - 0.5) * 2; kick();
    });
    host.addEventListener('pointerleave', () => { tx = ty = 0; kick(); });
  }
  tilt($('#hero'));

  /* Hero: el teléfono rota sus propias fotos y no sigue la estación elegida más abajo */
  const heroApp = $('#heroApp');
  if (heroApp && !reduce) setInterval(() => { if (!document.hidden && heroApp.getBoundingClientRect().bottom > 0) V.slide(heroApp, (+heroApp.dataset.slide || 0) + 1); }, 4200);

  /* Decisiones: cada placa tiene su escena y su teléfono ------------------- */
  const A = 'assets/';
  $$('.stage').forEach(tilt);

  // 01 · Partículas de la estación: nieve, pétalos, destellos u hojas según el CSS
  const stageSeason = $('#stageSeason');
  const fx = $('.sc__fx', stageSeason || document);
  if (fx && !reduce) {
    const r = (a, b) => (a + Math.random() * (b - a)).toFixed(2);
    fx.innerHTML = Array.from({ length: 26 }, () => `<i style="--x:${r(0, 100)}%;--y:${r(52, 96)}%;--z:${r(4, 9)}px;--dx:${r(-70, 70)}px;--r:${r(-260, 260)}deg;--du:${r(7, 15)}s;--dl:-${r(0, 15)}s"></i>`).join('');
  }

  // 03 · La foto: el fondo toma la imagen de la tarjeta bajo el cursor
  const stagePhoto = $('#stagePhoto'), tourApp = $('#tourApp');
  if (stagePhoto) {
    const layers = [$('#photoBg'), $('#photoBg2')];
    let cur = 0, curImg = 'ph-snowboard.webp';
    layers[0].classList.add('is-on');
    const setPhoto = (img) => {
      if (!img || img === curImg) return;
      curImg = img; cur = 1 - cur;
      layers[cur].style.backgroundImage = `url(${A + img})`;
      layers[cur].classList.add('is-on'); layers[1 - cur].classList.remove('is-on');
    };
    const expOf = (id) => V.EXP.find((e) => e.id === id);
    stagePhoto.dataset.view = 'top';
    tourApp.addEventListener('screenchange', (e) => {
      const [v, id] = String(e.detail).split(':');
      stagePhoto.dataset.view = v;
      if (v === 'detail') { const x = expOf(id); if (x) setPhoto(x.img); }
    });
    tourApp.addEventListener('pointerover', (e) => {
      const card = e.target.closest('.v-rank'); if (!card) return;
      const x = expOf(($('[data-id]', card) || {}).dataset?.id); if (x) setPhoto(x.img);
    });
    const fly = (from) => {
      const to = $('.v-tab[data-to="wish"] .v-iconbtn', tourApp); if (!to || reduce || !from.animate) return;
      const a = from.getBoundingClientRect(), b = to.getBoundingClientRect();
      const dot = document.body.appendChild(document.createElement('i')); dot.className = 'fly';
      const ax = a.right - 22, ay = a.top + a.height / 2, bx = b.left + b.width / 2, by = b.top + b.height / 2;
      dot.animate([
        { transform: `translate(${ax}px, ${ay}px) scale(1)`, opacity: 1 },
        { transform: `translate(${(ax + bx) / 2}px, ${Math.min(ay, by) - 50}px) scale(1.2)`, opacity: 1, offset: 0.5 },
        { transform: `translate(${bx}px, ${by}px) scale(.3)`, opacity: 0.2 }
      ], { duration: 650, easing: 'cubic-bezier(.4, 0, .2, 1)' }).onfinish = () => dot.remove();
    };
    $$('.glass', stagePhoto).forEach((c) => {
      const show = () => { const x = expOf(c.dataset.id); if (x) setPhoto(x.img); };
      c.addEventListener('pointerenter', show); c.addEventListener('focus', show);
      c.addEventListener('click', () => { const adding = !V.state.saved.has(c.dataset.id); V.toggleSave(c.dataset.id); if (adding) fly(c); });
    });
  }

  // 04 · Mapa sin señal
  const signal = $('#signal');
  if (signal) signal.addEventListener('click', () => {
    const off = signal.getAttribute('aria-pressed') !== 'true';
    signal.setAttribute('aria-pressed', off);
    $('span', signal).textContent = off ? 'Sin señal' : 'Con señal';
    $('#stageMap').classList.toggle('is-offline', off);
  });

  // 02 · El buscador: demo que corre sola en tres modos, termina en resultados y se puede tocar
  const sApp = $('#searchApp'), sStage = $('#stageSearch'), sModes = $('#searchModes');
  if (sApp) {
    const tapEl = sStage.appendChild(document.createElement('i')); tapEl.className = 'tap';
    const ORDER = ['voice', 'ia', 'steps'];
    let run = 0, chapter = ORDER[0], userStopped = false, visible = false;
    const setCh = (c) => { chapter = c; $$('button', sModes).forEach((b) => { const on = b.dataset.ch === c; b.classList.toggle('is-on', on); b.setAttribute('aria-pressed', on); }); };
    const stop = () => { run++; tapEl.classList.remove('is-on', 'is-down'); V.stopVoice(); };
    const mk = (id) => {
      const w = (ms) => new Promise((res, rej) => setTimeout(() => (id === run ? res() : rej(new Error('stop'))), ms));
      const t = async (sel, after = 300) => {
        const el = $(sel, sApp); if (!el) return;
        const sc = el.closest('.screen__scroll');
        if (sc) { const k = sc.getBoundingClientRect().height / sc.clientHeight, er = el.getBoundingClientRect(), sr = sc.getBoundingClientRect(); if (er.bottom > sr.bottom - 8 || er.top < sr.top + 8) sc.scrollTop += (er.top + er.height / 2 - (sr.top + sr.height / 2)) / k; }
        const r = el.getBoundingClientRect(), s = sStage.getBoundingClientRect();
        tapEl.style.left = (r.left + r.width / 2 - s.left) + 'px'; tapEl.style.top = (r.top + r.height / 2 - s.top) + 'px';
        tapEl.classList.add('is-on'); await w(330);
        tapEl.classList.add('is-down'); await w(110);
        el.click(); tapEl.classList.remove('is-down'); await w(after);
      };
      return { w, t };
    };
    const CH = {
      async voice({ w, t }) { await t('.v-pill__mic', 0); await w(2300); await t('[data-act="sdone"]', 650); },
      async ia({ w, t }) {
        await t('.v-pill__main'); await t('[data-act="smode"][data-v="ia"]');
        const txt = 'Un finde largo de invierno con dos chicos, sin auto';
        for (let i = 1; i <= txt.length; i++) { const ta = $('.v-free textarea', sApp); if (!ta) break; ta.value = txt.slice(0, i); ta.dispatchEvent(new Event('input', { bubbles: true })); await w(24); }
        await w(900);
      },
      async steps({ w, t }) {
        await t('.v-pill__main');
        await t('[data-act="swhere"][data-v="Bariloche"]');
        await t('[data-act="sseason"][data-v="invierno"]', 200);
        await t('[data-act="sdur"][data-v="Finde largo"]');
        await t('[data-act="swhat"][data-v="Aventura"]', 160); await t('[data-act="swhat"][data-v="Chocolaterías"]');
        await t('[data-act="sopen"][data-k="who"]');
        await t('[data-act="sstep"][data-k="kids"][data-d="1"]', 120); await t('[data-act="sstep"][data-k="kids"][data-d="1"]', 160);
        await t('[data-act="sflag"][data-k="nocar"]', 350);
      }
    };
    // En resultados: el dedo sale y la lista se desliza para mostrar lo encontrado
    const showResults = async ({ w }) => {
      tapEl.classList.remove('is-on'); await w(1300);
      const sc = $('.s-res .screen__scroll', sApp);
      if (sc && sc.scrollTo) sc.scrollTo({ top: 190, behavior: 'smooth' });
      await w(1900);
    };
    const play = async (from) => {
      stop(); const id = run, ctx = mk(id); let i = Math.max(0, ORDER.indexOf(from));
      try {
        for (;;) {
          setCh(ORDER[i]); V.search.reset(); V.go(sApp, 'home'); await ctx.w(800);
          await CH[ORDER[i]](ctx);
          await ctx.t('[data-act="sgo"]', 0);
          await showResults(ctx);
          i = (i + 1) % ORDER.length;
        }
      } catch (e) { /* detenida */ }
    };
    const still = (c) => {   // sin animación: muestra directamente el resultado de cada modo
      setCh(c); V.search.reset();
      if (c === 'steps') V.search.set({ where: 'Bariloche', season: 'invierno', dur: 'Finde largo', what: new Set(['Aventura', 'Chocolaterías']), kids: 2, nocar: true });
      else V.search.set({ mode: 'ia', text: c === 'ia' ? 'Un finde largo de invierno con dos chicos, sin auto' : 'Quiero hacer kayak el sábado, somos dos' });
      V.go(sApp, 'results');
    };
    $$('button', sModes).forEach((b) => b.addEventListener('click', () => { userStopped = false; reduce ? still(b.dataset.ch) : play(b.dataset.ch); }));
    sApp.addEventListener('pointerdown', () => { userStopped = true; stop(); });
    if (reduce) still(chapter);
    else new IntersectionObserver((en) => {
      visible = en[0].isIntersecting;
      if (visible && !userStopped) play(chapter); else if (!visible) stop();
    }, { threshold: .55 }).observe(sStage);
  }

  /* Estado compartido: estación + guardados -------------------------------- */
  $$('.seg button[data-season]').forEach((b) => b.addEventListener('click', () => V.setSeason(b.dataset.season)));
  const wish = $('#wishCount'), live = $('.dcopy__live');
  let lastSaved = 0, lastSeason = '';
  V.onChange((s) => {
    if (stageSeason) stageSeason.dataset.season = s.season;
    $$('.seg button[data-season]').forEach((b) => { const on = b.dataset.season === s.season; b.classList.toggle('is-on', on); b.setAttribute('aria-pressed', on); });
    if (live && s.season !== lastSeason) {
      const d = V.SEASONS[s.season];
      $('#seasonName').textContent = d.label; $('#seasonSub').textContent = d.sub.toLowerCase() + '.';
      if (lastSeason) { live.classList.remove('is-swap'); void live.offsetWidth; live.classList.add('is-swap'); }
      lastSeason = s.season;
    }
    $$('.glass').forEach((c) => { const on = s.saved.has(c.dataset.id); c.classList.toggle('is-on', on); c.setAttribute('aria-pressed', on); });
    if (wish) {
      wish.textContent = s.saved.size; $('#wishWord').textContent = s.saved.size === 1 ? 'guardada' : 'guardadas';
      if (s.saved.size !== lastSaved) { wish.classList.remove('is-bump'); void wish.offsetWidth; wish.classList.add('is-bump'); lastSaved = s.saved.size; }
    }
  });

  /* Releases: la línea avanza hasta el destino elegido --------------------- */
  const route = $('#route');
  if (route) {
    const stops = $$('li', route);
    let rest = 0;
    const setI = (i) => {
      route.style.setProperty('--i', i);
      stops.forEach((li, k) => { li.classList.toggle('is-past', k <= i); li.classList.toggle('is-at', k === i); });
    };
    setI(0);
    stops.forEach((li, k) => {
      li.addEventListener('pointerenter', () => setI(k)); li.addEventListener('focus', () => setI(k)); li.addEventListener('click', () => setI(k));
      li.addEventListener('blur', () => setI(rest));
    });
    route.addEventListener('pointerleave', () => setI(rest));
    new IntersectionObserver((en, o) => {
      if (!en[0].isIntersecting) return; o.disconnect();
      rest = stops.length - 1;
      if (reduce) return setI(rest);
      stops.forEach((_, k) => setTimeout(() => setI(k), 350 + k * 420));
    }, { threshold: .6 }).observe(route);
  }

  /* Laboratorio: pestañas + inspector ------------------------------------ */
  const META = {
    TopBar: ['v-topbar', 'Barra superior. Home (menú, logo y acciones), Detail (volver y título) o Transparent para usar sobre el hero.'],
    SearchField: ['v-search', 'Campo de búsqueda. Al enfocarlo toma el borde azul: probá escribir.'],
    CategoryItem: ['v-cat', 'Categoría del buscador. Un avatar circular con ícono; activo en azul.'],
    Chip: ['v-chip', 'Chip de categoría o filtro. Default, Active y Disabled.'],
    SeasonCard: ['v-season', 'Tarjeta de estación. Seleccionada suma borde azul y check, y reordena lo que sigue.'],
    CompactCard: ['v-compact', 'Fila compacta de recomendación: miniatura, título, subtítulo, puntaje y flecha.'],
    RankingCard: ['v-rank', 'Card del ranking Top 10. Foto a todo el ancho y puesto en una placa mínima.'],
    RatingBadge: ['v-rating', 'Estrella y puntaje. Dos tamaños.'],
    SaveBadge: ['v-save', 'Marcador de guardado. Activo, suma la experiencia a Mi lista.'],
    TabBar: ['v-tab', 'Barra inferior. El ítem activo va en azul con una barra debajo; Mi lista muestra el contador.'],
    Button: ['v-btn', 'Botón. Primary o Secondary, con estados Default, Pressed y Disabled.'],
    Avatar: ['v-avatar', 'Avatar circular con ícono o iniciales.'],
    PlaceCard: ['s-map__place', 'Ficha del lugar seleccionado en el mapa.'],
    SearchPill: ['v-pill', 'Entrada única del buscador: abre la hoja de preguntas o, desde el micrófono, el dictado.'],
    ModeToggle: ['v-mode', 'Cambia entre cargar los filtros paso a paso o contarlo con tus palabras.'],
    QuestionCard: ['v-q', 'Una pregunta del buscador. Abierta muestra las opciones; cerrada resume lo elegido.'],
    OptionChip: ['v-opt', 'Opción combinable, con más de 40 px de alto para tocarla sin errar.'],
    Stepper: ['v-step', 'Contador de personas con botones de 44 px.'],
    Understood: ['v-under', 'Lo que se entendió del texto o la voz, como filtros que se pueden corregir.'],
    FreeText: ['v-free', 'Campo de texto libre del modo Con tus palabras.'],
    VoiceInput: ['v-listen', 'Estado de dictado: onda y transcripción en vivo.'],
    ResultCard: ['v-res', 'Resultado de la búsqueda: foto, motivo por el que coincide y puntaje.'],
    QuerySummary: ['s-res__sum', 'Resumen de la búsqueda arriba de los resultados; al tocarlo se vuelve a editar.']
  };
  const lab = $('#lab'), labApp = $('#labApp');
  const esc = (t) => t.replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
  function cssFor(cls) {
    const out = [];
    for (const sheet of document.styleSheets) {
      if (!sheet.href || !/app\.css/.test(sheet.href)) continue;
      let rules; try { rules = sheet.cssRules; } catch (e) { continue; }
      for (const r of rules) {
        if (!r.selectorText || !new RegExp('^\\.' + cls + '(?![\\w-])').test(r.selectorText)) continue;
        const body = r.style.cssText.split(';').map((d) => d.trim()).filter(Boolean).map((d) => { const i = d.indexOf(':'); return `  <span class="n">${esc(d.slice(0, i))}</span>: <span class="s">${esc(d.slice(i + 1).trim())}</span>;`; }).join('\n');
        out.push(`<span class="k">${esc(r.selectorText)}</span> {\n${body}\n}`);
        if (out.length >= 4) return out;
      }
    }
    return out;
  }
  let tag;
  function pick(el) {
    $$('.is-pick', labApp).forEach((x) => x.classList.remove('is-pick'));
    if (tag) tag.remove();
    if (!el) return;
    const name = el.dataset.c, m = META[name]; if (!m) return;
    el.classList.add('is-pick');
    $('#labName').textContent = name;
    $('#labDesc').textContent = m[1];
    const rules = cssFor(m[0]);
    $('#labCode code').innerHTML = `<span class="c">/* css/app.css · .${m[0]} */</span>\n` + (rules.length ? rules.join('\n\n') : '<span class="c">/* Abrí el archivo para ver las reglas */</span>');
    $('#labCode').scrollTop = 0;
  }
  if (lab) {
    const sync = () => $$('.lab__tabs button').forEach((b) => b.classList.toggle('is-on', b.dataset.go.split(':')[0] === labApp.dataset.screen.split(':')[0]));
    $$('.lab__tabs button').forEach((b) => b.addEventListener('click', () => { if (b.dataset.go === 'search') V.search.reset(); V.go(labApp, b.dataset.go); }));
    labApp.addEventListener('screenchange', sync);
    let mode = 'comp';
    const setInspect = () => lab.classList.toggle('is-inspect', mode === 'comp');
    $$('.lab__modes button').forEach((b) => b.addEventListener('click', () => {
      mode = b.dataset.mode;
      $$('.lab__modes button').forEach((x) => x.classList.toggle('is-on', x === b));
      $$('.lab__pane', lab).forEach((p) => p.classList.toggle('is-on', p.dataset.pane === mode));
      setInspect(); if (mode !== 'comp') pick(null);
    }));
    const inspect = { get checked() { return mode === 'comp'; } };
    setInspect();
    setTimeout(() => pick($('[data-c="SearchPill"]', labApp)), 60);
    labApp.addEventListener('screenchange', () => setTimeout(() => { if (inspect.checked) pick($('[data-c]', labApp)); }, 30));
    labApp.addEventListener('pointerover', (e) => { if (!inspect.checked) return; const el = e.target.closest('[data-c]'); if (el) pick(el); });
    labApp.addEventListener('focusin', (e) => { if (!inspect.checked) return; const el = e.target.closest('[data-c]'); if (el) pick(el); });
  }

  /* Tokens ---------------------------------------------------------------- */
  const TOKENS = [
    ['Primary/Blue', '--color-primary-blue', '#4A80E6', 'Acciones, selección y estados activos.'],
    ['Primary/Blue Dark', '--color-primary-blue-dark', '#325FBF', 'Estado presionado del botón primario.'],
    ['Text/Primary', '--color-text-primary', '#212125', 'Títulos y texto principal.'],
    ['Text/Secondary', '--color-text-secondary', '#6B6B70', 'Subtítulos y descripciones.'],
    ['Text/Tertiary', '--color-text-tertiary', '#9E9EA3', 'Datos de apoyo e ítems inactivos.'],
    ['Surface/White', '--color-surface-white', '#FFFFFF', 'Tarjetas y barras.'],
    ['Surface/Background', '--color-surface-background', '#FBFAF9', 'Fondo de pantalla.'],
    ['Border/Default', '--color-border-default', '#E5E5E8', 'Bordes y divisores.'],
    ['Accent/Amber', '--color-accent-amber', '#E1A436', 'Estrellas de puntaje.'],
    ['Accent/Green', '--color-accent-green', '#429667', 'Estados positivos.']
  ];
  const sw = $('#swatches');
  if (sw) {
    sw.innerHTML = TOKENS.map(([n, v, h], i) => `<button data-i="${i}" class="${i ? '' : 'is-on'}" aria-label="${n} ${h}" title="${n}"><i style="--c:${h}"></i></button>`).join('');
    const show = (i) => {
      const [n, v, h, use] = TOKENS[i];
      $('#tokenCode code').innerHTML = `<span class="c">/* Figma: Color/${n} */</span>\n<span class="n">${v}</span>: <span class="s">${h}</span>;\n\n<span class="c">// Flutter</span>\n<span class="k">static const</span> ${v.replace('--color-', '').replace(/-(\w)/g, (m, c) => c.toUpperCase())} = <span class="p">Color</span>(<span class="s">0xFF${h.slice(1)}</span>);\n\n<span class="c">/* ${use} */</span>`;
      $$('button', sw).forEach((b) => b.classList.toggle('is-on', +b.dataset.i === i));
    };
    sw.addEventListener('click', (e) => { const b = e.target.closest('button'); if (b) show(+b.dataset.i); });
    show(0);
  }
  const tweak = $('#tweak');
  if (tweak) {
    const style = document.head.appendChild(document.createElement('style'));
    tweak.addEventListener('click', (e) => {
      const b = e.target.closest('button'); if (!b) return;
      $$('button', tweak).forEach((x) => x.classList.toggle('is-on', x === b));
      const c = b.style.getPropertyValue('--c'), d = b.style.getPropertyValue('--d');
      style.textContent = `.app{--color-primary-blue:${c};--color-primary-blue-dark:${d}}`;
    });
  }

  /* Código Dart ----------------------------------------------------------- */
  const KW = /\b(import|class|abstract|final|static|const|extends|return|void|if|required|super|this|enum|bool|int|double|String|Set|List|get|override)\b/g;
  function dart(src) {
    return esc(src).split('\n').map((l) => {
      if (/^\s*\/\//.test(l)) return `<span class="c">${l}</span>`;
      return l.replace(/('[^']*')/g, '\u0001$1\u0002').replace(KW, '<span class="k">$1</span>').replace(/\b([A-Z]\w+)(?=[.(<\s])/g, '<span class="p">$1</span>').replace(/\b(0x[0-9A-F]+|\d+(\.\d+)?)\b/g, '<span class="s">$1</span>').replace(/\u0001/g, '<span class="s">').replace(/\u0002/g, '</span>');
    }).join('\n');
  }
  const dc = $('#dartCode code');
  if (dc && window.DART) {
    const show = (k) => { dc.innerHTML = dart(window.DART[k]); dc.parentElement.scrollTop = 0; $$('.dart__tabs button').forEach((b) => b.classList.toggle('is-on', b.dataset.file === k)); };
    $$('.dart__tabs button').forEach((b) => b.addEventListener('click', () => show(b.dataset.file)));
    show('tokens');
  }

  /* Muro de pantallas ----------------------------------------------------- */
  $$('.wall__row').forEach((row) => { row.innerHTML += row.innerHTML; $$('img', row).slice(8).forEach((i) => i.setAttribute('aria-hidden', 'true')); });

  /* Videos del proceso ----------------------------------------------------- */
  // Agrandar: abre el video en una ventana a casi toda la pantalla, con controles
  const vbox = $('#vbox');
  if (vbox && vbox.showModal) {
    const bv = $('video', vbox);
    const closeBox = () => { if (vbox.open) vbox.close(); };
    $$('.vid__big').forEach((b) => b.addEventListener('click', () => {
      const fig = b.closest('.vid'), v = $('video', fig);
      $$('.vid video').forEach((o) => o.pause());
      bv.src = v.getAttribute('src'); bv.poster = v.getAttribute('poster');
      $('.vbox__cap', vbox).textContent = $('figcaption', fig).textContent.replace(/^(\d\d)/, '$1 · ');
      vbox.showModal(); bv.currentTime = 0; const pr = bv.play(); if (pr) pr.catch(() => {});
    }));
    $('.vbox__x', vbox).addEventListener('click', closeBox);
    vbox.addEventListener('click', (e) => { if (e.target === vbox) closeBox(); });
    vbox.addEventListener('close', () => { bv.pause(); bv.removeAttribute('src'); bv.load(); });
  } else $$('.vid__big').forEach((b) => { b.hidden = true; });

  $$('.vid').forEach((fig) => {
    const v = $('video', fig), btn = $('.vid__play', fig);
    v.addEventListener('error', () => { fig.hidden = true; });
    btn.addEventListener('click', () => {
      if (v.paused) { $$('.vid video').forEach((o) => { if (o !== v) o.pause(); }); const pr = v.play(); if (pr) pr.catch(() => {}); } else v.pause();
    });
    v.addEventListener('play', () => fig.classList.add('is-playing'));
    v.addEventListener('pause', () => fig.classList.remove('is-playing'));
  });

})();
