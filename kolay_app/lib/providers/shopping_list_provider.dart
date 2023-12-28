import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kolay_app/service/encryption_service.dart';
import '../service/firestore_service.dart';
import 'package:intl/intl.dart';

class ShoppingList extends ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  final EncryptionService _encryptionService = EncryptionService();
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
      Map<dynamic, dynamic> notDecryptedListItems = d.get('listItems') as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> decryptedListItems = {};

      notDecryptedListItems.forEach((key, value) {
         dynamic decrpytedKey = _encryptionService.decryptText(key);
         Map<dynamic, dynamic> decryptedValue = {'itemName': _encryptionService.decryptText(value['itemName']),'itemTicked': value['itemTicked']} ;
         decryptedListItems[decrpytedKey] = decryptedValue;
      });
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': _encryptionService.decryptText(d.get('listName')),
          'datetime': d.get('datetime').toDate() as DateTime,
          'listItems': decryptedListItems
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
      _encryptionService.encryptText(itemName): {
        "itemName": _encryptionService.encryptText(itemName),
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
        shoppingListsHome.add(_encryptionService.decryptText(d.get('listName')));
      }
    }
    notifyListeners();
  }
}