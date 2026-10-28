import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  // Та же монета и тот же размер, что и на нативном сплэше
  // (@drawable/splash_coin, @dimen/splash_coin_size)
  static const _coin = AssetImage('assets/images/splash_coin.png');
  static const _coinSize = 128.0;

  final SplashViewModel _viewModel = SplashViewModel();
  StreamSubscription? _subscriptionOpenNextScreen, _subscriptionError;
  bool _coinPrecached = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_coinPrecached) return;
    _coinPrecached = true;
    // Нативный сплэш висит до первого кадра Flutter: придерживаем кадр,
    // пока монета не декодирована, иначе мелькнёт экран без неё
    WidgetsBinding.instance.deferFirstFrame();
    precacheImage(
      _coin,
      context,
    ).whenComplete(WidgetsBinding.instance.allowFirstFrame);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerY =
              constraints.maxHeight / 2 +
              _navigationBarCompensation(context, constraints.maxHeight);
          return Stack(
            children: [
              Positioned(
                top: centerY - _coinSize / 2,
                left: 0,
                right: 0,
                child: const Center(
                  child: Image(
                    image: _coin,
                    width: _coinSize,
                    height: _coinSize,
                  ),
                ),
              ),
              Positioned(
                top: centerY + _coinSize / 2 + 26,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: Column(
                    children: [
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
              ),
            ],
          );
        },
      ),
    );
  }

  // Нативный сплэш центрирует монету по всему экрану. До Android 15 Flutter
  // не рисует под навигационной панелью, и центр его экрана выше на половину
  // её высоты. Большую разницу (multi-window) не компенсируем.
  double _navigationBarCompensation(BuildContext context, double viewHeight) {
    final display = View.of(context).display;
    final gap = display.size.height / display.devicePixelRatio - viewHeight;
    return gap > 0 && gap < 100 ? gap / 2 : 0;
  }
}
