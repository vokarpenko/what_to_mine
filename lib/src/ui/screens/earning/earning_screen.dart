import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/logic/favorites_store.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/ui/design/app_ui.dart';
import 'package:what_to_mine/src/ui/design/coin_lists.dart';
import 'package:what_to_mine/src/ui/widgets/earnings_widget.dart';
import 'package:what_to_mine/src/ui/widgets/coin_icon.dart';
import 'earning_view_model.dart';

class EarningScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenRig;
  const EarningScreen({this.onOpenSettings, this.onOpenRig, super.key});
  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final _viewModel = EarningViewModel();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  List<Earnings>? _data;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    Services.favorites.addListener(_onFavoritesChanged);
    _subscriptions.add(
      _viewModel.earnings.listen((items) {
        if (mounted) setState(() => _data = items);
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

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggle(String id) async {
    try {
      await Services.favorites.toggle(FavoriteList.earnings, id);
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
    Services.favorites.removeListener(_onFavoritesChanged);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _viewModel.onViewDispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Services.favorites.ids(FavoriteList.earnings);
    final items = arrangeCoins<Earnings>(
      items: _data ?? [],
      currency: (item) => item.cryptoCurrency,
      favorites: favorites,
      compare: (a, b) =>
          b.netDayEarningInCurrency.compareTo(a.netDayEarningInCurrency),
      query: _search.text,
      favoritesOnly: _favoritesOnly,
    );
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _viewModel.getData(true),
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeading(
                  title: 'home_earnings'.tr(context: context),
                  subtitle: 'earnings_subtitle'.tr(context: context),
                  action: IconButton.filledTonal(
                    tooltip: 'settings_appbar_title'.tr(context: context),
                    onPressed: widget.onOpenSettings,
                    icon: const Icon(Icons.tune_rounded, size: 21),
                  ),
                ),
              ),
              if (_data != null && _data!.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(child: _hero(_data!.first)),
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
                    icon: _search.text.isNotEmpty
                        ? Icons.search_off_rounded
                        : _favoritesOnly
                        ? Icons.star_outline_rounded
                        : Icons.memory_rounded,
                    title:
                        (_search.text.isNotEmpty
                                ? 'no_matches'
                                : _favoritesOnly
                                ? 'no_favorites'
                                : 'start_mining')
                            .tr(context: context),
                    message:
                        (_search.text.isNotEmpty
                                ? 'try_another_search'
                                : _favoritesOnly
                                ? 'favorites_hint'
                                : 'empty_earnings_message')
                            .tr(context: context),
                    action:
                        _data!.isEmpty &&
                            !_favoritesOnly &&
                            _search.text.isEmpty
                        ? FilledButton.icon(
                            onPressed: widget.onOpenRig,
                            icon: const Icon(Icons.add),
                            label: Text('setup_rig'.tr(context: context)),
                          )
                        : null,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final pinned = favorites.contains(item.cryptoCurrency.id);
                      final firstInGroup =
                          index == 0 ||
                          pinned !=
                              favorites.contains(
                                items[index - 1].cryptoCurrency.id,
                              );
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
                                    (pinned ? 'favorites' : 'opportunities').tr(
                                      context: context,
                                    ),
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EarningsWidget(
                              key: ValueKey(
                                'earning_${item.cryptoCurrency.id}',
                              ),
                              earnings: item,
                              favorite: pinned,
                              onFavorite: () => _toggle(item.cryptoCurrency.id),
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

  Widget _hero(Earnings best) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF152D37), Color(0xFF145347)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'best_daily_result'.tr(context: context).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFA7CDC0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'USD',
                style: TextStyle(
                  color: mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  usd(best.netDayEarningInCurrency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.7,
                    fontFeatures: numberFeatures,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            CoinLogoFrame(
              child: CoinIcon(
                best.cryptoCurrency.coin,
                coinId: best.cryptoCurrency.id,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 12, color: mint),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${best.cryptoCurrency.coin} · ${'after_electricity'.tr(context: context)}',
                style: const TextStyle(color: Color(0xFFC4DCD2), fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Divider(color: Colors.white.withValues(alpha: .13)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'projection_30d'.tr(context: context),
                style: const TextStyle(color: Color(0xFFA7CDC0), fontSize: 12),
              ),
            ),
            Text(
              usd(best.netMonthEarningInCurrency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: numberFeatures,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
