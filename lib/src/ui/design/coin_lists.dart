import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';

List<T> arrangeCoins<T>({
  required Iterable<T> items,
  required CryptoCurrency Function(T) currency,
  required Set<String> favorites,
  required Comparator<T> compare,
  String query = '',
  bool favoritesOnly = false,
}) {
  final terms = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty);
  final result = items.where((item) {
    final coin = currency(item);
    if (favoritesOnly && !favorites.contains(coin.id)) return false;
    final text = '${coin.coin} ${coin.name} ${coin.algorithm}'.toLowerCase();
    return terms.every(text.contains);
  }).toList();
  result.sort((a, b) {
    final aPinned = favorites.contains(currency(a).id);
    final bPinned = favorites.contains(currency(b).id);
    if (aPinned != bPinned) return aPinned ? -1 : 1;
    final ordered = compare(a, b);
    return ordered != 0 ? ordered : currency(a).id.compareTo(currency(b).id);
  });
  return result;
}
