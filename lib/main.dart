import 'package:architectured/locator.dart';
import 'package:architectured/views/home_view.dart';
import 'package:architectured/views/login_view.dart';
import 'package:architectured/views/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        HomeView.route: (context) => HomeView(),
        ProfileView.route: (context) => ProfileView(),
        LoginView.route: (context) => LoginView()
      },
      initialRoute: LoginView.route,
      // home: Scaffold(
      //     floatingActionButton: FloatingActionButton(
      //         child: Text('test'),
      //         onPressed: () {
      //           _firestore.collection('test').add({'works': true});
      //         }))
    );
  }
}
