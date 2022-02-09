import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/ui/widgets/crypto_currency_widget.dart';
import 'package:what_to_mine/src/utils/sys_utils.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

import 'currency_prices_view_model.dart';

class CurrencyPricesScreen extends StatefulWidget {
  const CurrencyPricesScreen({Key? key}) : super(key: key);

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
    _subscriptionError =
        _viewModel.errorMessage.listen((error) => UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr()));
    _viewModel.onViewInitState();
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
    RefreshController _refreshController = RefreshController(initialRefresh: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('prices_appbar_title'.tr()),
      ),
      body: Center(
        child: StreamBuilder<List<CryptoCurrency>>(
          stream: _viewModel.currencyList,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: const WaterDropMaterialHeader(),
                  controller: _refreshController,
                  onRefresh: () async {
                    await _viewModel.getData(true);
                    await SysUtils.delay(1);
                    _refreshController.refreshCompleted();
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return CryptoCurrencyWidget(ValueKey(snapshot.data![index].name), snapshot.data![index]);
                    },
                  ));
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
