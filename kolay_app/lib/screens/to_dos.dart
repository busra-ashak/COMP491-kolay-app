import 'package:flutter/material.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/sideabar_menu.dart';

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Your To Dos', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:10), //apply padding to all four sides
              child: Text('${context.watch<TodoList>().count}')
            ),
            const Divider(),
            Expanded(
                child: ListView.separated(
                  itemCount: context.watch<TodoList>().count,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Center(child: Text(context.watch<TodoList>().todosList[index].description)),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                )
            )
        ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('addItem_floatingActionButton'),
        onPressed: () => context.read<TodoList>().addItem(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}