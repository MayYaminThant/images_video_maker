import 'package:flutter/material.dart';

class VideoStateController with ChangeNotifier {
  void pause() {
    notifyListeners();
  }
}
