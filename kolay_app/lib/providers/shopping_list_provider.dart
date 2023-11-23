import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ShoppingList with ChangeNotifier {

  Future<Map<String, Map>> getAllShoppingLists() async {
    Map<String, Map> documents = {};

    try {
      var collectionReference = FirebaseFirestore.instance.collection('shoppingLists');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        var datetime = documentSnapshot.get('creationDatetime');
        Map<String, Map> doc = 
        {documentSnapshot.id : 
          {
          'listName': documentSnapshot.get('listName'),
          'creationDatetime': DateTime.fromMillisecondsSinceEpoch(datetime).toString(),
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

  void addItemToShoppingList(String listName, String newItem) {
    var documentReference = FirebaseFirestore.instance.collection('shoppingLists').doc(listName);

    documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
    }).catchError((error) {
      print('Error adding item: $error');
    });
    
    notifyListeners();
  }

  void toggleItemCheckbox(String listName, String itemName, bool itemTicked) {
    var documentReference = FirebaseFirestore.instance.collection('shoppingLists').doc(listName);

    documentReference.update({
      'listItems.$itemName.itemTicked': !itemTicked
    }).catchError((error) {
      print('Error updating checkbox: $error');
    });
    
    notifyListeners();
  }

  void deleteItemFromShoppingList(String listName, String oldItem) {
    var documentReference = FirebaseFirestore.instance.collection('shoppingLists').doc(listName);

    documentReference.update({
      'listItems.$oldItem': FieldValue.delete(),
    }).catchError((error) {
      print('Error deleting item: $error');
    });

    notifyListeners();
  }

  void createShoppingList(String listName) {
    FirebaseFirestore.instance.collection("shoppingLists").doc(listName).set(
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

  void deleteShoppingList(String listName) {
    // open modal and ask are you sure
    FirebaseFirestore.instance.collection("shoppingLists").doc(listName).delete().catchError((error) {
      print('Error deleting list: $error');
    });
    notifyListeners();
  }
}