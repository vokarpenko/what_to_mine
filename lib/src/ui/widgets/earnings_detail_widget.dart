import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';

class EarningsDetailWidget extends StatelessWidget {
  final Earnings _earnings;

  const EarningsDetailWidget(this._earnings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_earnings.cryptoCurrency.iconLink != null) {
      icon = SizedBox(
        width: 35,
        height: 35,
        child: ClipOval(
          child: FadeInImage.assetNetwork(
              placeholderFit: BoxFit.fill,
              fit: BoxFit.fill,
              placeholder: 'assets/images/loading.gif',
              image: _earnings.cryptoCurrency.iconLink!),
        ),
      );
    } else {
      icon = const SizedBox(
        width: 35,
        height: 35,
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: icon,
              ),
              Container(
                width: 15,
              ),
              Flexible(
                  child: Text(
                _earnings.cryptoCurrency.name,
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      fontSize: 28,
                    ),
                textAlign: TextAlign.center,
              )),
            ],
          ),
          const Divider(
            color: Colors.transparent,
          ),
          Padding(
              padding: const EdgeInsets.all(3),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      'algorithm'.tr(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      _earnings.cryptoCurrency.algorithm,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(3),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      'daily_volume'.tr(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      _earnings.cryptoCurrency.volume.toStringAsFixed(2) + ' USD',
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    'network_hashrate'.tr(),
                    textAlign: TextAlign.start,
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    _earnings.cryptoCurrency.getStringNetworkHashrate(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      child: Text('income_per_day'.tr()),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      child: Text(_earnings.dayEarningInCurrency.toStringAsFixed(4) + ' USD'),
                    ),
                    Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                            _earnings.dayEarningInCrypto.toStringAsFixed(8) + ' ${_earnings.cryptoCurrency.coin}')),
                  ],
                ),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text('income_per_month'.tr()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(_earnings.monthEarningInCurrency.toStringAsFixed(2) + ' USD'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                            _earnings.monthEarningInCrypto.toStringAsFixed(8) + ' ${_earnings.cryptoCurrency.coin}'),
                      ),
                    ],
                  ))
            ],
          ),
          const Divider(),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      child: Text('electricity_cost_per_day'.tr()),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      child: Text(_earnings.dayElectricityCost.toStringAsFixed(2) + ' USD'),
                    ),
                  ],
                ),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text('electricity_cost_per_month'.tr()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(_earnings.monthElectricityCost.toStringAsFixed(2) + ' USD'),
                      ),
                    ],
                  ))
            ],
          ),
          const Divider(),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text('net_income_per_day'.tr()),
                      ),
                      // чистая прибыль за день
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(_earnings.netDayEarningInCurrency.toStringAsFixed(4) + ' USD'),
                      ),
                    ],
                  )),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text('net_income_per_month'.tr()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(_earnings.netMonthEarningInCurrency.toStringAsFixed(2) + ' USD'),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
