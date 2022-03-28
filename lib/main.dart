import 'package:architectured/map/g_map.dart';
import 'package:architectured/map/pop.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/experimental/sliding_chat.dart';
import 'package:architectured/views/home_view.dart';
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/second':
            return PageTransition(
                child: SecondPage(),
                type: PageTransitionType.leftToRight,
                settings: settings,
                reverseDuration: Duration(milliseconds: 200));
        }
      },
      routes: {
        '/': (context) => SlidingChat(),
        '/auth': (context) => AuthView(),
        '/home': (context) => HomeView()
      },
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(uid == null ? 'ChatMap no user' : 'ChatMap $uid')),
      body: ElevatedButton(
        child: Text('go back to chats'),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/second');
          setState(() {
            uid = result;
          });
        },
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('second')),
      body: ElevatedButton(
        child: Text('bunch of users'),
        onPressed: () {
          Navigator.pop(context, 'john234');
        },
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('third')),
    );
  }
}
