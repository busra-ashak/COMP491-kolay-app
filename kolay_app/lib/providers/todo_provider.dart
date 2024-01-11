import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';

class TodoList with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> todoLists = {};

  Future createTodoList(String listName) async {
    await _firestoreService.createTodoList(listName);
    Map<String, dynamic> doc = {
      listName: {"listName": listName, "listItems": {}}
    };
    todoLists.addAll(doc);
    notifyListeners();
  }

  Map<String, dynamic> sortTodoLists(Map<String, dynamic> todoLists) {
    return Map.fromEntries(todoLists.entries.toList()
      ..sort((a, b) {
        bool allTickedA = checkAllTicked(a.value['listItems']);
        bool allTickedB = checkAllTicked(b.value['listItems']);

        if (allTickedA && !allTickedB) {
          return 1;
        } else if (!allTickedA && allTickedB) {
          return -1;
        } else {
          return 0;
        }
      }));
  }

  bool checkAllTicked(Map<dynamic, dynamic> listItems) {
    return listItems.values.every((item) => item['itemTicked'] == true);
  }

  Future getAllTodoLists() async {
    var querySnapshot = await _firestoreService.getAllTodoLists();
    todoLists.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': d.get('listName') as String,
          'listItems': d.get('listItems') as Map<dynamic, dynamic>
        }
      };
      todoLists.addAll(doc);
    }
    todoLists = sortTodoLists(todoLists);
    notifyListeners();
  }

  Future toggleItemCheckbox(
      String listName, String itemName, bool itemChecked) async {
    await _firestoreService.toggleTodoItemCheckbox(
        listName, itemName, itemChecked);
    todoLists[listName]['listItems'][itemName]['itemTicked'] = !itemChecked;
    notifyListeners();
  }

  Future addTodoItemToList(String listName, String itemName) async {
    await _firestoreService.addItemToTodoList(listName, itemName);
    Map<String, dynamic> doc = {
      itemName: {"itemName": itemName, "itemTicked": false}
    };
    todoLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future editTodoItemInList(
      String listName, String itemName, String oldItem) async {
    await _firestoreService.editItemInTodoList(listName, itemName, oldItem);
    Map<String, dynamic> doc = {
      itemName: {"itemName": itemName, "itemTicked": false}
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

  void editTodoList(String listName, String oldListName) async {
    await _firestoreService.editTodoList(listName, oldListName);
    Map<String, dynamic> items = todoLists[oldListName]['listItems'];
    Map<String, dynamic> doc = {
      listName: {"listName": listName, "listItems": items}
    };
    todoLists.remove(oldListName);
    todoLists.addAll(doc);
    notifyListeners();
  }
}
