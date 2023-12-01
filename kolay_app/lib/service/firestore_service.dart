import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final _fireStoreService = FirebaseFirestore.instance;

  /* SHOPPING LIST */

  Future addItemToShoppingList(String listName, String newItem) async {
    final DocumentReference documentReference = _fireStoreService.collection('shoppingLists').doc(listName);

    await documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
    });
  }

  Future toggleShopItemCheckbox(String listName, String itemName, bool itemTicked) async {
    final DocumentReference documentReference = _fireStoreService.collection('shoppingLists').doc(listName);

    await documentReference.update({
      'listItems.$itemName.itemTicked': !itemTicked
    });
  }

  Future deleteItemFromShoppingList(String listName, String oldItem) async {
    final DocumentReference documentReference = _fireStoreService.collection('shoppingLists').doc(listName);

    await documentReference.update({
      'listItems.$oldItem': FieldValue.delete(),
    });
  }

  Future createShoppingList(String listName) async {
    await _fireStoreService.collection('shoppingLists').doc(listName).set(
      {
      "listName": listName,
      "creationDatetime": DateTime.now().millisecondsSinceEpoch,
      "listItems": {}
      }
    );
  }

  Future deleteShoppingList(String listName) async {
    await _fireStoreService.collection('shoppingLists').doc(listName).delete();
  }

  Future<QuerySnapshot> getAllShoppingLists() async {
    final QuerySnapshot _ref = await _fireStoreService.collection('shoppingLists').get();
    return _ref;
  }

  /* MILESTONES */

  Future addSubgoalToMilestone(String milestoneName, String newSubgoal) async {
    final DocumentReference documentReference = _fireStoreService.collection('milestones').doc(milestoneName);

    await documentReference.update({
      'subgoals.$newSubgoal': {'subgoalName': newSubgoal, 'subgoalTicked': false}
    });
  }

  Future toggleSubgoalCheckbox(String milestoneName, String subgoalName, bool subgoalTicked) async {
    final DocumentReference documentReference = _fireStoreService.collection('milestones').doc(milestoneName);

    await documentReference.update({
      'subgoals.$subgoalName.subgoalTicked': !subgoalTicked
    });
  }

  Future deleteSubgoalFromMilestone(String milestoneName, String oldSubgoal) async {
    final DocumentReference documentReference = _fireStoreService.collection('milestones').doc(milestoneName);

    await documentReference.update({
      'subgoals.$oldSubgoal': FieldValue.delete(),
    });
  }

  Future createMilestone(String milestoneName) async {
    await _fireStoreService.collection('milestones').doc(milestoneName).set(
      {
      "milestoneName": milestoneName,
      "subgoals": {}
      }
    );
  }

  Future deleteMilestone(String milestoneName) async {
    await _fireStoreService.collection('milestones').doc(milestoneName).delete();
  }

  Future<QuerySnapshot> getAllMilestones() async {
    final QuerySnapshot _ref = await _fireStoreService.collection('milestones').get();
    return _ref;
  }

  /* ROUTINES */

  Future createRoutine(String routineName, String frequencyMeasure, int frequency) async {
    await _fireStoreService.collection('routines').doc(routineName).set(
      {
      "routineName": routineName,
      "frequency": frequency,
      "frequencyMeasure": frequencyMeasure,
      }
    );
  }

  Future deleteRoutine(String routineName) async {
    await _fireStoreService.collection('routines').doc(routineName).delete();
  }

  Future<QuerySnapshot> getAllRoutines() async {
    final QuerySnapshot _ref = await _fireStoreService.collection('routines').get();
    return _ref;
  }

  /* TO DO LISTS */

  Future addItemToTodoList(String listName, String newItem, String itemDeadline) async {
    final DocumentReference documentReference = _fireStoreService.collection('todoLists').doc(listName);

    await documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false, 'itemDeadline': itemDeadline}
    });
  }

  Future toggleTodoItemCheckbox(String listName, String itemName, bool itemTicked) async {
    final DocumentReference documentReference = _fireStoreService.collection('todoLists').doc(listName);

    await documentReference.update({
      'listItems.$itemName.itemTicked': !itemTicked
    });
  }

  Future deleteItemFromTodoList(String listName, String oldItem) async {
    final DocumentReference documentReference = _fireStoreService.collection('todoLists').doc(listName);

    await documentReference.update({
      'listItems.$oldItem': FieldValue.delete(),
    });
  }

  Future createTodoList(String listName) async {
    await _fireStoreService.collection('todoLists').doc(listName).set(
      {
      "listName": listName,
      "creationDatetime": DateTime.now().millisecondsSinceEpoch,
      "listItems": {}
      }
    );
  }

  Future deleteTodoList(String listName) async {
    await _fireStoreService.collection('todoLists').doc(listName).delete();
  }

  Future<QuerySnapshot> getAllTodoLists() async {
    final QuerySnapshot _ref = await _fireStoreService.collection('todoLists').get();
    return _ref;
  }

  /* MEAL PLANS */

  Future addIngredientToMealPlan(String listName, String newItem) async {
    final DocumentReference documentReference = _fireStoreService.collection('meals').doc(listName);

    await documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
    });
  }

  Future toggleIngredientCheckbox(String listName, String itemName, bool itemTicked) async {
    final DocumentReference documentReference = _fireStoreService.collection('meals').doc(listName);

    await documentReference.update({
      'listItems.$itemName.itemTicked': !itemTicked
    });
  }

  Future deleteIngreidentFromMealPlan(String listName, String oldItem) async {
    final DocumentReference documentReference = _fireStoreService.collection('meals').doc(listName);

    await documentReference.update({
      'listItems.$oldItem': FieldValue.delete(),
    });
  }

  Future createShoppingListFromMeal(String listName, List<String> listItems) async {
    await createShoppingList(listName);
    for(String item in listItems) {
      await addItemToShoppingList(listName, item);
    }
  }

  Future createMealPlan(String listName, DateTime dateTime) async {
    await _fireStoreService.collection('meals').doc(listName).set(
      {
      "listName": listName,
      "datetime": dateTime,
      "listItems": {}
      }
    );
  }

  Future deleteMealPlan(String listName) async {
    await _fireStoreService.collection('meals').doc(listName).delete();
  }

  Future<QuerySnapshot> getAllMealPlans() async {
    final QuerySnapshot _ref = await _fireStoreService.collection('meals').get();
    return _ref;
  }
}
