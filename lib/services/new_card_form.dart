import 'package:flutter/material.dart';

class NewCardFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  String tipo = '';
  String nombre = '';
  int color = 0;
  bool _isLoading = false;
  


  bool get isLoading => _isLoading;
  set isLoading(bool value) {
  _isLoading = value;
  notifyListeners();
  }

}
