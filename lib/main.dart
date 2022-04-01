import 'package:architectured/experimental/sand_box.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/friends.dart';
import 'package:architectured/views/chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

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
        // '/': (context) => debug(), // TODO: make a debugWidget
        '/auth': (context) => AuthView(),
        '/chat': (context) => Chat(),
        '/sandbox': (context) => SandBox()
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/friends':
            return PageTransition(
                child: Friends(),
                type: PageTransitionType.leftToRightWithFade,
                settings: settings,
                reverseDuration: Duration(milliseconds: 200));
        }
      },
    );
  }
}
