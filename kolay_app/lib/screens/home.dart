import 'package:flutter/material.dart';
import 'package:kolay_app/providers/reminder_provider.dart';
import 'package:kolay_app/providers/routine_provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:kolay_app/providers/tab_index_provider.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/screens/meal_plans.dart';
import 'package:kolay_app/screens/shopping_lists.dart';
import '../providers/bottom_navigation_provider.dart';
import 'package:kolay_app/screens/profile.dart';
import 'package:kolay_app/screens/to_dos.dart';
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
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor:
            themeBody[themeProvider.themeDataName]!['screenBackground'],
        appBar: AppBar(
          title: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "Today's Plan",
                style: TextStyle(fontSize: 28),
              )),
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
        body: Consumer4<ReminderList, Routine, ShoppingList, MealPlan>(builder:
            (context, reminderProvider, routineProvider, shoppingProvider,
                mealProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildListWithTitle(
                  'Reminders',
                  reminderProvider.reminderTasksHome,
                  themeBody[themeProvider.themeDataName]),
              _buildListWithTitle(
                  'Routines',
                  routineProvider.routinesHome.values.toList(),
                  themeBody[themeProvider.themeDataName]),
              _buildListWithTitle(
                  'Shopping Lists',
                  shoppingProvider.shoppingListsHome,
                  themeBody[themeProvider.themeDataName]),
              _buildListWithTitle('Meal Plans', mealProvider.mealPlansHome,
                  themeBody[themeProvider.themeDataName]),
            ],
          );
        }),
      );
    });
  }

  Widget _buildListWithTitle(String title, List items, var themeObject) {
    return Consumer2<BottomNavIndex, TabIndexProvider>(
        builder: (context, bottomNavIndex, tabIndexProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                color: themeObject['homeTitles'],
                fontSize: 20,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                color: themeObject['homeEmptyCard'],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    "Tap to add ${title.toLowerCase()} for today",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () => showCreateDialog(
                      context, title, bottomNavIndex, tabIndexProvider),
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
                    color: themeObject['homeNonEmptyCard'],
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: switch (title) {
                      'Routines' => ListTile(
                          onTap: () {
                            tabIndexProvider.tabIndex = 1;
                            bottomNavIndex.currentIndex = 1;
                          },
                          title: Text(
                            items[index]['routineName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "${items[index]['frequency'] - items[index]['currentProgress']} out of ${items[index]['frequency']} left for the ${items[index]['frequencyMeasure']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      'Reminders' => ListTile(
                          onTap: () {
                            tabIndexProvider.tabIndex = 2;
                            bottomNavIndex.currentIndex = 1;
                          },
                          title: Text(
                            items[index][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            items[index][1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      'Shopping Lists' => ListTile(
                          onTap: () {
                            bottomNavIndex.currentIndex = 2;
                          },
                          title: Text(
                            items[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      _ => ListTile(
                          onTap: () {
                            bottomNavIndex.currentIndex = 3;
                          },
                          title: Text(
                            items[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    });
              },
            ),
        ],
      );
    });
  }

  void showCreateDialog(BuildContext context, String item,
      BottomNavIndex bottomNavIndex, TabIndexProvider tabIndexProvider) {
    ToDosPageState todos = ToDosPageState();
    MealPlansPageState mealPlans = MealPlansPageState();
    ShoppingListsPageState shoppingLists = ShoppingListsPageState();

    switch (item) {
      case 'Routines':
        tabIndexProvider.tabIndex = 1;
        bottomNavIndex.currentIndex = 1;
        todos.showCreateDialogTodosPage(context, 1);
        break;
      case 'Reminders':
        tabIndexProvider.tabIndex = 2;
        bottomNavIndex.currentIndex = 1;
        todos.showCreateDialogTodosPage(context, 2);
        break;
      case 'Shopping Lists':
        bottomNavIndex.currentIndex = 2;
        shoppingLists.showCreateListDialog(context);
        break;
      default:
        bottomNavIndex.currentIndex = 3;
        mealPlans.showCreateMealPlanDialog(context);
        break;
    }
  }
}
