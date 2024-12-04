import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import 'edit_page.dart';
import 'login.dart';
import 'medication_info_page.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';
import 'CalendarPage.dart';
import 'alarm.dart';
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
    // Load medication and schedule data from Firebase when the HomePage is initialized
    Provider.of<MedicationInfoProvider>(context, listen: false).loadFromFirebase();
    Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
  }

  // 알람 설정 함수
  Future<void> _setAlarm({
    required String id,
    required DateTime dateTime,
    required String title,
  }) async {
    // 알람 설정
    final alarmSettings = AlarmSettings(
      id: id.hashCode, // Unique identifier for the alarm
      dateTime: dateTime, // Alarm time
      assetAudioPath: 'assets/alarm.mp3', // Path to alarm sound in assets
      notificationSettings: NotificationSettings(
        title: 'Alarm', // Notification title
        body: 'It\'s time for $title!', // Notification body
        stopButton: 'Stop', // Optional: Label for the stop button
        icon: 'app_icon', // Optional: Custom notification icon (drawable resource name)
      ),
      loopAudio: true, // Should the alarm sound loop
      vibrate: true, // Should the phone vibrate
      volume: 1.0, // Set alarm volume (1.0 is 100%)
      volumeEnforced: true, // Enforce the set volume
      fadeDuration: 0.0, // Duration of fade-in for the alarm sound
      warningNotificationOnKill: true, // Show warning if app is killed
      androidFullScreenIntent: true, // Launch a full-screen intent for the alarm
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print('Alarm set: $title at $dateTime');
  }

  // 알람 삭제 함수
  Future<void> _deleteAlarm(String id) async {
    await Alarm.stop(id.hashCode);
    print('Alarm deleted: $id');
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationInfoProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '약, 사',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 32),
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
            const SizedBox(height: 16),

            // "금일 복용 일정" section
            const Text(
              '금일 복용 일정',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1, color: Colors.grey), // Divider line
            const SizedBox(height: 8),

            // Separate scrolling for today's schedule
            Expanded(
              child: ListView.builder(
                itemCount: scheduleProvider.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleProvider.schedules[index];
                  return Dismissible(
                    key: Key(schedule['id']), // Unique key for each schedule
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      // 알람 삭제
                      await _deleteAlarm(schedule['id']);
                      scheduleProvider.deleteSchedule(schedule['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 시간이 삭제되었습니다')), // Notification time has been deleted
                      );
                    },
                    child: buildAlarmTile(
                      schedule['time'],
                      schedule['dayOfWeek'],
                      schedule['isEnabled'],
                          (value) async {
                        scheduleProvider.toggleSchedule(schedule['id'], value);
                        if (value) {
                          await _setAlarm(
                            id: schedule['id'],
                            dateTime: DateTime.parse(schedule['time']),
                            title: '알람',
                          );
                        } else {
                          await _deleteAlarm(schedule['id']);
                        }
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
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationInfoPage(isNewMedication: true),
                        ),
                      );
                    },
                  ),
                ]),
            const Divider(thickness: 1, color: Colors.grey), // Divider line
            const SizedBox(height: 8),

            // Separate scrolling for medication list
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
                      // Navigate to MedicationInfoPage to edit existing medication
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
            icon: const Icon(Icons.videocam, color: Colors.white, size: 32),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AlarmScreen()));
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
            icon: const Icon(Icons.calendar_today, color: Colors.white, size: 32),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarPage()));
            },
          ),
        ),
      ],
    ),
  );
}
