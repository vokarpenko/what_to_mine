import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/logic/favorites_store.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/ui/design/app_ui.dart';
import 'package:what_to_mine/src/ui/design/coin_lists.dart';
import 'package:what_to_mine/src/ui/widgets/crypto_currency_widget.dart';
import 'currency_prices_view_model.dart';

class CurrencyPricesScreen extends StatefulWidget {
  const CurrencyPricesScreen({super.key});
  @override
  State<CurrencyPricesScreen> createState() => _CurrencyPricesScreenState();
}

class _CurrencyPricesScreenState extends State<CurrencyPricesScreen> {
  final _viewModel = CurrencyPricesViewModel();
  final _search = TextEditingController();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  List<CryptoCurrency>? _data;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    Services.favorites.addListener(_changed);
    _subscriptions.add(
      _viewModel.currencyList.listen((data) {
        if (mounted) setState(() => _data = data);
      }),
    );
    _subscriptions.add(
      _viewModel.errorMessage.listen((error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }),
    );
    _viewModel.onViewInitState();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _toggle(String id) async {
    try {
      await Services.favorites.toggle(FavoriteList.prices, id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('favorite_save_error'.tr(context: context))),
        );
      }
    }
  }

  @override
  void dispose() {
    Services.favorites.removeListener(_changed);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _viewModel.onViewDispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final favorites = Services.favorites.ids(FavoriteList.prices);
    final items = arrangeCoins<CryptoCurrency>(
      items: _data ?? [],
      currency: (item) => item,
      favorites: favorites,
      compare: (a, b) => a.coin.toLowerCase().compareTo(b.coin.toLowerCase()),
      query: _search.text,
      favoritesOnly: _favoritesOnly,
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _viewModel.getData(true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeading(
                  title: 'home_prices'.tr(context: context),
                  subtitle: 'prices_subtitle'.tr(context: context),
                  action: Container(
                    margin: const EdgeInsets.only(top: 23),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'USD',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverToBoxAdapter(
                  child: SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stat(
                            context,
                            '${_data?.length ?? '—'}',
                            'assets_tracked'.tr(context: context),
                            Icons.token_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: colors.outlineVariant,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _stat(
                            context,
                            '${favorites.length}',
                            'on_watchlist'.tr(context: context),
                            Icons.star_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: SearchAndFavorites(
                    controller: _search,
                    favoritesOnly: _favoritesOnly,
                    favoriteCount: favorites.length,
                    onSearch: (_) => setState(() {}),
                    onFilter: (value) => setState(() => _favoritesOnly = value),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              if (_data == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyContent(
                    icon: _favoritesOnly
                        ? Icons.star_outline_rounded
                        : Icons.search_off_rounded,
                    title:
                        (_favoritesOnly && _search.text.isEmpty
                                ? 'no_favorites'
                                : 'no_matches')
                            .tr(context: context),
                    message:
                        (_favoritesOnly && _search.text.isEmpty
                                ? 'favorites_hint'
                                : 'try_another_search')
                            .tr(context: context),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final coin = items[index];
                      final pinned = favorites.contains(coin.id);
                      final firstInGroup =
                          index == 0 ||
                          pinned != favorites.contains(items[index - 1].id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (firstInGroup)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                                top: 2,
                              ),
                              child: Row(
                                children: [
                                  if (pinned) ...[
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 15,
                                      color: favoriteGold,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    (pinned ? 'favorites' : 'market_assets').tr(
                                      context: context,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CryptoCurrencyWidget(
                              key: ValueKey('price_${coin.id}'),
                              currency: coin,
                              favorite: pinned,
                              onFavorite: () => _toggle(coin.id),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              fontFeatures: numberFeatures,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
