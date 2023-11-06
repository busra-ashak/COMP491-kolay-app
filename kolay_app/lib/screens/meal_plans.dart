import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';

class MealPlansPage extends StatefulWidget {
 @override
 State<MealPlansPage> createState() => _MealPlansPageState();
}
class _MealPlansPageState extends State<MealPlansPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Your Meal Plans', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
    );
  }
}