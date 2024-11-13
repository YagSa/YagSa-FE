import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'information_provider.dart'; // Import the provider class

class EditAllInfoPage extends StatefulWidget {
  const EditAllInfoPage({super.key});

  @override
  _EditAllInfoPageState createState() => _EditAllInfoPageState();
}

class _EditAllInfoPageState extends State<EditAllInfoPage> {
  late TextEditingController nameController;
  late TextEditingController usageDurationController;
  late TextEditingController additionalInfoController;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MedicationInfoProvider>(context, listen: false);
    nameController = TextEditingController(text: provider.name);
    usageDurationController = TextEditingController(text: provider.usageDuration);
    additionalInfoController = TextEditingController(text: provider.additionalInfo);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        usageDurationController.text = "${DateFormat('yyyy.MM.dd').format(picked.start)} ~ ${DateFormat('yyyy.MM.dd').format(picked.end)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보 편집'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "명칭", // Name
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: usageDurationController,
                  decoration: const InputDecoration(
                    labelText: "복용 기간", // Usage Duration
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: additionalInfoController,
              decoration: const InputDecoration(
                labelText: "추가 정보", // Additional Info
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Update the provider with new values
                  Provider.of<MedicationInfoProvider>(context, listen: false).updateInfo(
                    nameController.text,
                    usageDurationController.text,
                    additionalInfoController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(iconColor: Colors.teal),
                child: const Text('Save', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            )

          ],
        ),
      ),
    );
  }
}
