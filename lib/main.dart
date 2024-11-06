import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main(){

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'CrimsonText',
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text('약, 사', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Color.fromRGBO(226, 241, 231, 1)),),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(98, 149, 132, 1),
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.navigate_before)),
        iconTheme: IconThemeData(color: Color.fromRGBO(226, 241, 231, 1),size: 40),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Calendar()
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(

        focusedDay: DateTime.now(),
        firstDay: DateTime(2024,1,1),
        lastDay: DateTime(2024,12,31)
    );
  }
}
