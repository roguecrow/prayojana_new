import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessToken {
  Future<void> getFirebaseAccessToken(User? user) async {
    try {
      if (user != null) {
        String uid = user.uid;
        String? accessToken = await user.getIdToken();
        final idTokenResult = await user.getIdTokenResult();
        //final refreshToken = await user.getIdToken(true);
        final expiryTime = idTokenResult.expirationTime;
       // print('refreshToken - $refreshToken');
        print('expiryTime - $expiryTime');
        setupAccessTokenRefresh(user);

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebaseAccessToken', accessToken);
          prefs.setString('uid', uid);
          print('uid - $uid');
          print('StoredAccessToken - $accessToken');
        }
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> refreshAccessToken(User user) async {
    try {
      final String? refreshedAccessToken = await user.getIdToken(true);

      if (refreshedAccessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebaseAccessToken', refreshedAccessToken);
        print('StoredRefreshToken - $refreshedAccessToken');
      }
    } catch (e) {
      print('Error refreshing access token: $e');
    }
  }

  void setupAccessTokenRefresh(User user) {
    Timer.periodic(const Duration(minutes: 50), (timer) {
      refreshAccessToken(user);
    });
  }
}






