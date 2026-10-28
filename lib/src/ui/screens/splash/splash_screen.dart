import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_view_model.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';
import 'splash_coin_toss.dart';

class SplashScreen extends StatefulWidget {
  final SplashViewModel? viewModel;

  const SplashScreen({this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() {
    return StateSplashScreen();
  }
}

class StateSplashScreen extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Та же монета и тот же размер, что и на нативном сплэше
  // (@drawable/splash_coin, @dimen/splash_coin_size)
  static const _coin = AssetImage('assets/images/splash_coin.png');
  static const _coinSize = 128.0;

  late final SplashViewModel _viewModel = widget.viewModel ?? SplashViewModel();
  late final AnimationController _toss;
  String? _readyScreen;
  bool _animationFinished = false;
  bool _navigating = false;
  StreamSubscription? _subscriptionOpenNextScreen, _subscriptionError;
  bool _coinPrecached = false;

  StateSplashScreen();

  @override
  void initState() {
    super.initState();
    _toss = AnimationController(vsync: this, duration: SplashCoinToss.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationFinished = true;
          _openWhenReady();
        }
      });
    _subscriptionOpenNextScreen = _viewModel.openNextScreen.listen((screen) {
      if (!mounted) return;
      _readyScreen = screen;
      _openWhenReady();
    });
    _subscriptionError = _viewModel.errorMessage.listen((error) async {
      if (!mounted) return;
      _readyScreen = null;
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
    precacheImage(_coin, context).whenComplete(() {
      WidgetsBinding.instance.allowFirstFrame();
      if (!mounted) return;
      // Start only after Flutter has painted the same static coin as Android.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.disableAnimationsOf(context)) {
          _toss.value = 1;
        } else {
          _toss.forward();
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    });
  }

  void _openWhenReady() {
    if (!mounted ||
        _navigating ||
        !_animationFinished ||
        _readyScreen == null) {
      return;
    }
    _navigating = true;
    Navigator.pushNamedAndRemoveUntil(context, _readyScreen!, (_) => false);
  }

  @override
  void dispose() {
    _subscriptionOpenNextScreen?.cancel();
    _subscriptionError?.cancel();
    _toss.dispose();
    _viewModel.onViewDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerY =
              constraints.maxHeight / 2 +
              _navigationBarCompensation(context, constraints.maxHeight);
          final rise = math.min(
            140.0,
            math.max(
              0.0,
              centerY - _coinSize / 2 - MediaQuery.paddingOf(context).top - 24,
            ),
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: centerY - _coinSize / 2,
                left: 0,
                right: 0,
                child: Center(
                  child: SplashCoinToss(
                    animation: _toss,
                    image: _coin,
                    size: _coinSize,
                    maxRise: rise,
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
