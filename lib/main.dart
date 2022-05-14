import 'package:architectured/bloc/application_bloc.dart';
import 'package:architectured/experimental/notification_practice.dart';
import 'package:architectured/experimental/sand_box.dart';
import 'package:architectured/models/push_notifications_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/views/friends.dart';
import 'package:architectured/views/chat.dart';
import 'package:architectured/views/google_maps.dart';
import 'package:architectured/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('Handling a background message ${message.messageId}');
}

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
            home: Notifications2(),
          )),
    );
  }
}

class Test extends StatefulWidget {
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    loadFCM();
    listenFCM();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      print(token);
    });
  }

  void listenFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      home: Notifications2(),
    ));
  }
}

class Notifications2 extends StatefulWidget {
  const Notifications2({Key? key}) : super(key: key);

  @override
  State<Notifications2> createState() => _Notifications2State();
}

class _Notifications2State extends State<Notifications2> {
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;
  PushNotificationsModel? _notification;

  void registerNotification() async {
    _messaging = FirebaseMessaging.instance;

    // notification states (not determined (null), granted(true), decline(false))

    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: false, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');

      // send message
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        PushNotificationsModel notification = PushNotificationsModel(
          title: remoteMessage.notification!.title,
          body: remoteMessage.notification!.body,
          dataTitle: remoteMessage.data['title'],
          dataBody: remoteMessage.data['body'],
        );

        setState(() {
          _totalNotificationCounter++;
          _notification = notification;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('push notification test')),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'flutter notifications',
          textAlign: TextAlign.center,
        ),
        NotificationBadge(totalNotifications: _totalNotificationCounter)
      ]),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;
  const NotificationBadge({Key? key, required this.totalNotifications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: Center(
        child: Text(totalNotifications.toString()),
      ),
    );
  }
}
