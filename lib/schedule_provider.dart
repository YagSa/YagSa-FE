import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> schedules = [];

  // load schedule data from Firebase
  Future<void> loadSchedulesFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scheduleCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      final querySnapshot = await scheduleCollection.get();

      schedules = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'dayOfWeek': data['dayOfWeek'],
          'time': data['time'],
          'isEnabled': data['isEnabled'],
        };
      }).toList();

      notifyListeners();
    }
  }

  // add new schedule data to Firestore and update
  Future<void> addSchedule(String dayOfWeek, String time, bool isEnabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final newSchedule = {
        'dayOfWeek': dayOfWeek,
        'time': time,
        'isEnabled': isEnabled,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDoc.collection('schedules').add(newSchedule);
      await loadSchedulesFromFirebase();
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
      await loadSchedulesFromFirebase();
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
      await scheduleRef.delete();
      await loadSchedulesFromFirebase();
    }
  }
}
