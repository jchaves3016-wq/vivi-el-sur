import 'package:flutter/widgets.dart';

import '../data/experiences.dart';
import '../models/experience.dart';
import '../models/search_query.dart';

/// Estado de la app: la estación elegida, la lista de guardados y la búsqueda.
/// Un solo ChangeNotifier, sin dependencias externas.
class AppState extends ChangeNotifier {
  Season _season = Season.invierno;
  final Set<String> _saved = {};
  SearchQuery _query = const SearchQuery();

  Season get season => _season;
  int get savedCount => _saved.length;
  SearchQuery get query => _query;

  bool isSaved(String id) => _saved.contains(id);

  /// Experiencias guardadas, en el orden del ranking.
  List<Experience> get wishlist => experiences.where((e) => _saved.contains(e.id)).toList();

  /// Recomendadas para la estación elegida.
  List<Experience> get recommended => experiences.where((e) => e.seasons.contains(_season)).toList();

  void selectSeason(Season season) {
    if (season == _season) return;
    _season = season;
    notifyListeners();
  }

  void toggleSaved(String id) {
    if (!_saved.remove(id)) _saved.add(id);
    notifyListeners();
  }

  void updateQuery(SearchQuery query) {
    _query = query;
    notifyListeners();
  }

  void clearQuery() => updateQuery(const SearchQuery());
}

/// Expone [AppState] al árbol de widgets y los reconstruye cuando cambia.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope no está en el árbol');
    return scope!.notifier!;
  }
}
