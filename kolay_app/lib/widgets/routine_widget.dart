import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
                  child: ListTile(
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
                            color: themeBody[themeProvider.themeDataName]!['routineSubtitle'], fontSize: 12),
                      )))));
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
}
