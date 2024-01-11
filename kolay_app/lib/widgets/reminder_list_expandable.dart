import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
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
                            _showEditReminderListDialog(context, listName);
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
                      title:
                          Text(listName, style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                          DateFormat('yyyy-MM-dd – kk:mm').format(dueDatetime),
                          style: const TextStyle(fontSize: 12)),
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

  List<Widget> _buildExpandableContent(
      BuildContext context, String listName, Map listItems, var themeObject) {
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
                onPressed: (context) {
                  _showEditReminderFromListDialog(
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
                  activeColor: themeObject['tick'],
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
          child: Text(
            "Add reminder",
            style: TextStyle(color: themeObject['expandableButton']),
          ),
        ),
      ]),
    ));

    return columnContent;
  }

  void _showAddReminderToListDialog(BuildContext context, String listName) {
    TextEditingController itemNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Add a new reminder to the reminder group',
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
                    labelText: 'New reminder',
                    labelStyle: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!,
                    ),
                  ),
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
                  child: Text(
                    'Add Deadline',
                    style: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogOnWhiteSurface']!, // Change this color to your desired color
                    ),
                  ),
                ),
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
                  context.read<ReminderList>().addReminderItemToList(
                      listName, newItemName, selectedDate);
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

  bool _areAllItemsChecked(Map listItems) {
    if (listItems.isEmpty) return false;
    for (Map item in listItems.values) {
      if (!item['itemTicked']) {
        return false; // At least one item is not checked
      }
    }
    return true; // All items are checked
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final ThemeProvider themeProvider = ThemeProvider();
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                  surface:
                      themeBody[themeProvider.themeDataName]!['dialogSurface']!,
                  primary:
                      themeBody[themeProvider.themeDataName]!['dialogPrimary']!,
                  onPrimary: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                  onSurface: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!),
            ),
            child: child!);
      },
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                surface:
                    themeBody[themeProvider.themeDataName]!['dialogSurface']!,
                primary:
                    themeBody[themeProvider.themeDataName]!['dialogPrimary']!,
                onPrimary:
                    themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
                onSurface:
                    themeBody[themeProvider.themeDataName]!['dialogOnSurface']!,
                tertiaryContainer:
                    themeBody[themeProvider.themeDataName]!['dialogPrimary']!,
              ),
            ),
            child: child!);
      },
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
                context.read<ReminderList>().deleteReminderList(listName);
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

  void _showDeleteReminderFromListDialog(
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
                    .read<ReminderList>()
                    .deleteReminderItemFromList(listName, oldItem);
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

  void _showEditReminderFromListDialog(
      BuildContext context, String listName, String oldItem) {
    DateTime selectedDate = DateTime.now();
    TextEditingController itemNameController = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit your reminder',
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
                    labelText: 'Edit reminder',
                    labelStyle: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!,
                    ),
                  ),
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
                  child: Text(
                    'Edit Deadline',
                    style: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogOnWhiteSurface']!, // Change this color to your desired color
                    ),
                  ),
                ),
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
                  context.read<ReminderList>().editReminderItemInList(
                      listName, newItemName, selectedDate, oldItem);
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

  void _showEditReminderListDialog(
      BuildContext context, String oldReminderListName) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Edit your reminder list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
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
                  labelText: 'The name of your reminder list',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
                  ),
                ),
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
                child: Text(
                  'Pick Date',
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnWhiteSurface']!, // Change this color to your desired color
                  ),
                ),
              ),
            ],
          ),
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
                if (newListName.isNotEmpty) {
                  context.read<ReminderList>().editReminder(
                      newListName, selectedDate, oldReminderListName);
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
}
