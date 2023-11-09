import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController _todoController = TextEditingController();
  List<String> _todoList = [];

  void _addTodo() {
    setState(() {
      String todo = _todoController.text;
      if (todo.isNotEmpty) {
        _todoList.add(todo);
        _todoController.clear();
      }
      DateTime currentTime = DateTime.now();
      FirebaseFirestore.instance.collection("TODOs").add({
        "TODO": todo,
        "time":"${currentTime.day}/${currentTime.month}/${currentTime.year}",
        "username":"KolayAppFirstUser"});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _todoController,
              decoration: InputDecoration(
                hintText: 'Enter your to-do',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: Text('Add To-Do'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}