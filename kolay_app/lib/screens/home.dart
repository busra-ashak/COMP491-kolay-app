import 'package:flutter/material.dart';
import '../widgets/sideabar_menu.dart';

class HomePage extends StatefulWidget {
 @override
 State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: SideBarMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Here is your plan for today', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),   
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: TodaysPlan(),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TodaysPlan extends StatelessWidget {
  final _todaysPlanItems = ["Call your mom <3", "Do 10 push-ups!", "Read 20 pages :)", "Go on a walk ^^"];
  final List<int> _colorCodes = <int>[600, 500, 400, 300];
  

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: _todaysPlanItems.length,
    itemBuilder: (BuildContext context, int index) {
      return Container(
        height: 50,
        color: Colors.teal[_colorCodes[index]],
        child: Center(child: Text(_todaysPlanItems[index])),
      );
    }
  );
  }
}