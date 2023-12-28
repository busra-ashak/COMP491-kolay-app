import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/slide_expandable_provider.dart';

class ShoppingListExpandable extends StatelessWidget {
  final String listName;
  final DateTime datetime;
  final Map listItems;

  const ShoppingListExpandable(
      {Key? key,
      required this.listName,
      required this.datetime,
      required this.listItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SlidableState(),
        child: Card(
            color: const Color(0xFF8B85C1),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ClipRect(child: Consumer<SlidableState>(
                builder: (context, slidableState, child) {
              return Slidable(
                closeOnScroll: false,
                enabled: slidableState.isSlidableEnabled,
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {},
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
                        _showDeleteListDialog(context, listName);
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
                  title: Text(listName, style: const TextStyle(fontSize: 20)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(datetime),
                      style: const TextStyle(fontSize: 12)),
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
              );
            }))));
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, String listName, Map listItems) {
    List<Widget> columnContent = [];

    if (listItems.isNotEmpty) {
      for (Map content in listItems.values) {
        columnContent.add(Slidable(
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
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
                  _showDeleteItemFromListDialog(
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
                activeColor: const Color(0xFF77BBB4),
                onChanged: (bool? val) {
                  context.read<ShoppingList>().updateToggle(
                      listName, content['itemName'], content['itemTicked']);
                }),
            title:
                Text(content['itemName'], style: const TextStyle(fontSize: 16)),
          ),
        ));
      }
    }

    columnContent.add(ListTile(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(
          onPressed: () => _showAddItemToListDialog(context, listName),
          child: const Text(
            "Add item",
            style: TextStyle(color: Color(0xFF6C64B3)),
          ),
        ),
      ]),
    ));

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
                  context
                      .read<ShoppingList>()
                      .addShoppingListItem(listName, newItemName);
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

  void _showDeleteItemFromListDialog(
      BuildContext context, String listName, String oldItem) {
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
                    .read<ShoppingList>()
                    .removeShoppingListItem(listName, oldItem);
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
