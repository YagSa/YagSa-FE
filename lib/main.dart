import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(98, 149, 132, 1)),
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
  final List<MedicationHistory> historyList= [
    MedicationHistory(hour:'06',minute:'23',name: '타이레놀',detail: '식후복용',img_path: 'assets/images/image7.png',),
    MedicationHistory(hour:'13',minute:'02',name: '타이레놀',detail: '식후복용',img_path: 'assets/images/image7.png',),
    MedicationHistory(hour:'20',minute:'40',name: '타이레놀',detail: '식후복용',img_path: 'assets/images/image7.png',)
  ];

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 320,
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color.fromRGBO(238, 238, 238, 1),
                    ),
                    child: Calendar(),
                ),
                SizedBox(height: 15,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '복용 기록',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    width: 500,
                    child: Divider(
                        color: Colors.black,
                        thickness: 3.0,),
                ),
                Expanded(
                  child: ListView(
                    children: historyList,
                  ),
                )
              ],
            ),
          ),
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime(2024, 1, 1),
      lastDay: DateTime(2024, 12, 31),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
          fontSize: 15,
        ),
        leftChevronPadding: EdgeInsets.only(left: 10.0),
        rightChevronPadding: EdgeInsets.only(right: 10.0),
        headerPadding: EdgeInsets.only(top: 10.0,bottom: 10.0),
        formatButtonDecoration: BoxDecoration(
            border: const Border.fromBorderSide(BorderSide()),
            borderRadius: const BorderRadius.all(Radius.circular(11.0))
        ),
        formatButtonPadding: EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 3.0)
      ),
      // 캘린더에서 현재 선택된 날짜를 지정하는 데 사용
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      // 사용자가 캘린더에서 날짜를 선택하면 해당 날짜가 _selectedDay로 업데이트되고
      // 화면이 업데이트되어 선택한 날짜에 대한 변경 사항을 표시
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
    );
  }
}

class MedicationHistory extends StatelessWidget {
  final String hour;
  final String minute;
  final String name;
  final String? detail;
  final String img_path;

  const MedicationHistory({
    super.key,
    required this.hour,
    required this.minute,
    required this.name,
    this.detail,
    required this.img_path
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color.fromRGBO(238, 238, 238, 1),
          ),
        height: 97,
        width: 320,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 복용 시간 및 약명 기록
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${hour}:${minute}',style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold
                    ),
                  ),
                  Text('${name}/${detail}',style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
            // 이미지 삽입
            Image.asset(
                img_path,
                height: 97,
                width: 154,
                fit: BoxFit.cover),
          ],
        ),
      )
    );
  }
}


