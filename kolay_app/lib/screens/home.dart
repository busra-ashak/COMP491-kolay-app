import 'package:flutter/material.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/sideabar_menu.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<TodoList>().getIncompleteToDoTasksForHomeScreen();
      context.read<ShoppingList>().getShoppingListsForHomeScreen();
      context.read<MealPlan>().getMealPlansForHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Today's Plan", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: Consumer3<TodoList, ShoppingList, MealPlan>(
          builder: (context, todosProvider, shoppingProvider, mealProvider, child) {
            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildListWithTitle('To dos', todosProvider.todoTasksHome),
                _buildListWithTitle('Shopping Lists', shoppingProvider.shoppingListsHome),
                _buildListWithTitle('Meal Plans', mealProvider.mealPlansHome),
              ],
            );
          }
        ),
    );
  }

  Widget _buildListWithTitle(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if(items.isEmpty) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "You have no $title for today :)",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        if(items.isNotEmpty) ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.teal[200],
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  items[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}