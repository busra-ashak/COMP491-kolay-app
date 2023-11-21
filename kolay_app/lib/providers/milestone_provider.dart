import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Milestone with ChangeNotifier {

  Future<Map<String, Map>> getAllMilestones() async {
    Map<String, Map> documents = {};

    try {
      var collectionReference = FirebaseFirestore.instance.collection('milestones');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, Map> doc = 
        {documentSnapshot.id : 
          {
          'milestoneName': documentSnapshot.get('milestoneName'),
          'subgoals': documentSnapshot.get('subgoals')
          }
        };
        documents.addAll(doc);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return Future.value(documents);
  }

  
  void addSubgoalToMilestone(String milestoneName, String newSubgoal) {
    var documentReference = FirebaseFirestore.instance.collection('milestones').doc(milestoneName);

    documentReference.update({
      'subgoals.$newSubgoal': {'subgoalName': newSubgoal, 'subgoalTicked': false}
    }).catchError((error) {
      print('Error adding subgoal: $error');
    });
    
    notifyListeners();
  }

  void toggleSubgoalCheckbox(String milestoneName, String subgoalName, bool subgoalTicked) {
    var documentReference = FirebaseFirestore.instance.collection('milestones').doc(milestoneName);

    documentReference.update({
      'subgoals.$subgoalName.subgoalTicked': !subgoalTicked
    }).catchError((error) {
      print('Error updating checkbox: $error');
    });
    
    notifyListeners();
  }

  void deleteSubgoalFromMilestone(String milestoneName, String oldSubgoal) {
    var documentReference = FirebaseFirestore.instance.collection('milestones').doc(milestoneName);

    documentReference.update({
      'subgoals.$oldSubgoal': FieldValue.delete(),
    }).catchError((error) {
      print('Error deleting subgoal: $error');
    });

    notifyListeners();
  }

  Future<double> getMilestonePercentage(String milestoneName) async {

    int ticked = 0;
    int len = 0;
    try {

      var queryReference = await FirebaseFirestore.instance.collection('milestones').doc(milestoneName).get();
      var content = queryReference.data();
      len = content?['subgoals'].values.length;
      if(content != null){
        for(Map subgoal in content['subgoals']){
          if(subgoal['subgoalTicked']){
            ticked++;
          }
        }
      }
        
      
    } catch (e) {
      print('Error fetching document IDs: $e');
    }
    return ticked/len;
  }

  void createMilestone(String milestoneName) {
    FirebaseFirestore.instance.collection("milestones").doc(milestoneName).set(
      {
      "milestoneName": milestoneName,
      "subgoals": {}
      }
    ).catchError((error) {
      print('Error creating milestone: $error');
    });
    notifyListeners();
  }

  void deleteMilestone(String milestoneName) {
    // open modal and ask are you sure
    FirebaseFirestore.instance.collection("milestones").doc(milestoneName).delete().catchError((error) {
      print('Error deleting milestone: $error');
    });
    notifyListeners();
  }
}