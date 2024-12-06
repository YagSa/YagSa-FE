import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_page.dart';
import 'information_provider.dart';
import 'notification_schedule_page.dart';
import 'schedule_provider.dart';
import 'home.dart';

class MedicationInfoPage extends StatefulWidget {
  final bool isNewMedication; // Indicates if adding a new medication or editing
  final String? medicationId; // ID of medication for editing, null if new

  const MedicationInfoPage(
      {Key? key, required this.isNewMedication, this.medicationId})
      : super(key: key);

  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.medicationId != null) {
      Provider.of<ScheduleProvider>(context, listen: false)
          .loadSchedulesFromFirebase(widget.medicationId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationInfoProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    // Check if editing an existing medication
    Map<String, dynamic>? medication;
    if (!widget.isNewMedication && widget.medicationId != null) {
      medication = medicationProvider.medications
          .firstWhere((med) => med['id'] == widget.medicationId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("약물 정보",
            style: TextStyle(
                fontFamily: 'Tenada',
                fontSize: 28,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(98, 149, 132, 1),
        leading: IconButton(
          onPressed: () async {
            await Provider.of<ScheduleProvider>(context, listen: false)
                .loadAllSchedulesFromFirebase();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
          icon: const Icon(Icons.navigate_before),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(226, 241, 231, 1),
          size: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 (Basic Info)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "기본 정보",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAllInfoPage(
                          isNewMedication: widget.isNewMedication,
                          medicationId: widget.medicationId,
                        ),
                      ),
                    );
                    // Reload data from Firebase after editing
                    Provider.of<MedicationInfoProvider>(context, listen: false)
                        .loadFromFirebase();
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 1.0),
            _buildInfoField(
                title: "명칭", value: medication?['name'] ?? ''), // Name
            _buildInfoField(
                title: "복용 기간",
                value: medication?['usageDuration'] ?? ''), // Usage Duration
            _buildInfoField(
                title: "추가 정보",
                value: medication?['additionalInfo'] ?? ''), // Additional Info

            // 금일 복용 일정 (Today's Schedule)
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "금일 복용 일정",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () async {
                    final newSchedule = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationSchedulePage(
                            medicationId: widget.medicationId ?? ''),
                      ),
                    );
                    if (newSchedule != null && widget.medicationId != null) {
                      await Provider.of<ScheduleProvider>(context,
                              listen: false)
                          .addSchedule(
                        widget.medicationId!,
                        newSchedule.time,
                        newSchedule.isEnabled,
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: scheduleProvider.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleProvider.schedules[index];
                  return Dismissible(
                    key: Key(schedule['id']), // Unique key for each item
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      Provider.of<ScheduleProvider>(context, listen: false)
                          .deleteSchedule(schedule['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                '스케줄이 삭제되었습니다')), // Schedule has been deleted
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[
                            200], // Background color for better visual separation
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${schedule['time']}", // Display day and time
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: schedule['isEnabled'],
                            onChanged: (bool value) {
                              Provider.of<ScheduleProvider>(context,
                                      listen: false)
                                  .toggleSchedule(schedule['id'], value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4.0),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1.0),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: value,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
