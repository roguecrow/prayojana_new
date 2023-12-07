//
// import 'dart:io';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import 'package:prayojana_new/environment.dart';
// import 'package:prayojana_new/firebase_options.dart';
// import 'package:prayojana_new/screens/notification%20page/push_notification_screen.dart';
// import 'package:prayojana_new/screens/splash%20screen/splash_screen.dart';
// import 'package:prayojana_new/services/firebase_api.dart';
// import 'constants.dart';
// import 'flavor_settings.dart';
// import 'myApp.dart';
// import 'screens/auth Page/auth_screen.dart';
// import 'package:flutter/services.dart';
//
//
//
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('after clearing notification');
//   print('notification body : ${message.notification!.body}');
//   print("Handling a background message: ${message.messageId}");
//   FirebaseApi().firebaseMessagingBackgroundHandler(message);
// }
//
// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }
//
//
// Future<void> main() async {
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final settings = await getFlavorSettings();
//   print('API URL ${settings.apiBaseUrl}');
//    await ApiConstants.initializeBaseUrl();
//   SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//
//   await Firebase.initializeApp(
//       name: 'Prayojana',
//       options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseApi().initPushNotification();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   WidgetsFlutterBinding.ensureInitialized();
//   HttpOverrides.global = new MyHttpOverrides();
//   runApp( MyApp(environment: EnvironmentValue.development,));
// }
//
//
//
//
//
// //RegisterScreen(),
// //MemberScreen(),
// //BottomNavigator(),
//
//
