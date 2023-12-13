import 'package:flutter/material.dart';

enum SlideActionType {
  primary,
  secondary,
}

class SlidableState extends ChangeNotifier {
  bool isSlidableEnabled = true;

  void setSlidableEnabled(bool value) {
    isSlidableEnabled = value;
    notifyListeners();
  }
}