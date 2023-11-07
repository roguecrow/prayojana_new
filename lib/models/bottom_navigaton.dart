import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/screens/calendar%20page/calendar_screen.dart';
import 'package:prayojana_new/screens/dashboard%20page/dashboard_screen.dart';
import 'package:prayojana_new/screens/interactions%20page/interaction_screen.dart';
import 'package:prayojana_new/screens/member%20page/member_screen.dart';
import 'package:prayojana_new/screens/tasks%20page/task_screen.dart';

import '../services/firebase_api.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({Key? key}) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const MemberScreen(),
    const InteractionScreen(),
    const TaskScreen(),
    const CalendarScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print('initiated notification');
   // initiateNotification();
  }

  void initiateNotification() async {
    print('from bottom nav');
    FirebaseApi().initPushNotification();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Use the current page based on _currentIndex
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Interactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_sharp),
            label: 'Calendar',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
      ),
    );
  }
}


//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:prayojana_new/screens/calendar%20page/calendar_screen.dart';
// import 'package:prayojana_new/screens/dashboard%20page/dashboard_screen.dart';
// import 'package:prayojana_new/screens/interactions%20page/interaction_screen.dart';
// import 'package:prayojana_new/screens/member%20page/member_screen.dart';
// import 'package:prayojana_new/screens/tasks%20page/task_screen.dart';
//
// class BottomNavigator extends StatefulWidget {
//   const BottomNavigator({Key? key}) : super(key: key);
//
//   @override
//   State<BottomNavigator> createState() => _BottomNavigatorState();
// }
//
// class _BottomNavigatorState extends State<BottomNavigator> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages = [
//     const DashboardScreen(),
//     const MemberScreen(),
//     const InteractionScreen(),
//     const TaskScreen(),
//     const CalendarScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex], // Use the current page based on _currentIndex
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//           _bottomNavigationBarItem('Dashboard.png', 'Dashboard', 0),
//           _bottomNavigationBarItem('Members.png', 'Members', 1),
//           _bottomNavigationBarItem('Interactions.png', 'Interactions', 2),
//           _bottomNavigationBarItem('Tasks.png', 'Tasks', 3),
//           _bottomNavigationBarItem('Calendar (1).png', 'Calendar', 4),
//         ],
//
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.black,
//         selectedLabelStyle: TextStyle(fontSize: 12.sp),
//         unselectedLabelStyle: TextStyle(fontSize: 12.sp),
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _bottomNavigationBarItem(String imageName, String label, int index) {
//     return BottomNavigationBarItem(
//       icon: Image.asset(
//         'assets/icons/$imageName',
//
//         // color: _currentIndex == index ? Colors.blue,
//         height: 24, // Adjust the height as needed
//         width: 24,  // Adjust the width as needed
//       ),
//       label: label,
//     );
//   }
// }
//

