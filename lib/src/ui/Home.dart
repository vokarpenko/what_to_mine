import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/earning/EarningScreen.dart';
import 'package:what_to_mine/src/ui/screens/gpus/GpuListScreen.dart';

import 'screens/prices/CurrencyPricesScreen.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [EarningScreen(), CurrencyPricesScreen(), GPUListScreen()],
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            label: "Доходы",
            icon: Icon(Icons.stream),
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_dollar), label: "Курсы"),
          BottomNavigationBarItem(icon: Icon(Icons.personal_video_outlined), label: "Видеокарты")
        ],
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int value) {
    setState(() {
      _currentIndex = value;
    });
  }
}
