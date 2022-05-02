import 'package:architectured/bloc/application_bloc.dart';
import 'package:architectured/experimental/notification_practice.dart';
import 'package:architectured/experimental/sand_box.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/friends.dart';
import 'package:architectured/views/chat.dart';
import 'package:architectured/views/google_maps.dart';
import 'package:architectured/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: StreamProvider<String?>.value(
          value: Auth().stream,
          initialData: null,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/notific',
            routes: {
              '/notific': (context) => NotificationPractice(),
              '/wrapper': (context) => Wrapper(),
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
                      reverseDuration: Duration(milliseconds: 500));
              }
            },
          )),
    );
  }
}
