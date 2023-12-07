import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/screens/notification%20page/push_notification_screen.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../floor/database.dart';
import '../../models/drawer_items.dart';
import 'dashboard_metrics.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime today = DateTime.now();
  Map<String, dynamic>? calendarDetail; // Add this line
  Map<String, dynamic>? dashboardDetail; // Add this line
  late String dashBoardDate;
  String? name;
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> interactions = [];
  int _currentPage = 0; // Add this line
  int? _counter;
  final PageController _pageController = PageController(initialPage: 0);



  @override
  void initState() {
    super.initState();
    incrementCounter();
    loadUserDetails();
    dashBoardDate = DateFormat('dd MMM').format(today);
    fetchCalendarDetails(); // Call the method to fetch details
    fetchDashboardDetails();
  }

  Future<void> incrementCounter() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final unviewedNotifications = await database.notificationDao.findUnviewedNotifications();
    final unviewedNotificationCount = unviewedNotifications.length;
    print('Unviewed Notification Count: $unviewedNotificationCount');
    setState(() {
      _counter = unviewedNotificationCount;
    });
  }


  void loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginUserDetails = prefs.getString('loginUserDetails');

    if (loginUserDetails != null) {
      Map<String, dynamic> userDetails = json.decode(loginUserDetails);
      print(userDetails);
      setState(() {
        name = userDetails['data']['name'];
      });
    }
  }

  void fetchCalendarDetails() async {
    final details = await CalenderApi().fetchCalendarDetails(formatDate(today), formatDate(today));
    setState(() {
      calendarDetail = details;
      print('Calendar data: $calendarDetail');
      fetchTaskAndInteraction();
    });
  }

  String formatDueDate(String dueDate) {
    final originalFormat = DateFormat('yyyy-MM-dd');
    final newFormat = DateFormat('dd MMM yyyy');

    final dateTime = originalFormat.parse(dueDate);
    return newFormat.format(dateTime);
  }

  void fetchDashboardDetails() async {
    final details = await DashBoardApi().fetchDashBoardDetails();
    setState(() {
      dashboardDetail = details;
      print('DashBoard data: $dashboardDetail');
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }


  void fetchTaskAndInteraction() {
    if (calendarDetail != null && calendarDetail!['status']) {
      tasks = List<Map<String, dynamic>>.from(calendarDetail!['tasks']);
      interactions = List<Map<String, dynamic>>.from(calendarDetail!['interactions']);
      print('Tasks - $tasks');
      print('Interaction - $interactions');
    }
  }

  Widget buildDot(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey,
      ),
    );
  }
  void onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dashboardDetail == null || dashboardDetail!.isEmpty  || calendarDetail == null || calendarDetail!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Prayojana'),
        actions: [
          Stack(
            children: [
              Padding(
                padding:  EdgeInsets.only(right: 8.0.w),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PushNotificationScreen(),
                      ),
                    );
                  },
                  icon:  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    //size: 25.w,
                  ),
                ),
              ),
              Container(
                width: 35.w,
                height: 30.h,
                alignment: Alignment.topRight,
                margin:  EdgeInsets.only(top: 5.h),
                child: Container(
                  width: 15.w,
                  height: 10.h,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffc32c37),
                     // border: Border.all(color: Colors.white, width: 1.w)
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Text(
                        _counter.toString(),
                        style: TextStyle(fontSize: 8.sp),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
      ),
        drawer: AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0.w, top: 20.0.h),
            child: Text(
              'Hi $name!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: SizedBox(
              height: 100.h,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                onPageChanged: onPageChanged, // Add this line
                children: [
                  StatusContainerDashboard(
                    title: "Task Status this Week",
                    taskList: (dashboardDetail?['task'] as List<dynamic>).cast<Map<String, dynamic>>(),
                  ),
                  StatusContainerDashboard(
                    title: "Interactions this week",
                    taskList: (dashboardDetail?['interactions'] as List<dynamic>).cast<Map<String, dynamic>>(),
                  ),
                  StatusContainerDashboard(
                    title: "Onboarding this week",
                    taskList: (dashboardDetail?['members'] as List<dynamic>).cast<Map<String, dynamic>>(),
                  ),
                  // Add more pages if needed
                ],
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 10.0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Replace with the actual number of pages
                    (index) => buildDot(index),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 20.0.h , left: 20.0.w ,right: 20.0.w),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                     // height: 390.h,
                      width: 320.w,
                      decoration: BoxDecoration(
                       // color: const Color(0xfff1f9ff),
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                        border: Border.all(
                          color: const Color(0xffd1d5db), // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                     // color: const Color(0xfff1f9ff),
                      child: Padding(
                        padding: EdgeInsets.only(left:16.w, top:18.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 24.0.w,top: 8.h),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: 30.h,
                                  child: Text(
                                    "Today, $dashBoardDate", // Use the length of interactions list
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff555555),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 5.0.w),
                              child: Text(
                                "INTERACTION (${interactions.length})", // Use the length of interactions list
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // List of names with checkboxes
                            Column(
                              children: List.generate(interactions.length, (index) {
                                final interaction = interactions[index];
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: interactions[index]['ist_id'] == 2,
                                      onChanged: (bool? value) {
                                        // Handle checkbox change here
                                      },
                                      visualDensity: const VisualDensity(
                                        horizontal: VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity,
                                      ),
                                      activeColor: const Color(0xff7fd9b2),
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0.r),
                                        side: BorderSide(
                                          color: const Color(0xffd1d5db),
                                          width: 1.0.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.w,),
                                    Text(
                                      interaction['title'], // Assuming 'title' is the key for interaction title
                                      style: TextStyle(fontSize: 16.sp,color: const Color(0xff222222),fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            Divider(height: 30.h,indent: 5.w,color: Colors.black,), // Added Divider
                            Padding(
                              padding: EdgeInsets.only(left: 5.0.w),
                              child: Text(
                                "TASKS (${tasks.length})", // Use the length of tasks list
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding:  EdgeInsets.only(bottom: 12.0.h),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: tasks[index]['tst_id'] == 3,
                                            onChanged: (bool? value) {
                                              // Handle checkbox change if needed
                                            },
                                            visualDensity: const VisualDensity(
                                              horizontal: VisualDensity.minimumDensity,
                                              vertical: VisualDensity.minimumDensity,
                                            ),
                                            activeColor: const Color(0xff7fd9b2),
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0.r),
                                              side: BorderSide(
                                                color: const Color(0xffd1d5db),
                                                width: 1.0.w,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.w,),
                                          Text(
                                            tasks[index]['task_title'],
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: tasks[index]['tst_color'] == '#D81616'
                                                  ? const Color(0xffD81616) // Use the specified color
                                                  : const Color(0xff222222), // Use black if condition is not met
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 120.w, top: 4.h), // Adjust the indentation as needed
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Due Date: ${formatDueDate(tasks[index]['due_date'])}",
                                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w100),
                                            ),
                                            SizedBox(height: 3.h,),
                                            Text(
                                              "Assigned By: ${tasks[index]['sp_name']}",
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    }
  }
}
