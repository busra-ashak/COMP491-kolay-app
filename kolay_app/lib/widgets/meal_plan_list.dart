import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import 'package:intl/intl.dart';


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
    return Row(
      children: <Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => _showDeleteMealPlanDialog(context, listName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(listName), // Use the list name here
            subtitle: Text(DateFormat('dd/MM/yyyy').format(datetime)),
            children: <Widget>[
              Column(
                children: _buildExpandableContent(
                  context,
                  listName,
                  listItems,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _showRenameDialog(context, listName);
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, String listName, Map listItems) {

    List<Widget> columnContent = [];

    if (listItems.isNotEmpty) {
      for (Map content in listItems.values) {
        columnContent.add(
          ListTile(
            leading: Checkbox(
                value: content['itemTicked'],
                onChanged: (bool? val) {
                  context
                      .read<MealPlan>()
                      .toggleIngredientCheckbox(listName, content['itemName'], content['itemTicked']);
                }),
            trailing: IconButton(
                onPressed: () => _showDeleteItemFromMealPlanDialog(context, listName, content['itemName']),
                icon: const Icon(Icons.delete)),
            title: Text(content['itemName']),
          ),
        );
      }
    }

    columnContent.add(
      ListTile(
        title: IconButton(
            onPressed: () =>
                _showAddItemToMealDialog(context, listName),
            icon: const Icon(Icons.add)),
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
          title: const Text('Add a new item to the Meal Plan'),
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
                  context.read<MealPlan>().addIngredientToList(listName, newItemName);
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

  void _showRenameDialog(BuildContext context, String listName) {
    TextEditingController controller = TextEditingController(text: listName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Meal Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enter a new name:'),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'New Name'),
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
              onPressed: () {},
              child: const Text('Rename'),
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

  void _showDeleteItemFromMealPlanDialog(BuildContext context, String mealplanName, String oldItem) {
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
                context.read<MealPlan>().deleteIngredientFromList(mealplanName, oldItem);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

}

