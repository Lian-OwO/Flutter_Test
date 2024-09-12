import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PageProvider with ChangeNotifier {
  bool _safeArea = true;
  bool _showNavBar = true;
  Color _backgroundColor = Colors.white;

  bool get safeArea => _safeArea;
  bool get showNavBar => _showNavBar;
  Color get backgroundColor => _backgroundColor;

  void setSafeArea(bool value) {
    _safeArea = value;
    notifyListeners();
  }

  void setShowNavBar(bool value) {
    _showNavBar = value;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }
}
