import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AppData extends ChangeNotifier {
  String _accessToken = '';
  String get accessToken => _accessToken;
  set accessToken(String value) {
    _accessToken = value;
    notifyListeners();
  }

  String _username = '';
  String get username => _username;
  set username(String value) {
    _username = value;
    notifyListeners();
  }
  
  void logout(){
    _accessToken = '';
    _username = '';
    notifyListeners();
  }
}
