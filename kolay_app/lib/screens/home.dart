import 'package:flutter/material.dart';
import 'package:kolay_app/providers/reminder_provider.dart';
import 'package:kolay_app/providers/routine_provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:kolay_app/screens/settings.dart';
import 'package:provider/provider.dart';

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
      context.read<ReminderList>().getIncompleteToDoTasksForHomeScreen();
      context.read<ShoppingList>().getShoppingListsForHomeScreen();
      context.read<MealPlan>().getMealPlansForHomeScreen();
      context.read<Routine>().getRoutinesForHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text("Today's Plan",
            style: TextStyle(
                color: Color(0xFF77BBB4),
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
      body: Consumer4<ReminderList, Routine, ShoppingList, MealPlan>(builder:
          (context, reminderProvider, routineProvider, shoppingProvider, mealProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _buildListWithTitle(
                'Reminders', reminderProvider.reminderTasksHome),
            _buildListWithTitle('Routines', routineProvider.routinesHome),
            _buildListWithTitle(
                'Shopping Lists', shoppingProvider.shoppingListsHome),
            _buildListWithTitle('Meal Plans', mealProvider.mealPlansHome),
          ],
        );
      }),
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
              color: Color(0xFF8B85C1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              color: Colors.teal[200],
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  "You have no ${title.toLowerCase()} planned for today :)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        if (items.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                color: Colors.teal[200],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  title: Text(
                    items[index],
                    style: const TextStyle(
                      color: Colors.white,
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
