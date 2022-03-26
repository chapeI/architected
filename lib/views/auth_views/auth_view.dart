import 'package:architectured/views/auth_views/login_view.dart';
import 'package:architectured/views/auth_views/signup_view.dart';
import 'package:flutter/material.dart';

class AuthView extends StatefulWidget {
  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool loginInView = false;

  void toggleAuthView() {
    setState(() {
      loginInView = !loginInView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loginInView
        ? LoginView(
            toggleAuthView: toggleAuthView,
          )
        : SignUpView(
            toggleAuthView: toggleAuthView,
          );
  }
}
