import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';

class ShoppingListExpandable extends StatelessWidget {
  final String initialShoppingListName;

  // Constructor to accept the initial shopping list name
  const ShoppingListExpandable({Key? key, required this.initialShoppingListName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () => context.read<ShoppingList>().getAllShoppingLists(),
          icon: const Icon(Icons.delete),
        ),
        Expanded(
          child: ExpansionTile(
            title: Text(initialShoppingListName), // Use the initial shopping list name here
            subtitle: const Text('Creation date placeholder'),
            children: <Widget>[
              Column(
                children: _buildExpandableContent(
                  context,
                  context.watch<ShoppingList>().shoppingList,
                  initialShoppingListName,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandableContent(
      BuildContext context, List<String> shopList, String shopListName) {
    List<Widget> columnContent = [];

    for (String content in shopList) {
      columnContent.add(
        ListTile(
          trailing: IconButton(
              onPressed: () => context
                  .read<ShoppingList>()
                  .deleteItemFromShoppingList(shopListName, content, false),
              icon: const Icon(Icons.delete)),
          title: Text(content),
        ),
      );
    }

    columnContent.add(
      ListTile(
        title: IconButton(
            onPressed: () =>
                context.read<ShoppingList>().addItemToShoppingList(shopListName, "newItem4"),
            icon: const Icon(Icons.add)),
      ),
    );

    return columnContent;
  }
}
