import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';

class Milestone with ChangeNotifier {
  
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> milestones = {};


  Future createMilestone(String milestoneName) async {
    await _firestoreService.createMilestone(milestoneName);
    Map<String, dynamic> doc = {
      milestoneName: {
        "milestoneName": milestoneName,
        "subgoals": {}
      }
    };
    milestones.addAll(doc);
    notifyListeners();
  }

  Future getAllMilestones() async {
    var querySnapshot = await _firestoreService.getAllMilestones();
    milestones.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<String, dynamic> doc = {
        d.get('milestoneName'): {
          'milestoneName': d.get('milestoneName') as String,
          'subgoals': d.get('subgoals') as Map<dynamic, dynamic>
        }
      };
      milestones.addAll(doc);
    }

    notifyListeners();
  }

  Future toggleSubgoalCheckbox(String milestoneName, String subgoalName, bool subgoalTicked) async {
    await _firestoreService.toggleSubgoalCheckbox(milestoneName, subgoalName, subgoalTicked);
    milestones[milestoneName]['subgoals'][subgoalName]['subgoalTicked'] = !subgoalTicked;
    notifyListeners();
  }

  Future addSubgoalToMilestone(String milestoneName, String newSubgoalName) async {
    await _firestoreService.addSubgoalToMilestone(milestoneName, newSubgoalName);
    Map<String, dynamic> doc = {
      newSubgoalName: {
        "subgoalName": newSubgoalName,
        "subgoalTicked": false
      }
    };
    milestones[milestoneName]['subgoals'].addAll(doc);
    notifyListeners();
  }

  Future deleteSubgoalFromMilestone(String milestoneName, String oldSubgoalName) async {
    await _firestoreService.deleteSubgoalFromMilestone(milestoneName, oldSubgoalName);
    milestones[milestoneName]['subgoals'].remove(oldSubgoalName);
    notifyListeners();
  }
  
  Future deleteMilestone(String milestoneName) async {
    await _firestoreService.deleteMilestone(milestoneName);
    milestones.remove(milestoneName);
    notifyListeners();
  }
}