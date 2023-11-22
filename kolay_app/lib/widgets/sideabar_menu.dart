import 'package:flutter/material.dart';
import '../screens/meal_plans.dart';
import '../screens/home.dart';
import '../screens/ambitions.dart';
import '../screens/settings.dart';
import '../screens/shopping_lists.dart';
import '../screens/to_dos.dart';

class SideBarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Jane Doe'),
            accountEmail: const Text('example@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.food_bank),
            title: const Text('Meal Plans'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => MealPlansPage())),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Shopping Lists'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => ShoppingListsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.man_rounded),
            title: const Text('Ambitions'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => AmbitionsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.check_box),
            title: const Text('To dos'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => ToDosPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => SettingsPage())),
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}