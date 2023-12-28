import 'package:flutter/material.dart';

class SlidableState extends ChangeNotifier {
  bool _isSlidableEnabled = true;

  bool get isSlidableEnabled => _isSlidableEnabled;

  set isSlidableEnabled(bool value) {
    _isSlidableEnabled = value;
    notifyListeners();
  }
}