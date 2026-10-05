import 'dart:async';

import 'package:flutter/material.dart';

import '../models/experience.dart';
import '../models/search_query.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

enum _Mode { steps, words }

enum _Question { where, when, what, who }

/// Buscador a pantalla completa.
/// Paso a paso: una pregunta abierta por vez y las demás resumidas.
/// Con tus palabras: texto libre o voz, traducidos a filtros que se pueden corregir.
class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key, this.startListening = false});

  /// Devuelve `true` si la persona confirmó la búsqueda.
  /// Abre directamente en dictado (cuando se entra desde el micrófono).
  final bool startListening;

  static Route<bool> route({bool startListening = false}) => MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => SearchSheet(startListening: startListening),
      );

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  // Frase de ejemplo: el dictado real todavía no está conectado (ver README).
  static const _sample = 'Quiero hacer kayak el sábado, somos dos';

  final _text = TextEditingController();
  _Mode _mode = _Mode.steps;
  _Question _open = _Question.where;
  bool _listening = false;
  String _heard = '';
  Timer? _voice;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    if (widget.startListening) {
      _mode = _Mode.words;
      WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
    }
  }

  @override
  void dispose() {
    _voice?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _listen() {
    _voice?.cancel();
    final words = _sample.split(' ');
    var i = 0;
    setState(() {
      _mode = _Mode.words;
      _listening = true;
      _heard = '';
      _text.clear();
    });
    _voice = Timer.periodic(const Duration(milliseconds: 260), (timer) {
      i++;
      setState(() => _heard = words.take(i).join(' '));
      if (i >= words.length) timer.cancel();
    });
  }

  void _stopListening({required bool keep}) {
    _voice?.cancel();
    setState(() {
      _listening = false;
      if (keep) _text.text = _heard;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final query = state.query;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundButton(icon: Icons.close, label: 'Cerrar', onTap: () => Navigator.of(context).pop()),
                  _ModeToggle(
                    mode: _mode,
                    onChanged: (mode) {
                      if (_listening) _stopListening(keep: false);
                      setState(() => _mode = mode);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
                children: _mode == _Mode.steps ? _steps(state, query) : _words(),
              ),
            ),
            _bottomBar(state),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- Paso a paso

  List<Widget> _steps(AppState state, SearchQuery query) {
    Widget card(_Question question, String label, String title, String summary, Widget body) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _QuestionCard(
          label: label,
          title: title,
          summary: summary,
          open: _open == question,
          onOpen: () => setState(() => _open = question),
          child: body,
        ),
      );
    }

    return [
      card(
        _Question.where,
        'Dónde',
        '¿Dónde?',
        query.whereLabel,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final destination in destinations)
              _DestinationRow(
                destination: destination,
                selected: query.where == destination.name,
                onTap: () {
                  state.updateQuery(query.copyWith(where: destination.name));
                  setState(() => _open = _Question.when);
                },
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Después, toda la Patagonia: El Calafate, Ushuaia, Puerto Madryn y Carretera Austral.',
              style: AppText.caption,
            ),
          ],
        ),
      ),
      card(
        _Question.when,
        'Cuándo',
        '¿Cuándo?',
        query.whenLabel,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.9,
              children: [
                for (final season in Season.values)
                  _SeasonOption(
                    season: season,
                    selected: query.season == season,
                    onTap: () {
                      // La estación del buscador es la misma que ordena la home.
                      state.selectSeason(season);
                      state.updateQuery(query.copyWith(season: season));
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _Label('¿Cuánto tiempo?'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final duration in durations)
                  _OptionChip(
                    label: duration,
                    selected: query.duration == duration,
                    onTap: () {
                      state.updateQuery(query.copyWith(duration: duration));
                      if (query.season != null) setState(() => _open = _Question.what);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      card(
        _Question.what,
        'Qué',
        '¿Qué querés hacer?',
        query.whatLabel,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final group in categories.entries) ...[
              _Label(group.key),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item in group.value)
                    _OptionChip(
                      label: item,
                      selected: query.what.contains(item),
                      onTap: () {
                        final what = {...query.what};
                        if (!what.remove(item)) what.add(item);
                        state.updateQuery(query.copyWith(what: what));
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
      card(
        _Question.who,
        'Quiénes',
        '¿Quiénes viajan?',
        query.whoLabel,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Stepper(
              label: 'Adultos',
              detail: '13 años o más',
              value: query.adults,
              min: 1,
              onChanged: (value) => state.updateQuery(query.copyWith(adults: value)),
            ),
            _Stepper(
              label: 'Niños',
              detail: 'De 2 a 12 años',
              value: query.kids,
              onChanged: (value) => state.updateQuery(query.copyWith(kids: value)),
            ),
            _Stepper(
              label: 'Bebés',
              detail: 'Menos de 2 años',
              value: query.babies,
              onChanged: (value) => state.updateQuery(query.copyWith(babies: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _OptionChip(
                  label: 'Con mascota',
                  selected: query.withPet,
                  onTap: () => state.updateQuery(query.copyWith(withPet: !query.withPet)),
                ),
                _OptionChip(
                  label: 'Sin auto',
                  selected: query.withoutCar,
                  onTap: () => state.updateQuery(query.copyWith(withoutCar: !query.withoutCar)),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ----------------------------------------------------------- Con tus palabras

  List<Widget> _words() {
    final found = understand(_listening ? _heard : _text.text);

    return [
      if (_listening)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.textPrimary, width: 1.5),
          ),
          child: Column(
            children: [
              const _Label('Escuchando'),
              const SizedBox(height: AppSpacing.xl),
              const _Wave(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _heard.isEmpty ? 'Hablá como se lo contarías a alguien' : '“$_heard…”',
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(fontSize: 22, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        )
      else
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, size: 20, color: AppColors.textSecondary),
              TextField(
                controller: _text,
                minLines: 2,
                maxLines: 4,
                style: AppText.display.copyWith(fontSize: 22, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Contá qué querés hacer, con tus palabras',
                  hintStyle: AppText.display.copyWith(fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 10),
      if (found.isNotEmpty)
        _UnderstoodCard(items: found)
      else if (!_listening)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.all(AppSpacing.xs), child: _Label('Probá con')),
            for (final example in const [
              _sample,
              'Algo tranquilo para un día de lluvia',
              'Un finde largo de invierno con dos chicos, sin auto',
            ])
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Material(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _text.text = example,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 13),
                      child: Text(example, style: AppText.bodyMedium.copyWith(fontSize: 14.5, fontWeight: FontWeight.w400)),
                    ),
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  // -------------------------------------------------------------- Acción fija

  Widget _bottomBar(AppState state) {
    void search() => Navigator.of(context).pop(true);

    final Widget left;
    final Widget right;
    if (_listening) {
      left = TextButton(onPressed: () => _stopListening(keep: false), child: const Text('Cancelar'));
      right = _Cta(icon: Icons.stop, label: 'Listo', onTap: () => _stopListening(keep: true));
    } else {
      left = _mode == _Mode.words
          ? _RoundButton(icon: Icons.mic_none, label: 'Dictar', size: 52, onTap: _listen)
          : TextButton(onPressed: state.clearQuery, child: const Text('Borrar todo'));
      right = _Cta(icon: Icons.search, label: 'Buscar', onTap: search);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [left, right]),
    );
  }
}

// ------------------------------------------------------------------- Piezas

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.overline.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.3, color: AppColors.textSecondary),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap, this.size = 44});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.surfaceWhite,
        shape: const CircleBorder(side: BorderSide(color: AppColors.borderDefault)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: size, height: size, child: Icon(icon, size: size * .4, color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: AppText.bodyMedium.copyWith(fontSize: 15),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _Mode mode;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(_Mode value, String label, [IconData? icon]) {
      final selected = mode == value;
      final color = selected ? Colors.white : AppColors.textSecondary;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
              Text(label, style: AppText.bodyMedium.copyWith(color: color)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(_Mode.steps, 'Paso a paso'),
          const SizedBox(width: 2),
          option(_Mode.words, 'Con tus palabras', Icons.auto_awesome),
        ],
      ),
    );
  }
}

/// Una pregunta del buscador. Abierta muestra las opciones; cerrada, el resumen.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.label,
    required this.title,
    required this.summary,
    required this.open,
    required this.onOpen,
    required this.child,
  });

  final String label;
  final String title;
  final String summary;
  final bool open;
  final VoidCallback onOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: open
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.large,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.display.copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            )
          : Material(
              color: AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                side: const BorderSide(color: AppColors.borderDefault),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 15),
                  child: Row(
                    children: [
                      Text(label, style: AppText.bodyMedium.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          summary,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.title.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({required this.destination, required this.selected, required this.onTap});

  final Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = destination.phase == null;
    final color = enabled ? AppColors.textPrimary : AppColors.textSecondary;

    return Material(
      color: selected ? AppColors.surfaceMuted : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, 10, AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surfaceWhite : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  destination.name == 'Cerca de mí' ? Icons.near_me_outlined : Icons.place_outlined,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.name, style: AppText.title.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
                    const SizedBox(height: 2),
                    Text(destination.detail, style: AppText.caption.copyWith(fontSize: 12.5)),
                  ],
                ),
              ),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Text(destination.phase!, style: AppText.caption),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonOption extends StatelessWidget {
  const _SeasonOption({required this.season, required this.selected, required this.onTap});

  final Season season;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(season.label, style: AppText.h1.copyWith(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                season.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body.copyWith(color: selected ? Colors.white.withOpacity(.86) : AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opción combinable. Más de 40 px de alto para tocarla sin errar.
class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: selected ? AppColors.textPrimary : AppColors.borderDefault),
          ),
          child: Text(
            label,
            style: AppText.bodyMedium.copyWith(fontSize: 14, color: selected ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, required this.detail, required this.value, required this.onChanged, this.min = 0});

  final String label;
  final String detail;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.title.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(detail, style: AppText.caption.copyWith(fontSize: 12.5)),
              ],
            ),
          ),
          _RoundButton(icon: Icons.remove, label: 'Menos $label', onTap: () => onChanged(value > min ? value - 1 : value)),
          SizedBox(
            width: 40,
            child: Text('$value', textAlign: TextAlign.center, style: AppText.h1.copyWith(fontWeight: FontWeight.w600)),
          ),
          _RoundButton(icon: Icons.add, label: 'Más $label', onTap: () => onChanged(value < 9 ? value + 1 : value)),
        ],
      ),
    );
  }
}

/// Lo que se entendió del texto o la voz, como filtros que se pueden corregir.
class _UnderstoodCard extends StatelessWidget {
  const _UnderstoodCard({required this.items});

  final List<Understood> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(AppRadius.xxl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.sm),
              _Label('Así lo entendí'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 9),
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${item.label}  ', style: AppText.caption.copyWith(fontSize: 12)),
                        TextSpan(text: item.value, style: AppText.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Tocá un dato para corregirlo. Nada se busca hasta que confirmes.', style: AppText.caption),
        ],
      ),
    );
  }
}

/// Onda del dictado: barras que suben y bajan mientras escucha.
class _Wave extends StatefulWidget {
  const _Wave();

  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const heights = <double>[10, 22, 36, 18, 48, 30, 14, 40, 56, 28, 16, 34, 46, 20, 12, 26, 10];

    return SizedBox(
      height: 56,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < heights.length; i++)
                Container(
                  width: 4,
                  height: heights[i] * (i.isEven ? .35 + .65 * _controller.value : 1 - .65 * _controller.value),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(2)),
                ),
            ],
          );
        },
      ),
    );
  }
}
