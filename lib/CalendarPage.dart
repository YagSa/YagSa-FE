import 'package:flutter/material.dart';
import 'package:yagsa/home.dart';
import 'Medication.dart';
import 'calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
        leading: IconButton(onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context)=> HomePage()));
        }, icon: Icon(Icons.navigate_before)),
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
