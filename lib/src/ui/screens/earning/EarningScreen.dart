import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/ui/screens/earning/EarningViewModel.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsScreen.dart';
import 'package:what_to_mine/src/ui/widgets/EarningsWidget.dart';
import 'package:what_to_mine/src/utils/SysUtils.dart';

class EarningScreen extends StatefulWidget {
  final EarningViewModel _viewModel = EarningViewModel();
  @override
  State<StatefulWidget> createState() {
    return EarningScreenState(_viewModel);
  }
}

class EarningScreenState extends State<EarningScreen> {
  EarningViewModel _viewModel = EarningViewModel();
  EarningScreenState(this._viewModel);
  StreamSubscription? _subscriptionOpenSettingsScreen;
  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    _subscriptionOpenSettingsScreen = _viewModel.openSettingsScreen.listen((settings) {
      showBarModalBottomSheet(
          context: context, duration: Duration(milliseconds: 300), builder: (context) => SettingScreen(settings));
    });
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionOpenSettingsScreen?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController = RefreshController(initialRefresh: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('earnings_appbar_title'.tr()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
                tooltip: "settings_appbar_title".tr(),
                onPressed: () => _viewModel.openSettingScreen(),
                splashRadius: 25,
                icon: Icon(
                  Icons.settings,
                  size: 27,
                )),
          )
        ],
      ),
      body: Center(
          child: StreamBuilder<List<Earnings>>(
        stream: _viewModel.earnings,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.isNotEmpty)
              return SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropMaterialHeader(),
                  controller: _refreshController,
                  onRefresh: () async {
                    await _viewModel.getData(true);
                    await SysUtils.delay(1);
                    _refreshController.refreshCompleted();
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return EarningsWidget(ValueKey(snapshot.data![index].cryptoCurrency.name), snapshot.data![index]);
                    },
                  ));
            else
              return (Text(
                'empty_earnings_message'.tr(),
                textAlign: TextAlign.center,
              ));
          } else
            return CircularProgressIndicator();
        },
      )),
    );
  }
}
