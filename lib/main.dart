import 'package:architectured/bloc/application_bloc.dart';
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
              // canvasColor: Colors.red,
              // elevatedButtonTheme: ElevatedButtonTheme(data: ),
              appBarTheme: AppBarTheme(
                  elevation: 0,
                  color: Colors.grey[100],
                  foregroundColor: Colors.black54),
              // primaryColor: Colors.red,

              primaryColorLight: Colors.purple,
              primaryColor: Colors.red,
              backgroundColor: Colors.orange,
              // scaffoldBackgroundColor: Colors.red,
              colorScheme: ColorScheme.fromSwatch(
                backgroundColor: Colors.red,
                accentColor: Colors.red,
                cardColor: Colors.orange,
                // brightness: Brightness.dark,
                primarySwatch: Palette.kToDark,
                // primaryColorDark: Colors.red,
                // accentColor: Colors.purple,
                // backgroundColor: Colors.orange,
                // cardColor: Colors.brown
              ),
            ),
            initialRoute: '/wrapper',
            routes: {
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

class Palette {
  static const MaterialColor kToDark = const MaterialColor(
    0xfff8f8f8, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xffce5641), //10%
      100: const Color(0xffb74c3a), //20%
      200: const Color(0xffa04332), //30%
      300: const Color(0xff89392b), //40%
      400: const Color(0xff733024), //50%
      500: const Color(0xff5c261d), //60%
      600: const Color(0xff451c16), //70%
      700: const Color(0xff2e130e), //80%
      800: const Color(0xff170907), //90%
      900: const Color(0xff000000), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.
