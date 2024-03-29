import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/tab_index_provider.dart';
import '../widgets/routine_widget.dart';
import '../widgets/reminder_list_expandable.dart';
import '../widgets/todo_list_expandable.dart';

enum FrequencyMeasure {
  daily('day'),
  weekly('week');

  const FrequencyMeasure(this.label);

  final String label;
}

class ToDosPage extends StatefulWidget {
  @override
  State<ToDosPage> createState() => ToDosPageState();
}

class ToDosPageState extends State<ToDosPage> {
  @override
  void initState() {
    super.initState();
    loadAmbitions();
  }

  loadAmbitions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<Routine>().getAllRoutines();
      context.read<TodoList>().getAllTodoLists();
      context.read<ReminderList>().getAllReminderLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(
            color: Colors.transparent,
          ),
        ),
        child: Consumer2<TabIndexProvider, ThemeProvider>(
            builder: (context, tabIndexProvider, themeProvider, child) {
          return DefaultTabController(
              initialIndex: tabIndexProvider.tabIndex,
              length: 3,
              child: Scaffold(
                backgroundColor:
                    themeBody[themeProvider.themeDataName]!['screenBackground'],
                appBar: AppBar(
                    title: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text("Your To-Do's")),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.person),
                        iconSize: 31.0,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()));
                        },
                      )
                    ],
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: TabBar(
                          onTap: (index) {
                            tabIndexProvider.tabIndex = index;
                          },
                          labelColor: themeBody[themeProvider.themeDataName]![
                              'tabColorSelected'],
                          unselectedLabelColor: themeBody[themeProvider
                              .themeDataName]!['tabColorUnselected'],
                          indicatorColor: themeBody[
                              themeProvider.themeDataName]!['tabColorSelected'],
                          tabs: [
                            Tab(
                                icon: Icon(
                                  Icons.checklist_outlined,
                                  color: tabIndexProvider.tabIndex == 0
                                      ? themeBody[themeProvider.themeDataName]![
                                          'tabColorSelected']
                                      : themeBody[themeProvider.themeDataName]![
                                          'tabColorUnselected'],
                                ),
                                text: "Tasks"),
                            Tab(
                                icon: Icon(
                                  Icons.published_with_changes,
                                  color: tabIndexProvider.tabIndex == 1
                                      ? themeBody[themeProvider.themeDataName]![
                                          'tabColorSelected']
                                      : themeBody[themeProvider.themeDataName]![
                                          'tabColorUnselected'],
                                ),
                                text: "Routines"),
                            Tab(
                                icon: Icon(
                                  Icons.access_alarms_outlined,
                                  color: tabIndexProvider.tabIndex == 2
                                      ? themeBody[themeProvider.themeDataName]![
                                          'tabColorSelected']
                                      : themeBody[themeProvider.themeDataName]![
                                          'tabColorUnselected'],
                                ),
                                text: "Reminders"),
                          ],
                        ))),
                body: Consumer3<TodoList, Routine, ReminderList>(builder:
                    (context, todoProvider, routineProvider, reminderProvider,
                        child) {
                  return (TabBarView(children: [
                    ListView(
                      children: todoProvider.todoLists.values
                          .map((doc) => TodoListExpandable(
                                listName: doc['listName'],
                                listItems: doc['listItems'],
                                showProgressBar: doc['showProgressBar'],
                              ))
                          .toList(),
                    ),
                    ListView(
                      children: routineProvider.routines.values
                          .map((doc) => RoutineWidget(
                                routineName: doc['routineName'],
                                frequency: doc['frequency'],
                                frequencyMeasure: doc['frequencyMeasure'],
                                currentProgress: doc['currentProgress'],
                              ))
                          .toList(),
                    ),
                    ListView(
                      children: reminderProvider.reminderLists.values
                          .map((doc) => ReminderListExpandable(
                                listName: doc['listName'],
                                dueDatetime: doc['dueDatetime'],
                                listItems: doc['listItems'],
                              ))
                          .toList(),
                    ),
                  ]));
                }),
                persistentFooterButtons: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: themeBody[themeProvider.themeDataName]![
                          'floatingButton'],
                      boxShadow: [
                        BoxShadow(
                            color: themeBody[themeProvider.themeDataName]![
                                'floatingButtonOutline'] as Color,
                            spreadRadius: 3),
                      ],
                    ),
                    child: Consumer<TabIndexProvider>(
                        builder: (context, tabIndexProvider, child) {
                      return IconButton(
                        color: themeBody[themeProvider.themeDataName]![
                            'floatingButtonOutline'],
                        onPressed: () {
                          showCreateDialogTodosPage(
                              context, tabIndexProvider.tabIndex);
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                ],
                persistentFooterAlignment: AlignmentDirectional.bottomCenter,
              ));
        }));
  }

  void showCreateDialogTodosPage(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        _showCreateTodoListDialog(context);
        break;
      case 1:
        _showCreateRoutineDialog(context);
        break;
      case 2:
        _showCreateReminderListDialog(context);
        break;
    }
  }

  void _showCreateTodoListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Create a new to-do list',
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
                  labelText: 'The name of your to-do list',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
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
                  context.read<TodoList>().createTodoList(newListName);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Create',
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

  void _showCreateRoutineDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dropdownController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Create a new routine',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: SizedBox(
            height: 150,
            child: Column(children: [
              Row(
                children: [
                  Text(
                    "I will ",
                    style: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!, // Change this color to your desired color
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    style: TextStyle(
                        color: themeBody[themeProvider.themeDataName]![
                            'dialogOnSurface']!),
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '      the name of your routine',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: themeBody[themeProvider.themeDataName]![
                              'dialogOnSurface']!),
                    ),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    style: TextStyle(
                        color: themeBody[themeProvider.themeDataName]![
                            'dialogOnSurface']!),
                    controller: frequencyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  )),
                  Text(
                    " time(s) a ",
                    style: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogPrimary']!, // Change this color to your desired color
                    ),
                  ),
                  DropdownMenu<FrequencyMeasure>(
                    width: 100,
                    initialSelection: FrequencyMeasure.daily,
                    controller: dropdownController,
                    requestFocusOnTap: false,
                    textStyle: TextStyle(
                      color: themeBody[themeProvider.themeDataName]![
                          'dialogOnSurface']!,
                    ),
                    dropdownMenuEntries: FrequencyMeasure.values
                        .map<DropdownMenuEntry<FrequencyMeasure>>(
                            (FrequencyMeasure measure) {
                      return DropdownMenuEntry<FrequencyMeasure>(
                        value: measure,
                        label: measure.label,
                      );
                    }).toList(),
                  ),
                ],
              )
            ]),
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
                String newRoutineName = nameController.text;
                String frequencyMeasure = dropdownController.text;
                int frequency = int.parse(frequencyController.text);
                if (newRoutineName.isNotEmpty) {
                  context.read<Routine>().createRoutine(
                      newRoutineName, frequencyMeasure, frequency);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Create',
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

  void _showCreateReminderListDialog(BuildContext context) {
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
            'Create a new reminder list',
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
                  context
                      .read<ReminderList>()
                      .createReminderList(newListName, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Create',
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
}
