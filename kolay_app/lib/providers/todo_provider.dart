import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';
import 'package:intl/intl.dart';
class TodoList with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> todoLists = {};
  List<String> todoListsHome = [];
  List<String> todoTasksHome = [];


  Future createTodoList(String listName, DateTime datetime) async {
    await _firestoreService.createTodoList(listName, datetime);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "dueDatetime": datetime,
        "listItems": {}
      }
    };
    todoLists.addAll(doc);
    notifyListeners();
  }

  Future getAllTodoLists() async {
    var querySnapshot = await _firestoreService.getAllTodoLists();
    todoLists.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': d.get('listName') as String,
          'dueDatetime': d.get('dueDatetime').toDate() as DateTime,
          'listItems': d.get('listItems') as Map<dynamic, dynamic>
        }
      };
      todoLists.addAll(doc);
    }

    notifyListeners();
  }

  Future toggleItemCheckbox(String listName, String itemName, bool itemChecked) async {
    await _firestoreService.toggleTodoItemCheckbox(listName, itemName, itemChecked);
    todoLists[listName]['listItems'][itemName]['itemTicked'] = !itemChecked;
    notifyListeners();
  }

  Future addTodoItemToList(String listName, String itemName, DateTime itemDeadline) async {
    await _firestoreService.addItemToTodoList(listName, itemName, itemDeadline);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemDeadline": itemDeadline,
        "itemTicked": false
      }
    };
    todoLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future deleteTodoItemFromList(String listName, String itemName) async {
    await _firestoreService.deleteItemFromTodoList(listName, itemName);
    todoLists[listName]['listItems'].remove(itemName);
    notifyListeners();
  }
  
  Future deleteTodoList(String listName) async {
    await _firestoreService.deleteTodoList(listName);
    todoLists.remove(listName);
    notifyListeners();
  }

  Future getToDoListsForHomeScreen() async {
    var now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllTodoLists();
    todoListsHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      var taskDueDate = DateFormat('dd/MM/yyyy').format(d.get('dueDatetime').toDate() as DateTime);
      if(now==taskDueDate){
        todoListsHome.add(d.get('listName'));
      }
    }
    notifyListeners();
  }

  Future getIncompleteToDoTasksForHomeScreen() async {
    var now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllTodoLists();
    todoTasksHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      String listName = d.get('listName');
      var tasks = d.get('listItems');
      for(var task in tasks.values){
        var taskDueDate = DateFormat('dd/MM/yyyy').format(task['itemDeadline'].toDate() as DateTime);
        if(now==taskDueDate){
          String itemName = task['itemName'];
          todoTasksHome.add('$itemName - $listName');
        }
      }
    }
    notifyListeners();
  }

}