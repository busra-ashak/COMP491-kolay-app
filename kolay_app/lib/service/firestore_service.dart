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
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
      await documentReference.update({
        'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
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
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(oldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(oldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('shoppingLists').doc(listName).set(
            {
              "listName": listName,
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
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('routines').doc(oldRoutineName);
      await documentReference.delete();

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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });
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
        "listName": _encryptionService.encryptText(listName),
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

  Future editTodoList(String listName, String oldListName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(oldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(oldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName).set(
            {
              "listName": listName,
              "listItems": items
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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });

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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(oldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(oldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('reminderLists').doc(listName).set(
            {
              "listName": listName,
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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName);

      await documentReference.update({
        'listItems.$oldItem': FieldValue.delete(),
      });

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
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(oldListName);

      documentReference.get()
          .then((DocumentSnapshot documentSnapshot) async {
        Map<String, dynamic> items = documentSnapshot.get('listItems');
        await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(oldListName).delete();
        await _fireStoreService.collection('USERS').doc(uid).collection('meals').doc(listName).set(
            {
              "listName": listName,
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
