import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import '../design/app_ui.dart';
import 'coin_icon.dart';

class EarningsDetailWidget extends StatelessWidget {
  final Earnings earnings;
  const EarningsDetailWidget(this.earnings, {super.key});

  @override
  Widget build(BuildContext context) {
    final coin = earnings.cryptoCurrency;
    final colors = Theme.of(context).colorScheme;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFeatures: numberFeatures,
              ),
            ),
          ),
        ],
      ),
    );
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          4,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CoinLogoFrame(child: CoinIcon(coin.coin, coinId: coin.id)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${coin.coin} · ${coin.algorithm}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'net_daily'.tr(context: context),
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              usd(earnings.netDayEarningInCurrency),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: earnings.netDayEarningInCurrency >= 0
                    ? colors.primary
                    : colors.error,
                fontFeatures: numberFeatures,
              ),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              child: Column(
                children: [
                  row(
                    'income_per_day'.tr(context: context),
                    usd(earnings.dayEarningInCurrency),
                  ),
                  const Divider(),
                  row(
                    'electricity_cost_per_day'.tr(context: context),
                    usd(earnings.dayElectricityCost),
                  ),
                  const Divider(),
                  row(
                    'projection_30d'.tr(context: context),
                    usd(earnings.netMonthEarningInCurrency),
                  ),
                  const Divider(),
                  row(
                    'daily_mining'.tr(context: context),
                    '${earnings.dayEarningInCrypto.toStringAsFixed(8)} ${coin.coin}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            row(
              'network_hashrate'.tr(context: context),
              coin.getStringNetworkHashrate(),
            ),
            row('daily_volume'.tr(context: context), coin.formattedVolume),
            const SizedBox(height: 12),
            Text(
              'projection_note'.tr(context: context),
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
