import 'package:flutter/material.dart';

class ShoppingList with ChangeNotifier {
  List<String> _shoppingList = ['potato', 'tomato'];

  int get count => _shoppingList.length;
  List<String> get shoppingList => _shoppingList;

    set shoppingList(List<String> newShoppingList) {
      _shoppingList = newShoppingList;
      notifyListeners();
    }

  void addItemToShoppingList(String newItem) {
    _shoppingList.add(newItem);
    notifyListeners();
  }

  void deleteItemFromShoppingList(String oldItem) {
    _shoppingList.remove(oldItem);
    notifyListeners();
  }

  void createShoppingList() {
    // how to create new instance ??
    // write into database -> in the page file read from the database?
    notifyListeners();
  }

  void deleteShoppingList(String newItem) {
    // open modal and ask are you sure
    notifyListeners();
  }
}