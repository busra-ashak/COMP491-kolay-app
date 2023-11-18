import 'package:flutter/material.dart';

class TodoList with ChangeNotifier {
  final List<Todo> _todos = [Todo(), Todo(), Todo()];
    //'Call mom', 'Rob a bank', 'Compliment a random person'];

  int get count => _todos.length;
  List<Todo> get todosList => _todos;

  void addItem() {
    _todos.add(Todo());
    notifyListeners();
  }
}

class Todo with ChangeNotifier {
  bool isChecked = false;
  String description = 'New TODO ehe';
  DateTime creationDateTime = DateTime.now();

  void createTodo(String description) {
    this.description = description;
    creationDateTime = DateTime.now();
    notifyListeners();
  }

  void toggleCheckbox() {
    isChecked = !isChecked;
    notifyListeners();
  }

}