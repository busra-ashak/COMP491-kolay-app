import 'package:flutter/material.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/sideabar_menu.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Your Daily Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: TodaysPlan(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality to open a dialog or navigate to a new screen for adding tasks.
        },
        child: Icon(Icons.gps_fixed_rounded),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class TodaysPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: context.read<TodoList>().getIncompleteTasksForHomeScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No incomplete tasks for today!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
          List<String> incompleteTasks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: incompleteTasks.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                color: Colors.teal[200],
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    incompleteTasks[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // You can add additional elements like icons here.
                  // Example: trailing: Icon(Icons.check),
                ),
              );
            },
          );
        }
      },
    );
  }
}