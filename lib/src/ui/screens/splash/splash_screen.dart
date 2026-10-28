import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../design/app_ui.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_view_model.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    _subscriptionOpenNextScreen = _viewModel.openNextScreen.listen((screen) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, screen, (_) => false);
    });
    _subscriptionError = _viewModel.errorMessage.listen((error) async {
      if (!mounted) return;
      await UIUtils.showAlertDialog(
        context,
        'error'.tr(context: context),
        error,
        'ok'.tr(context: context),
        afterPopFunction: _viewModel.getData,
        afterPopFunctionDelay: 2,
      );
    });
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionOpenNextScreen?.cancel()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.bolt_rounded, size: 48, color: mint),
            ),
            const SizedBox(height: 26),
            Text(
              'What to mine',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'loading_markets'.tr(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 90,
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
