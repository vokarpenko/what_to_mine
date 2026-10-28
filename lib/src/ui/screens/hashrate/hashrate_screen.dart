import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/logic/favorites_store.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/ui/design/app_ui.dart';
import 'package:what_to_mine/src/ui/widgets/hashrate_widget.dart';
import 'hashrate_view_model.dart';

class HashrateScreen extends StatefulWidget {
  final bool embedded;
  const HashrateScreen({this.embedded = false, super.key});
  @override
  State<HashrateScreen> createState() => _HashrateScreenState();
}

class _HashrateScreenState extends State<HashrateScreen> {
  final _viewModel = HashrateViewModel();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _search = TextEditingController();
  // Keep exact input text when filtering unmounts a card, including decimals
  // that are still being entered. The view model keeps the numeric save values.
  final _draftHashrates = <String, String>{};
  final _draftPowers = <String, String>{};
  List<HashAlgorithm>? _data;
  bool _dirty = false;
  bool _favoritesOnly = false;

  String _id(HashAlgorithm algorithm) => algorithm.name.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    Services.favorites.addListener(_favoritesChanged);
    _subscriptions.add(
      _viewModel.hashrate.listen((items) {
        if (!mounted) return;
        setState(() {
          _data = items;
          _draftHashrates.clear();
          _draftPowers.clear();
        });
      }),
    );
    _subscriptions.add(
      _viewModel.showApplyButton.listen((dirty) {
        if (mounted) setState(() => _dirty = dirty);
      }),
    );
    _subscriptions.add(_viewModel.infoMessage.listen(_message));
    _subscriptions.add(_viewModel.errorMessage.listen(_message));
    _viewModel.onViewInitState();
  }

  void _favoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggle(String id) async {
    try {
      await Services.favorites.toggle(FavoriteList.hashrates, id);
    } catch (_) {
      if (mounted) _message('favorite_save_error'.tr(context: context));
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void dispose() {
    Services.favorites.removeListener(_favoritesChanged);
    _search.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _viewModel.onViewDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Services.favorites.ids(FavoriteList.hashrates);
    final terms = _search.text.trim().toLowerCase().split(RegExp(r'\s+'));
    final items =
        (_data ?? <HashAlgorithm>[]).where((algorithm) {
          return (!_favoritesOnly || favorites.contains(_id(algorithm))) &&
              terms.every(algorithm.name.toLowerCase().contains);
        }).toList()..sort((a, b) {
          final aPinned = favorites.contains(_id(a));
          final bPinned = favorites.contains(_id(b));
          if (aPinned != bPinned) return aPinned ? -1 : 1;
          return _id(a).compareTo(_id(b));
        });
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: Text('home_hashrate'.tr(context: context))),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              children: [
                SearchAndFavorites(
                  controller: _search,
                  searchKey: 'hashrate_search',
                  searchHint: 'search_hashrates',
                  allLabel: 'all_hashrates',
                  favoritesOnly: _favoritesOnly,
                  favoriteCount: favorites.length,
                  onSearch: (_) => setState(() {}),
                  onFilter: (value) => setState(() => _favoritesOnly = value),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 18),
                  child: Text(
                    'hashrate_hint'.tr(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ),
                if (items.isEmpty)
                  EmptyContent(
                    icon: _favoritesOnly
                        ? Icons.star_outline_rounded
                        : Icons.search_off_rounded,
                    title:
                        (_search.text.trim().isNotEmpty
                                ? 'no_matches'
                                : _favoritesOnly
                                ? 'no_favorites'
                                : 'start_mining')
                            .tr(context: context),
                    message:
                        (_search.text.trim().isNotEmpty
                                ? 'try_another_search'
                                : _favoritesOnly
                                ? 'hashrate_favorites_hint'
                                : 'empty_hashrates_message')
                            .tr(context: context),
                  ),
                for (final algorithm in items)
                  Padding(
                    key: ValueKey('hashrate_row_${_id(algorithm)}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HashrateWidget(
                      _viewModel,
                      algorithm,
                      key: ValueKey('hashrate_${algorithm.name}'),
                      favorite: favorites.contains(_id(algorithm)),
                      onFavorite: () => _toggle(_id(algorithm)),
                      initialHashrate: _draftHashrates[_id(algorithm)],
                      initialPower: _draftPowers[_id(algorithm)],
                      onHashrateChanged: (value) =>
                          _draftHashrates[_id(algorithm)] = value,
                      onPowerChanged: (value) =>
                          _draftPowers[_id(algorithm)] = value,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: _dirty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: FilledButton.icon(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _viewModel.onApplyHashrate();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text('save_changes'.tr(context: context)),
                ),
              ),
            )
          : null,
    );
  }
}
