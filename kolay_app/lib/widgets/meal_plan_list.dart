import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';


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
          onPressed: () => context.read<MealPlan>().deleteMealPlan(listName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(listName), // Use the list name here
            subtitle: Text(datetime.toString()),
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
                onPressed: () => context
                    .read<MealPlan>()
                    .deleteIngredientFromList(listName, content['itemName']),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
}

