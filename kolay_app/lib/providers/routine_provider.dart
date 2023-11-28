import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';

class Routine with ChangeNotifier {

  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> routines = {};


  Future createRoutine(String routineName, String frequencyMeasure, int frequency) async {
    await _firestoreService.createRoutine(routineName, frequencyMeasure, frequency);
    Map<String, dynamic> doc = {
      routineName: {
        "routineName": routineName,
        "frequencyMeasure": frequencyMeasure,
        "frequency": frequency,
      }
    };
    routines.addAll(doc);
    notifyListeners();
  }

  Future getAllRoutines() async {
    var querySnapshot = await _firestoreService.getAllRoutines();
    routines.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<String, dynamic> doc = {
        d.get('routineName'): {
          'routineName': d.get('routineName') as String,
          'frequencyMeasure': d.get('frequencyMeasure') as String,
          'frequency': d.get('frequency') as int
        }
      };
      routines.addAll(doc);
    }

    notifyListeners();
  }
  
  Future deleteRoutine(String routineName) async {
    await _firestoreService.deleteRoutine(routineName);
    routines.remove(routineName);
    notifyListeners();
  }
}