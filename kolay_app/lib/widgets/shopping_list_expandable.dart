import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';

class ShoppingListExpandable extends StatelessWidget {
  final String listName;
  final String creationDatetime;
  final Map listItems;

  const ShoppingListExpandable({
    Key? key, 
    required this.listName,
    required this.creationDatetime,
    required this.listItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => _showDeleteListDialog(context, listName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(listName),
            subtitle: Text(creationDatetime),
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
                    .read<ShoppingList>()
                    .updateToggle(listName, content['itemName'], content['itemTicked']);
              }),
            trailing: IconButton(
                onPressed: () => _showDeleteItemFromListDialog(context, listName, content['itemName']),
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
              _showAddItemToListDialog(context, listName),
            icon: const Icon(Icons.add)),
      ),
    );

    return columnContent;
  }

  void _showAddItemToListDialog(BuildContext context, String listName) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new item to the shopping list'),
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
                  context.read<ShoppingList>().addShoppingListItem(listName, newItemName);
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
  
  void _showDeleteListDialog(BuildContext context, String listName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $listName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<ShoppingList>().removeShoppingList(listName);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemFromListDialog(BuildContext context, String listName, String oldItem) {
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
                context.read<ShoppingList>().removeShoppingListItem(listName, oldItem);
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
