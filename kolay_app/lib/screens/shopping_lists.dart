import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/screens/profile.dart';
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
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(
            color: Colors.transparent,
          ),
        ),
        child: Scaffold(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['screenBackground'],
          appBar: AppBar(
            title: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Your Shopping Lists")),
            actions: <Widget>[
              IconButton(
                padding: const EdgeInsets.only(right: 8),
                icon: const Icon(Icons.person),
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
                color:
                    themeBody[themeProvider.themeDataName]!['floatingButton'],
                boxShadow: [
                  BoxShadow(
                      color: themeBody[themeProvider.themeDataName]![
                          'floatingButtonOutline'] as Color,
                      spreadRadius: 3),
                ],
              ),
              child: IconButton(
                color: themeBody[themeProvider.themeDataName]![
                    'floatingButtonOutline'],
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
    });
  }

  void showCreateListDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Create a new shopping list',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                ),
                decoration: InputDecoration(
                  labelText: 'The name of your Shopping List',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final ThemeProvider themeProvider = ThemeProvider();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                                surface: themeBody[themeProvider
                                    .themeDataName]!['dialogSurface']!,
                                primary: themeBody[themeProvider
                                    .themeDataName]!['dialogPrimary']!,
                                onPrimary: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!,
                                onSurface: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!),
                          ),
                          child: child!);
                    },
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text(
                  'Pick Date',
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnWhiteSurface']!, // Change this color to your desired color
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
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
              child: Text(
                'Create',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
