import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:kolay_app/screens/settings.dart';
import 'package:kolay_app/widgets/routine_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/milestone_expandable.dart';
import '../providers/milestone_provider.dart';
import '../providers/routine_provider.dart';

enum FrequencyMeasure {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const FrequencyMeasure(this.label);

  final String label;
}

class AmbitionsPage extends StatefulWidget {
  @override
  State<AmbitionsPage> createState() => _AmbitionsPageState();
}

class _AmbitionsPageState extends State<AmbitionsPage> {
  @override
  void initState() {
    super.initState();
    loadAmbitions();
  }

  loadAmbitions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<Routine>().getAllRoutines();
      context.read<Milestone>().getAllMilestones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 31.0,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Your Ambitions',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                iconSize: 31.0,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              )
            ],
            bottom: const TabBar(
              tabs: [
                Tab(
                    icon: Icon(Icons.rocket_launch_outlined),
                    text: "Milestones"),
                Tab(icon: Icon(Icons.published_with_changes), text: "Routines"),
              ],
            ),
          ),
          body: Consumer2<Milestone, Routine>(
              builder: (context, milestoneProvider, routineProvider, child) {
            return (TabBarView(children: [
              ListView(
                children: milestoneProvider.milestones.values
                    .map((doc) => MilestoneExpandable(
                          milestoneName: doc['milestoneName'],
                          subgoals: doc['subgoals'],
                        ))
                    .toList(),
              ),
              ListView(
                children: routineProvider.routines.values
                    .map((doc) => RoutineWidget(
                          routineName: doc['routineName'],
                          frequency: doc['frequency'],
                          frequencyMeasure: doc['frequencyMeasure'],
                        ))
                    .toList(),
              ),
            ]));
          }),
          floatingActionButton: IconButton(
            onPressed: () {
              _showCreateDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ));
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new ambition'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _showCreateMilestoneDialog(context);
              },
              child: const Text('Milestone'),
            ),
            TextButton(
              onPressed: () {
                _showCreateRoutineDialog(context);
              },
              child: const Text('Routine'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateMilestoneDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new milestone'),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(labelText: 'The name of your milestone'),
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
                String newMilestoneName = controller.text;
                if (newMilestoneName.isNotEmpty) {
                  context.read<Milestone>().createMilestone(newMilestoneName);
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

  void _showCreateRoutineDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dropdownController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new routine'),
          content: Column(children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'The name of your routine'),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: DropdownMenu<FrequencyMeasure>(
                  initialSelection: FrequencyMeasure.daily,
                  controller: dropdownController,
                  requestFocusOnTap: false,
                  label: const Text('Frequency Measure'),
                  dropdownMenuEntries: FrequencyMeasure.values
                      .map<DropdownMenuEntry<FrequencyMeasure>>(
                          (FrequencyMeasure measure) {
                    return DropdownMenuEntry<FrequencyMeasure>(
                      value: measure,
                      label: measure.label,
                    );
                  }).toList(),
                )),
            TextField(
              controller: frequencyController,
              decoration: const InputDecoration(labelText: 'How frequent?'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
                String newRoutineName = nameController.text;
                String frequencyMeasure = dropdownController.text;
                int frequency = int.parse(frequencyController.text);
                if (newRoutineName.isNotEmpty) {
                  context.read<Routine>().createRoutine(
                      newRoutineName, frequencyMeasure, frequency);
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
