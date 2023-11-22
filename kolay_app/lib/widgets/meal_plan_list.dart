import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';


class MealPlanWidget extends StatelessWidget {
  final String listName;
  final String datetime;
  final Map listItems;
  final VoidCallback onSave;

  const MealPlanWidget({
    Key? key,
    required this.listName,
    required this.datetime,
    required this.listItems,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => context.read<MealPlanList>().deleteMealPlan(listName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(listName), // Use the list name here
            subtitle: Text(datetime),
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
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Confirm'),
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
                      .read<MealPlanList>()
                      .IngredientCheckbox(listName, content['itemName'], content['itemTicked']);
                }),
            trailing: IconButton(
                onPressed: () => context
                    .read<MealPlanList>()
                    .deleteIngredientFromList(listName, content['itemName'], content['itemTicked']),
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
                  context.read<MealPlanList>().addMealPlanItem(listName, newItemName);
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
              onPressed: () {
                _renameMealPlan(context, listName, controller.text);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _renameMealPlan(BuildContext context, String oldListName, String newListName) {
    var mealPlanList = context.read<MealPlanList>();
    mealPlanList.renameMealPlan(oldListName, newListName);
    Navigator.of(context).pop(); // Dismiss the dialog
  }
}





// class MealPlanWidget extends StatelessWidget {
//   final String description;
//   final DateTime? date;
//   final bool? isCompleted;
//   final Function(bool?)? onCheckboxChanged; // Update the function signature

//   MealPlanWidget({
//     required this.description,
//     this.date,
//     this.isCompleted,
//     this.onCheckboxChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(description),
//       subtitle: Text('Date: $date'),
//       trailing: Checkbox(
//         value: isCompleted,
//         onChanged: onCheckboxChanged,
//       ),
//     );
//   }
// }
