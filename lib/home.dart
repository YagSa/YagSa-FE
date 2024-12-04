import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_page.dart';
import 'login.dart';
import 'medication_info_page.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';
import 'CalendarPage.dart';
import 'notification_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Provider.of<MedicationInfoProvider>(context, listen: false).loadFromFirebase();
    Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationInfoProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: const Text(
          '약, 사',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 흰색으로 변경
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 32),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Provider.of<MedicationInfoProvider>(context, listen: false).clearData();
              Provider.of<ScheduleProvider>(context, listen: false).schedules = [];
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SplashScreen()));
            },
          ),
        ],
        backgroundColor: const Color.fromRGBO(98, 149, 132, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "금일 복용 일정" section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '금일 복용 일정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // 시계 아이콘 버튼
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () async {
                      final newSchedule = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSchedulePage(),
                        ),
                      );
                      if (newSchedule != null) {
                        Provider.of<ScheduleProvider>(context, listen: false).addSchedule(
                          newSchedule.dayOfWeek,
                          newSchedule.time.format(context),
                          newSchedule.isEnabled,
                        );
                        await Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey), // Divider line
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: scheduleProvider.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleProvider.schedules[index];
                  return Dismissible(
                    key: Key(schedule['id']),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(schedule['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 시간이 삭제되었습니다')),
                      );
                    },
                    child: buildAlarmTile(
                      schedule['time'],
                      schedule['dayOfWeek'],
                      schedule['isEnabled'],
                          (value) {
                        scheduleProvider.toggleSchedule(schedule['id'], value);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // "관리 약물 목록" section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '관리 약물 목록',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // '+' 버튼
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      Provider.of<MedicationInfoProvider>(context, listen: false).clearData();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditAllInfoPage(isNewMedication: true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: medicationProvider.medications.length,
                itemBuilder: (context, index) {
                  final medication = medicationProvider.medications[index];
                  return buildMedicationTile(
                    medication['name'],
                    medication['usageDuration'],
                    medication['additionalInfo'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationInfoPage(
                            isNewMedication: false,
                            medicationIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: buildCustomButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildAlarmTile(String time, String description, bool isActive, Function(bool) onChanged) {
    return Card(
      child: ListTile(
        title: Text(
          time,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Switch(
          value: isActive,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildMedicationTile(String name, String usageDuration, String additionalInfo, {required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$usageDuration\n$additionalInfo"),
        onTap: onTap,
      ),
    );
  }
}

Widget buildCustomButton(BuildContext context) {
  return Container(
    width: 150,
    height: 60,
    decoration: BoxDecoration(
      color: const Color.fromRGBO(98, 149, 132, 1),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
            icon: const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              // Camera button functionality
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: VerticalDivider(
            color: Colors.white,
            thickness: 2,
            width: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: IconButton(
            icon: const Icon(
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
        ),
      ],
    ),
  );
}
