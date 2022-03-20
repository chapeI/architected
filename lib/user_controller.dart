import 'package:architectured/services/auth_service.dart';
import 'package:architectured/user_model.dart';
import 'package:flutter/material.dart';

class UserController {
  late UserModel _currentUser;
  AuthService _authService = AuthService();
  UserController() {}

  Future<UserModel> signIn(email, password) async {
    _currentUser = await _authService.signIn(email, password);
    return _currentUser;
  }
}
