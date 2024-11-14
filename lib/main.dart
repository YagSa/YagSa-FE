import 'package:flutter/material.dart';
import 'login.dart';
import 'alarm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
    );
  }
}
