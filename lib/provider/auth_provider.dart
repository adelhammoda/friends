import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/utils/validator.dart';

class AuthProvider with ChangeNotifier, Validator {
  final AuthenticationApi _server = AuthenticationApi();
  bool showError = false;
  bool isLoading = false;
  bool rememberMe = false;
  String errorMessage = '';
  String userType = '';

  void changeUserType(String selectedUserType) {
    if (userType == selectedUserType) {
      userType = '';
    } else {
      userType = selectedUserType;
    }
  }

  AuthProvider();

  void changeRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }


  void switchLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  Stream<User?> get isAuth => _server.gitUserState;
}
