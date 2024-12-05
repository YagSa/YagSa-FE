import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'information_provider.dart';

class EditAllInfoPage extends StatefulWidget {
  final bool isNewMedication;
  final String? medicationId;

  const EditAllInfoPage({Key? key, required this.isNewMedication, this.medicationId}) : super(key: key);

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

    if (widget.isNewMedication) {
      nameController = TextEditingController();
      usageDurationController = TextEditingController();
      additionalInfoController = TextEditingController();
    } else if (widget.medicationId != null) {
      final medication = provider.medications.firstWhere((med) => med['id'] == widget.medicationId);
      nameController = TextEditingController(text: medication['name']);
      usageDurationController = TextEditingController(text: medication['usageDuration']);
      additionalInfoController = TextEditingController(text: medication['additionalInfo']);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
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
        centerTitle: true,
        title: Text(
          widget.isNewMedication ? '새 약물 추가' : '약물 정보 편집',
          style: const TextStyle(
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
                onPressed: () async {
                  final provider = Provider.of<MedicationInfoProvider>(context, listen: false);

                  if (widget.isNewMedication) {
                    String medicationId = await provider.saveNewToFirebase(
                      nameController.text,
                      usageDurationController.text,
                      additionalInfoController.text,
                    );
                  } else if (widget.medicationId != null) {
                    await provider.saveUpdateToFirebase(
                      widget.medicationId!,
                      nameController.text,
                      usageDurationController.text,
                      additionalInfoController.text,
                    );
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(iconColor: Colors.teal),
                child: Text(
                  widget.isNewMedication ? '새로 추가' : '저장',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
