import 'package:flutter/material.dart';
import '../widgets/shopping_list_expandable.dart';
import '../widgets/sideabar_menu.dart';
import 'package:provider/provider.dart';
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Your Shopping Lists', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
      body: Column(
        children: [
          ShoppingListExpandable(), 
          ShoppingListExpandable(),
          IconButton(
            onPressed: () => context.read<ShoppingList>().createShoppingList(),
            icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}