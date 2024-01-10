import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kolay_app/service/encryption_service.dart';
import '../service/firestore_service.dart';
class TodoList with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  final EncryptionService _encryptionService = EncryptionService();
  Map<String, dynamic> todoLists = {};


  Future createTodoList(String listName) async {
    await _firestoreService.createTodoList(listName);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
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
      Map<dynamic, dynamic> notDecryptedListItems = d.get('listItems') as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> decryptedListItems = {};

      notDecryptedListItems.forEach((key, value) {
         dynamic decrpytedKey = _encryptionService.decryptText(key);
         Map<dynamic, dynamic> decryptedValue = {'itemName': _encryptionService.decryptText(value['itemName']),'itemTicked': value['itemTicked']} ;
         decryptedListItems[decrpytedKey] = decryptedValue;
      });
      Map<String, dynamic> doc = {
         _encryptionService.decryptText(d.get('listName')): {
          'listName': _encryptionService.decryptText(d.get('listName')),
          'listItems': decryptedListItems
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

  void editTodoList(String listName, String oldListName) async {
    await _firestoreService.editTodoList(listName, oldListName);
    Map<String, dynamic> items = todoLists[oldListName]['listItems'];
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "listItems": items
      }
    };
    todoLists.remove(oldListName);
    todoLists.addAll(doc);
    notifyListeners();
  }

}