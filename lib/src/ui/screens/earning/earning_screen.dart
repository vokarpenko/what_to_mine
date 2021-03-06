import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/ui/screens/settings/settings_screen.dart';
import 'package:what_to_mine/src/ui/widgets/earnings_widget.dart';
import 'package:what_to_mine/src/utils/sys_utils.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

import 'earning_view_model.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EarningScreenState();
  }
}

class EarningScreenState extends State<EarningScreen> {
  final EarningViewModel _viewModel = EarningViewModel();
  StreamSubscription? _subscriptionOpenSettingsScreen, _subscriptionError;

  EarningScreenState();

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    _subscriptionOpenSettingsScreen = _viewModel.openSettingsScreen.listen((settings) {
      showBarModalBottomSheet(
          context: context, duration: const Duration(milliseconds: 300), builder: (context) => SettingScreen(settings));
    });
    _subscriptionError = _viewModel.errorMessage.listen((error) {
      UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr());
    });
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionOpenSettingsScreen?.cancel()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController = RefreshController(initialRefresh: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('earnings_appbar_title'.tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
                tooltip: "settings_appbar_title".tr(),
                onPressed: () => _viewModel.openSettingScreen(),
                splashRadius: 25,
                icon: const Icon(
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
            if (snapshot.data!.isNotEmpty) {
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
                      return EarningsWidget(ValueKey(snapshot.data![index].cryptoCurrency.name), snapshot.data![index]);
                    },
                  ));
            } else {
              return _buildEmptyEarningsListWidget();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      )),
    );
  }

  Widget _buildEmptyEarningsListWidget() {
    Brightness brightness = Theme.of(context).brightness;
    String imagePath =
        brightness == Brightness.light ? 'assets/images/not_earnings.png' : 'assets/images/not_earnings_bw.png';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.fitWidth,
          width: MediaQuery.of(context).size.width * 0.6,
        ),
        Container(
          padding: const EdgeInsets.only(top: 30, left: 5, right: 5),
          child: Text(
            'empty_earnings_message'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
