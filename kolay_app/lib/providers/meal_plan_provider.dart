import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kolay_app/service/encryption_service.dart';
import '../service/firestore_service.dart';
import 'package:intl/intl.dart';
class MealPlan with ChangeNotifier {
  final FireStoreService _firestoreService = FireStoreService();
  final EncryptionService _encryptionService = EncryptionService();
  Map<String, dynamic> mealPlans = {};
  List<String> mealPlansHome = [];


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
          'datetime': d.get('datetime').toDate() as DateTime,
          'listItems': decryptedListItems
        }
      };
      mealPlans.addAll(doc);
    }

    notifyListeners();
  }

  Future createShoppingListFromMeal(String listName, List<String> listItems, DateTime datetime) async {
    await _firestoreService.createShoppingListFromMeal(listName, listItems, datetime);
    notifyListeners();
  }

  Future addToShoppingListFromMeal(String listName, List<String> listItems) async {
    await _firestoreService.addToShoppingListFromMeal(listName, listItems);
    notifyListeners();
  }

  List<String> getUntickedIngredients(String listName){
    List<String> untickedIngredients = [];
    if(mealPlans[listName]['listItems'].values.isNotEmpty){
      mealPlans[listName]['listItems'].values.map((item) => {
        if(!item['itemTicked']){
          untickedIngredients.add(item['itemName'] as String)
        }
      }).toList();
    }
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
    await _firestoreService.deleteMealPlan(listName);
    mealPlans.remove(listName);
    notifyListeners();
  }

   Future getMealPlansForHomeScreen() async {
    var now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var querySnapshot = await _firestoreService.getAllMealPlans();
    mealPlansHome.clear();
    for (DocumentSnapshot d in querySnapshot.docs) {
      var taskDueDate = DateFormat('dd/MM/yyyy').format(d.get('datetime').toDate() as DateTime);
      if(now==taskDueDate){
        mealPlansHome.add(_encryptionService.decryptText(d.get('listName')));
      }
    }
    notifyListeners();
  }
}