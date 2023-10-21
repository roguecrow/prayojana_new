import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottom_navigaton.dart';
import 'auth Page/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _waitAndNavigate();
  }

  Future<void> _waitAndNavigate() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // // Clear the 'uid' data
    // prefs.remove('uid');
    // Delay for 1500 milliseconds (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 3500));
    // Check user authentication
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      // UID found in local storage, navigate to the bottom navigation page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BottomNavigator(),
        ),
      );
    } else {
      // UID not found, navigate to the authentication page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

