import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/firestore_service.dart';

class ShoppingList extends ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> shoppingLists = {};


  Future addShoppingList(String listName) async {
    await _firestoreService.createShoppingList(listName);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "creationDatetime": DateTime.now().millisecondsSinceEpoch.toString(),
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
      var datetime = d.get('creationDatetime');
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': d.get('listName') as String,
          'creationDatetime': DateTime.fromMillisecondsSinceEpoch(datetime).toString(),
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
}