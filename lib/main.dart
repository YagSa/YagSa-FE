import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'alarm.dart';
import 'signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // 기본 시작 페이지 경로
      routes: {
        '/': (context) => AlarmScreen(), // 홈 페이지
        '/login': (context) => LoginPage(), // 로그인 페이지
        '/signup': (context) => SignupPage(), // 프로필 페이지
      },
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
    );
  }
}
