import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/screens/auth%20Page/auth_screen.dart';
import 'package:prayojana_new/screens/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      });
    }
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

      // Settings
      DrawerItem(
        icon: const Icon(Icons.settings_outlined, color: Colors.white),
        title: 'Settings',
        onTap: () {
          // Handle Settings onTap
        },
      ),
      // Sign Out
      DrawerItem(
        icon: const Icon(Icons.logout_outlined, color: Colors.white),
        title: 'Sign Out',
        onTap: () async {
          // Clear SharedPreferences data
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          print('local Storage Cleared');
          // Navigate to Auth page
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
      ),
      // About
      DrawerItem(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        title: 'About',
        onTap: () {
          // Handle About onTap
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
                    name ?? '',
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

