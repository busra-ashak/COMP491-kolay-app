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
  void initState() {
    super.initState();
    loadTodoLists();
  }

  loadTodoLists() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<TodoList>().getAllTodoLists();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Your Todo Lists', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Consumer<TodoList>(
          builder: (context, viewModel, child) {
            return ListView(
              children: viewModel.todoLists.values.map(
                    (doc) => TodoListExpandable(
                      listName: doc['listName'],
                      creationDatetime: doc['creationDatetime'],
                      listItems: doc['listItems'],
                      )).toList(),
            );
          }
      ),
      floatingActionButton: IconButton(
            onPressed: () {
              _showCreateListDialog(context);
            },
            icon: const Icon(Icons.add),
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
