import 'package:flutter/material.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:kolay_app/screens/settings.dart';
import 'package:provider/provider.dart';
import '../widgets/shopping_list_expandable.dart';
import '../providers/shopping_list_provider.dart';

class ShoppingListsPage extends StatefulWidget {
  @override
  State<ShoppingListsPage> createState() => ShoppingListsPageState();
}

class ShoppingListsPageState extends State<ShoppingListsPage> {
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
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5E6),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            iconSize: 31.0,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
          backgroundColor: const Color(0xFFF7B9CB),
          centerTitle: true,
          title: const Text('Your Shopping Lists',
              style: TextStyle(
                  color: Color(0xFF4768AD),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              iconSize: 31.0,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            )
          ],
        ),
        body: Consumer<ShoppingList>(builder: (context, viewModel, child) {
          return ListView(
            children: viewModel.shoppingLists.values
                .map((doc) => ShoppingListExpandable(
                      listName: doc['listName'],
                      datetime: doc['datetime'],
                      listItems: doc['listItems'],
                    ))
                .toList(),
          );
        }),
        persistentFooterButtons: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: const Color(0xDDB2F7EF),
              boxShadow: const [
                BoxShadow(color: Color(0xFF77BBB4), spreadRadius: 3),
              ],
            ),
            child: IconButton(
              color: const Color(0xFF77BBB4),
              onPressed: () {
                showCreateListDialog(context);
              },
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      ),
    );
  }

  void showCreateListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new shopping list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'The name of your Shopping List'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text('Pick Date'),
              ),
            ],
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
                  context
                      .read<ShoppingList>()
                      .addShoppingList(newListName, selectedDate);
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
