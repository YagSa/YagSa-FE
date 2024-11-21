import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'information_provider.dart';
import 'edit_page.dart';
import 'notification_schedule_page.dart';

class MedicationInfoPage extends StatefulWidget {
  const MedicationInfoPage({super.key});

  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  List<NotificationSchedule> schedules = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationInfoProvider(),
      child: Consumer<MedicationInfoProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "기본 정보", // Basic Info
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 2.0,
                        color: Colors.black, // Color of the horizontal underline
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Placeholder for edit functionality
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0.1),
              _buildInfoField(title: "명칭", value: provider.name), // Name
              _buildInfoField(title: "복용 기간", value: provider.usageDuration), // Usage Duration
              _buildInfoField(title: "추가 정보", value: provider.additionalInfo), // Additional Info

              // Today's Schedule Section
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "금일 복용 일정", // Today's Schedule
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 2.0,
                        color: Colors.black, // Color of the horizontal underline
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Placeholder for adding a schedule
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color for better visual separation
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${schedules[index].dayOfWeek} - ${schedules[index].time.format(context)}", // Display day and time
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: schedules[index].isEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                schedules[index].isEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        Text(title),
        TextField(
          decoration: InputDecoration(
            hintText: value,
            border: const OutlineInputBorder(),
          ),
          readOnly: true,
        ),
      ],
    );
  }
}