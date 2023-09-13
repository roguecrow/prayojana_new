import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi{

  final _firebaseMessageing = FirebaseMessaging.instance;

  Future<void> initNotification() async {

    await _firebaseMessageing.requestPermission();
    final FCMToken = await _firebaseMessageing.getToken();
    print('Token :$FCMToken');

    initPushNotification();
  }


  void handleMessage(RemoteMessage? message){

    if(message == null) return;

  }

  Future initPushNotification()  async {

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

}