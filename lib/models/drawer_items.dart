import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart'as http;
import 'package:prayojana_new/about.dart';
import 'package:prayojana_new/graphql_queries.dart';
import 'package:prayojana_new/screens/auth%20Page/auth_screen.dart';
import 'package:prayojana_new/screens/user_profile/user_profile.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../floor/database.dart';


class DrawerItem {
  final Icon icon;
  final String title;
  final Function onTap;

  DrawerItem({required this.icon, required this.title, required this.onTap});
}

class AppDrawer extends StatefulWidget {


  @override
  State<AppDrawer> createState() => _AppDrawerState();
}


class _AppDrawerState extends State<AppDrawer> {
  String? name;
  String? phone;
  String? firstName;
  String? profile;
  int? userId;
  List<dynamic> userDetails = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId')!;
    print(userId);

    try {
      String accessToken = await getFirebaseAccessToken();

      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': getUserProfile(userId!), // Use the updateUserProfile function
          'variables': {'userId': userId},
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        setState(() {
          userDetails = List<Map<String, dynamic>>.from(data['data']['users']);
          if (userDetails.isNotEmpty) {
             name = userDetails[0]['name'];
             phone = userDetails[0]['mobile_number'];
             profile = userDetails[0]['people'][0]['profile_photo'];

             List<String> nameParts = name!.split(' ');
             if (nameParts.isNotEmpty) {
               firstName = nameParts[0];
               print(firstName);
               print('profilePic = $profile');
             }
          }

        });
        print('userDetails - $userDetails');
        print(profile);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }


  // void loadUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? loginUserDetails = prefs.getString('loginUserDetails');
  //
  //   if (loginUserDetails != null) {
  //     userDetails = json.decode(loginUserDetails);
  //     print(userDetails);
  //     setState(() {
  //       name = userDetails['data']['name'];
  //       phone = userDetails['data']['mobile_number'];
  //       profile = userDetails['data']['profile_photo'];
  //
  //       // Split the full name and take the first part
  //       List<String> nameParts = name!.split(' ');
  //       if (nameParts.isNotEmpty) {
  //         firstName = nameParts[0];
  //         print(firstName);
  //         print('profilePic = $profile');
  //       }
  //     });
  //   }
  // }

 Future<void> logOutFCMToken() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   final regId = prefs.getString('FCMToken');
   int? userId = prefs.getInt('userId');
   bool isNotExpired = false;
   print(isNotExpired);
   print(regId);
   print(userId);
   FCMMessaging.logoutFunction(regId, userId, isNotExpired);
   print('update done isNotExpired is false');
 }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                //update notification device
                await logOutFCMToken();
                // Clear SharedPreferences data
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                await database.notificationDao.deleteAllNotifications();
                print('local db cleared');
                print('Local Storage Cleared');
                // Navigate to Auth page
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfileScreen() async {
    final shouldUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(userDetails: {}),
      ),
    );
    if(shouldUpdate == true) {
      loadUserData();
    }
  }



  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [

      // Profile
      DrawerItem(
        icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
        title: 'Profile',
        onTap: () {
          _navigateToProfileScreen();
        },
      ),

      // Sign Out
      DrawerItem(
        icon: const Icon(Icons.logout_outlined, color: Colors.white),
        title: 'Sign Out',
        onTap: () async {
          _showSignOutDialog(context);
        },
      ),

      // About
      DrawerItem(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        title: 'About',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>  const AboutPage()
            ),
          );
        },
      ),
    ];

    return Drawer(
      child: Container(
        color: const Color(0xff006bbf),
        child: ListView(
          children: [
            Container(
              color: const Color(0xff006bbf),
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.only(top: 20.0.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    height: 70.h,
                    child: profile != null &&
                        profile != ''
                        ? CircleAvatar(
                      radius: 45.r,
                      backgroundImage: NetworkImage(profile!),
                    )
                        :  CircleAvatar(
                      radius: 45.r,
                      backgroundColor: Colors.grey,
                      child:  Icon(Icons.person, size: 40.sp, color: Colors.white), // Change the background color as needed
                    ),
                  ),
                  Text(
                    firstName ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  ),
                  //SizedBox(height: 4.h),
                  Text(
                    phone ?? '',
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            ...drawerItems.map((item) {
              return Padding(
                padding:  EdgeInsets.only(top: 10.0.h),
                child: ListTile(
                  leading: item.icon,
                  title: InkWell(
                    onTap: () => item.onTap(),
                   // overlayColor: Colors.yellow, // This is where you handle the tap
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

