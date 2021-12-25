import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:what_to_mine/src/ui/screens/ScreenRoutes.dart';
import 'package:what_to_mine/src/ui/screens/introduction/IntroViewModel.dart';

class IntroScreen extends StatefulWidget {
  final IntroViewModel _viewModel = IntroViewModel();

  @override
  State<StatefulWidget> createState() {
    return IntroScreenState(_viewModel);
  }
}

class IntroScreenState extends State<IntroScreen> {
  IntroViewModel _viewModel;
  StreamSubscription? _subscriptionOpenHomeScreen;

  IntroScreenState(this._viewModel);

  @override
  void initState() {
    super.initState();

    _subscriptionOpenHomeScreen = _viewModel.openHomeScreen
        .listen((_) => Navigator.pushNamedAndRemoveUntil(context, ScreenRoutes.homeScreen, (_) => false));

    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.onViewDispose();
    _subscriptionOpenHomeScreen?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        _buildPage("", "", Container()),
        _buildPage("", "", Container()),
      ],
      onDone: () {
        _viewModel.onDone();
      },
      onSkip: () {
        _viewModel.onDone();
      },
      showSkipButton: true,
      skip: Text("intro_go_skip".tr()),
      next: Icon(Icons.navigate_next),
      done: Text('intro_go_start'.tr(), style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
    );
  }

  PageViewModel _buildPage(String? title, String? body, Widget? image) {
    return PageViewModel(
      title: "Title of first page",
      body: "Here you can write the description of the page, to explain someting...",
      image: const Center(child: Icon(Icons.android)),
      footer: ElevatedButton(
        onPressed: () {
          // On button presed
        },
        child: const Text("Let's Go !"),
      ),
    );
  }
}
