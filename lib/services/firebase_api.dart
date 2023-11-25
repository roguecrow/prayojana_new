
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayojana_new/main.dart';
import 'package:prayojana_new/screens/dashboard%20page/dashboard_screen.dart';
import 'package:prayojana_new/screens/notification%20page/push_notification_screen.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import '../floor/database.dart';
import '../floor/notification_model.dart';


class FirebaseApi{

  final _firebaseMessageing = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _firebaseMessageing.requestPermission();
    final FCMToken = await _firebaseMessageing.getToken();
    print('Token :$FCMToken');
    if (FCMToken != null) {
      await prefs.setString('FCMToken', FCMToken);
    }
    int? userId = prefs.getInt('userId');
    String? platFrom = Platform.isAndroid ? 'Android' : 'IOS';
    print(userId);
    print(platFrom);
    print(FCMToken);

    print('inserting in db');
      // Insert new data
      FCMMessaging.postFCMToken(platFrom, true, FCMToken, userId);
   // print('forwarding to push notification');
    //initPushNotification();
  }

  Future<void> handleMessage(RemoteMessage? message) async {
    print('handleMessage called');

    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
        '/notification_screen',
      arguments: message,
    );
  }


  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

    print("Handling a background message");
    print("Handling a background message in other function: ${message.messageId}");
    final notification = AppNotification(
      id: null,
      notification: message.notification!.body.toString(),
      isViewed: false,
      title: message.notification!.title.toString(),
      data: message.data.toString(),
      sentTime: DateTime.now().toString(),
    );

    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    await database.notificationDao.insertNotification(notification);
    print('added background message to db');
  }


  Future initPushNotification()  async {

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Create a notification object with id as null (to auto-generate), and isViewed as false
        final notification = AppNotification(
          id: null,
          notification: message.notification!.body.toString(),
          isViewed: false,
          title: message.notification!.title.toString(),
          data: message.data.toString(),
          sentTime: DateTime.now().toString(),
        );

        final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
        await database.notificationDao.insertNotification(notification);

        // Print all notifications from the database
        final notifications = await database.notificationDao.findAllNotification();
        for (var notification in notifications) {
          print('Notification ID: ${notification.id}, '
              ' Title: ${notification.title} , '
              'data: ${notification.data} ,'
              'Message: ${notification.notification},'
              'sentTime: ${notification.sentTime} , '
              'isViewed: ${notification.isViewed}');
        }
      }
    });
  }
}

