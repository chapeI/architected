// ignore_for_file: prefer_const_constructors

import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  Function toggleAuthView;
  SignUpView({required this.toggleAuthView});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    nameController.text = 'tester';
    emailController.text = 'tester@test.com';
    passwordController.text = '1234567';

    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'name is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'name'),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'email is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'email'),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'password'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await getIt.get<UserController>().register(
                          emailController.text,
                          passwordController.text,
                          nameController.text);
                      Navigator.pushNamed(context, '/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('error: $e')));
                      print('error: $e');
                    }
                  }
                },
                child: Text('Sign Up')),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  widget.toggleAuthView();
                },
                child: Text('Go to Sign In'))
          ]),
        ),
      ),
    );
  }
}
