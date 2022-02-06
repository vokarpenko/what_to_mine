import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashViewModel.dart';
import 'package:what_to_mine/src/utils/UIUtils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateSplashScreen();
  }
}

class StateSplashScreen extends State<SplashScreen> {
  final SplashViewModel _viewModel = SplashViewModel();
  StreamSubscription? _subscriptionOpenNextScreen, _subscriptionError;

  StateSplashScreen();

  @override
  void initState() {
    super.initState();
    _subscriptionOpenNextScreen =
        _viewModel.openNextScreen.listen((screen) => Navigator.pushNamedAndRemoveUntil(context, screen, (_) => false));
    _subscriptionError = _viewModel.errorMessage.listen((error) async {
      await UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr(),
          afterPopFunction: _viewModel.getData, afterPopFunctionDelay: 2);
    });
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionOpenNextScreen?.cancel()
      .._subscriptionError?.cancel()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
          child: SizedBox(
        width: 200,
        height: 200,
        child: Image.asset('assets/images/splash_loading.gif'),
      )),
    );
  }
}
