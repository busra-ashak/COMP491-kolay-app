import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sideabar_menu.dart';
import '../widgets/shopping_list_expandable.dart';
import '../providers/shopping_list_provider.dart';

class ShoppingListsPage extends StatefulWidget {
  @override
  State<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Your Shopping Lists', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: ListView(
        children: [
          FutureBuilder<Map<String, Map>>(
            future: context.watch<ShoppingList>().getAllShoppingLists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(),)); // Display a loading indicator while the future is being resolved
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!.isEmpty)) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No shopping lists available.')));
              } else {
                return Column(
                  children: (snapshot.data ?? {}).values.map(
                    (doc) => ShoppingListExpandable(
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
          title: const Text('Create a new shopping list'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'The name of your shopping list'),
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
                  context.read<ShoppingList>().createShoppingList(newListName);
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
