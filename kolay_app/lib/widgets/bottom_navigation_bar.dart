import 'package:flutter/material.dart';
import 'package:kolay_app/providers/bottom_navigation_provider.dart';
import 'package:kolay_app/screens/home.dart';
import 'package:kolay_app/screens/to_dos.dart';
import 'package:kolay_app/screens/meal_plans.dart';
import 'package:kolay_app/screens/shopping_lists.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarController extends StatelessWidget {

  final List<Widget> _children = [
    HomePage(),
    ToDosPage(),
    ShoppingListsPage(),
    MealPlansPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => BottomNavIndex(),
        child:
            Consumer<BottomNavIndex>(builder: (context, bottomNavIndex, child) {
          return Scaffold(
            body: _children[bottomNavIndex.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 31.0,
              selectedItemColor: const Color(0xFF77BBB4),
              unselectedItemColor: const Color(0xFFF7B9CB),
              onTap: (index) {
                bottomNavIndex.currentIndex = index;
              },
              currentIndex: bottomNavIndex.currentIndex,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.done_outline_outlined), label: "To-do's"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart), label: 'Shopping Lists'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.local_dining), label: 'Meal Plans'),
              ],
            ),
          );
        }));
  }
}
