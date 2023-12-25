import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import 'package:intl/intl.dart';

class ReminderListExpandable extends StatelessWidget {
  final String listName;
  final DateTime dueDatetime;
  final DateTime creationDatetime;
  final Map listItems;

  // Constructor to accept the initial reminder list name
  const ReminderListExpandable(
      {Key? key,
      required this.listName,
      required this.dueDatetime,
      required this.creationDatetime,
      required this.listItems})
      : super(key: key);

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
            title: Text(listName), // Use the initial reminder list name here
            subtitle:
                Text(DateFormat('yyyy-MM-dd – kk:mm').format(creationDatetime)),
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
        var itemDeadline = content['itemDeadline'].runtimeType == Timestamp
            ? content['itemDeadline'].toDate()
            : content['itemDeadline'];
        columnContent.add(
          ListTile(
            leading: Checkbox(
                value: content['itemTicked'],
                onChanged: (bool? val) {
                  context.read<ReminderList>().toggleItemCheckbox(
                      listName, content['itemName'], content['itemTicked']);
                }),
            trailing: IconButton(
                onPressed: () => _showDeleteItemFromListDialog(
                    context, listName, content['itemName']),
                icon: const Icon(Icons.delete)),
            title: Text(content['itemName']),
            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(itemDeadline)),
          ),
        );
      }
    }

    columnContent.add(
      ListTile(
        title: IconButton(
            onPressed: () => _showAddItemToListDialog(context, listName),
            icon: const Icon(Icons.add)),
      ),
    );

    return columnContent;
  }

  void _showAddItemToListDialog(BuildContext context, String listName) {
    TextEditingController itemNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDateTimePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null && pickedDate != selectedDate) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: const Text('Add Deadline'),
                ),
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
                  context.read<ReminderList>().addReminderItemToList(
                      listName, newItemName, selectedDate);
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

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
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
                context.read<ReminderList>().deleteReminderList(listName);
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
                    .read<ReminderList>()
                    .deleteReminderItemFromList(listName, oldItem);
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
