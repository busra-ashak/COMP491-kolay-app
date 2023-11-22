import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';


class RoutineWidget extends StatelessWidget {
  final String routineName;
  final String frequencyMeasure;
  final int frequency;

  final Map<String, String> _frequencyMapping = {
    "Daily": "day",
    "Weekly": "week",
    "Monthly": "month",
  };

  RoutineWidget({
    Key? key, 
    required this.routineName,
    required this.frequencyMeasure,
    required this.frequency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => _showDeleteRoutineDialog(context, routineName),
          icon: const Icon(Icons.delete),
        ),
      title: Text(routineName),
      subtitle: Text('$frequency time(s) a ${_frequencyMapping[frequencyMeasure]}')
    );
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
