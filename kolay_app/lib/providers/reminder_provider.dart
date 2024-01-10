import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kolay_app/service/encryption_service.dart';
import '../service/firestore_service.dart';
import 'package:intl/intl.dart';
class ReminderList with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  final EncryptionService _encryptionService = EncryptionService();
  Map<String, dynamic> reminderLists = {};
  List<String> reminderListsHome = [];
  List<List<String>> reminderTasksHome = [];


  Future createReminderList(String listName, DateTime datetime) async {
    await _firestoreService.createReminderList(listName, datetime);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "dueDatetime": datetime,
        "listItems": {}
      }
    };
    reminderLists.addAll(doc);
    notifyListeners();
  }

  Future getAllReminderLists() async {
    var querySnapshot = await _firestoreService.getAllReminderLists();
    reminderLists.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<dynamic, dynamic> notDecryptedListItems = d.get('listItems') as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> decryptedListItems = {};

      notDecryptedListItems.forEach((key, value) {
         dynamic decrpytedKey = _encryptionService.decryptText(key);
         Map<dynamic, dynamic> decryptedValue = {'itemDeadline': value['itemDeadline'],'itemName': _encryptionService.decryptText(value['itemName']),'itemTicked': value['itemTicked']} ;
         decryptedListItems[decrpytedKey] = decryptedValue;
      });

      Map<String, dynamic> doc = {
         _encryptionService.decryptText(d.get('listName')): {
          'listName': _encryptionService.decryptText(d.get('listName')),
          'dueDatetime': d.get('dueDatetime').toDate() as DateTime,
          'listItems': decryptedListItems
        }
      };
      reminderLists.addAll(doc);
    }

    notifyListeners();
  }

  Future toggleItemCheckbox(String listName, String itemName, bool itemChecked) async {
    await _firestoreService.toggleReminderItemCheckbox(listName, itemName, itemChecked);
    reminderLists[listName]['listItems'][itemName]['itemTicked'] = !itemChecked;
    notifyListeners();
  }

  Future addReminderItemToList(String listName, String itemName, DateTime itemDeadline) async {
    await _firestoreService.addItemToReminderList(listName, itemName, itemDeadline);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemDeadline": itemDeadline,
        "itemTicked": false
      }
    };
    reminderLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future editReminderItemInList(String listName, String itemName, DateTime itemDeadline, String oldItem) async {
    await _firestoreService.editItemInReminderList(listName, itemName, itemDeadline, oldItem);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemDeadline": itemDeadline,
        "itemTicked": false
      }
    };
    reminderLists[listName]['listItems'].remove(oldItem);
    reminderLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future deleteReminderItemFromList(String listName, String itemName) async {
    await _firestoreService.deleteItemFromReminderList(listName, itemName);
    reminderLists[listName]['listItems'].remove(itemName);
    notifyListeners();
  }

  Future deleteReminderList(String listName) async {
    await _firestoreService.deleteReminderList(listName);
    reminderLists.remove(listName);
    notifyListeners();
  }

  Future getToDoListsForHomeScreen() async {
    var now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllReminderLists();
    reminderListsHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      var taskDueDate = DateFormat('dd/MM/yyyy').format(d.get('dueDatetime').toDate() as DateTime);
      if(now==taskDueDate){
        reminderListsHome.add(d.get('listName'));
      }
    }
    notifyListeners();
  }

  Future getIncompleteToDoTasksForHomeScreen() async {
    String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllReminderLists();
    reminderTasksHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      String listName = _encryptionService.decryptText(d.get('listName'));
      var tasks = d.get('listItems');
      for(var task in tasks.values){
        String taskDueDate = DateFormat('dd/MM/yyyy').format(task['itemDeadline'].toDate() as DateTime);
        bool itemTicked = task['itemTicked'];
        if(now==taskDueDate && !itemTicked){
          String itemName = _encryptionService.decryptText(task['itemName']);
          reminderTasksHome.add([itemName,listName]);
        }
      }
    }
    notifyListeners();
  }

  Future editReminder(String listName, DateTime dateTime, String oldListName) async {
    await _firestoreService.editReminderList(listName, dateTime, oldListName);
    Map<dynamic, dynamic> items = reminderLists[oldListName]['listItems'];
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "dueDatetime": dateTime,
        "listItems": items
      }
    };
    reminderLists.remove(oldListName);
    reminderLists.addAll(doc);
    notifyListeners();
  }

}