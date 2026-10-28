import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/earning/earning_screen.dart';
import 'package:what_to_mine/src/ui/screens/prices/currency_prices_screen.dart';
import 'package:what_to_mine/src/ui/screens/rig/rig_screen.dart';
import 'package:what_to_mine/src/ui/screens/settings/settings_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  late final List<Widget?> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EarningScreen(
        onOpenSettings: () => _select(3),
        onOpenRig: () => _select(2),
      ),
      null,
      null,
      null,
    ];
  }

  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index = index;
      _screens[index] ??= switch (index) {
        1 => const CurrencyPricesScreen(),
        2 => const RigScreen(),
        3 => const SettingScreen(),
        _ => const SizedBox.shrink(),
      };
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _screens.length; i++)
          TickerMode(
            enabled: i == _index,
            child: _screens[i] ?? const SizedBox.shrink(),
          ),
      ],
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .6),
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard_rounded),
            label: 'home_earnings'.tr(context: context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.candlestick_chart_outlined),
            selectedIcon: const Icon(Icons.candlestick_chart_rounded),
            label: 'home_prices'.tr(context: context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.memory_outlined),
            selectedIcon: const Icon(Icons.memory_rounded),
            label: 'home_rig'.tr(context: context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: 'settings_appbar_title'.tr(context: context),
          ),
        ],
      ),
    ),
  );
}
