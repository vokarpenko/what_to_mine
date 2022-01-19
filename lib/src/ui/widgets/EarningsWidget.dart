import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/ui/widgets/EarningsDetailWidget.dart';

class EarningsWidget extends StatelessWidget {
  final Earnings _earnings;

  EarningsWidget(Key key, this._earnings) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_earnings.cryptoCurrency.iconLink != null) {
      icon = Container(
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
    } else
      icon = Container(
        width: 35,
        height: 35,
      );

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: InkWell(
        onTap: () => _onOpenEarningsDetail(context),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 3),
                            child: icon,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(_earnings.cryptoCurrency.coin),
                          ),
                        ],
                      )),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3),
                          child: Text('daily_volume'.tr() + ' ${_earnings.cryptoCurrency.coin}'),
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          child: Text(_earnings.cryptoCurrency.volume.toStringAsFixed(2) + ' USD'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                          padding: EdgeInsets.all(3),
                          child: Text('net_income_per_day'.tr()),
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          child: Text(_earnings.netDayEarningInCurrency.toStringAsFixed(4) + ' USD'),
                        ),
                        Container(
                            padding: EdgeInsets.all(3),
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
                            padding: EdgeInsets.only(left: 3, top: 3, bottom: 3),
                            child: Text('net_income_per_month'.tr()),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 3, top: 3, bottom: 3),
                            child: Text(_earnings.netMonthEarningInCurrency.toStringAsFixed(4) + ' USD'),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 3, top: 3, bottom: 3),
                            child: Text(_earnings.monthEarningInCrypto.toStringAsFixed(8) +
                                ' ${_earnings.cryptoCurrency.coin}'),
                          ),
                        ],
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onOpenEarningsDetail(BuildContext context) {
    showBarModalBottomSheet(
        context: context, duration: Duration(milliseconds: 300), builder: (context) => EarningsDetailWidget(_earnings));
  }
}
