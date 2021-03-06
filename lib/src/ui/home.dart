import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/earning/earning_screen.dart';
import 'package:what_to_mine/src/ui/screens/gpu/gpu_list_screen.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/hashrate_screen.dart';
import 'package:what_to_mine/src/ui/screens/prices/currency_prices_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _earningsIconAnimationController,
      _pricesIconAnimationController,
      _gpusIconAnimationController,
      _hashratesIconAnimationController;

  bool earningsIsSelected = true, pricesIsSelected = false, gpusIsSelected = false, hashratesIsSelected = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _earningsIconAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pricesIconAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _gpusIconAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _hashratesIconAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._earningsIconAnimationController.dispose()
      .._pricesIconAnimationController.dispose()
      .._gpusIconAnimationController.dispose()
      .._hashratesIconAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: const [EarningScreen(), CurrencyPricesScreen(), GpuListScreen(), HashrateScreen()],
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
                child: const ImageIcon(AssetImage('assets/icons/earnings_icon.png'))),
          ),
          BottomNavigationBarItem(
            label: 'home_prices'.tr(),
            icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_pricesIconAnimationController),
                child: const ImageIcon(AssetImage('assets/icons/prices_icon.png'))),
          ),
          BottomNavigationBarItem(
              icon: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_gpusIconAnimationController),
                  child: const ImageIcon(
                    AssetImage('assets/icons/gpus_icon.png'),
                  )),
              label: 'home_gpus'.tr()),
          BottomNavigationBarItem(
              icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_hashratesIconAnimationController),
                child: const ImageIcon(AssetImage('assets/icons/hashrates_icon.png')),
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
