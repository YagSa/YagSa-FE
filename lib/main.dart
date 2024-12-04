import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Alarm.init();

  // Android 권한 확인 및 요청
  await checkAndroidScheduleExactAlarmPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationInfoProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  print('Schedule exact alarm permission: $status.');
  if (status.isDenied) {
    print('Requesting schedule exact alarm permission...');
    final res = await Permission.scheduleExactAlarm.request();
    print('Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '약,사',
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Provider.of<MedicationInfoProvider>(context, listen: false)
                .loadFromFirebase();
            Provider.of<ScheduleProvider>(context, listen: false)
                .loadSchedulesFromFirebase();
            return HomePage();
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}
