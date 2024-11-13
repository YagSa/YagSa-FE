import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'information_provider.dart'; // Import the provider class
import 'edit_page.dart'; // Import the new file for the EditAllInfoPage
import 'notification_schedule_page.dart'; // Import NotificationSchedule and NotificationSchedulePage

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationInfoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicationInfoPage(),
    );
  }
}

class MedicationInfoPage extends StatefulWidget {
  const MedicationInfoPage({super.key});

  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  List<NotificationSchedule> schedules = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("약, 사", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 Section with underline and framed edit button
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
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditAllInfoPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0.1),
            _buildInfoField(title: "명칭", value: context.watch<MedicationInfoProvider>().name), // Name
            _buildInfoField(title: "복용 기간", value: context.watch<MedicationInfoProvider>().usageDuration), // Usage Duration
            _buildInfoField(title: "추가 정보", value: context.watch<MedicationInfoProvider>().additionalInfo), // Additional Info

            // 금일 복용 일정 Section with underline and framed add button
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
                    onPressed: () async {
                      final newSchedule = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSchedulePage(),
                        ),
                      );
                      if (newSchedule != null) {
                        setState(() {
                          schedules.add(newSchedule);
                        });
                      }
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
        ),
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
