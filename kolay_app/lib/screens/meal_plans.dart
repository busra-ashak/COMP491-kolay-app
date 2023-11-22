import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/meal_plan_list.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';

class MealPlansPage extends StatefulWidget {
 @override
 State<MealPlansPage> createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Your Meal Plans',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: ListView(
        children: [
          FutureBuilder<Map<String, Map>>(
            future: context.watch<MealPlanList>().getAllMealPlanLists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!.isEmpty)) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No Meal Plans available.')),
                );
              } else {
                return Column(
                  children: (snapshot.data ?? {}).values.map(
                    (doc) => Column(
                      children: [
                        MealPlanWidget(
                          listName: doc['listName'],
                          datetime: doc['datetime'],
                          listItems: doc['listItems'],
                          onSave: () => _saveMealPlanToDatabase(context, doc['listName']),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmDialog(context, doc['listName']);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ).toList(),
                );
              }
            },
          ),
          IconButton(
            onPressed: () {
              _showCreateListDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String listName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Meal Plan'),
          content: const Text('Are you sure you want to save this meal plans?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveMealPlanToDatabase(context, listName);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _saveMealPlanToDatabase(BuildContext context, String listName) async {
    var mealPlanList = context.read<MealPlanList>();
    var mealPlan = mealPlanList.localMealPlans.firstWhere(
      (element) => element['listName'] == listName,
      orElse: () => Map<String, dynamic>(),
    );

    if (mealPlan.isNotEmpty) {
      await mealPlanList.createMealPlan(mealPlan['listName'], DateTime.now()); // Update with the selected or current date

      for (var itemName in mealPlan['listItems'].keys) {
        await mealPlanList.addMealPlanItem(mealPlan['listName'], itemName);

        var itemDetails = mealPlan['listItems'][itemName];
        if (itemDetails['itemTicked']) {
          await mealPlanList.IngredientCheckbox(
            mealPlan['listName'],
            itemName,
            itemDetails['itemTicked'],
          );
        }
      }

      mealPlanList.clearLocalMealPlans();
      Navigator.pop(context); // Dismiss the dialog
    }
  }


  

  void _showCreateListDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now(); // Initial date

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new Meal Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'The name of your Meal Plan'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text('Pick Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newListName = nameController.text;
                if (newListName.isNotEmpty) {
                  context.read<MealPlanList>().createMealPlan(newListName, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

}










// class _MealPlansPageState extends State<MealPlansPage> {
//   final TextEditingController _descriptionController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     final mealPlanProvider = Provider.of<MealPlanList>(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Your Meal Plans', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection("meals").snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;

//               final mealPlan = MealPlan(
//                 id: documents[index].id,
//                 description: data['description'],
//                 isCompleted: data['isCompleted'],
//                 date: data['date'].toDate(),
//               );

//               return MealPlanWidget(
//                 description: mealPlan.description,
//                 date: mealPlan.date,
//                 isCompleted: mealPlan.isCompleted,
//                 onCheckboxChanged: (value) {
//                   // Update the 'isCompleted' field in Firebase
//                   FirebaseFirestore.instance.collection("meals").doc(mealPlan.id).update({
//                     'isCompleted': value,
//                   });

//                   // Update the local state using the provider
//                   mealPlanProvider.updateMealPlanCompletion(mealPlan.id, value ?? false); // Provide a default value if value is null
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _addMealPlan(context, mealPlanProvider),
//         tooltip: 'Add Meal Plan',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//    void _addMealPlan(BuildContext context, MealPlanProvider mealPlanProvider) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Meal Plan'),
//           content: Column(
//             children: [
//               TextField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(labelText: 'Meal Plan Name'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () async {
//                   DateTime? date = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );
//                   if (date != null) {
//                   setState(() {
//                     _selectedDate = date;
//                   });
//                   }
//                 },
//                 child: Text('Select Date'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String name = _descriptionController.text ?? ' ';
//                 await FirebaseFirestore.instance.collection("meals").add({
//                   'name': _descriptionController.text,
//                   'isCompleted': false,
//                   'date': _selectedDate,
//                 });

//                 mealPlanProvider.addMealPlan(
//                   MealPlan(
//                     id: name, // Using name as an ID
//                     description: name,
//                     isCompleted: false,
//                     date: _selectedDate,
//                   ),
//                 );

//                 Navigator.of(context).pop();
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }