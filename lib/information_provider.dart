import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationInfoProvider extends ChangeNotifier {
  List<Map<String, dynamic>> medications = [];

  // Update the info of a specific medication by its ID
  void updateMedication(String medicationId, String newName, String newUsageDuration, String newAdditionalInfo) {
    final medicationIndex = medications.indexWhere((med) => med['id'] == medicationId);
    if (medicationIndex != -1) {
      medications[medicationIndex] = {
        'id': medicationId,
        'name': newName,
        'usageDuration': newUsageDuration,
        'additionalInfo': newAdditionalInfo,
      };
      notifyListeners();
    }
  }

  // Add a new medication to the list
  void addMedication(String name, String usageDuration, String additionalInfo) {
    final newMedication = {
      'name': name,
      'usageDuration': usageDuration,
      'additionalInfo': additionalInfo,
    };
    medications.add(newMedication);
    notifyListeners();
  }

  // Load all medications from Firebase
  Future<void> loadFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final medicationCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medications');

      final querySnapshot = await medicationCollection.get();
      medications = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'usageDuration': doc.data()['usageDuration'] ?? '',
          'additionalInfo': doc.data()['additionalInfo'] ?? '',
        };
      }).toList();

      notifyListeners();
    }
  }

  // Save a new medication to Firebase
  Future<String> saveNewToFirebase(String name, String usageDuration, String additionalInfo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      final newMedicationData = {
        'name': name,
        'usageDuration': usageDuration,
        'additionalInfo': additionalInfo,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add a new document to 'medications' collection
      DocumentReference newDoc = await userDoc.collection('medications').add(newMedicationData);
      await loadFromFirebase(); // Reload to update the local list
      return newDoc.id; // Return the medicationId for further use
    }
    return ''; // Return empty if user is null
  }

  // Save updates for an existing medication
  Future<void> saveUpdateToFirebase(String documentId, String name, String usageDuration, String additionalInfo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference medicationDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(documentId);

      final medicationData = {
        'name': name,
        'usageDuration': usageDuration,
        'additionalInfo': additionalInfo,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await medicationDoc.update(medicationData);
      await loadFromFirebase(); // Reload to update the local list
    }
  }

  // Clear all medications in the local list (e.g., when signing out)
  void clearData() {
    medications.clear();
    notifyListeners();
  }

  // Method to delete a medication
  Future<void> deleteMedication(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .doc(id)
            .delete();
        medications.removeWhere((medication) => medication['id'] == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting medication: $e');
      throw Exception('Failed to delete medication');
    }
  }

}
