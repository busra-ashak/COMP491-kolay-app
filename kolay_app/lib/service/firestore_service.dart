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
    // _fireStoreService.collection('falans').doc('encrypt').set(
    //   {"busra":_encryptionService.encryptText('busra')}
    // );
    // Get the UID of the currently authenticated user
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
    //var querySnapshot = await _fireStoreService.collection('falans').get();

    // for (DocumentSnapshot d in querySnapshot.docs) {
    //   print(d.get('busra'));
    //   print(_encryptionService.decryptText(d.get('busra')));
    // }
    // Get the UID of the currently authenticated user
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

  /* MILESTONES */

  Future addSubgoalToMilestone(String milestoneName, String newSubgoal) async {
    // Get the UID of the currently authenticated user
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('milestones').doc(milestoneName);

      await documentReference.update({
        'subgoals.$newSubgoal': {'subgoalName': newSubgoal, 'subgoalTicked': false}
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future toggleSubgoalCheckbox(String milestoneName, String subgoalName, bool subgoalTicked) async {
    // Get the UID of the currently authenticated user
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('milestones').doc(milestoneName);

      await documentReference.update({
        'subgoals.$subgoalName.subgoalTicked': !subgoalTicked
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteSubgoalFromMilestone(String milestoneName, String oldSubgoal) async {
    // Get the UID of the currently authenticated user
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentReference documentReference = _fireStoreService.collection('USERS').doc(uid).collection('milestones').doc(milestoneName);

      await documentReference.update({
        'subgoals.$oldSubgoal': FieldValue.delete(),
      });
    }else{
      print("User is not authenticated");
    }
  }

  Future createMilestone(String milestoneName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('milestones').doc(milestoneName).set(
        {
        "milestoneName": milestoneName,
        "subgoals": {}
        }
      );
    }else{
      print("User is not authenticated");
    }
  }

  Future deleteMilestone(String milestoneName) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('milestones').doc(milestoneName).delete();
    }else{
      print("User is not authenticated");
    }
  }

  Future<QuerySnapshot> getAllMilestones() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final QuerySnapshot _ref = await _fireStoreService.collection('USERS').doc(uid).collection('milestones').get();
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
        }
      );
    }else{
      print("User is not authenticated");
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

  Future createTodoList(String listName, DateTime datetime) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _fireStoreService.collection('USERS').doc(uid).collection('todoLists').doc(listName).set(
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
