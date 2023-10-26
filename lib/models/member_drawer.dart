import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20Notes/member_notes.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20assistance/member_assistance.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20documents/member_documents.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20interest/member_interest.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20prayojana%20Profile/member_prayojana_profile.dart';
import 'drawer_header.dart';
import '../screens/member page/member details/member health/member_health.dart';
import '../screens/member page/member details/member profile/member_profile.dart';
import '../screens/member page/member details/member report/member_report.dart';

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
      title = Text('Member Profile',style: TextStyle(fontSize: 20.0.sp),);
      container = MemberProfile(member: member); // Pass member data to MemberHealth
    }
    else if (currentPage == DrawerSections.health) {
      title = Text('Member Health',style: TextStyle(fontSize: 20.0.sp));
      container = MemberHealth(member: member); // Pass member data to MemberDashboard (if needed)
    }
    // else if (currentPage == DrawerSections.reports) {
    //   title = Text('Member Report',style: TextStyle(fontSize: 20.0.sp));
    //   container = MemberReport(member: member); // Pass member data to MemberReport (if needed)
    // }
    else if (currentPage == DrawerSections.notes) {
      title = Text('Member Summaries',style: TextStyle(fontSize: 20.0.sp));
      container = MemberNotes(member: member);
    }
    else if (currentPage == DrawerSections.assistance) {
      title = Text('Member Assistance',style: TextStyle(fontSize: 20.0.sp));
      container = MemberAssistance(member: member);
    }
    else if (currentPage == DrawerSections.documents) {
      title = Text('Member Documents',style: TextStyle(fontSize: 20.0.sp));
      container = MemberDocuments(member: member);
    }
    else if (currentPage == DrawerSections.prayojanaprofile) {
      title = Text('Prayojana Profile',style: TextStyle(fontSize: 20.0.sp));
      container = MemberPrayojanaProfile(member: member);
    }
    else if (currentPage == DrawerSections.interests) {
      title = Text('Member Interest',style: TextStyle(fontSize: 20.0.sp));
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
      padding: const EdgeInsets.only(
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
          // menuItem(4, "Reports", Icons.report_outlined,
          //     currentPage == DrawerSections.reports ? true : false),
          menuItem(5, "Assistance", Icons.assistant_outlined,
              currentPage == DrawerSections.assistance ? true : false),
          menuItem(6, "Prayojana Profile", Icons.account_circle_outlined,
              currentPage == DrawerSections.prayojanaprofile ? true : false),
          const Divider(),
          menuItem(7, "Documents", Icons.file_present_outlined,
              currentPage == DrawerSections.documents ? true : false),
          menuItem(8, "Interests", Icons.interests_outlined,
              currentPage == DrawerSections.interests ? true : false),
          const Divider(),
          // menuItem(9, "Settings", Icons.settings_outlined,
          //     currentPage == DrawerSections.settings ? true : false),
          // menuItem(10, "Notifications", Icons.notifications_outlined,
          //     currentPage == DrawerSections.notifications ? true : false),
          // Divider(),
          // menuItem(11, "Privacy policy", Icons.privacy_tip_outlined,
          //     currentPage == DrawerSections.privacy_policy ? true : false),
          // menuItem(12, "Send feedback", Icons.feedback_outlined,
          //     currentPage == DrawerSections.send_feedback ? true : false),
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
            }
              // else if (id == 4) {
            //   currentPage = DrawerSections.reports;
            // }
            else if (id == 5) {
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
          padding: EdgeInsets.only(top: 12.0.h ,right: 12.0.h,bottom: 12.0.h),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 16.h,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
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
 // reports,
  assistance,
  prayojanaprofile,
  documents,
  interests,
  settings,
  notifications,
  privacy_policy,
  send_feedback,
}
