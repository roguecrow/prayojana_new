import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'environment.dart';
import 'fBackgroundMessaging.dart';
import 'firebase_options.dart';
import 'flavor_settings.dart';
import 'httpOverrides.dart';
import 'main.dart';
import 'myApp.dart';
import 'services/firebase_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorSettings().initializeApiBaseUrl('https://prayojana-api-v1.slashdr.com');
  print('API URL ${FlavorSettings().apiBaseUrl}');
  await ApiConstants.initializeBaseUrl();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown]
  );
  await Firebase.initializeApp(
      name: 'Prayojana',
      options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initPushNotification();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  runApp( MyApp(environment: EnvironmentValue.production,));
}