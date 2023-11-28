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
  void initState() {
    super.initState();
    loadShoppingLists();
  }

  loadShoppingLists() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ShoppingList>().readShoppingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Your Shopping Lists', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
      body:Consumer<ShoppingList>(
          builder: (context, viewModel, child) {
            return ListView(
              children: viewModel.shoppingLists.values.map(
                    (doc) => ShoppingListExpandable(
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
                  context.read<ShoppingList>().addShoppingList(newListName);
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