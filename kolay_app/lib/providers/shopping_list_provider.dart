import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import 'package:intl/intl.dart';

class ShoppingList extends ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> shoppingLists = {};
  List<String> shoppingListsHome = [];


  Future addShoppingList(String listName, DateTime datetime) async {
    await _firestoreService.createShoppingList(listName, datetime);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "datetime": datetime,
        "listItems": {}
      }
    };
    shoppingLists.addAll(doc);
    notifyListeners();
  }

  Future readShoppingList() async {
    var querySnapshot = await _firestoreService.getAllShoppingLists();
    shoppingLists.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': d.get('listName') as String,
          'datetime': d.get('datetime').toDate() as DateTime,
          'listItems': d.get('listItems') as Map<dynamic, dynamic>
        }
      };
      shoppingLists.addAll(doc);
    }

    notifyListeners();
  }

  Future updateToggle(String listName, String itemName, bool itemChecked) async {
    await _firestoreService.toggleShopItemCheckbox(listName, itemName, itemChecked);
    shoppingLists[listName]['listItems'][itemName]['itemTicked'] = !itemChecked;
    notifyListeners();
  }

  Future addShoppingListItem(String listName, String itemName) async {
    await _firestoreService.addItemToShoppingList(listName, itemName);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemTicked": false
      }
    };
    shoppingLists[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future removeShoppingListItem(String listName, String itemName) async {
    await _firestoreService.deleteItemFromShoppingList(listName, itemName);
    shoppingLists[listName]['listItems'].remove(itemName);
    notifyListeners();
  }
  
  Future removeShoppingList(String listName) async {
    await _firestoreService.deleteShoppingList(listName);
    shoppingLists.remove(listName);
    notifyListeners();
  }

  Future getShoppingListsForHomeScreen() async {
    var now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllShoppingLists();
    shoppingListsHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      var taskDueDate = DateFormat('dd/MM/yyyy').format(d.get('datetime').toDate() as DateTime);
      if(now==taskDueDate){
        shoppingListsHome.add(d.get('listName'));
      }
    }
    notifyListeners();
  }
}