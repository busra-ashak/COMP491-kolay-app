import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/sideabar_menu.dart';
import '../widgets/todo_list_expandable.dart';

class ToDosPage extends StatefulWidget {
  @override
  State<ToDosPage> createState() => _ToDosPageState();
}

class _ToDosPageState extends State<ToDosPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Your Todo Lists', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: ListView(
        children: [
          // Use FutureBuilder to asynchronously build the UI based on the result of getAllTodoLists
          FutureBuilder<Map<String, Map>>(
            future: context.watch<TodoList>().getAllTodoLists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(),)); // Display a loading indicator while the future is being resolved
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!.isEmpty)) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No Todo lists available.')));
              } else {
                // Dynamically create TodoListExpandable widgets based on available shopping lists
                return Column(
                  children: (snapshot.data ?? {}).values.map(
                          (doc) => TodoListExpandable(
                        listName: doc['listName'],
                        creationDatetime: doc['creationDatetime'],
                        listItems: doc['listItems'],
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
          title: const Text('Create a new Todo list'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'The name of your Todo list'),
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
                  context.read<TodoList>().createTodoList(newListName);
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
