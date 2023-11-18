import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';

class ShoppingListExpandable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children:<Widget>[
        IconButton(
          alignment: Alignment.topLeft,
          onPressed: () {}, 
          icon: const Icon(Icons.delete)
        ),
        Expanded(
          child:ExpansionTile(
            title: const Text('Shopping list name placeholder'),
            subtitle: const Text('Creation date placeholder'),
            children: <Widget>[
              Column(
                children: _buildExpandableContent(context, context.watch<ShoppingList>().shoppingList),
              ),
            ],
          )
        ),
      ]
    );
  }

  _buildExpandableContent(BuildContext context, List<String> shopList) {
    List<Widget> columnContent = [];

    for (String content in shopList) {
      columnContent.add(
        ListTile(
          trailing: IconButton(
            onPressed: () => context.read<ShoppingList>().deleteItemFromShoppingList(content),
            icon: const Icon(Icons.delete)),
          title: Text(content),
        )
      );
    }

    columnContent.add(
      ListTile(
        title: IconButton(
          onPressed: () => context.read<ShoppingList>().addItemToShoppingList("newItem"),
          icon: const Icon(Icons.add)
        )
      )
    );

    return columnContent;
  }
}