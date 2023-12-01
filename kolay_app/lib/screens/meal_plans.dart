import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';
import '../widgets/meal_plan_list.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';

class MealPlansPage extends StatefulWidget {
 @override
 State<MealPlansPage> createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage> {
  @override
  void initState() {
    super.initState();
    loadMealPlans();
  }

  loadMealPlans() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<MealPlan>().getAllMealPlans();
    });
  }

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
      body: Consumer<MealPlan>(
          builder: (context, viewModel, child) {
            return ListView(
              children: viewModel.mealPlans.values.map(
                    (doc) => Column(
                      children: [
                        MealPlanWidget(
                          listName: doc['listName'],
                          datetime: doc['datetime'],
                          listItems: doc['listItems'],),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmDialog(context, doc['listName']);
                          },
                          child: const Text('Create Shopping List'),
                        ),
                      ],
                    ),
                  ).toList(),
            );
          }
      ),
      floatingActionButton: IconButton(
            onPressed: () {
              _showCreateListDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
    );
  }

  void _showConfirmDialog(BuildContext context, String listName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Shopping List'),
          content: const Text('Are you sure you want to create shopping list with missing ingredients?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _createShoppingList(context, listName);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future _createShoppingList(BuildContext context, String listName) async {
    print("a");
    List<String> listItems = context.read<MealPlan>().getUntickedIngredients(listName);
    print(listItems);
    await context.read<MealPlan>().createShoppingListFromMeal(listName, listItems);
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
                  context.read<MealPlan>().createMealPlan(newListName, selectedDate);
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
