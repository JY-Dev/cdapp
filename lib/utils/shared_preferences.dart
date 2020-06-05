import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String _language = "language";
  static final String _ads = "ads";
  static final String _theme= "theme";

  static Future<String> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_language) ?? null;
  }

  static Future<bool> setLanguage(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_language, value);
  }


  static Future<bool> isDarkTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_theme) ?? false;
  }

  static Future<bool> setDarkTheme(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_theme, value);
  }

  static Future<int> incrementCounter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt(_ads) ?? 1;
    prefs.setInt(_ads, counter + 1);
    return counter + 1;
  }
}
