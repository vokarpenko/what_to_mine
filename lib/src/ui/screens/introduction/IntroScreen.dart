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
        _buildPage('intro_page1_title'.tr(), 'intro_page1_body'.tr(), 'assets/images/intro_page_1.png'),
        _buildPage('intro_page2_title'.tr(), 'intro_page2_body'.tr(), 'assets/images/intro_page_2.png'),
        _buildPage('intro_page3_title'.tr(), 'intro_page3_body'.tr(), 'assets/images/intro_page_3.png')
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

  PageViewModel _buildPage(String title, String body, String imagePath) {
    return PageViewModel(
      decoration: PageDecoration(imageAlignment: Alignment.bottomCenter),
      title: title,
      body: body,
      image: Container(
        margin: EdgeInsets.only(top: 50),
        child: Image.asset(imagePath),
      ),
    );
  }
}
