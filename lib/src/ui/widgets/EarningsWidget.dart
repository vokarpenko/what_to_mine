import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';

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
          child: FadeInImage.assetNetwork(
            fit: BoxFit.fill,
            placeholder: 'assets/images/loading.gif',
            image: _earnings.cryptoCurrency.iconLink!,
          ));
    } else
      icon = Container(
        width: 35,
        height: 35,
      );

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 30,
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
                        child: Text("Суточный объем ${_earnings.cryptoCurrency.coin}"),
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(_earnings.cryptoCurrency.volume.toStringAsFixed(2) + " USD"),
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
                        child: Text("Доход за день"),
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(_earnings.dayEarningInCurrency.toStringAsFixed(4) + " USD"),
                      ),
                      Container(
                          padding: EdgeInsets.all(3),
                          child: Text(
                              _earnings.dayEarningInCrypto.toStringAsFixed(8) + " ${_earnings.cryptoCurrency.coin}")),
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
                          padding: EdgeInsets.all(3),
                          child: Text("Доход за месяц"),
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          child: Text(_earnings.monthEarningInCurrency.toStringAsFixed(4) + " USD"),
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          child: Text(
                              _earnings.monthEarningInCrypto.toStringAsFixed(8) + " ${_earnings.cryptoCurrency.coin}"),
                        ),
                      ],
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
