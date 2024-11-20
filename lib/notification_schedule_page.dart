import 'package:flutter/material.dart';

class NotificationSchedulePage extends StatefulWidget {
  const NotificationSchedulePage({super.key});

  @override
  _NotificationSchedulePageState createState() => _NotificationSchedulePageState();
}

class _NotificationSchedulePageState extends State<NotificationSchedulePage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedDay = "월요일"; // default
  final List<String> daysOfWeek = [
    "월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"
  ]; // Days of the week

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "알림 시간 선택", // "Select Notification Time"
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
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
        const SizedBox(height: 16.0),
        const Text(
          "요일 선택", // "Select Day of the Week"
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
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
          child: ElevatedButton(
            onPressed: () {
              NotificationSchedule schedule = NotificationSchedule(
                dayOfWeek: selectedDay,
                time: selectedTime,
              );
              // This can be passed to a parent widget or saved as needed.
            },
            style: ElevatedButton.styleFrom(iconColor: Colors.teal),
            child: const Text('Save', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class NotificationSchedule {
  String dayOfWeek;
  TimeOfDay time;
  bool isEnabled;

  NotificationSchedule({required this.dayOfWeek, required this.time, this.isEnabled = true});
}