import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/about.dart';
import 'package:prayojana_new/screens/auth%20Page/auth_screen.dart';
import 'package:prayojana_new/screens/user_profile/user_profile.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }


  void loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginUserDetails = prefs.getString('loginUserDetails');

    if (loginUserDetails != null) {
      userDetails = json.decode(loginUserDetails);
      setState(() {
        name = userDetails['data']['name'];
        phone = userDetails['data']['mobile_number'];

        // Split the full name and take the first part
        List<String> nameParts = name!.split(' ');
        if (nameParts.isNotEmpty) {
          firstName = nameParts[0];
          print(firstName);
        }
      });
    }
  }

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



  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [

      // Profile
      DrawerItem(
        icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
        title: 'Profile',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePage(userDetails: userDetails),
            ),
          );
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
                    height: 50.h,
                    child: Icon(Icons.person, size: 50.h, color: Colors.white) // Show profile icon if no image
                  ),
                  Text(
                    firstName ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  ),
                  SizedBox(height: 4.h),
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

