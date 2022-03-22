import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/home_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthView(),
        '/home': (context) => HomeView()
      },
    );
  }
}
