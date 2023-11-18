import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ShoppingList with ChangeNotifier {
  final List<String> _shoppingList = ['potato', 'tomato'];

  int get count => _shoppingList.length;
  List<String> get shoppingList => _shoppingList;

  void getAllShoppingLists() async {
    // Parse the data in a meaningful way
    try {
      var collectionReference = FirebaseFirestore.instance.collection('shoppingLists');
      // Get all documents in the collection
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        print('Document ID: ${documentSnapshot.id}, Data: $data');
      }
    } catch (e) {
      print('Error fetching documents: $e');
    }
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