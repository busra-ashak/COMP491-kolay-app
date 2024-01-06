import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kolay_app/providers/slide_expandable_provider.dart';

class TodoListExpandable extends StatelessWidget {
  final String listName;
  final Map listItems;

  const TodoListExpandable(
      {Key? key, required this.listName, required this.listItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SlidableState(),
        child: Card(
            color: const Color(0xFF8B85C1),
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
                          _showDeleteTodoListDialog(context, listName);
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
                    subtitle: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: LinearPercentIndicator(
                          width: 210.0,
                          lineHeight: 14.0,
                          percent: _getTaskProgress(listItems),
                          center: Text(
                            _getTaskProgress(listItems).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12.0),
                          ),
                          trailing: const Icon(Icons.mood),
                          barRadius: const Radius.circular(10),
                          backgroundColor: Colors.grey,
                          progressColor: const Color(0xFF77BBB4),
                        ),
                      ),
                    ),
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
              }),
            )));
  }

  double _getTaskProgress(Map listItems) {
    if (listItems.isEmpty) return 0;
    int len = listItems.values.length;
    int ticked = 0;
    for (Map item in listItems.values) {
      if (item['itemTicked']) {
        ticked++;
      }
    }
    return ticked / len;
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
                  _showDeleteTodoFromListDialog(
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
                  context.read<TodoList>().toggleItemCheckbox(
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
          onPressed: () => _showAddTodoToListDialog(context, listName),
          child: const Text(
            "Add item",
            style: TextStyle(color: Color(0xFF6C64B3)),
          ),
        ),
      ]),
    ));

    return columnContent;
  }

  void _showAddTodoToListDialog(BuildContext context, String listName) {
    TextEditingController itemNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new item to the to-do list'),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: 'New Item'),
                ),
                const SizedBox(height: 16),
              ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newItemName = itemNameController.text;
                if (newItemName.isNotEmpty) {
                  context
                      .read<TodoList>()
                      .addTodoItemToList(listName, newItemName);
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

  void _showDeleteTodoListDialog(BuildContext context, String listName) {
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
                context.read<TodoList>().deleteTodoList(listName);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteTodoFromListDialog(
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
                    .read<TodoList>()
                    .deleteTodoItemFromList(listName, oldItem);
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
