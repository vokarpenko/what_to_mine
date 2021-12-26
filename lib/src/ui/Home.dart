import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/earning/EarningScreen.dart';
import 'package:what_to_mine/src/ui/screens/gpu/GpuListScreen.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/HashrateScreen.dart';

import 'screens/prices/CurrencyPricesScreen.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _earningsIconAnimationController;
  late AnimationController _pricesIconAnimationController;
  late AnimationController _gpusIconAnimationController;
  late AnimationController _hashratesIconAnimationController;

  bool earningsIsSelected = true;
  bool pricesIsSelected = false;
  bool gpusIsSelected = false;
  bool hashratesIsSelected = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _earningsIconAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _pricesIconAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _gpusIconAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _hashratesIconAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [EarningScreen(), CurrencyPricesScreen(), GpuListScreen(), HashrateScreen()],
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            label: 'home_earnings'.tr(),
            icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_earningsIconAnimationController),
                child: ImageIcon(AssetImage('assets/icons/earnings_icon.png'))),
          ),
          BottomNavigationBarItem(
            label: 'home_prices'.tr(),
            icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_pricesIconAnimationController),
                child: ImageIcon(AssetImage('assets/icons/prices_icon.png'))),
          ),
          BottomNavigationBarItem(
              icon: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_gpusIconAnimationController),
                  child: ImageIcon(
                    AssetImage('assets/icons/gpus_icon.png'),
                  )),
              label: 'home_gpus'.tr()),
          BottomNavigationBarItem(
              icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_hashratesIconAnimationController),
                child: ImageIcon(AssetImage('assets/icons/hashrates_icon.png')),
              ),
              label: 'home_hashrate'.tr()),
        ],
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int value) {
    setState(() {
      if (_currentIndex == value) return;
      _currentIndex = value;
      switch (_currentIndex) {
        case 0:
          earningsIsSelected = !earningsIsSelected;
          earningsIsSelected ? _earningsIconAnimationController.forward() : _earningsIconAnimationController.reverse();
          break;
        case 1:
          pricesIsSelected = !pricesIsSelected;
          pricesIsSelected ? _pricesIconAnimationController.forward() : _pricesIconAnimationController.reverse();
          break;
        case 2:
          gpusIsSelected = !gpusIsSelected;
          gpusIsSelected ? _gpusIconAnimationController.forward() : _gpusIconAnimationController.reverse();
          break;
        case 3:
          hashratesIsSelected = !hashratesIsSelected;
          hashratesIsSelected
              ? _hashratesIconAnimationController.forward()
              : _hashratesIconAnimationController.reverse();
          break;
      }
    });
  }
}
