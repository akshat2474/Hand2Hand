import 'package:flutter/material.dart';


class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  double _longitude = 0.0;
  double get longitude => _longitude;
  set longitude(double value) {
    _longitude = value;
  }

  double _latitude = 0.0;
  double get latitude => _latitude;
  set latitude(double value) {
    _latitude = value;
  }

  String _userID = '';
  String get userID => _userID;
  set userID(String value) {
    _userID = value;
  }

  String _question = '** Your Question Will Appear Here **';
  String get question => _question;
  set question(String value) {
    _question = value;
  }

  String _page = '';
  String get page => _page;
  set page(String value) {
    _page = value;
  }
}
