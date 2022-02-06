import 'package:flutter/material.dart';

import '../../domain/currency/CryptoCurrency.dart';

class CryptoCurrencyWidget extends StatelessWidget {
  final CryptoCurrency _cryptoCurrency;

  const CryptoCurrencyWidget(Key key, this._cryptoCurrency) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_cryptoCurrency.iconLink != null) {
      icon = Container(
          margin: const EdgeInsets.all(20),
          width: 35,
          height: 35,
          child: ClipOval(
            child: FadeInImage.assetNetwork(
                placeholderFit: BoxFit.fill,
                fit: BoxFit.fill,
                placeholder: 'assets/images/loading.gif',
                image: _cryptoCurrency.iconLink!),
          ));
    } else {
      icon = Container(
        margin: const EdgeInsets.all(10),
        width: 50,
        height: 50,
      );
    }
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Center(
          child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: Row(
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
                    padding: const EdgeInsets.all(5),
                  ),
                  Container(
                    child: Text(_cryptoCurrency.price.toStringAsFixed(5) + ' \$'),
                    padding: const EdgeInsets.all(5),
                  ),
                ],
              )),
        ],
      )),
    );
  }
}
