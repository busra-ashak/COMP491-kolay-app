import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';
class TodoList with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> todoLists = {};


  Future createTodoList(String listName) async {
    await _firestoreService.createTodoList(listName);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "listItems": {},
        'showProgressBar': true,
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
          'listItems': d.get('listItems') as Map<dynamic, dynamic>,
          'showProgressBar': d.get('showProgressBar') as bool
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

  void toggleProgressionBar(String listName, bool showProgressionBar) {
    todoLists[listName]['showProgressionBar'] = showProgressionBar;
    notifyListeners();
  }

  Future addTodoItemToList(String listName, String itemName) async {
    await _firestoreService.addItemToTodoList(listName, itemName);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemTicked": false
      }
    };
    todoLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future editTodoItemInList(String listName, String itemName, String oldItem) async {
    await _firestoreService.editItemInTodoList(listName, itemName, oldItem);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemTicked": false
      }
    };
    todoLists[listName]['listItems'].remove(oldItem);
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

  void editTodoList(String listName, String oldListName, bool showProgressBar) async {
    await _firestoreService.editTodoList(listName, oldListName, showProgressBar);
    Map<dynamic, dynamic> items = todoLists[oldListName]['listItems'];
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "listItems": items,
        'showProgressBar': showProgressBar,
      }
    };
    todoLists.remove(oldListName);
    todoLists.addAll(doc);
    notifyListeners();
  }

}