import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Routine with ChangeNotifier {

  Future<Map<String, Map>> getAllRoutines() async {
    Map<String, Map> documents = {};

    try {
      var collectionReference = FirebaseFirestore.instance.collection('routines');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, Map> doc = 
        {documentSnapshot.id : 
          {
          'routineName': documentSnapshot.get('routineName'),
          'frequency': documentSnapshot.get('frequency'),
          'frequencyMeasure': documentSnapshot.get('frequencyMeasure')
          }
        };
        documents.addAll(doc);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return Future.value(documents);
  }

  void createRoutine(String routineName, String frequencyMeasure, int frequency) {
    FirebaseFirestore.instance.collection("routines").doc(routineName).set(
      {
      'routineName': routineName,
      'frequency': frequency,
      'frequencyMeasure': frequencyMeasure
      }
    ).catchError((error) {
      print('Error creating routine: $error');
    });
    notifyListeners();
  }

  void deleteRoutine(String routineName) {
    FirebaseFirestore.instance.collection("routines").doc(routineName).delete().catchError((error) {
      print('Error deleting routine: $error');
    });
    notifyListeners();
  }
}