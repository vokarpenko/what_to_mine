import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/prices/CurrencyPricesViewModel.dart';
import 'package:what_to_mine/src/ui/widgets/CryptoCurrencyWidget.dart';

import '../../../domain/currency/CryptoCurrency.dart';

class CurrencyPricesScreen extends StatefulWidget {
  final CurrencyPricesViewModel _viewModel = CurrencyPricesViewModel();

  @override
  State<StatefulWidget> createState() {
    return CurrencyPricesScreenState(_viewModel);
  }
}

class CurrencyPricesScreenState extends State<CurrencyPricesScreen> {
  final CurrencyPricesViewModel _viewModel;

  CurrencyPricesScreenState(this._viewModel);

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
/*    _viewModel.errorMessage.listen((message) {
      new Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(message),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await SysUtils.delay(6);
                        _viewModel.onViewInitState();
                      },
                      child: Text("OK"))
                ],
              );
            });
      });
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    widget._viewModel.onViewDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Курсы криптовалют"),
      ),
      body: Center(
        child: StreamBuilder<List<CryptoCurrency>>(
          stream: _viewModel.currencyList,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return CryptoCurrencyWidget(snapshot.data![index]);
                },
              );
            } else
              return CircularProgressIndicator();
          },
        ),
      ),
      /*StreamBuilder<bool>(
          initialData: true,
          stream: widget._viewModel.isLoading,
          builder: (context, loadingSnapShot) {
            if (loadingSnapShot.hasData && loadingSnapShot.data!)
              return CircularProgressIndicator();
            else
              return Container();
          },
        ),*/

      floatingActionButton: FloatingActionButton(
        heroTag: "refreshCurrencies",
        onPressed: () {
          _viewModel.onViewInitState();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
