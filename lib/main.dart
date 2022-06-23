import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/wheel_item.dart';

import 'pages/home.dart';
import 'pages/number.dart';
import 'pages/wheel.dart';
import 'pages/wheel_edit.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WheelTextAdapter());
  await Hive.openBox('decise');

  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(primary: Colors.black),
      ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routes: {
        '/': (context) => HomePage(),
        '/number': (context) => NumberPage(),
        '/wheel': (context) => WheelPage(),
        '/wheelEdit': (context) => WheelEditPage(),
      },
    );
  }
}
