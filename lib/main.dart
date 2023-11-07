
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayojana_new/firebase_options.dart';
import 'package:prayojana_new/screens/notification%20page/push_notification_screen.dart';
import 'package:prayojana_new/screens/splash%20screen/splash_screen.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:prayojana_new/services/api_service.dart';
import 'package:prayojana_new/services/firebase_api.dart';
import 'screens/auth Page/auth_screen.dart';
import 'package:flutter/services.dart';


final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('after clearing notification');
  print('notification body : ${message.notification!.body}');
  print("Handling a background message: ${message.messageId}");
  FirebaseApi().firebaseMessagingBackgroundHandler(message);
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp(
      name: 'Prayojana',
      options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initPushNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('myNotifications');


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640), // Design size for your UI
      minTextAdapt: true,
      builder: (BuildContext context, Widget? widget) {
        return MaterialApp(
          title: 'Prayojana',
          theme: ThemeData(
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: SplashScreen(),
          //RegisterScreen(),
          // MemberScreen(),
          //BottomNavigator(),
          navigatorKey: navigatorKey,
          routes: {
            '/notification_screen' :(context) => const PushNotificationScreen(),
          },
        );
      },
    );
  }
}



//RegisterScreen(),
//MemberScreen(),
//BottomNavigator(),


