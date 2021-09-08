import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/splash/SplashScreen.dart';

import 'src/ui/Home.dart';
import 'src/ui/screens/ScreenRoutes.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: ScreenRoutes.splashScreen,
        routes: {
          ScreenRoutes.splashScreen: (BuildContext context) => SplashScreen(),
          ScreenRoutes.homeScreen: (BuildContext context) => Home()
        });
  }
}
