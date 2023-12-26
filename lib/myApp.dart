
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayojana_new/environment.dart';
import 'package:prayojana_new/screens/notification%20page/push_notification_screen.dart';
import 'package:prayojana_new/screens/splash%20screen/splash_screen.dart';
import 'package:flutter/services.dart';


final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {

  final Environment environment;

  const MyApp({Key? key, required this.environment}) : super(key: key);

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
            useMaterial3: false,
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