import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import 'package:intl/intl.dart';
import 'package:kolay_app/providers/slide_expandable_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ReminderListExpandable extends StatelessWidget {
  final String listName;
  final DateTime dueDatetime;
  final Map listItems;

  const ReminderListExpandable(
      {Key? key,
      required this.listName,
      required this.dueDatetime,
      required this.listItems})
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
                          _showDeleteReminderListDialog(context, listName);
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
                    subtitle: Text(
                        DateFormat('yyyy-MM-dd – kk:mm').format(dueDatetime),
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
              }),
            )));
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, String listName, Map listItems) {
    List<Widget> columnContent = [];

    if (listItems.isNotEmpty) {
      for (Map content in listItems.values) {
        var itemDeadline = content['itemDeadline'].runtimeType == Timestamp
            ? content['itemDeadline'].toDate()
            : content['itemDeadline'];
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
                  _showDeleteReminderFromListDialog(
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
                    context.read<ReminderList>().toggleItemCheckbox(
                        listName, content['itemName'], content['itemTicked']);
                  }),
              title: Text(content['itemName'],
                  style: const TextStyle(fontSize: 16)),
              subtitle: Text(
                  DateFormat('yyyy-MM-dd – kk:mm').format(itemDeadline),
                  style: const TextStyle(fontSize: 12))),
        ));
      }
    }

    columnContent.add(ListTile(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(
          onPressed: () => _showAddReminderToListDialog(context, listName),
          child: const Text(
            "Add reminder",
            style: TextStyle(color: Color(0xFF6C64B3)),
          ),
        ),
      ]),
    ));

    return columnContent;
  }

  void _showAddReminderToListDialog(BuildContext context, String listName) {
    TextEditingController itemNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new reminder to the reminder group'),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: 'New reminder'),
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

  void _showDeleteReminderListDialog(BuildContext context, String listName) {
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

  void _showDeleteReminderFromListDialog(
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
