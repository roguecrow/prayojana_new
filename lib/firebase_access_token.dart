import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessToken {
  Future<void> getFirebaseAccessToken(User? user) async {
    try {
      if (user != null) {
        String? accessToken = await user.getIdToken();
        final idTokenResult = await user.getIdTokenResult();
        final Refresh_token =user.refreshToken;
        final expiryTime = idTokenResult.expirationTime;
        print(Refresh_token);
        print(expiryTime);


        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebaseAccessToken', accessToken);
          print(accessToken);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}


