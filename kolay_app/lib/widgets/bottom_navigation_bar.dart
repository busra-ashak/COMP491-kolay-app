import 'package:flutter/material.dart';
import 'package:kolay_app/screens/ambitions.dart';
import 'package:kolay_app/screens/home.dart';
import 'package:kolay_app/screens/meal_plans.dart';
import 'package:kolay_app/screens/shopping_lists.dart';
import 'package:kolay_app/screens/to_dos.dart';

class BottomNavigationBarController extends StatefulWidget {
  const BottomNavigationBarController({super.key});

  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  int _currentIndex = 2; // index of HomePage()

  final List<Widget> _children = [
    ToDosPage(),
    AmbitionsPage(),
    HomePage(),
    ShoppingListsPage(),
    MealPlansPage()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          iconSize: 31.0,
          selectedItemColor: const Color(0xFF77BBB4),
          unselectedItemColor: const Color(0xFFF7B9CB),
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.done_outline_outlined), label: 'To-do'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ambitions'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_dining), label: 'Meal Plans')
          ],
        ),
      ),
    );
  }
}
