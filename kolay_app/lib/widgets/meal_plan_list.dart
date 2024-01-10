import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:kolay_app/providers/slide_expandable_provider.dart';

class MealPlanWidget extends StatelessWidget {
  final String listName;
  final DateTime datetime;
  final Map listItems;

  const MealPlanWidget({
    Key? key,
    required this.listName,
    required this.datetime,
    required this.listItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SlidableState(),
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return Card(
              color: themeBody[themeProvider.themeDataName]!['expandable'],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ClipRect(
                child: Consumer<SlidableState>(
                    builder: (context, slidableState, child) {
                  return Slidable(
                    closeOnScroll: false,
                    enabled: slidableState.isSlidableEnabled,
                    startActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _showEditMealPlanDialog(context, listName);
                          },
                          backgroundColor: Colors.green,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _showDeleteMealPlanDialog(context, listName);
                          },
                          backgroundColor: Colors.red,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      textColor: Colors.white,
                      onExpansionChanged: (isExpanded) {
                        slidableState.isSlidableEnabled = !isExpanded;
                      },
                      collapsedTextColor: Colors.white,
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      shape: const Border(),
                      title:
                          Text(listName, style: const TextStyle(fontSize: 20)),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(datetime),
                          style: const TextStyle(fontSize: 12)),
                      children: <Widget>[
                        Column(
                          children: _buildExpandableContent(
                            context,
                            listName,
                            listItems,
                            themeBody[themeProvider.themeDataName]
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ));
        }));
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, String listName, Map listItems, var themeObject) {
    List<Widget> columnContent = [];

    if (listItems.isNotEmpty) {
      for (Map content in listItems.values) {
        columnContent.add(Slidable(
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {_showEditItemInMealDialog(
                    context, listName, content['itemName']);},
                backgroundColor: Colors.green,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  _showDeleteItemFromMealPlanDialog(
                      context, listName, content['itemName']);
                },
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            textColor: Colors.white,
            leading: Checkbox(
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: const CircleBorder(),
                value: content['itemTicked'],
                  activeColor: themeObject['tick'],
                onChanged: (bool? val) {
                  context.read<MealPlan>().toggleIngredientCheckbox(
                      listName, content['itemName'], content['itemTicked']);
                }),
            title:
                Text(content['itemName'], style: const TextStyle(fontSize: 16)),
          ),
        ));
      }
    }

    columnContent.add(
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showAddItemToMealDialog(context, listName),
              child: Text(
                "Add ingredient",
                style: TextStyle(color: themeObject['expandableButton'], fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showConfirmDialog(context, listName),
              child:  Text(
                "Create shopping list",
                style: TextStyle(color: themeObject['expandableButton'], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );

    return columnContent;
  }

  void _showAddItemToMealDialog(BuildContext context, String listName) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new item to the meal plan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Item'),
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
                String newItemName = controller.text;
                if (newItemName.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .addIngredientToList(listName, newItemName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteMealPlanDialog(BuildContext context, String mealplanName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $mealplanName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<MealPlan>().deleteMealPlan(mealplanName);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemFromMealPlanDialog(
      BuildContext context, String mealplanName, String oldItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $oldItem?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<MealPlan>()
                    .deleteIngredientFromList(mealplanName, oldItem);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMealPlanDialog(BuildContext context, String oldMealPlanName) {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Meal Plan'),
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
                String newMealPlanName = nameController.text;
                if (newMealPlanName.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .editMealPlan(newMealPlanName, selectedDate, oldMealPlanName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
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

  void _showEditItemInMealDialog(BuildContext context, String listName, String oldName) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit ingredient in the meal plan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Edit Item'),
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
                String newItemName = controller.text;
                if (newItemName.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .editIngredientInList(listName, newItemName, oldName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}
