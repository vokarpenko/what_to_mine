import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const ink = Color(0xFF142733);
const emerald = Color(0xFF00856A);
const mint = Color(0xFFBDF1D6);
const favoriteGold = Color(0xFFfac73a);
const numberFeatures = [FontFeature.tabularFigures()];

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Semantics(label: label, child: child),
    ],
  );
}

final _usdWithThousands = NumberFormat('#,##0.00', 'en_US');

String usd(double value) {
  final absolute = value.abs();
  final amount = absolute > 0 && absolute < 0.01
      ? absolute.toStringAsFixed(4)
      : _usdWithThousands.format(absolute);
  return '${value < 0 ? '−' : ''}\$$amount';
}

class PageHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeading({
    required this.title,
    required this.subtitle,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WHAT TO MINE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    ),
  );
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color:
            borderColor ??
            Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.65),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class SearchAndFavorites extends StatelessWidget {
  final TextEditingController controller;
  final bool favoritesOnly;
  final int favoriteCount;
  final ValueChanged<String> onSearch;
  final ValueChanged<bool> onFilter;
  final String searchHint;
  final String allLabel;
  final String searchKey;

  const SearchAndFavorites({
    required this.controller,
    required this.favoritesOnly,
    required this.favoriteCount,
    required this.onSearch,
    required this.onFilter,
    this.searchHint = 'search_coins',
    this.allLabel = 'all_coins',
    this.searchKey = 'coin_search',
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        key: ValueKey(searchKey),
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onSearch,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: searchHint.tr(context: context),
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'clear_search'.tr(context: context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                ),
        ),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ChoiceChip(
            label: Text(allLabel.tr(context: context)),
            selected: !favoritesOnly,
            showCheckmark: false,
            onSelected: (_) => onFilter(false),
          ),
          ChoiceChip(
            avatar: Icon(
              Icons.star_rounded,
              size: 17,
              color: favoritesOnly
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : favoriteGold,
            ),
            label: Text(
              '${'favorites'.tr(context: context)}${favoriteCount > 0 ? ' · $favoriteCount' : ''}',
            ),
            selected: favoritesOnly,
            showCheckmark: false,
            onSelected: (_) => onFilter(true),
          ),
        ],
      ),
    ],
  );
}

class FavoriteButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String coinId;
  final String list;

  const FavoriteButton({
    required this.selected,
    required this.onTap,
    required this.coinId,
    required this.list,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: selected,
    child: IconButton(
      key: ValueKey('favorite_${list}_$coinId'),
      tooltip: (selected ? 'favorite_remove' : 'favorite_add').tr(
        context: context,
      ),
      onPressed: onTap,
      icon: Icon(
        selected ? Icons.star_rounded : Icons.star_outline_rounded,
        color: selected
            ? favoriteGold
            : Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
      ),
    ),
  );
}

class EmptyContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyContent({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

class CoinLogoFrame extends StatelessWidget {
  final Widget child;
  const CoinLogoFrame({required this.child, super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFCFB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8EEE9)),
    ),
    child: child,
  );
}
