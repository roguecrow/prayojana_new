import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusContainerDashboard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> taskList;

  const StatusContainerDashboard({super.key,
    required this.title,
    required this.taskList,
  });

  @override
  State<StatusContainerDashboard> createState() => _StatusContainerDashboardState();
}

class _StatusContainerDashboardState extends State<StatusContainerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.w, left: 20.w),
      width: 290.w,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Color(0xFFD1D5DB),
          width: 1.0.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.0.h),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15.0.w, right: 12.0.w, top: 10.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.taskList.length,
                itemBuilder: (BuildContext context, int index) {
                  var task = widget.taskList[index];
                  var statusColor = task['color'];
                  Color countColor = Colors.black;
                  if (task['name'].toLowerCase() != 'canceled') {
                    countColor = Color(int.parse(statusColor.replaceAll('#', '0xFF')));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IntrinsicWidth(
                        child: SizedBox(
                          width: 72.w,
                          child: Column(
                            verticalDirection: VerticalDirection.down,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                task['count'].toString(),
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  color: countColor,
                                ),
                              ),
                              Text(
                                task['name'],
                                style: TextStyle(
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// STATIC VIEW OF THE CONTAINER IN DASHBOARD


// Container(
//   margin: EdgeInsets.only(right: 16.w, left: 20.w),
//   width: 290.w,
//   decoration: BoxDecoration(
//     shape: BoxShape.rectangle,
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(10.r),
//     border: Border.all(
//       color: Color(0xFFD1D5DB), // Border color
//       width: 1.0.w, // Border width
//     ),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: EdgeInsets.all(12.0.h),
//         child: Text(
//           "This Week Task Status",
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       Expanded(
//         child: Padding(
//           padding: EdgeInsets.only(left: 12.0.w, right: 12.0.w, top: 10.h),
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: dashboardDetail?['task'].length,
//             itemBuilder: (BuildContext context, int index) {
//               var task = dashboardDetail?['task'][index];
//               var statusColor = task['color']; // Get the status color from the response
//               Color countColor = Colors.black; // Default count color for "canceled" status
//               if (task['name'].toLowerCase() != 'canceled') {
//                 countColor = Color(int.parse(statusColor.replaceAll('#', '0xFF')));
//               }
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 66.w, // Adjust the width as needed
//                     child: Column(
//                       verticalDirection: VerticalDirection.down,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           task['count'].toString(),
//                           style: TextStyle(
//                             fontSize: 30.sp,
//                             color: countColor,
//                             // Convert hex color to Color object
//                           ),
//                         ),
//                         Text(
//                           task['name'],
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
