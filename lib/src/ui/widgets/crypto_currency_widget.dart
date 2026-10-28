import 'package:flutter/material.dart';
import 'coin_icon.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';

class CryptoCurrencyWidget extends StatelessWidget {
  final CryptoCurrency _cryptoCurrency;

  const CryptoCurrencyWidget(Key key, this._cryptoCurrency) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = Padding(
      padding: const EdgeInsets.all(12),
      child: CoinIcon(_cryptoCurrency.coin, coinId: _cryptoCurrency.id),
    );
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
                child: Row(children: [icon, Text(_cryptoCurrency.coin)]),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Text(_cryptoCurrency.name),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Text(_cryptoCurrency.formattedPrice),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
