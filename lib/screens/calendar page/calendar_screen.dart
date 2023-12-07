import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:prayojana_new/screens/interactions%20page/create_new_interaction_new.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/drawer_items.dart';
import '../tasks page/create_new_task_new.dart';

class CalendarScreen extends StatefulWidget {

  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _key = GlobalKey<ExpandableFabState>();
  DateTime today = DateTime.now();
  Map<String, dynamic>? calendarDetail; // Add this line
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> interactions = [];

  bool isOpened = false;

  bool showCalendar = false;

  void toggleCalendar() {
    setState(() {
      showCalendar = !showCalendar;
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay)  {
    setState(()  {
      today = day; // Use 'today' if 'day' is null
       CalenderApi().fetchCalendarDetails(formatDate(today), formatDate(today))
          .then((details) {
        setState(() {
          calendarDetail = details; // Update calendarDetail when data is fetched
          print('Calendar data: $calendarDetail');
          fetchTaskAndInteraction();
        });
      });
    });
  }



  @override
  void initState() {
    super.initState();
    print('today - $today');
    fetchCalendarDetails(); // Call the method to fetch details
  }




  void fetchCalendarDetails() async {
    final details = await CalenderApi().fetchCalendarDetails(formatDate(today), formatDate(today));
    setState(() {
      calendarDetail = details;
      print('Calendar data: $calendarDetail');
      fetchTaskAndInteraction();
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

  String formatDueDate(String dueDate) {
    final originalFormat = DateFormat('yyyy-MM-dd');
    final newFormat = DateFormat('dd MMM yyyy');

    final dateTime = originalFormat.parse(dueDate);
    return newFormat.format(dateTime);
  }

  String viewDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today, ${DateFormat('dd MMM').format(date)}';
    } else {
      DateTime yesterday = now.subtract(const Duration(days: 1));
      if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        return 'Yesterday, ${DateFormat('dd MMM').format(date)}';
      } else {
        return DateFormat('EEEE, dd MMM').format(date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Add this line
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Calendar'),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.search,
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.r),
            bottomRight: Radius.circular(5.r),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(18.0.dm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                     viewDate(today),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkResponse(
                    onTap: () {
                      toggleCalendar();
                    },
                    child: Image.asset(
                      "assets/icons/Calendar.png",
                      width: 22.w,
                      height: 22.h,
                      color: showCalendar ? Colors.blue : null, // Apply a color when highlighted
                    ),
                  )

                ],
              ),
            ),

            if (showCalendar)
              Container(
                margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 20.h),
                child: TableCalendar(
                 // rowHeight: 30.h,
                  headerStyle: const HeaderStyle(formatButtonVisible: false,titleCentered: true),
                  availableGestures: AvailableGestures.all,
                  firstDay: DateTime.utc(1900, 1, 1),
                  lastDay: DateTime.utc(3000, 12, 31),
                  focusedDay: today,
                  onDaySelected: _onDaySelected,
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  // onDaySelected: _onDaySelected, // Call the function when a day is selected
                  // ... Customize the calendar as needed ...
                ),
              ),
            Column(
              children: [
                Container(
                  height: 4.h,
                  width: 320.w,
                  color: const Color(0xff006bbf) ,
                ),
                SingleChildScrollView(
                  child: Container(
                    //height: 390.h,
                    width: 320.w,
                    color: const Color(0xfff1f9ff),
                    child: Padding(
                      padding: EdgeInsets.only(left:16.w, top:18.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          SizedBox(height: 4.h),
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
                          SizedBox(height: 4.h),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Row(
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
                              );
                            },
                          ),
                          Divider(height: 30.h,indent: 5.w,color: Colors.black,), // Added Divider
                          // SizedBox(
                          //   width: ScreenUtil().screenWidth - 20.w,
                          //   child: Padding(
                          //     padding:  EdgeInsets.only(left: 12.0.w,bottom: 20.h),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
                          //       children: [
                          //          Text(
                          //             "EVENTS",
                          //             style: TextStyle(
                          //               fontSize: 12.sp,
                          //               fontWeight: FontWeight.w500,
                          //             )
                          //         ),
                          //         SizedBox(height: 10.h,),
                          //         Row(
                          //           children: [
                          //             Image.asset(
                          //               "assets/icons/Star.png",
                          //               height: 15.h,
                          //             ),
                          //             SizedBox(width: 12.w),
                          //             Text(
                          //               "Raghu’s Anniversary",
                          //               style: TextStyle(
                          //                 color: const Color(0xff018fff),
                          //                 fontSize: 14.sp,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        duration: const Duration(milliseconds: 60),
        distance: 50.h,
        overlayStyle: ExpandableFabOverlayStyle(blur: 2),
        type: ExpandableFabType.up,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: const OvalBorder(),
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.close,
                size: 40,
              ),
            );
          },
        ),
        children: [
          FloatingActionButton.extended(
            heroTag: 'interaction',
            onPressed: () {
              _navigateToCreateInteractionScreen();
            },
            label: const Text('INTERACTION'),
            foregroundColor:const Color(0xff018fff) ,
            backgroundColor: const Color(0xffffffff),
          ),
          FloatingActionButton.extended(
            heroTag: 'task',
            onPressed: () {
              _navigateToCreateTaskScreen();
            },
            label: const Text('TASK'),
            foregroundColor:const Color(0xff018fff) ,
            backgroundColor: const Color(0xffffffff),
          ),
        ],
      ),
    );
  }
  void _navigateToCreateTaskScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskNew()),
    );
  }
  void _navigateToCreateInteractionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInteractionNew()),
    );
  }

}


