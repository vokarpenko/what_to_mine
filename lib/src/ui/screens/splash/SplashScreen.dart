import 'dart:async';

import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashViewModel.dart';

class SplashScreen extends StatefulWidget {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  State<StatefulWidget> createState() {
    return StateSplashScreen(_viewModel);
  }
}

class StateSplashScreen extends State<SplashScreen> {
  final SplashViewModel _viewModel;
  StreamSubscription? _subscriptionOpenNextScreen;

  StateSplashScreen(this._viewModel);

  @override
  void initState() {
    super.initState();
    _subscriptionOpenNextScreen =
        _viewModel.openNextScreen.listen((screen) => Navigator.pushNamedAndRemoveUntil(context, screen, (_) => false));
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.onViewDispose();
    _subscriptionOpenNextScreen?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
          child: Container(
            width: 200,
            height: 200,
            child: Image.asset('assets/images/splash_loading.gif'),
          )),
    );
  }
}
