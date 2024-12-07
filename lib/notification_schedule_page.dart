import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSchedulePage extends StatefulWidget {
  final String medicationId;
  const NotificationSchedulePage({super.key, required this.medicationId});

  @override
  _NotificationSchedulePageState createState() =>
      _NotificationSchedulePageState();
}

class _NotificationSchedulePageState extends State<NotificationSchedulePage> {
  final user = FirebaseAuth.instance.currentUser;

  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedDay = "월요일"; // default
  final List<String> daysOfWeek = [
    "월요일",
    "화요일",
    "수요일",
    "목요일",
    "금요일",
    "토요일",
    "일요일"
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
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "일정 추가",
          style: TextStyle(
            fontFamily: 'Tenada',
            fontSize: 30,
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
                fontFamily: 'Tenada',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1, color: Colors.black),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText:
                        "시간: ${formatTimeOfDay(selectedTime)}", // Display selected time
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          NotificationSchedule schedule = NotificationSchedule(
                            time: selectedTime,
                          );
                          await Provider.of<ScheduleProvider>(context,
                                  listen: false)
                              .addSchedule(
                            widget.medicationId, // Pass the medicationId here
                            formatTimeOfDay(selectedTime),
                            true,
                          );
                          await Provider.of<ScheduleProvider>(context,
                                  listen: false)
                              .loadSchedulesFromFirebase(widget.medicationId);
                          Navigator.pop(context, schedule);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('error: $e')),
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(400, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Color(0xFF243642), // 테두리 색상
                            width: 2, // 테두리 두께
                          ), // 테두리 두께
                        ),
                        backgroundColor: Color(0xFF243642),
                      ),
                      child: Text(
                        '저장하기',
                        style:
                            TextStyle(color: Color(0xFFEEEEEE), fontSize: 19),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSchedule {
  TimeOfDay time;
  bool isEnabled;

  NotificationSchedule({required this.time, this.isEnabled = true});
}
