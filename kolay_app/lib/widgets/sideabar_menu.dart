import 'package:flutter/material.dart';
import '../screens/meal_plans.dart';
import '../screens/home.dart';

class SideBarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('ZartZurt08'),
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
            title: const Text('Shopping List'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => MealPlansPage())),
          ),
          ListTile(
            leading: const Icon(Icons.man_rounded),
            title: const Text('Personal Goals'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => MealPlansPage())),
          ),
          const ListTile(
            leading: Icon(Icons.check_box),
            title: Text('To dos'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => MealPlansPage())),
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
 builder: (context) => MealPlansPage())),
          ),
        ],
      ),
    );
  }
}