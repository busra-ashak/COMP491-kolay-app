import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kolay_app/providers/slide_expandable_provider.dart';

class TodoListExpandable extends StatelessWidget {
  final String listName;
  final Map listItems;
  final bool showProgressBar;

  const TodoListExpandable(
      {Key? key,
      required this.listName,
      required this.listItems,
      required this.showProgressBar})
      : super(key: key);

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
                            _showEditTodoListDialog(
                                context, listName, showProgressBar);
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
                      title:
                          Text(listName, style: const TextStyle(fontSize: 20)),
                      subtitle: Center(
                        child: Visibility(
                          visible: showProgressBar,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: LinearPercentIndicator(
                              width: 210.0,
                              lineHeight: 15.0,
                              animation: true,
                              percent: _getTaskProgress(listItems),
                              center: Text(
                                _getTaskProgressString(listItems),
                                style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black45),
                              ),
                              barRadius: const Radius.circular(10),
                              backgroundColor: Colors.grey,
                              progressColor: _areAllItemsChecked(listItems)
                                  ? themeBody[themeProvider.themeDataName]![
                                      'todoPercentageDone']
                                  : themeBody[themeProvider.themeDataName]![
                                      'todoPercentage'],
                            ),
                          ),
                        ),
                      ),
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

  String _getTaskProgressString(Map listItems) {
    if (listItems.isEmpty) return '';
    int len = listItems.values.length;
    int ticked = 0;
    for (Map item in listItems.values) {
      if (item['itemTicked']) {
        ticked++;
      }
    }
    return '$ticked / $len';
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
    return len == 0 ? 0 : ticked / len;
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
                  _showEditTodoFromListDialog(
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
                activeColor: themeObject['tick'],
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
          child: Text(
            "Add item",
            style: TextStyle(color: themeObject['expandableButton']),
          ),
        ),
        ElevatedButton(
          onPressed: () => _completeAllItems(context, listName, listItems),
          child: Text(
            "Complete",
            style: TextStyle(color: themeObject['expandableButton']),
          ),
        ),
      ]),
    ));

    return columnContent;
  }

  void _completeAllItems(BuildContext context, String listName, Map listItems) {
    for (Map item in listItems.values) {
      if (!item['itemTicked']) {
        context
            .read<TodoList>()
            .toggleItemCheckbox(listName, item['itemName'], false);
      }
    }
  }

  void _showAddTodoToListDialog(BuildContext context, String listName) {
    TextEditingController itemNameController = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Add a new item to the to-do list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnSurface']!,
                  ),
                  decoration: InputDecoration(
                    labelText: 'New Item',
                    labelStyle: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
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
                String newItemName = itemNameController.text;
                if (newItemName.isNotEmpty) {
                  context
                      .read<TodoList>()
                      .addTodoItemToList(listName, newItemName);
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

  void _showDeleteTodoListDialog(BuildContext context, String listName) {
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Are you sure you want to delete $listName?',
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
                context.read<TodoList>().deleteTodoList(listName);
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

  void _showDeleteTodoFromListDialog(
      BuildContext context, String listName, String oldItem) {
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
                context
                    .read<TodoList>()
                    .deleteTodoItemFromList(listName, oldItem);
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

  void _showEditTodoFromListDialog(
      BuildContext context, String listName, String oldItem) {
    final ThemeProvider themeProvider = ThemeProvider();

    TextEditingController itemNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit your to-do item',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnSurface']!,
                  ),
                  decoration: InputDecoration(
                      labelText: 'Edit Item',
                      labelStyle: TextStyle(
                        color: themeBody[themeProvider.themeDataName]![
                            'dialogPrimary']!,
                      ),
                      hintText: oldItem),
                ),
                const SizedBox(height: 16),
              ]),
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
                String newItemName = itemNameController.text;
                if (newItemName.isNotEmpty) {
                  context
                      .read<TodoList>()
                      .editTodoItemInList(listName, newItemName, oldItem);
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

  void _showEditTodoListDialog(
      BuildContext context, String oldTodoListName, bool showProgressBar) {
    TextEditingController controller = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit your to-do list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
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
                    labelText: 'The name of your to-do list',
                    labelStyle: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      activeColor: themeBody[themeProvider.themeDataName]![
                      'tick']!,
                      value: showProgressBar,
                      onChanged: (bool? value) {
                        setState(() {
                          showProgressBar = !showProgressBar;
                          context.read<TodoList>().toggleProgressionBar(
                              oldTodoListName, showProgressBar);
                        });
                      },
                    ),
                    Text(
                      'Show progress bar',
                      style: TextStyle(
                        color: themeBody[themeProvider.themeDataName]![
                            'routineSubtitle']!, // Change this color to your desired color
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
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
                String newListName = controller.text;
                if (newListName.isEmpty) {
                  newListName = oldTodoListName;
                }
                context.read<TodoList>().editTodoList(
                    newListName, oldTodoListName, showProgressBar);
                Navigator.of(context).pop();
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
