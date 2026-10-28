import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import '../design/app_ui.dart';
import 'coin_icon.dart';
import 'earnings_detail_widget.dart';

class EarningsWidget extends StatelessWidget {
  final Earnings earnings;
  final bool favorite;
  final VoidCallback onFavorite;

  const EarningsWidget({
    required this.earnings,
    required this.favorite,
    required this.onFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final coin = earnings.cryptoCurrency;
    final colors = Theme.of(context).colorScheme;
    final positive = earnings.netDayEarningInCurrency >= 0;
    return SurfaceCard(
      borderColor: favorite ? favoriteGold.withValues(alpha: 0.45) : null,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => EarningsDetailWidget(earnings),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinLogoFrame(child: CoinIcon(coin.coin, coinId: coin.id)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.coin,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              FavoriteButton(
                selected: favorite,
                onTap: onFavorite,
                coinId: coin.id,
                list: 'earnings',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'net_daily'.tr(context: context),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      usd(earnings.netDayEarningInCurrency),
                      style: TextStyle(
                        fontSize: 27,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w800,
                        color: positive ? colors.primary : colors.error,
                        fontFeatures: numberFeatures,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'projection_30d'.tr(context: context),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    usd(earnings.netMonthEarningInCurrency),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFeatures: numberFeatures,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 17),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  coin.algorithm,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${earnings.dayEarningInCrypto.toStringAsFixed(5)} ${coin.coin} / ${'day_short'.tr(context: context)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontFeatures: numberFeatures,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
