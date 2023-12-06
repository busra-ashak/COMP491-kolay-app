import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/reminder_list_expandable.dart';
import '../widgets/sideabar_menu.dart';
import '../widgets/todo_list_expandable.dart';

class ToDosPage extends StatefulWidget {
  @override
  State<ToDosPage> createState() => _ToDosPageState();
}

class _ToDosPageState extends State<ToDosPage> {
  @override
  void initState() {
    super.initState();
    loadTodoLists();
  }

  loadTodoLists() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<TodoList>().getAllTodoLists();
      context.read<ReminderList>().getAllReminderLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: SideBarMenu(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Your Tasks',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.checklist_outlined), text: "Todos"),
              Tab(icon: Icon(Icons.access_alarms_outlined), text: "Reminders"),
            ],
          ),
        ),
        body: Consumer2<TodoList, ReminderList>(
            builder: (context, todoProvider, reminderProvider, child) {
          return TabBarView(children: [
            ListView(
              children: todoProvider.todoLists.values
                  .map((doc) => TodoListExpandable(
                        listName: doc['listName'],
                        dueDatetime: doc['dueDatetime'],
                        listItems: doc['listItems'],
                      ))
                  .toList(),
            ),
            ListView(
              children: reminderProvider.reminderLists.values
                  .map((doc) => ReminderListExpandable(
                        listName: doc['listName'],
                        dueDatetime: doc['dueDatetime'],
                        listItems: doc['listItems'],
                        creationDatetime: DateTime.now(),
                      ))
                  .toList(),
            )
          ]);
        }),
        floatingActionButton: IconButton(
          onPressed: () {
            _showCreateDialog(context);
          },
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new task'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _showCreateTodoListDialog(context);
              },
              child: const Text('Todo'),
            ),
            TextButton(
              onPressed: () {
                _showCreateReminderListDialog(context);
              },
              child: const Text('Reminder'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTodoListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new Todo list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'The name of your To Do List'),
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
                child: const Text('Pick Date'),
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
                String newListName = controller.text;
                if (newListName.isNotEmpty) {
                  context
                      .read<TodoList>()
                      .createTodoList(newListName, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateReminderListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new Reminder list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'The name of your Reminder List'),
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
                child: const Text('Pick Date'),
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
                String newListName = controller.text;
                if (newListName.isNotEmpty) {
                  context.read<ReminderList>().createReminderList(newListName, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
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

}
