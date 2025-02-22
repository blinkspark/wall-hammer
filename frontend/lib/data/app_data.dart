import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  AppData() {
    init();
  }

  Future<void> init() async {
    accessToken = await _prefs.getString('accessToken') ?? '';
    username = await _prefs.getString('username') ?? '';
    downloadPath = await _prefs.getString('downloadPath') ?? '';
    cachePath = await _prefs.getString('cachePath') ?? '';
  }

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  String _accessToken = '';
  String get accessToken => _accessToken;
  set accessToken(String value) {
    _accessToken = value;
    _prefs.setString('accessToken', value);
    notifyListeners();
  }

  String _username = '';
  String get username => _username;
  set username(String value) {
    _username = value;
    _prefs.setString('username', value);
    notifyListeners();
  }

  void logout() {
    _accessToken = '';
    _username = '';
    _prefs.remove('accessToken');
    _prefs.remove('username');
    notifyListeners();
  }

  String _downloadPath = '';
  String get downloadPath => _downloadPath;
  set downloadPath(String value) {
    _downloadPath = value;
    _prefs.setString('downloadPath', value);
    notifyListeners();
  }

  String _cachePath = '';
  String get cachePath => _cachePath;
  set cachePath(String value) {
    _cachePath = value;
    _prefs.setString('cachePath', value);
    notifyListeners();
  }
}
