import 'package:flutter/material.dart';

class DrawerItem {
  final Icon icon;
  final String title;
  final Function onTap;

  DrawerItem({required this.icon, required this.title, required this.onTap});
}

class AppDrawer extends StatelessWidget {
  final List<DrawerItem> drawerItems;
  const AppDrawer({super.key, required this.drawerItems});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xff798fa0),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ...drawerItems.map((item) {
              return ListTile(
                leading: item.icon,
                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onTap: () => item.onTap(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}


