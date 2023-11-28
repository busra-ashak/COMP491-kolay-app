import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ReminderList with ChangeNotifier {

  Future<Map<String, Map>> getAllReminderLists() async {
    Map<String, Map> documents = {};

    try {
      var collectionReference = FirebaseFirestore.instance.collection('reminderLists');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        var datetime = documentSnapshot.get('creationDatetime');
        Map<String, Map> doc =
        {documentSnapshot.id :
        {
          'listName': documentSnapshot.get('listName'),
          'creationDatetime': DateTime.fromMillisecondsSinceEpoch(datetime),
          'listItems': documentSnapshot.get('listItems')
        }
        };
        documents.addAll(doc);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return Future.value(documents);
  }

  //A function that fetches incompleted tasks to represent in homescreen
  Future<List<String>> getIncompleteTasksForHomeScreen() async {
    List<String> incompleteTasks = [];

    try {
      var collectionReference = FirebaseFirestore.instance.collection('reminderLists');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> listItems = documentSnapshot.get('listItems');

        listItems.forEach((itemName, itemDetails) {
          if (itemDetails['itemTicked'] == false) {
            incompleteTasks.add(itemName);
          }
        });
      }
    } catch (e) {
      print('Error fetching incomplete tasks: $e');
    }

    return incompleteTasks;
  }

  void addReminderItemToList(String listName, String newItem, String deadline) {
    var documentReference = FirebaseFirestore.instance.collection('reminderLists').doc(listName);

    documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false, 'itemDeadline': deadline}
    }).catchError((error) {
      print('Error adding item: $error');
    });

    notifyListeners();
  }

  void toggleItemCheckbox(String listName, String itemName, bool itemTicked, String deadline) async {
    var documentReference = FirebaseFirestore.instance.collection('reminderLists').doc(listName);

    documentReference.update({
      'listItems.$itemName': {'itemName': itemName, 'itemTicked': !itemTicked, 'itemDeadline': deadline}
    }).catchError((error) {
      print('Error adding item: $error');
    });

    notifyListeners();
  }

  void deleteReminderItemFromList(String listName, String oldItem, bool oldItemTicked) {
    var documentReference = FirebaseFirestore.instance.collection('reminderLists').doc(listName);

    documentReference.update({
      'listItems.$oldItem': FieldValue.delete(),
    }).catchError((error) {
      print('Error deleting item: $error');
    });

    notifyListeners();
  }

  void createReminderList(String listName) {
    FirebaseFirestore.instance.collection("reminderLists").doc(listName).set(
        {
          "listName": listName,
          "creationDatetime": DateTime.now().millisecondsSinceEpoch,
          "listItems": {}
        }
    ).catchError((error) {
      print('Error creating list: $error');
    });
    notifyListeners();
  }

  void deleteReminderList(String listName) {
    // open modal and ask are you sure
    FirebaseFirestore.instance.collection("reminderLists").doc(listName).delete().catchError((error) {
      print('Error creating list: $error');
    });
    notifyListeners();
  }
}