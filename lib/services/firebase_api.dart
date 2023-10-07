
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi{

  final _firebaseMessageing = FirebaseMessaging.instance;

  Future<void> initNotification() async {

    await _firebaseMessageing.requestPermission();
    final FCMToken = await _firebaseMessageing.getToken();
    print('Token :$FCMToken');

    if(FCMToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('FCMToken', FCMToken);
    }
    FCMMessaging.postFCMToken();
    initPushNotification();
  }


  void handleMessage(RemoteMessage? message){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received data message: ${message.data}');
      // Process the data here
    });

    if(message == null) return;
  }

  Future<void> handleBackgroundMessaging(RemoteMessage message)async {
    print('title: ${message.notification?.title}');
    print('body: ${message.notification?.body}');
    print('payload: ${message.data}');
  }

  Future initPushNotification()  async {

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
  }

}