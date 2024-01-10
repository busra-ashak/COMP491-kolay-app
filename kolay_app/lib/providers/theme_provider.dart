import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themeBody = {
  'light': {
    'expandable': Color(0xFF8B85C1),
    'expandableButton': Color(0xFF6C64B3),
    'tick': Color(0xFF77BBB4),
    'screenBackground': Color(0xFFFAF5E6),
    'tabColorSelected': Color(0xFF4C4385),
    'tabColorUnselected': Color(0xFFD1738F),
    'floatingButton': Color(0xDDB2F7EF),
    'floatingButtonOutline': Color(0xFF77BBB4),
    'routineSubtitle': Color(0xFFF8C5D4),
    'todoPercentage': Color(0xFF77BBB4),
    'homeTitles': Color(0xff8b85c1),
    'homeEmptyCard': Color(0xFFF7B9CB),
    'homeNonEmptyCard': Color(0xFF77BBB4),
  },
  'dark': {
    'expandable': Color(0xFF944D3B),
    'expandableButton': Color(0xFF743D2F),
    'tick': Color(0xFF2a9d8f),
    'screenBackground': Color(0xFF264653),
    'tabColorSelected': Color(0xFFECC35C),
    'tabColorUnselected': Color(0xFFA06A3D),
    'floatingButton': Color(0xFF2a9d8f),
    'floatingButtonOutline': Color(0xFF14242B),
    'routineSubtitle': Color.fromARGB(255, 245, 216, 141),
    'todoPercentage': Color(0xFF2a9d8f),
    'homeTitles': Color(0xFFE9C46A),
    'homeEmptyCard': Color(0xFFF4A261),
    'homeNonEmptyCard': Color(0xFF2A9D8F),
  }
};

const themeIcon = {
  'light': Icons.nightlight,
  'dark': Icons.sunny,
};

class ThemeProvider with ChangeNotifier {
  final ThemeData lightTheme = ThemeData(
      canvasColor: const Color(0xFFF1CFD9),
      useMaterial3: true,
      fontFamily: 'Nunito',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF4C4385),
        unselectedItemColor: Color(0xFFD1738F),
      ),
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF1CFD9),
          iconTheme: IconThemeData(color: Color(0xFF4C4385)),
          titleTextStyle: TextStyle(
              color: Color(0xFF4C4385),
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.bold,
              fontSize: 24)));

  final ThemeData darkTheme = ThemeData(
      canvasColor: const Color(0xFF14242B),
      useMaterial3: true,
      fontFamily: 'Nunito',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFFECC35C),
        unselectedItemColor: Color(0xFFA06A3D),
      ),
      appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Color(0xFFECC35C)),
          backgroundColor: Color(0xFF14242B),
          titleTextStyle: TextStyle(
              color: Color(0xFFECC35C),
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.bold,
              fontSize: 24)));

  late ThemeData _themeData;
  late String _themeDataName;
  final String _themeKey = 'theme';

  ThemeProvider() {
    _themeData = darkTheme;
    _themeDataName = 'light';
    _loadTheme();
  }

  ThemeData get themeData => _themeData;
  String get themeDataName => _themeDataName;

  void toggleTheme() {
    _themeData = (_themeDataName == 'light') ? darkTheme : lightTheme;
    _themeDataName = (_themeDataName == 'light') ? 'dark' : 'light';
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeData = isDarkMode ? darkTheme : lightTheme;
    _themeDataName = isDarkMode ? 'dark' : 'light';
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, _themeData == darkTheme);
  }
}
