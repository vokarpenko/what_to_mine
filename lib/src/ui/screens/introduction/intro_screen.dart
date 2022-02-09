import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../screen_routes.dart';
import 'intro_view_model.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IntroScreenState();
  }
}

class IntroScreenState extends State<IntroScreen> {
  final IntroViewModel _viewModel = IntroViewModel();
  StreamSubscription? _subscriptionOpenHomeScreen;
  double selectedItem = 0.1;

  IntroScreenState();

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
        _buildPage('intro_page3_title'.tr(), 'intro_page3_body'.tr(), 'assets/images/intro_page_3.png'),
        _buildElectricityCostPage()
      ],
      onDone: () {
        _viewModel.onDone(selectedItem);
      },
      onSkip: () {
        _viewModel.onSkip();
      },
      showSkipButton: true,
      skip: Text("intro_go_skip".tr()),
      next: const Icon(Icons.navigate_next),
      done: Text('intro_go_start'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
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
      decoration: const PageDecoration(imageAlignment: Alignment.bottomCenter),
      title: title,
      body: body,
      image: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Image.asset(imagePath),
      ),
    );
  }

  PageViewModel _buildElectricityCostPage() {
    List<double> items = [];
    for (int i = 1; i <= 40; i++) {
      double item = 0.01 * i;
      items.add(double.parse(item.toStringAsFixed(2)));
    }

    return PageViewModel(
      decoration: const PageDecoration(imageAlignment: Alignment.bottomCenter),
      title: 'intro_page4_title'.tr(),
      bodyWidget: SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: CupertinoPicker(
            diameterRatio: 2,
            scrollController: FixedExtentScrollController(initialItem: 9),
            children: items.map<DropdownMenuItem<double>>((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Center(
                  child: Text(
                    value.toStringAsFixed(2) + ' USD',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              );
            }).toList(),
            onSelectedItemChanged: (int selected) {
              setState(() {
                selectedItem = items.elementAt(selected);
              });
            },
            itemExtent: 50,
          )),
      image: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Image.asset('assets/images/intro_page_4.png'),
      ),
    );
  }
}
