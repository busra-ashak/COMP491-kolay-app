import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../screens/to_dos.dart';

class RoutineWidget extends StatelessWidget {
  final String routineName;
  final String frequencyMeasure;
  final int frequency;
  final int currentProgress;

  const RoutineWidget(
      {Key? key,
      required this.routineName,
      required this.frequencyMeasure,
      required this.frequency,
      required this.currentProgress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Card(
          color: themeBody[themeProvider.themeDataName]!['expandable'],
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ClipRect(
              child: Slidable(
                  closeOnScroll: false,
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showEditRoutineDialog(context, routineName);
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
                          _showDeleteRoutineDialog(context, routineName);
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
                  child: Column(children: [
                    ListTile(
                      trailing: SizedBox(
                          width: 96,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    context.read<Routine>().undoOneRoutine(
                                        routineName, currentProgress);
                                  },
                                  icon: const Icon(Icons.remove_circle)),
                              IconButton(
                                  onPressed: () {
                                    context.read<Routine>().completeOneRoutine(
                                        routineName,
                                        frequency,
                                        currentProgress);
                                  },
                                  icon: const Icon(Icons.check_circle))
                            ],
                          )),
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      shape: const Border(),
                      title: Text(routineName,
                          style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                        'Completed $currentProgress out of $frequency time${frequency > 1 ? 's' : ''} for the $frequencyMeasure',
                        style: TextStyle(
                            color: themeBody[themeProvider.themeDataName]![
                                'routineSubtitle'],
                            fontSize: 12),
                      ),
                    ),
                    LinearPercentIndicator(
                      width: 210.0,
                      lineHeight: 10.0,
                      animation: true,
                      percent: frequency == 0 ? 0 : currentProgress / frequency,
                      barRadius: const Radius.circular(10),
                      backgroundColor: Colors.grey,
                      progressColor: themeBody[themeProvider.themeDataName]![
                          'todoPercentage'],
                    ),
                    const Padding(padding: EdgeInsets.all(10.0)),
                  ]))));
    });
  }

  void _showDeleteRoutineDialog(BuildContext context, String routineName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $routineName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<Routine>().deleteRoutine(routineName);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showEditRoutineDialog(BuildContext context, String routineName) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dropdownController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit your routine'),
          content: SizedBox(
            height: 150,
            child: Column(children: [
              Row(
                children: [
                  const Text("I will "),
                  Expanded(
                      child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        hintText: 'the name of your routine',
                        hintStyle: TextStyle(fontSize: 12)),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: frequencyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  )),
                  const Text(" time(s) a "),
                  DropdownMenu<FrequencyMeasure>(
                    width: 100,
                    initialSelection: FrequencyMeasure.daily,
                    controller: dropdownController,
                    requestFocusOnTap: false,
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newRoutineName = nameController.text;
                String frequencyMeasure = dropdownController.text;
                int frequency = int.parse(frequencyController.text);
                if (newRoutineName.isNotEmpty) {
                  context.read<Routine>().editRoutine(
                      newRoutineName, frequencyMeasure, frequency, routineName);
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
}
