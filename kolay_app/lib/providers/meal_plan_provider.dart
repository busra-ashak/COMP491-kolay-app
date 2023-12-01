import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore_service.dart';
class MealPlan with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  Map<String, dynamic> mealPlans = {};


  Future createMealPlan(String listName, DateTime dateTime) async {
    await _firestoreService.createMealPlan(listName, dateTime);
    Map<String, dynamic> doc = {
      listName: {
        "listName": listName,
        "datetime": dateTime,
        "listItems": {}
      }
    };
    mealPlans.addAll(doc);
    notifyListeners();
  }

  Future getAllMealPlans() async {
    var querySnapshot = await _firestoreService.getAllMealPlans();
    mealPlans.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      var datetime = d.get('datetime');
      Map<String, dynamic> doc = {
        d.get('listName'): {
          'listName': d.get('listName') as String,
          'datetime': DateTime.fromMillisecondsSinceEpoch(datetime),
          'listItems': d.get('listItems') as Map<dynamic, dynamic>
        }
      };
      mealPlans.addAll(doc);
    }

    notifyListeners();
  }

  Future createShoppingListFromMeal(String listName, List<String> listItems) async {
    await _firestoreService.createShoppingListFromMeal(listName, listItems);
    notifyListeners();
  }

  List<String> getUntickedIngredients(String listName){
    List<String> untickedIngredients = [];
    mealPlans[listName]['listItems'].values.map((item) => {
      if(!item['itemTicked']){
        untickedIngredients.add(item['itemName'] as String)
      }
    }).toList();
    return untickedIngredients;
  }

  Future toggleIngredientCheckbox(String listName, String itemName, bool itemChecked) async {
    await _firestoreService.toggleIngredientCheckbox(listName, itemName, itemChecked);
    mealPlans[listName]['listItems'][itemName]['itemTicked'] = !itemChecked;
    notifyListeners();
  }

  Future addIngredientToList(String listName, String itemName) async {
    await _firestoreService.addIngredientToMealPlan(listName, itemName);
    Map<String, dynamic> doc = {
      itemName: {
        "itemName": itemName,
        "itemTicked": false
      }
    };
    mealPlans[listName]['listItems'].addAll(doc);
    notifyListeners();
  }

  Future deleteIngredientFromList(String listName, String itemName) async {
    await _firestoreService.deleteIngreidentFromMealPlan(listName, itemName);
    mealPlans[listName]['listItems'].remove(itemName);
    notifyListeners();
  }
  
  Future deleteMealPlan(String listName) async {
    await _firestoreService.deleteTodoList(listName);
    mealPlans.remove(listName);
    notifyListeners();
  }
}