import 'package:flutter/material.dart';

class BarCode with ChangeNotifier {
  String _barCode;

  BarCode(this._barCode);

  getBarCode() => _barCode;
  setBarCode(String barCode) => _barCode = barCode;


}
