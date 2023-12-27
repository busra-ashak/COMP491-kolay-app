import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RoutineWidget extends StatelessWidget {
  final String routineName;
  final String frequencyMeasure;
  final int frequency;

  final Map<String, String> _frequencyMapping = {
    "Daily": "day",
    "Weekly": "week",
    "Monthly": "month",
  };

  RoutineWidget(
      {Key? key,
      required this.routineName,
      required this.frequencyMeasure,
      required this.frequency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: const Color(0xFF8B85C1),
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
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    shape: const Border(),
                    title:
                        Text(routineName, style: const TextStyle(fontSize: 20)),
                    subtitle: Text(
                        '$frequency time(s) a ${_frequencyMapping[frequencyMeasure]}',
                        style: const TextStyle(fontSize: 12))))));
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
