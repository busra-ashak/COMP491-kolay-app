import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sideabar_menu.dart';
import '../widgets/milestone_expandable.dart';
import '../providers/milestone_provider.dart';

class AmbitionsPage extends StatefulWidget {
 @override
 State<AmbitionsPage> createState() => _AmbitionsPageState();
}
class _AmbitionsPageState extends State<AmbitionsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Your Ambitions', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
      body: ListView(
        children: [
          FutureBuilder<Map<String, Map>>(
            future: context.watch<Milestone>().getAllMilestones(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(),)); // Display a loading indicator while the future is being resolved
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!.isEmpty)) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No milestones available.')));
              } else {
                return Column(
                  children: (snapshot.data ?? {}).values.map(
                    (doc) => MilestoneExpandable(
                      milestoneName: doc['milestoneName'],
                      subgoals: doc['subgoals'],
                      )).toList(),
                );
              }
            },
          ),
          IconButton(
            onPressed: () {
              _showCreateListDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new milestone'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'The name of your milestone'),
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
}