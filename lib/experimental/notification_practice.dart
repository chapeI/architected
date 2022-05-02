import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPractice extends StatelessWidget {
  const NotificationPractice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: ElevatedButton(
        child: Text('send a notification'),
        onPressed: () {
          showNotification();
        },
      )),
    );
  }

  showNotification() async {
    print('alo');
    final _notifications = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings("@mipmap/ic_launcher");

    final initializationSettings = InitializationSettings(android: android);

    await _notifications.initialize(initializationSettings);

    final channel = AndroidNotificationChannel('high channel', 'high imp notif',
        description: 'channel is mine', importance: Importance.max);

    FlutterLocalNotificationsPlugin().show(
        0,
        'some head',
        'somebody once told me',
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name)));
  }
}
