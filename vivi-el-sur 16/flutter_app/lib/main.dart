import 'package:flutter/material.dart';

import 'screens/coming_soon_screen.dart';
import 'screens/home_screen.dart';
import 'screens/top10_screen.dart';
import 'screens/wishlist_screen.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';

void main() => runApp(const ViviElSurApp());

class ViviElSurApp extends StatefulWidget {
  const ViviElSurApp({super.key});

  @override
  State<ViviElSurApp> createState() => _ViviElSurAppState();
}

class _ViviElSurAppState extends State<ViviElSurApp> {
  final _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Viví el Sur',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Shell(),
      ),
    );
  }
}

/// Estructura principal: Explorar, Cerca, Mi lista y Mi viaje.
/// El ranking vive dentro de Explorar: se llega desde "Ver ranking" o al
/// confirmar una búsqueda.
class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;
  bool _ranking = false;

  void _showRanking() => setState(() {
        _index = 0;
        _ranking = true;
      });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final pages = [
      _ranking ? const Top10Screen() : HomeScreen(onShowRanking: _showRanking),
      const ComingSoonScreen(
        icon: Icons.place_outlined,
        title: 'Cerca de mí',
        message: 'El mapa descargable para usar sin señal llega en la próxima versión.',
      ),
      WishlistScreen(onExplore: _showRanking),
      const ComingSoonScreen(
        icon: Icons.work_outline,
        title: 'Tu itinerario, día por día',
        message: 'Todavía no está en esta versión. Mientras tanto, guardá experiencias en Mi lista.',
      ),
    ];

    return PopScope(
      canPop: !(_index == 0 && _ranking),
      onPopInvoked: (didPop) {
        if (!didPop) setState(() => _ranking = false);
      },
      child: Scaffold(
        appBar: _index == 0 && _ranking
            ? AppBar(
                leading: BackButton(onPressed: () => setState(() => _ranking = false)),
                title: const Text('Experiencias'),
              )
            : null,
        body: SafeArea(top: !(_index == 0 && !_ranking), child: IndexedStack(index: _index, children: pages)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          backgroundColor: AppColors.surfaceWhite,
          indicatorColor: AppColors.surfaceMuted,
          onDestinationSelected: (index) => setState(() {
            _index = index;
            if (index == 0) _ranking = false;
          }),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
            const NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Cerca'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.savedCount > 0,
                label: Text('${state.savedCount}'),
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(Icons.bookmark_border),
              ),
              selectedIcon: const Icon(Icons.bookmark),
              label: 'Mi lista',
            ),
            const NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Mi viaje'),
          ],
        ),
      ),
    );
  }
}
