import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:prayojana_new/services/firebase_api.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('after clearing notification');
  print('notification body : ${message.notification!.body}');
  print("Handling a background message: ${message.messageId}");
  FirebaseApi().firebaseMessagingBackgroundHandler(message);
}