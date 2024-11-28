import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_page.dart';
import 'information_provider.dart';
import 'schedule_provider.dart';

class MedicationInfoPage extends StatefulWidget {
  final bool isNewMedication; // Indicates if adding a new medication or editing
  final int? medicationIndex; // Index of medication for editing, null if new

  const MedicationInfoPage({Key? key, required this.isNewMedication, this.medicationIndex}) : super(key: key);

  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Provider.of<ScheduleProvider>(context, listen: false).loadSchedulesFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationInfoProvider>();

    // Check if editing an existing medication
    Map<String, dynamic>? medication;
    if (!widget.isNewMedication && widget.medicationIndex != null) {
      medication = medicationProvider.medications[widget.medicationIndex!];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("약물 정보", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAllInfoPage(
                            isNewMedication: widget.isNewMedication,
                            medicationIndex: widget.medicationIndex,
                          ),
                        ),
                      );
                      // Reload data from Firebase after editing
                      Provider.of<MedicationInfoProvider>(context, listen: false).loadFromFirebase();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1.0),
            _buildInfoField(title: "명칭", value: medication?['name'] ?? ''), // Name
            _buildInfoField(title: "복용 기간", value: medication?['usageDuration'] ?? ''), // Usage Duration
            _buildInfoField(title: "추가 정보", value: medication?['additionalInfo'] ?? ''), // Additional Info
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
