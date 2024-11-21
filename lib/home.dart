import 'package:flutter/material.dart';
import 'CalendarPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authentication = FirebaseAuth.instance;

  // Alarm toggle states
  bool alarm1 = false;
  bool alarm2 = false;
  bool alarm3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '약, 사',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(98, 149, 132, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign out button
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SplashScreen()));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Color(0xFFEEEEEE), // 테두리 색상
                      width: 2, // 테두리 두께
                    ),
                  ),
                  backgroundColor: Color(0xFF629584),
                ),
                child: Text(
                  'Sign out',
                  style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 20),
                ),
              ),
              SizedBox(height: 16),
              // "금일 복용 일정" section
              Text(
                '금일 복용 일정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(thickness: 1, color: Colors.grey), // Divider line
              SizedBox(height: 8),
              buildAlarmTile('06:00', '타이레놀 / 식후 복용', alarm1, (value) {
                setState(() {
                  alarm1 = value;
                });
              }),
              buildAlarmTile('12:00', '타이레놀 / 식후 복용', alarm2, (value) {
                setState(() {
                  alarm2 = value;
                });
              }),
              buildAlarmTile('18:00', '타이레놀 / 식후 복용', alarm3, (value) {
                setState(() {
                  alarm3 = value;
                });
              }),
              SizedBox(height: 24),
              // "관리 약물 목록" section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '관리 약물 목록',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Add functionality for adding new medication
                    },
                  ),
                ],
              ),
              Divider(thickness: 1, color: Colors.grey), // Divider line
              SizedBox(height: 8),
              buildMedicationTile('타이레놀', '1일 3회 / 식후 복용', '2024.10.26~2024.11.07'),
              buildMedicationTile('이부프로펜', '1일 2회 / 식후 복용', '2024.10.26~2024.11.07'),
              buildMedicationTile('아스피린', '1일 1회 / 식후 복용', '2024.10.26~2024.11.07'),
            ],
          ),
        ),
      ),
      floatingActionButton: buildCustomButton(context), // Corrected position of custom button
    );
  }

  // Widget to build each alarm tile
  Widget buildAlarmTile(String time, String description, bool isActive, Function(bool) onChanged) {
    return Card(
      child: ListTile(
        title: Text(
          time,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Switch(
          value: isActive,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Widget to build each medication tile
  Widget buildMedicationTile(String name, String dosage, String duration) {
    return Card(
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$dosage\n$duration'),
        onTap: () {
          // Add functionality for editing medication
        },
      ),
    );
  }
}

// Custom button for camera & calendar
Widget buildCustomButton(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    decoration: BoxDecoration(
      color: Color.fromRGBO(98, 149, 132, 1), // 녹색 배경
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.videocam,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            // Camera button functionality
          },
        ),
        VerticalDivider(
          color: Colors.white,
          thickness: 2,
          width: 20,
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            );
          },
        ),
      ],
    ),
  );
}
