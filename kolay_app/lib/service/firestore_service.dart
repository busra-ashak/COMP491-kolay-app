import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreService {
  final _fireStoreService = FirebaseFirestore.instance;

  /* SHOPPING LIST */

  Future addItemToShoppingList(String listName, String newItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName);

      await documentReference.update({
        'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
      });
    }else{
      print('User is not authneticated');
    }
  }

  Future toggleShopItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName);

      await documentReference.update({
        'listItems.$itemName.itemTicked': !itemTicked
      });
    }else{
      print('User is not authneticated');
    }
    
  }

  Future deleteItemFromShoppingList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
    }else{
      print('User is not authneticated');
    }
  }

  Future createShoppingList(String listName, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName).set(
        {
        "listName": listName,
        "datetime": datetime,
        "listItems": {}
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteShoppingList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName).delete();
    }else{
      print('User is not authneticated');
    }
    
  }

  Future<QuerySnapshot> getAllShoppingLists() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').get();
      return _ref;
    }else{
      throw Exception("User is not authenticated");
    }
  }

  /* ROUTINES */

  Future createRoutine(String routineName, String frequencyMeasure, int frequency) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(routineName).set(
        {
        "routineName": routineName,
        "frequency": frequency,
        "frequencyMeasure": frequencyMeasure,
        "currentProgress": 0,
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future completeOneRoutine(String routineName, int frequency, int currentProgress) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    int updatedProgress = min(currentProgress+1, frequency);

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(routineName);

      await documentReference.update({
        "currentProgress": updatedProgress
      });
    }else{
      print('User is not authneticated');
    }
    
  }

  Future undoOneRoutine(String routineName, int currentProgress) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    int updatedProgress = max(currentProgress-1, 0);

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(routineName);

      await documentReference.update({
        "currentProgress": updatedProgress
      });
    }else{
      print('User is not authneticated');
    }
    
  }

  Future deleteRoutine(String routineName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(routineName).delete();
    }else{
      print("User is not authenticated");
    }
  }

  Future<QuerySnapshot> getAllRoutines() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('routines').get();
     return _ref;
    }else{
      throw Exception("User is not authenticated");
    }
  }

  /* TO DO LISTS */

  Future addItemToTodoList(String listName, String newItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName);

      await documentReference.update({
        'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleTodoItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName);

      await documentReference.update({
        'listItems.$itemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteItemFromTodoList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createTodoList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName).set(
        {
        "listName": listName,
        "listItems": {}
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteTodoList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName).delete();
    }else{
      print("User is not authenticated");
    }
  }

  Future<QuerySnapshot> getAllTodoLists() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').get();
      return _ref;
    }else{
      throw Exception("User is not authenticated");
    }
  }

/* REMINDER LISTS */

  Future addItemToReminderList(String listName, String newItem, DateTime itemDeadline) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName);

      await documentReference.update({
        'listItems.$newItem': {'itemName': newItem, 'itemTicked': false, 'itemDeadline': itemDeadline}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleReminderItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName);

      await documentReference.update({
        'listItems.$itemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteItemFromReminderList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createReminderList(String listName, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName).set(
          {
            "listName": listName,
            "dueDatetime": datetime,
            "listItems": {}
          }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteReminderList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName).delete();
    }else{
      print("User is not authenticated");
    }
  }

  Future<QuerySnapshot> getAllReminderLists() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').get();
      return _ref;
    }else{
      throw Exception("User is not authenticated");
    }
  }


  /* MEAL PLANS */

  Future addIngredientToMealPlan(String listName, String newItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName);

      await documentReference.update({
        'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleIngredientCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName);

      await documentReference.update({
        'listItems.$itemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteIngreidentFromMealPlan(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createShoppingListFromMeal(String listName, List<String> listItems, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await createShoppingList(listName, datetime);
      for(String item in listItems) {
        await addItemToShoppingList(listName, item);
      }
    }else{
      print("User is not authenticated");
    }
  }
  
  Future addToShoppingListFromMeal(String listName, List<String> listItems) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      for(String item in listItems) {
        await addItemToShoppingList(listName, item);
      }
    }else{
      print("User is not authenticated");
    }
  }

  Future createMealPlan(String listName, DateTime dateTime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName).set(
        {
        "listName": listName,
        "datetime": dateTime,
        "listItems": {}
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteMealPlan(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName).delete();
    }else{
      print("User is not authenticated");
    }
  }

  Future<QuerySnapshot> getAllMealPlans() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('meals').get();
      return _ref;
    }else{
      throw Exception("User is not authenticated");
    }
  }
}
