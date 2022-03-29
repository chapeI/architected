import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/experimental/friends_screen.dart';
import 'package:architectured/views/experimental/sliding_chat.dart';
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
        '/chat': (context) => SlidingChat(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/friends':
            return PageTransition(
                child: FriendsScreen(),
                type: PageTransitionType.leftToRightWithFade,
                settings: settings,
                reverseDuration: Duration(milliseconds: 200));
        }
      },
    );
  }
}
