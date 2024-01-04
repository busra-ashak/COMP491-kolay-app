import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';

class Routine with ChangeNotifier {

  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> routines = {};
  Map<String, dynamic> routinesHome = {};


  Future createRoutine(String routineName, String frequencyMeasure, int frequency) async {
    await _firestoreService.createRoutine(routineName, frequencyMeasure, frequency);
    Map<String, dynamic> doc = {
      routineName: {
        "routineName": routineName,
        "frequencyMeasure": frequencyMeasure,
        "frequency": frequency,
        "currentProgress": 0,
      }
    };
    routines.addAll(doc);
    notifyListeners();
  }

  Future completeOneRoutine(String routineName, int frequency, int currentProgress) async {
    await _firestoreService.completeOneRoutine(routineName, frequency, currentProgress);
    routines[routineName]['currentProgress']= min(currentProgress+1, frequency);
    notifyListeners();
  }

  Future undoOneRoutine(String routineName, int currentProgress) async {
    await _firestoreService.undoOneRoutine(routineName, currentProgress);
    routines[routineName]['currentProgress']= max(currentProgress-1, 0);
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
          'frequency': d.get('frequency') as int,
          'currentProgress': d.get('currentProgress') as int
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

  Future getRoutinesForHomeScreen() async {
    var querySnapshot = await _firestoreService.getAllRoutines();
    routinesHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      int currentProgress = d.get('currentProgress');
      int frequency = d.get('frequency');
      if(frequency!=currentProgress){
        String frequencyMeasure = d.get('frequencyMeasure');
        String routineName = d.get('routineName');
        Map<String, dynamic> doc = {
        routineName: {
          'routineName': routineName,
          'frequencyMeasure': frequencyMeasure,
          'frequency': frequency,
          'currentProgress': currentProgress
        }
      };
      routinesHome.addAll(doc);
      }
    }
    notifyListeners();
  }
}