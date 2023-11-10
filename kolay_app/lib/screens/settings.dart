import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';

class SettingsPage extends StatefulWidget {
 @override
 State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Settings', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
    );
  }
}