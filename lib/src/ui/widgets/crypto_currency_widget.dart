import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import '../design/app_ui.dart';
import 'coin_icon.dart';

class CryptoCurrencyWidget extends StatelessWidget {
  final CryptoCurrency currency;
  final bool favorite;
  final VoidCallback onFavorite;

  const CryptoCurrencyWidget({
    required this.currency,
    required this.favorite,
    required this.onFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      borderColor: favorite ? favoriteGold.withValues(alpha: 0.45) : null,
      child: Row(
        children: [
          CoinLogoFrame(child: CoinIcon(currency.coin, coinId: currency.id)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.coin,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  currency.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currency.formattedUsdPrice,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                fontFeatures: numberFeatures,
              ),
            ),
          ),
          FavoriteButton(
            selected: favorite,
            onTap: onFavorite,
            coinId: currency.id,
            list: 'prices',
          ),
        ],
      ),
    );
  }
}
