import 'package:flutter/material.dart';

class MedicationInfoProvider extends ChangeNotifier {
  String name = "";
  String usageDuration = "";
  String additionalInfo = "";

  void updateInfo(String newName, String newUsageDuration, String newAdditionalInfo) {
    name = newName;
    usageDuration = newUsageDuration;
    additionalInfo = newAdditionalInfo;
    notifyListeners();
  }
}