import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/providers/milestone_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MilestoneExpandable extends StatelessWidget {
  final String milestoneName;
  final Map subgoals;

  const MilestoneExpandable({
    Key? key, 
    required this.milestoneName,
    required this.subgoals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => _showDeleteMilestoneDialog(context, milestoneName),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Center(child: Text(milestoneName)),
            subtitle:  Center(child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: LinearPercentIndicator(
                          width: 210.0,
                          lineHeight: 14.0,
                          percent: _getMilestoneProgress(subgoals),
                          center: Text(
                            _getMilestoneProgress(subgoals).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12.0),
                          ),
                          trailing: const Icon(Icons.mood),
                          barRadius: const Radius.circular(10),
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                      ),
                    ),
            children: <Widget>[
              Column(
                children: _buildExpandableContent(
                  context,
                  milestoneName,
                  subgoals,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMilestoneProgress(Map subgoals){
    if(subgoals.isEmpty) return 0;
    int len = subgoals.values.length;
    int ticked = 0;
    for(Map subgoal in subgoals.values){
      if(subgoal['subgoalTicked']){
        ticked++;
      }
    }
    return ticked/len;
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, String milestoneName, Map subgoals) {
    
    List<Widget> columnContent = [];

    if (subgoals.isNotEmpty) {
      for (Map content in subgoals.values) {
        columnContent.add(
          ListTile(
            leading: Checkbox(
              value: content['subgoalTicked'],
              onChanged: (bool? val) {
                context
                    .read<Milestone>()
                    .toggleSubgoalCheckbox(milestoneName, content['subgoalName'], content['subgoalTicked']);
              }),
            trailing: IconButton(
                onPressed: () => _showDeleteSubgoalFromMilestoneDialog(context, milestoneName, content['subgoalName']),
                icon: const Icon(Icons.delete)),
            title: Text(content['subgoalName']),
          ),
        );
      }
    }

    columnContent.add(
      ListTile(
        title: IconButton(
            onPressed: () =>
              _showAddSubgoalToMilestoneDialog(context, milestoneName),
            icon: const Icon(Icons.add)),
      ),
    );

    return columnContent;
  }

  void _showAddSubgoalToMilestoneDialog(BuildContext context, String milestoneName) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new subgoal to the milestone'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Subgoal'),
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
                String newSubgoalName = controller.text;
                if (newSubgoalName.isNotEmpty) {
                  context.read<Milestone>().addSubgoalToMilestone(milestoneName, newSubgoalName);
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

  void _showDeleteMilestoneDialog(BuildContext context, String milstoneName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $milestoneName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<Milestone>().deleteMilestone(milstoneName);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSubgoalFromMilestoneDialog(BuildContext context, String milstoneName, String oldSubgoal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $oldSubgoal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<Milestone>().deleteSubgoalFromMilestone(milstoneName, oldSubgoal);
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
