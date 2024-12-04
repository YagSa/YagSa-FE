import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();

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

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '약,사',
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if(snapshot.hasData){
          Provider.of<MedicationInfoProvider>(context, listen: false).loadFromFirebase();
          Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
          return HomePage();
        }else{
          return SplashScreen();
        }
      })
    );
  }
}
