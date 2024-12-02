import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSchedulePage extends StatefulWidget {
  const NotificationSchedulePage({super.key});

  @override
  _NotificationSchedulePageState createState() => _NotificationSchedulePageState();
}

class _NotificationSchedulePageState extends State<NotificationSchedulePage> {
  final user = FirebaseAuth.instance.currentUser;

  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedDay = "월요일"; // default
  final List<String> daysOfWeek = [
    "월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"
  ]; // Days of the week

  bool isLoading = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "일정 편집",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(98, 149, 132, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "알림 시간 선택", // "Select Notification Time"
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1, color: Colors.black),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "시간: ${selectedTime.format(context)}", // Display selected time
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            const Text(
              "요일 선택", // "Select Day of the Week"
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1, color: Colors.black),
            const SizedBox(height: 4.0),
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: daysOfWeek.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                        isLoading = true; // Bắt đầu tải
                        });
                        try {
                          NotificationSchedule schedule = NotificationSchedule(
                            dayOfWeek: selectedDay,
                            time: selectedTime,
                          );
                          await Provider.of<ScheduleProvider>(context, listen: false).addSchedule(
                            selectedDay,
                            formatTimeOfDay(selectedTime),
                            true,
                          );
                          await Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
                          Navigator.pop(context, schedule);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('error: $e')),
                           );
                        } finally {
                            setState(() {
                            isLoading = false; // Dừng tải
                          });
                         }
                        },
                        style: ElevatedButton.styleFrom(iconColor: Colors.teal),
                        child: const Text('저장', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSchedule {
  String dayOfWeek;
  TimeOfDay time;
  bool isEnabled;

  NotificationSchedule({required this.dayOfWeek, required this.time, this.isEnabled = true});
}
