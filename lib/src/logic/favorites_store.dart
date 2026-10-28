import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FavoriteList { earnings, prices, hashrates }

class FavoritesStore extends ChangeNotifier {
  final SharedPreferences _preferences;
  final Map<FavoriteList, Set<String>> _ids;
  Future<void> _pending = Future.value();

  FavoritesStore({required SharedPreferences preferences})
    : _preferences = preferences,
      _ids = {
        for (final list in FavoriteList.values)
          list: (preferences.getStringList(_key(list)) ?? []).toSet(),
      };

  static String _key(FavoriteList list) => 'favorites.v1.${list.name}';

  Set<String> ids(FavoriteList list) => Set.unmodifiable(_ids[list]!);
  bool contains(FavoriteList list, String id) => _ids[list]!.contains(id);

  Future<void> toggle(FavoriteList list, String id) {
    final operation = _pending.then((_) async {
      final next = {..._ids[list]!};
      if (!next.add(id)) next.remove(id);
      final values = next.toList()..sort();
      if (!await _preferences.setStringList(_key(list), values)) {
        throw StateError('Could not save favorites');
      }
      _ids[list] = next;
      notifyListeners();
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }
}
