import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/logic/favorites_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'favorites survive recreation and remain separate for each tab',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = FavoritesStore(preferences: preferences);
      await store.toggle(FavoriteList.earnings, '162');
      await store.toggle(FavoriteList.prices, '234');
      await store.toggle(FavoriteList.hashrates, 'kawpow');
      final restored = FavoritesStore(preferences: preferences);
      expect(restored.ids(FavoriteList.earnings), {'162'});
      expect(restored.ids(FavoriteList.prices), {'234'});
      expect(restored.ids(FavoriteList.hashrates), {'kawpow'});
      await restored.toggle(FavoriteList.earnings, '162');
      expect(restored.ids(FavoriteList.earnings), isEmpty);
      expect(restored.ids(FavoriteList.prices), {'234'});
      store.dispose();
      restored.dispose();
    },
  );

  test('rapid toggles serialize without losing changes', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = FavoritesStore(preferences: preferences);
    await Future.wait([
      store.toggle(FavoriteList.prices, 'a'),
      store.toggle(FavoriteList.prices, 'b'),
      store.toggle(FavoriteList.prices, 'a'),
      store.toggle(FavoriteList.earnings, 'a'),
    ]);
    expect(store.ids(FavoriteList.prices), {'b'});
    expect(store.ids(FavoriteList.earnings), {'a'});
    expect(FavoritesStore(preferences: preferences).ids(FavoriteList.prices), {
      'b',
    });
    store.dispose();
  });
}
