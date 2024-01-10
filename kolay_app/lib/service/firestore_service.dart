import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolay_app/service/encryption_service.dart';

class FireStoreService {
  final _fireStoreService = FirebaseFirestore.instance;

  final EncryptionService _encryptionService = EncryptionService();

  /* SHOPPING LIST */

  Future addItemToShoppingList(String listName, String newItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(newItem);
      await documentReference.update({
        'listItems.$encryptedItemName': {'itemName': encryptedItemName, 'itemTicked': false}
      });
    }else{
      print('User is not authneticated');
    }
  }

  Future editItemInShoppingList(String listName, String newItem, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String encryptedListName = _encryptionService.encryptText(listName);
    String encryptedOldItemName = _encryptionService.encryptText(oldItem);
    String encryptedNewItemName = _encryptionService.encryptText(newItem);
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(encryptedListName);

      await documentReference.update({
        'listItems.$encryptedOldItemName': FieldValue.delete(),
      });
      await documentReference.update({
        'listItems.$encryptedNewItemName': {'itemName': encryptedNewItemName, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }


  Future toggleShopItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(itemName);
      await documentReference.update({
        
        'listItems.$encryptedItemName.itemTicked': !itemTicked
      });
    }else{
      print('User is not authneticated');
    }
    
  }

  Future deleteItemFromShoppingList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(_encryptionService.encryptText(listName));

      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
      });
    }else{
      print('User is not authneticated');
    }
  }

  Future createShoppingList(String listName, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(_encryptionService.encryptText(listName)).set(
        {
        "listName": _encryptionService.encryptText(listName),
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
      await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(_encryptionService.encryptText(listName)).delete();
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

  Future editShoppingList(String listName, DateTime dateTime, String oldListName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String encryptedOldListName = _encryptionService.encryptText(oldListName);
    String encryptedListName = _encryptionService.encryptText(listName);
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(encryptedOldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(encryptedOldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(encryptedListName).set(
            {
              "listName": encryptedListName,
              "datetime": dateTime,
              "listItems": items
            }
        );
      });

    }else{
      print("User is not authenticated");
    }
  }

  /* ROUTINES */

  Future createRoutine(String routineName, String frequencyMeasure, int frequency) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String encryptedRoutineName = _encryptionService.encryptText(routineName);
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedRoutineName).set(
        {
        "routineName": encryptedRoutineName,
        "frequency": frequency,
        "frequencyMeasure": frequencyMeasure,
        "currentProgress": 0,
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future editRoutine(String routineName, String frequencyMeasure, int frequency, String oldRoutineName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String encryptedOldRoutineName = _encryptionService.encryptText(oldRoutineName);
    String encryptedNewRoutineName = _encryptionService.encryptText(routineName);
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedOldRoutineName);
      await documentReference.delete();

      await _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedNewRoutineName).set(
          {
            "routineName": encryptedNewRoutineName,
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
    String encryptedRoutineName = _encryptionService.encryptText(routineName);

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedRoutineName);

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
    String encryptedRoutineName = _encryptionService.encryptText(routineName);

    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedRoutineName);

      await documentReference.update({
        "currentProgress": updatedProgress
      });
    }else{
      print('User is not authneticated');
    }
    
  }

  Future deleteRoutine(String routineName) async {
    String encryptedRoutineName = _encryptionService.encryptText(routineName);
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(encryptedRoutineName).delete();
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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(newItem);
      await documentReference.update({
        'listItems.$encryptedItemName': {'itemName': encryptedItemName, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future editItemInTodoList(String listName, String newItem, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedListName = _encryptionService.encryptText(listName);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(encryptedListName);
      String encryptedNewItemName = _encryptionService.encryptText(newItem);
      String encryptedOldItemName = _encryptionService.encryptText(newItem);
      await documentReference.update({
        'listItems.$encryptedOldItemName': FieldValue.delete(),
      });
      await documentReference.update({
        'listItems.$encryptedNewItemName': {'itemName': encryptedNewItemName, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleTodoItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(itemName);
      await documentReference.update({
        'listItems.$encryptedItemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteItemFromTodoList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(_encryptionService.encryptText(listName));
      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createTodoList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(_encryptionService.encryptText(listName)).set(
        {
        "listName": listName,
        "listItems": {},
        'showProgressBar': true,
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteTodoList(String listName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(_encryptionService.encryptText(listName)).delete();
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

  Future editTodoList(String listName, String oldListName, bool showProgressBar) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedListName = _encryptionService.encryptText(listName);
      String encryptedOldListName = _encryptionService.encryptText(oldListName);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(encryptedOldListName);
      
      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(encryptedOldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(encryptedListName).set(
            {
              "listName": listName,
              "listItems": items,
              'showProgressBar': showProgressBar,
            }
        );
      });

    }else{
      print("User is not authenticated");
    }
  }

/* REMINDER LISTS */

  Future addItemToReminderList(String listName, String newItem, DateTime itemDeadline) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(newItem);
      await documentReference.update({
        'listItems.$encryptedItemName': {'itemName': encryptedItemName, 'itemTicked': false, 'itemDeadline': itemDeadline}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future editItemInReminderList(String listName, String newItem, DateTime itemDeadline, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedListName = _encryptionService.encryptText(listName);
      String encryptedNewItem = _encryptionService.encryptText(newItem);
      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(encryptedListName);

      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
      });

      await documentReference.update({
        'listItems.$encryptedNewItem': {'itemName': encryptedNewItem, 'itemTicked': false, 'itemDeadline': itemDeadline}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleReminderItemCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(itemName);
      await documentReference.update({
        'listItems.$encryptedItemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteItemFromReminderList(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(_encryptionService.encryptText(listName));

      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createReminderList(String listName, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(_encryptionService.encryptText(listName)).set(
          {
            "listName": _encryptionService.encryptText(listName),
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
      await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(_encryptionService.encryptText(listName)).delete();
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

  Future editReminderList(String listName, DateTime dateTime, String oldListName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedOldListName = _encryptionService.encryptText(oldListName);
      String encryptedListName = _encryptionService.encryptText(listName);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(encryptedOldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(encryptedOldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(encryptedListName).set(
            {
              "listName": encryptedListName,
              "dueDatetime": dateTime,
              "listItems": items
            }
        );
      });

    }else{
      print("User is not authenticated");
    }
  }


  /* MEAL PLANS */

  Future addIngredientToMealPlan(String listName, String newItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(newItem);
      await documentReference.update({
        'listItems.$encryptedItemName': {'itemName': encryptedItemName, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future editIngredientInMealPlan(String listName, String newItem, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedListName = _encryptionService.encryptText(listName);
      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      String encryptedNewName = _encryptionService.encryptText(newItem);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(encryptedListName);

      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
      });

      await documentReference.update({
        'listItems.$encryptedNewName': {'itemName': encryptedNewName, 'itemTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleIngredientCheckbox(String listName, String itemName, bool itemTicked) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(_encryptionService.encryptText(listName));
      String encryptedItemName = _encryptionService.encryptText(itemName);
      await documentReference.update({
        'listItems.$encryptedItemName.itemTicked': !itemTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteIngreidentFromMealPlan(String listName, String oldItem) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(_encryptionService.encryptText(listName));
      String encryptedOldItem = _encryptionService.encryptText(oldItem);
      await documentReference.update({
        'listItems.$encryptedOldItem': FieldValue.delete(),
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
      await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(_encryptionService.encryptText(listName)).set(
        {
        "listName": _encryptionService.encryptText(listName),
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
      await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(_encryptionService.encryptText(listName)).delete();
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

  Future editMealPlan(String listName, DateTime dateTime, String oldListName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String encryptedListName = _encryptionService.encryptText(listName);
      String encryptedOldListName = _encryptionService.encryptText(oldListName);
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(encryptedOldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(encryptedOldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(encryptedListName).set(
            {
              "listName": encryptedListName,
              "datetime": dateTime,
              "listItems": items
            }
        );
      });

    }else{
      print("User is not authenticated");
    }
  }
}
