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
              color: _areAllItemsChecked(listItems)
                  ? themeBody[themeProvider.themeDataName]!['expandablePale']
                  : themeBody[themeProvider.themeDataName]!['expandable'],
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
                              themeBody[themeProvider.themeDataName]),
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
                onPressed: (context) {
                  _showEditItemInMealDialog(
                      context, listName, content['itemName']);
                },
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
                style: TextStyle(
                    color: themeObject['expandableButton'], fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showConfirmDialog(context, listName),
              child: Text(
                "Create shopping list",
                style: TextStyle(
                    color: themeObject['expandableButton'], fontSize: 12),
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
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Add a new item to the meal plan',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color:
                  themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
            ),
            decoration: InputDecoration(
              labelText: 'New Item',
              labelStyle: TextStyle(
                color:
                    themeBody[themeProvider.themeDataName]!['dialogPrimary']!,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
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
              child: Text(
                'Add',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMealPlanDialog(BuildContext context, String mealplanName) {
    final ThemeProvider themeProvider = ThemeProvider();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Are you sure you want to delete $mealplanName?',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<MealPlan>().deleteMealPlan(mealplanName);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemFromMealPlanDialog(
      BuildContext context, String mealplanName, String oldItem) {
    final ThemeProvider themeProvider = ThemeProvider();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Are you sure you want to delete $oldItem?',
            style: TextStyle(
              color:
                  themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<MealPlan>()
                    .deleteIngredientFromList(mealplanName, oldItem);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditMealPlanDialog(BuildContext context, String oldMealPlanName) {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit Meal Plan',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                ),
                decoration: InputDecoration(
                  labelText: 'The name of your Meal Plan',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                                surface: themeBody[themeProvider
                                    .themeDataName]!['dialogSurface']!,
                                primary: themeBody[themeProvider
                                    .themeDataName]!['dialogPrimary']!,
                                onPrimary: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!,
                                onSurface: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!),
                          ),
                          child: child!);
                    },
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text(
                  'Pick Date',
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnWhiteSurface']!, // Change this color to your desired color
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String newMealPlanName = nameController.text;
                if (newMealPlanName.isNotEmpty) {
                  context.read<MealPlan>().editMealPlan(
                      newMealPlanName, selectedDate, oldMealPlanName);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Edit',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context, String mealPlanName) {
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Add to a Shopping List',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Text(
            'Do you want to add to an existing shopping list or create a new one?',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAddToListDialog(context, mealPlanName);
              },
              child: Text(
                'Add to existing',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateListDialog(context, mealPlanName);
              },
              child: Text(
                'Create a new one',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddToListDialog(BuildContext context, String mealPlanName) {
    TextEditingController controller = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Add to a shopping list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color:
                  themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
            ),
            decoration: InputDecoration(
              labelText: 'The name of your shopping list',
              labelStyle: TextStyle(
                color:
                    themeBody[themeProvider.themeDataName]!['dialogPrimary']!,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
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
              child: Text(
                'Add',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context, String mealPlanName) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Create a shopping list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                ),
                decoration: InputDecoration(
                  labelText: 'The name of your Shopping List',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                                surface: themeBody[themeProvider
                                    .themeDataName]!['dialogSurface']!,
                                primary: themeBody[themeProvider
                                    .themeDataName]!['dialogPrimary']!,
                                onPrimary: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!,
                                onSurface: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!),
                          ),
                          child: child!);
                    },
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text(
                  'Pick Date',
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnWhiteSurface']!, // Change this color to your desired color
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
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
              child: Text(
                'Create',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _areAllItemsChecked(Map listItems) {
    if (listItems.isEmpty) return false;
    for (Map item in listItems.values) {
      if (!item['itemTicked']) {
        return false; // At least one item is not checked
      }
    }
    return true; // All items are checked
  }

  void _showEditItemInMealDialog(
      BuildContext context, String listName, String oldName) {
    TextEditingController controller = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit ingredient in the meal plan',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color:
                  themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
            ),
            decoration: const InputDecoration(labelText: 'Edit Item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
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
              child: Text(
                'Edit',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
