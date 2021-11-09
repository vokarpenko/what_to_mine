import 'package:flutter/material.dart';

import '../../domain/currency/CryptoCurrency.dart';

class CryptoCurrencyWidget extends StatefulWidget {
  final CryptoCurrency _cryptoCurrency;
  CryptoCurrencyWidget(Key key, this._cryptoCurrency) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CryptoCurrencyState(_cryptoCurrency);
  }
}

class CryptoCurrencyState extends State<CryptoCurrencyWidget> {
  final CryptoCurrency _cryptoCurrency;

  CryptoCurrencyState(this._cryptoCurrency);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_cryptoCurrency.iconLink != null) {
      icon = Container(
          margin: EdgeInsets.all(20),
          width: 35,
          height: 35,
          child: FadeInImage.assetNetwork(
            fit: BoxFit.fill,
            placeholder: 'assets/images/loading.gif',
            image: _cryptoCurrency.iconLink!,
          ));
    } else
      icon = Container(
        margin: EdgeInsets.all(10),
        width: 50,
        height: 50,
      );
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 30,
      child: Center(
          child: Flex(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: [
          Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    icon,
                    Text(_cryptoCurrency.coin),
                  ],
                ),
              )),
          Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(_cryptoCurrency.name),
                    padding: EdgeInsets.all(5),
                  ),
                  Container(
                    child: Text(_cryptoCurrency.price.toStringAsFixed(5) + " \$"),
                    padding: EdgeInsets.all(5),
                  ),
                ],
              )),
        ],
      )),
    );
  }
}
