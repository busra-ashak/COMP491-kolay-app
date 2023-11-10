import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';

class ToDosPage extends StatefulWidget {
 @override
 State<ToDosPage> createState() => _ToDosPageState();
}
class _ToDosPageState extends State<ToDosPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Your To Dos', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
    );
  }
}