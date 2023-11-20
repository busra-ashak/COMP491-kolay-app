import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/shopping_list_expandable.dart';
import '../widgets/sideabar_menu.dart';
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
      body: Column(
        children: [
          // Use FutureBuilder to asynchronously build the UI based on the result of getAllShoppingLists
          FutureBuilder<List<String>>(
            future: context.watch<ShoppingList>().getAllShoppingLists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Display a loading indicator while the future is being resolved
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!.isEmpty)) {
                return Text('No shopping lists available.');
              } else {
                // Dynamically create ShoppingListExpandable widgets based on available shopping lists
                return Column(
                  children: (snapshot.data ?? []).map((listName) => ShoppingListExpandable(initialShoppingListName: listName)).toList(),
                );
              }
            },
          ),
          // "Add" button to create a new shopping list
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

  // Function to show a dialog for creating a new shopping list
  void _showCreateListDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create a new shopping list'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Shopping list name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newListName = _controller.text;
                if (newListName.isNotEmpty) {
                  context.read<ShoppingList>().createShoppingList(newListName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
