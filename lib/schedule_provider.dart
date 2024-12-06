import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yagsa/utility.dart';
import 'package:alarm/alarm.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> schedules = [];

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
        title: 'Alarm',
        body: 'It\'s time for $title!',
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
          .where('medicationId', isEqualTo: medicationId); // Only load schedules for specific medication


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
  Future<void> addSchedule(String medicationId, String time, bool isEnabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

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
      } else {
        print("Schedule already exists!");
      }
    }
  }


  // update toggle
  Future<void> toggleSchedule(String scheduleId, bool newStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(scheduleId);

      await scheduleRef.update({'isEnabled': newStatus});
      final medicationId = schedules.firstWhere((schedule) => schedule['id'] == scheduleId)['medicationId'];
      await loadSchedulesFromFirebase(medicationId);
    }
  }

  void clearData() {
    schedules = [];
    notifyListeners();
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(scheduleId);
      final medicationId = schedules.firstWhere((schedule) => schedule['id'] == scheduleId)['medicationId'];
      await scheduleRef.delete();
      await loadSchedulesFromFirebase(medicationId);
    }
  }
}
