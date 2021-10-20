import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigProvider extends ChangeNotifier {
  final String key = 'cross_axis_count';
  int crossAxisCount = 3;

  ConfigProvider() {
    loadAxisCount();
  }

  Future loadAxisCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    crossAxisCount = prefs.getInt(key) ?? 3;
    notifyListeners();
  }

  Future<void> setCrossAxisCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, count);
    crossAxisCount = count;
    notifyListeners();
  }
}
