import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:todoapp_live/task_list_screen.dart';

void main() {
  AwesomeNotifications().initialize('resource://drawable/notification_1', [
    NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled channel',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true)
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}
