import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolay_app/service/encryption_service.dart';

class FireStoreService {
  final _fireStoreService = FirebaseFirestore.instance;

  final EncryptionService _encryptionService = EncryptionService();

  /* SHOPPING LIST */

  Future addItemToShoppingList(String listName, String newItem) async {
    
    // Get the UID of the currently authenticated user
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

  Future toggleShopItemCheckbox(String listName, String itemName, bool itemTicked) async {
    // Get the UID of the currently authenticated user
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
    // Get the UID of the currently authenticated user
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
        }
      );
    }else{
      print("User is not authenticated");
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
}
