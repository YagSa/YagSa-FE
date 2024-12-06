import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'edit_page.dart';
import 'login.dart';
import 'medication_info_page.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';
import 'CalendarPage.dart';
import 'alarm.dart';
import 'permission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alarm_test.dart';
import 'notification_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  List<AlarmSettings> alarms = [];
  static StreamSubscription<AlarmSettings>? ringSubscription;
  static StreamSubscription<int>? updateSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();

    AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    unawaited(loadAlarms());
    ringSubscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    updateSubscription ??= Alarm.updateStream.stream.listen((_) {
      unawaited(loadAlarms());
    });
    // Load medication and schedule data from Firebase when the HomePage is initialized
  }

  // Load data with error handling
  Future<void> _loadData() async {
    try {
      await Provider.of<ScheduleProvider>(context, listen: false)
          .loadAllSchedulesFromFirebase();
      await Provider.of<MedicationInfoProvider>(context, listen: false)
          .loadFromFirebase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load ')),
      );
    }
  }

  Future<void> loadAlarms() async {
    final updatedAlarms = await Alarm.getAlarms();
    updatedAlarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    setState(() {
      alarms = updatedAlarms;
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AlarmScreen(alarmSettings: alarmSettings),
      ),
    );
    unawaited(loadAlarms());
  }

  Future<void> _setDailyAlarm({
    required String id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id.hashCode,
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.MP3',
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'app_icon',
      ),
      loopAudio: true,
      vibrate: true,
      volume: 0.1,
      volumeEnforced: true,
      fadeDuration: 0.0,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print('Alarm set: $title at $dateTime');
  }

  Future<void> _stopAlarm(String id) async {
    await Alarm.stop(id.hashCode);
    print('Alarm deleted: $id');
  }

  DateTime parseTime(String time) {
    final DateFormat format = DateFormat('hh:mm a');
    try {
      DateTime parsedTime = format.parse(time);
      return DateTime.now().copyWith(
          hour: parsedTime.hour,
          minute: parsedTime.minute,
          second: 0,
          millisecond: 0);
    } catch (e) {
      print('Error parsing time: $e');
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationInfoProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          '약,사',
          style: TextStyle(
            fontFamily: 'Tenada',
            fontSize: 35,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 32),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Provider.of<MedicationInfoProvider>(context, listen: false)
                  .clearData();
              Provider.of<ScheduleProvider>(context, listen: false).clearData();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SplashScreen()));
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
            const Text(
              '금일 복용 일정',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),
            Expanded(
              child: scheduleProvider.schedules.isEmpty
              ? const Center(
                  child: Text("등록된 약물이 없습니다."))
              : ListView.builder(
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
                    onDismissed: (direction) async {
                      await _stopAlarm(schedule['id']);
                      scheduleProvider.deleteSchedule(schedule['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 시간이 삭제되었습니다')),
                      );
                    },
                    child: buildAlarmTile(
                      schedule['time'],
                      //(String time, String name, String additionalInfo, bool isActive, Function(bool) onChanged)
                      medicationProvider.medications.firstWhere((item) =>
                          item['id'] == schedule['medicationId'])['name'],
                      medicationProvider.medications.firstWhere((item) =>
                        item['id'] == schedule['medicationId'])['additionalInfo'],
                      schedule['isEnabled'],
                      (value) {
                        setState(() {
                          try {
                            DateTime alarmTime = parseTime(schedule['time']);
                            print('Parsed alarm time: $alarmTime');
                            scheduleProvider.toggleSchedule(
                                schedule['id'], value);
                          } catch (e) {
                            print('Error parsing time: $e');
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                        builder: (context) =>
                            const EditAllInfoPage(isNewMedication: true),
                      ),
                    );
                    await Provider.of<MedicationInfoProvider>(context,
                            listen: false)
                        .loadFromFirebase();
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),
            Expanded(
              child: medicationProvider.medications.isEmpty
                  ? const Center(
                      child: Text("등록된 약물이 없습니다.")) // No medications found
                  : ListView.builder(
                      itemCount: medicationProvider.medications.length,
                      itemBuilder: (context, index) {
                        final medication =
                            medicationProvider.medications[index];
                        return Dismissible(
                          key: Key(
                              medication['id']), // Unique key for each schedule
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            Provider.of<MedicationInfoProvider>(context,
                                    listen: false)
                                .deleteMedication(medication['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('약물이 삭제되었습니다')),
                            );
                          },
                          child: buildMedicationTile(
                            medication['name'],
                            medication['usageDuration'],
                            medication['additionalInfo'],
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MedicationInfoPage(
                                    isNewMedication: false,
                                    medicationId: medication['id'],
                                  ),
                                ),
                              );
                              await Provider.of<MedicationInfoProvider>(context,
                                      listen: false)
                                  .loadFromFirebase();
                            },
                          ),
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

  Widget buildAlarmTile(String time, String title, String description,
      bool isActive, Function(bool) onChanged) {
    return Card(
      child: ListTile(
        title: Text(
          time,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {
            onChanged(value);
            try {
              DateTime alarmTime = parseTime(time);
              if (value) {
                _setDailyAlarm(
                  id: time,
                  dateTime: alarmTime,
                  title: title,
                  body: description,
                );
              } else {
                _stopAlarm(time);
              }
            } catch (e) {
              print('Error parsing time: $e');
            }
          },
          activeTrackColor: Color(0xFF243642),
        ),
      ),
    );
  }

  Widget buildMedicationTile(
      String name, String usageDuration, String additionalInfo,
      {required VoidCallback onTap}) {
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
              //TODO
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
            icon:
                const Icon(Icons.calendar_today, color: Colors.white, size: 32),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CalendarPage()));
            },
          ),
        ),
      ],
    ),
  );
}
