import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MealPlanList with ChangeNotifier {
  List<Map<String, dynamic>> _localMealPlans = [];

  List<Map<String, dynamic>> get localMealPlans => _localMealPlans;
 Future<Map<String, Map>> getAllMealPlanLists() async {
    Map<String, Map> documents = {};

    try {
      var collectionReference = FirebaseFirestore.instance.collection('meals');
      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        var datetime = documentSnapshot.get('datetime');
        Map<String, Map> doc =
        {documentSnapshot.id :
        {
          'listName': documentSnapshot.get('listName'),
          'datetime': DateTime.fromMillisecondsSinceEpoch(datetime),
          'listItems': documentSnapshot.get('listItems')
        }
        };
        documents.addAll(doc);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return Future.value(documents);
  }

  //keep the information at the local machine
  void addLocalMealPlan(Map<String, dynamic> mealPlan) {
    _localMealPlans.add(mealPlan);
    notifyListeners();
  }

  void clearLocalMealPlans() {
    _localMealPlans.clear();
    notifyListeners();
  }

  Future<void> confirmAndUploadMealPlans() async {
    for (var mealPlan in _localMealPlans) {
      await createMealPlan(mealPlan['listName'], mealPlan['datetime']);
      for (var itemName in mealPlan['listItems'].keys) {
        await addMealPlanItem(mealPlan['listName'], itemName);
        var itemDetails = mealPlan['listItems'][itemName];
        if (itemDetails['itemTicked']) {
          await IngredientCheckbox(
            mealPlan['listName'],
            itemName,
            itemDetails['itemTicked'],
          );
        }
      }
    }
    clearLocalMealPlans();
  }


  Future<void> addMealPlanItem(String listName, String newItem) async {
    var documentReference = FirebaseFirestore.instance.collection('meals').doc(listName);

    await documentReference.update({
      'listItems.$newItem': {'itemName': newItem, 'itemTicked': false}
    }).catchError((error) {
      print('Error adding item: $error');
    });

    notifyListeners();
  }

  Future<void> IngredientCheckbox(String listName, String itemName, bool itemTicked) async {
    var documentReference = FirebaseFirestore.instance.collection('meals').doc(listName);

    await documentReference.update({
      'listItems.$itemName': {'itemName': itemName, 'itemTicked': !itemTicked}
    }).catchError((error) {
      print('Error adding item: $error');
    });

    notifyListeners();
  }

  deleteIngredientFromList(String listName, String oldItem, bool oldItemTicked) {
    var documentReference = FirebaseFirestore.instance.collection('meals').doc(listName);

    documentReference.update({
      'listItems': FieldValue.arrayRemove([{'itemName': oldItem, 'itemTicked': oldItemTicked}])
    }).catchError((error) {
      print('Error deleting item: $error');
    });

    notifyListeners();
  }

  Future<void>  createMealPlan(String listName, DateTime datetime) async {
  FirebaseFirestore.instance.collection("meals").doc(listName).set(
    {
      "listName": listName,
      "datetime": datetime.millisecondsSinceEpoch,
      "listItems": {}
    },
  ).catchError((error) {
    print('Error creating list: $error');
  });

  notifyListeners();
}


  void deleteMealPlan(String listName) {
    // open modal and ask are you sure
    FirebaseFirestore.instance.collection("meals").doc(listName).delete().catchError((error) {
      print('Error creating list: $error');
    });
    notifyListeners();
  }

  void renameMealPlan(String oldListName, String newListName) {
    var localMealPlan = _localMealPlans.firstWhere(
      (element) => element['listName'] == oldListName,
      orElse: () => Map<String, dynamic>(),
    );

    if (localMealPlan.isNotEmpty) {
      localMealPlan['listName'] = newListName;
      notifyListeners();
    }
  }

}





// class MealPlan {
//   final String id;
//   final String description;
//   final bool? isCompleted;
//   final DateTime? date;

//   MealPlan({
//     required this.id,
//     required this.description,
//     this.isCompleted,
//     this.date,
//   });

//   // Define a copyWith method
//   MealPlan copyWith({
//     String? id,
//     String? description,
//     bool? isCompleted,
//     DateTime? date,
//   }) {
//     return MealPlan(
//       id: id ?? this.id,
//       description: description ?? this.description,
//       isCompleted: isCompleted ?? this.isCompleted,
//       date: date ?? this.date,
//     );
//   }
// }


// class MealPlanProvider with ChangeNotifier {
//   List<MealPlan> _mealPlans = [];

//   List<MealPlan> get mealPlans => _mealPlans;

//   void addMealPlan(MealPlan mealPlan) {
//     _mealPlans.add(mealPlan);
//     notifyListeners();
//   }

//   void updateMealPlanCompletion(String? mealPlanId, bool isCompleted) {
//     final mealPlanIndex = _mealPlans.indexWhere((plan) => plan.id == mealPlanId);
//     if (mealPlanIndex != -1) {
//       _mealPlans[mealPlanIndex] = _mealPlans[mealPlanIndex].copyWith(isCompleted: isCompleted);
//       notifyListeners();
//     }
//   }
// }
