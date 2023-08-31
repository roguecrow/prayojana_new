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
        title: Text('Prayojana'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
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
    );
  }
}
