import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yagsa/utility.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> schedules = [];

  DateTime parseTime(String time) {
    final DateFormat format = DateFormat('hh:mm a');
    try {
      DateTime parsedTime = DateTime.now().copyWith(
        hour: format.parse(time).hour,
        minute: format.parse(time).minute,
        second: 0,
        millisecond: 0,
      );
      DateTime now = DateTime.now();

      if (parsedTime.isBefore(now)) {
        now = now.add(Duration(days: 1));
      }

      print('Parsing time: $now , $parsedTime');

      return now.copyWith(
        hour: parsedTime.hour,
        minute: parsedTime.minute,
        second: 0,
        millisecond: 0,
      );
    } catch (e) {
      print('Error parsing time: $e');
      return DateTime.now();
    }
  }

  Future<void> setDailyAlarm({
    required String id,
    required String dateTime,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id.hashCode,
      dateTime: parseTime(dateTime),
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

  Future<void> stopAlarm(String id) async {
    await Alarm.stop(id.hashCode);
    print('Alarm deleted: $id');
  }

  Future<void> loadAllSchedulesFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules'); // Remove filtering condition

      final querySnapshot = await scheduleCollection.get();

      schedules = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'time': data['time'],
          'isEnabled': data['isEnabled'],
          'medicationId': data['medicationId'], // Keep medicationId field
        };
      }).toList();

      notifyListeners();
    }
  }

  // load schedule data from Firebase
  Future<void> loadSchedulesFromFirebase(String medicationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .where('medicationId',
              isEqualTo:
                  medicationId); // Only load schedules for specific medication

      final querySnapshot = await scheduleCollection.get();

      schedules = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'time': data['time'],
          'isEnabled': data['isEnabled'],
          'medicationId': data['medicationId'],
        };
      }).toList();

      notifyListeners();
    }
  }

  // add new schedule data to Firestore and update
  Future<void> addSchedule(String medicationId, String time, bool isEnabled,
      String title, String body) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      String formattedTime = formatTime(time);

      final scheduleCollection = userDoc.collection('schedules');
      final existingSchedule = await scheduleCollection
          .where('medicationId', isEqualTo: medicationId)
          .where('time', isEqualTo: formattedTime)
          .get();

      if (existingSchedule.docs.isEmpty) {
        final newSchedule = {
          'medicationId': medicationId,
          'time': time,
          'isEnabled': isEnabled,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await userDoc.collection('schedules').add(newSchedule);
        await loadSchedulesFromFirebase(medicationId);

        setDailyAlarm(
          id: time,
          dateTime: time,
          title: title,
          body: body,
        );
      } else {
        print("Schedule already exists!");
      }
    }
  }

  // update toggle
  Future<void> toggleSchedule(
      String scheduleId, bool newStatus, bool loadAll) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(scheduleId);

      await scheduleRef.update({'isEnabled': newStatus});
      final medicationId = schedules.firstWhere(
          (schedule) => schedule['id'] == scheduleId)['medicationId'];
      loadAll
          ? await loadAllSchedulesFromFirebase()
          : await loadSchedulesFromFirebase(medicationId);
    }
  }

  void clearData() {
    schedules = [];
    notifyListeners();
  }

  Future<void> deleteSchedule(String scheduleId, bool loadAll) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(scheduleId);
      final medicationId = schedules.firstWhere(
          (schedule) => schedule['id'] == scheduleId)['medicationId'];
      await scheduleRef.delete();
      loadAll
          ? await loadAllSchedulesFromFirebase()
          : await loadSchedulesFromFirebase(medicationId);
    }
  }
}
