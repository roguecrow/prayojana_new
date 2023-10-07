import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20Notes/member_notes.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20assistance/member_assistance.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20documents/member_documents.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20interest/member_interest.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20prayojana%20Profile/member_prayojana_profile.dart';
import '../../../drawer_header.dart';
import 'screens/member page/member details/member health/member_health.dart';
import 'screens/member page/member details/member profile/member_profile.dart';
import 'screens/member page/member details/member report/member_report.dart';

class MemberDrawer extends StatefulWidget {
  final Map<String, dynamic> member;

  const MemberDrawer({Key? key, required this.member}) : super(key: key);

  @override
  State<MemberDrawer> createState() => _MemberDrawerState();
}


class _MemberDrawerState extends State<MemberDrawer> {
  Map<String, dynamic> get member => widget.member; // Access member data
  var currentPage = DrawerSections.profile;

  @override
  Widget build(BuildContext context) {
    var container , title;
    if (currentPage == DrawerSections.profile) {
      title = Text('Member Profile');
      container = MemberProfile(member: member); // Pass member data to MemberHealth
    } else if (currentPage == DrawerSections.health) {
      title = Text('Member Health');
      container = MemberHealth(member: member); // Pass member data to MemberDashboard (if needed)
    } else if (currentPage == DrawerSections.reports) {
      title = Text('Member Report');
      container = MemberReport(member: member); // Pass member data to MemberReport (if needed)
    }
    else if (currentPage == DrawerSections.notes) {
      title = Text('Member Summaries');
      container = MemberNotes(member: member);
    }
    else if (currentPage == DrawerSections.assistance) {
      title = Text('Member Assistance');
      container = MemberAssistance(member: member);
    }
    else if (currentPage == DrawerSections.documents) {
      title = Text('Member Documents');
      container = MemberDocuments(member: member);
    }
    else if (currentPage == DrawerSections.prayojanaprofile) {
      title = Text('Prayojana Profile');
      container = MemberPrayojanaProfile(member: member);
    }
    else if (currentPage == DrawerSections.interests) {
      title = Text('Member Interest');
      container = MemberInterest(member: member);
    }
    return Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: const Color(0xff006bbf),
        shadowColor: const Color(0xff006bbf),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
      ),
      body: container,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                HeaderDrawer(member: member),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem(1, "Profile", Icons.people_alt_outlined,
              currentPage == DrawerSections.profile ? true : false),
          menuItem(2, "Health", Icons.health_and_safety_outlined,
              currentPage == DrawerSections.health ? true : false),
          menuItem(3, "Notes", Icons.notes_outlined,
              currentPage == DrawerSections.notes ? true : false),
          menuItem(4, "Reports", Icons.report_outlined,
              currentPage == DrawerSections.reports ? true : false),
          menuItem(5, "Assistance", Icons.assistant_outlined,
              currentPage == DrawerSections.assistance ? true : false),
          menuItem(6, "Prayojana Profile", Icons.account_circle_outlined,
              currentPage == DrawerSections.prayojanaprofile ? true : false),
          menuItem(7, "Documents", Icons.file_present_outlined,
              currentPage == DrawerSections.documents ? true : false),
          menuItem(8, "Interests", Icons.interests_outlined,
              currentPage == DrawerSections.interests ? true : false),
          Divider(),
          menuItem(9, "Settings", Icons.settings_outlined,
              currentPage == DrawerSections.settings ? true : false),
          menuItem(10, "Notifications", Icons.notifications_outlined,
              currentPage == DrawerSections.notifications ? true : false),
          Divider(),
          menuItem(11, "Privacy policy", Icons.privacy_tip_outlined,
              currentPage == DrawerSections.privacy_policy ? true : false),
          menuItem(12, "Send feedback", Icons.feedback_outlined,
              currentPage == DrawerSections.send_feedback ? true : false),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              currentPage = DrawerSections.profile;
            } else if (id == 2) {
              currentPage = DrawerSections.health;
            } else if (id == 3) {
              currentPage = DrawerSections.notes;
            } else if (id == 4) {
              currentPage = DrawerSections.reports;
            } else if (id == 5) {
              currentPage = DrawerSections.assistance;
            } else if (id == 6) {
              currentPage = DrawerSections.prayojanaprofile;
            }else if (id == 7) {
              currentPage = DrawerSections.documents;
            }else if (id == 8) {
              currentPage = DrawerSections.interests;
            }else if (id == 9) {
              currentPage = DrawerSections.settings;
            } else if (id == 10) {
              currentPage = DrawerSections.notifications;
            } else if (id == 11) {
              currentPage = DrawerSections.privacy_policy;
            } else if (id == 12) {
              currentPage = DrawerSections.send_feedback;
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  profile,
  health,
  notes,
  reports,
  assistance,
  prayojanaprofile,
  documents,
  interests,
  settings,
  notifications,
  privacy_policy,
  send_feedback,
}


// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// /// Flutter code sample for [NavigationDrawer].
//
// class ExampleDestination {
//   const ExampleDestination(this.label, this.icon, this.selectedIcon);
//
//   final String label;
//   final Widget icon;
//   final Widget selectedIcon;
// }
//
// const List<ExampleDestination> destinations = <ExampleDestination>[
//   ExampleDestination(
//       'page 0', Icon(Icons.widgets_outlined), Icon(Icons.widgets)),
//   ExampleDestination(
//       'page 1', Icon(Icons.format_paint_outlined), Icon(Icons.format_paint)),
//   ExampleDestination(
//       'page 2', Icon(Icons.text_snippet_outlined), Icon(Icons.text_snippet)),
//   ExampleDestination(
//       'page 3', Icon(Icons.invert_colors_on_outlined), Icon(Icons.opacity)),
// ];
//
// class MemberDrawer extends StatefulWidget {
//   final Map<String, dynamic> member;
//
//   const MemberDrawer({Key? key, required this.member}) : super(key: key);
//
//   @override
//   State<MemberDrawer> createState() => _MemberDrawerState();
// }
//
// class _MemberDrawerState extends State<MemberDrawer> {
//   Map<String, dynamic> get member => widget.member; // Access member data
//   int screenIndex = 0;
//   late Widget content;
//
//   @override
//   Widget build(BuildContext context) {
//     Widget content;
//     String title = destinations[screenIndex].label;
//
//     if (screenIndex == 0) {
//       content = Text('Page 0 Content'); // Replace with your content for Page 0
//     } else if (screenIndex == 1) {
//       content = Text('Page 1 Content'); // Replace with your content for Page 1
//     } else if (screenIndex == 2) {
//       content = Text('Page 2 Content'); // Replace with your content for Page 2
//     } else if (screenIndex == 3) {
//       content = Text('Page 3 Content'); // Replace with your content for Page 3
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         backgroundColor: const Color(0xff006bbf),
//         shadowColor: const Color(0xff006bbf),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(5.w),
//             bottomRight: Radius.circular(5.w),
//           ),
//         ),
//       ),
//       body: const TabBarView(
//         children: [
//           Icon(Icons.directions_car),
//           Icon(Icons.directions_transit),
//           Icon(Icons.directions_bike),
//         ],
//       ),
//       endDrawer: NavigationDrawer(
//         onDestinationSelected: (int index) {
//           setState(() {
//             screenIndex = index;
//           });
//         },
//         selectedIndex: screenIndex,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
//             child: Text(
//               'Header',
//               style: Theme.of(context).textTheme.titleSmall,
//             ),
//           ),
//           ...destinations.map(
//                 (ExampleDestination destination) {
//               return NavigationDrawerDestination(
//                 label: Text(destination.label),
//                 icon: destination.icon,
//                 selectedIcon: destination.selectedIcon,
//               );
//             },
//           ),
//           const Padding(
//             padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
//             child: Divider(),
//           ),
//         ],
//       ),
//     );
//   }
// }
