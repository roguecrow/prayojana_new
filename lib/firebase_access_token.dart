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
        final expiryTime = idTokenResult.expirationTime!.millisecondsSinceEpoch; // Convert DateTime to milliseconds since epoch
        setupAccessTokenRefresh(user);

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebaseAccessToken', accessToken);
          await prefs.setString('uid', uid);
          await prefs.setInt('accessTokenExpiry', expiryTime); // Store expiry time in local storage
          print('uid - $uid');
          print('StoredAccessToken - $accessToken');
          print('StoredAccessTokenExpiry - $expiryTime');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> refreshAccessToken(User user) async {
    try {
      final String? refreshedAccessToken = await user.getIdToken(true);
      final idTokenResult = await user.getIdTokenResult();
      final refreshedExpiryTime = idTokenResult.expirationTime!.millisecondsSinceEpoch;

      if (refreshedAccessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebaseAccessToken', refreshedAccessToken);
        prefs.setInt('accessTokenExpiry', refreshedExpiryTime); // Update expiry time
        print('StoredRefreshToken - $refreshedAccessToken');
        print('StoredRefreshTokenExpiry - $refreshedExpiryTime');
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







