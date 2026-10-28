import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/ui/widgets/crypto_currency_widget.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

import 'currency_prices_view_model.dart';

class CurrencyPricesScreen extends StatefulWidget {
  const CurrencyPricesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CurrencyPricesScreenState();
  }
}

class CurrencyPricesScreenState extends State<CurrencyPricesScreen> {
  final CurrencyPricesViewModel _viewModel = CurrencyPricesViewModel();
  StreamSubscription? _subscriptionError;

  CurrencyPricesScreenState();

  @override
  void initState() {
    super.initState();
    _subscriptionError = _viewModel.errorMessage.listen((error) {
      if (!mounted) return;
      UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr());
    });
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('prices_appbar_title'.tr())),
      body: Center(
        child: StreamBuilder<List<CryptoCurrency>>(
          stream: _viewModel.currencyList,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return RefreshIndicator(
                onRefresh: () => _viewModel.getData(true),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return CryptoCurrencyWidget(
                      ValueKey(snapshot.data![index].name),
                      snapshot.data![index],
                    );
                  },
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
