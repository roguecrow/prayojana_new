import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bottom_navigaton.dart';
import '../firebase_access_token.dart';
import 'auth Page/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0;


  @override
  void initState() {
    super.initState();
    _waitAndNavigate();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  Future<void> _waitAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Clear the 'uid' data
    // prefs.remove('uid');
    // prefs.remove('firebaseAccessToken');
    //Delay for 1500 milliseconds (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 3500));
    // Check user authentication
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? accessToken = prefs.getString('firebaseAccessToken');

    if (uid != null && accessToken != null) {
      // UID and access token found in local storage
      DateTime expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);

      if (expiryTime.isBefore(DateTime.now())) {
        // Access token is expired, refresh it
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await AccessToken().refreshAccessToken(user);
          accessToken = prefs.getString('firebaseAccessToken');
          expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);
        }
      }

      if (expiryTime.isAfter(DateTime.now())) {
        // Valid access token, navigate to the bottom navigation page
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavigator(),
          ),
        );
      }
      print(accessToken);
    } else {
      // UID or access token not found, navigate to the authentication page
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 1), // Adjust the duration as needed
          opacity: opacity,
          child: SizedBox(
            child: Image.asset(
              'assets/Prayojana_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

