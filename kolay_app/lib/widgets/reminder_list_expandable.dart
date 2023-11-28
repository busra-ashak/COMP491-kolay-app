import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import 'package:intl/intl.dart';

class ReminderListExpandable extends StatelessWidget {
  final String listName;
  final DateTime creationDatetime;
  final Map listItems;

  // Constructor to accept the initial reminder list name
  const ReminderListExpandable({
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
          onPressed: () => context.read<ReminderList>().deleteReminderList(listName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(listName), // Use the initial reminder list name here
            subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(creationDatetime)),
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
                      .read<ReminderList>()
                      .toggleItemCheckbox(listName, content['itemName'], content['itemTicked'], content['itemDeadline']);
                }),
            trailing: IconButton(
                onPressed: () => context
                    .read<ReminderList>()
                    .deleteReminderItemFromList(listName, content['itemName'], content['itemTicked']),
                icon: const Icon(Icons.delete)),
            title: Text(content['itemName']),
            subtitle: Text(content['itemDeadline']),
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
    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemDeadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new item to the Reminder list'),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              // wrap content in flutter
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: 'New Item'),
                ),
                TextField(
                  controller: itemDeadlineController,
                  decoration: const InputDecoration(labelText: 'Deadline'),
                )]
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
                String newItemName = itemNameController.text;
                String itemDeadline = itemDeadlineController.text;
                if (newItemName.isNotEmpty) {
                  context.read<ReminderList>().addReminderItemToList(listName, newItemName, itemDeadline);
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
}
