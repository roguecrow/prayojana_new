import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../drawer_items.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Dashboard',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Members',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Interactions',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Tasks',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Reports',
      onTap: () {},
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Prayojana'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
      ),
      drawer: AppDrawer(drawerItems: _drawerItems),
      // body: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Padding(
      //       padding: EdgeInsets.only(left: 20.0.w, top: 20.0.h),
      //       child: Text(
      //         "Hi Geetha!",
      //         style: TextStyle(
      //           fontSize: 18.sp,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.only(top: 18.0),
      //       child: SizedBox(
      //         height: 100.h,
      //         child: ListView(
      //           scrollDirection: Axis.horizontal,
      //           children: [
      //             Container(
      //               margin: EdgeInsets.only(right: 16.w,left: 20.w),
      //               width: 290.w,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.rectangle,
      //                 color: Colors.pink,
      //                 borderRadius: BorderRadius.circular(10.r),
      //               ),
      //             ),
      //             Container(
      //               margin: EdgeInsets.only(right: 16.w),
      //               width: 167.w,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.rectangle,
      //                 color: Colors.pink,
      //                 borderRadius: BorderRadius.circular(10.r),
      //               ),
      //             ),
      //             Container(
      //               margin: EdgeInsets.only(right: 20.w),
      //               width: 290.w,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.rectangle,
      //                 color: Colors.pink,
      //                 borderRadius: BorderRadius.circular(10.r),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Padding(
      //         padding: EdgeInsets.only(top: 30.0.h , left: 20.0.w ,right: 20.0.w),
      //         child: Stack(
      //           children: [
      //             Container(
      //               decoration: BoxDecoration(
      //                 border: Border.all(color: Colors.black),
      //                 borderRadius: BorderRadius.circular(10.r),
      //               ),
      //               child: Center(
      //                 child: Text(
      //                   "Container below ListView (1/3 of the view)",
      //                   style: TextStyle(
      //                     fontSize: 18.sp,
      //                     color: Colors.black,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             Positioned(
      //               top: 24.h,
      //               right: 24.w,
      //               child: Text(
      //                 "Today, 07 Aug",
      //                 style: TextStyle(
      //                   fontSize: 18.sp,
      //                   color: Colors.black,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //
      //   ],
      // ),
    );
  }
}
