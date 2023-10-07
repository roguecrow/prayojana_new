import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayojana_new/bottom_navigaton.dart';
import 'package:prayojana_new/firebase_options.dart';
import 'package:prayojana_new/services/firebase_api.dart';
import 'screens/auth Page/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'Prayojana',
      options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
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
          home: RegisterScreen(),
          // MemberScreen(),
          //BottomNavigator(),
        );
      },
    );
  }
}



//RegisterScreen(),
//MemberScreen(),
//BottomNavigator(),