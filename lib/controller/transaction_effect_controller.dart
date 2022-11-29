import 'package:flutter/material.dart';

class TransactionEffectController with ChangeNotifier {
  int _selectIndex = 0;
  int get selectIndex => _selectIndex;

  set selectIndex(int selectIndexArg) {
    if (selectIndexArg == _selectIndex) return;
    _selectIndex = selectIndexArg;
    notifyListeners();
  }
}
