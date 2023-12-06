import 'package:flutter/material.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:kolay_app/screens/settings.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          iconSize: 31.0,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Your Meal Plans',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            iconSize: 31.0,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          )
        ],
      ),
      body: Consumer<MealPlan>(builder: (context, viewModel, child) {
        return ListView(
          children: viewModel.mealPlans.values
              .map(
                (doc) => Column(
                  children: [
                    MealPlanWidget(
                      listName: doc['listName'],
                      datetime: doc['datetime'],
                      listItems: doc['listItems'],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showConfirmDialog(context, doc['listName']);
                      },
                      child: const Text('Add to a Shopping List'),
                    ),
                  ],
                ),
              )
              .toList(),
        );
      }),
      floatingActionButton: IconButton(
        onPressed: () {
          _showCreateMealPlanDialog(context);
        },
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String mealPlanName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to a Shopping List'),
          content: const Text(
              'Do you want to add to an existing shopping list or create a new one?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAddToListDialog(context, mealPlanName);
              },
              child: const Text('Add to existing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateListDialog(context, mealPlanName);
              },
              child: const Text('Create a new one'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateMealPlanDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new Meal Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'The name of your Meal Plan'),
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
                String mealPlanName = nameController.text;
                if (mealPlanName.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .createMealPlan(mealPlanName, selectedDate);
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

  void _showAddToListDialog(BuildContext context, String mealPlanName) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to a shopping list'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
                labelText: 'The name of your shopping list'),
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
                String listName = controller.text;
                List<String> listItems = context
                    .read<MealPlan>()
                    .getUntickedIngredients(mealPlanName);
                if (listName.isNotEmpty && listItems.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .addToShoppingListFromMeal(listName, listItems);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context, String mealPlanName) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a shopping list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'The name of your Shopping List'),
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
                String listName = controller.text;
                List<String> listItems = context
                    .read<MealPlan>()
                    .getUntickedIngredients(mealPlanName);
                if (listName.isNotEmpty && listItems.isNotEmpty) {
                  context.read<MealPlan>().createShoppingListFromMeal(
                      listName, listItems, selectedDate);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
