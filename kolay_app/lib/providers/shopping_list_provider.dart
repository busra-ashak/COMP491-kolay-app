import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ShoppingList with ChangeNotifier {
  final List<String> _shoppingList = ['potato', 'tomato'];

  int get count => _shoppingList.length;
  List<String> get shoppingList => _shoppingList;

  Future<List<String>> getAllShoppingLists() async {
    List<String> documentIDs = [];

    try {
      var collectionReference = FirebaseFirestore.instance.collection('shoppingLists');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        documentIDs.add(documentSnapshot.id);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return Future.value(documentIDs);
}

  void addItemToShoppingList(String listName, String newItem) {
    _shoppingList.add(newItem);
    Map newItemMap = {'itemName': newItem, 'itemTicked': false};
    var documentReference = FirebaseFirestore.instance.collection('shoppingLists').doc(listName);

    documentReference.update({
      'listItems': FieldValue.arrayUnion([newItemMap])
    }).catchError((error) {
      print('Error adding item: $error');
    });
    
    notifyListeners();
  }

  void deleteItemFromShoppingList(String listName, String oldItem, bool oldItemTicked) {
    _shoppingList.remove(oldItem);
    var documentReference = FirebaseFirestore.instance.collection('shoppingLists').doc(listName);

    documentReference.update({
      'listItems': FieldValue.arrayRemove([{'itemName': oldItem, 'itemTicked': oldItemTicked}])
    }).catchError((error) {
      print('Error deleting item: $error');
    });

    notifyListeners();
  }

  void createShoppingList(String listName) {
    FirebaseFirestore.instance.collection("shoppingLists").doc(listName).set(
      {
      "listName": listName,
      "creationDatetime": DateTime.now(),
      "listItems": []
      }
    ).catchError((error) {
      print('Error creating list: $error');
    });
    notifyListeners();
  }

  void deleteShoppingList(String listName) {
    // open modal and ask are you sure
    FirebaseFirestore.instance.collection("shoppingLists").doc(listName).delete().catchError((error) {
      print('Error creating list: $error');
    });
    notifyListeners();
  }
}