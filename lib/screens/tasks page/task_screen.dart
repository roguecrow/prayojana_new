import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:prayojana_new/screens/tasks%20page/create_new_task.dart';
import 'package:prayojana_new/services/api_service.dart';
import '../../drawer_items.dart';
import 'update_task_details.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic>? _taskData;
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
  void initState() {
    super.initState();
    fetchTaskData();
  }

  Future<void> fetchTaskData() async {
    MemberApi memberApi = MemberApi();
    List<dynamic>? tasks = await memberApi.fetchTaskMembersData();
    setState(() {
      _taskData = tasks;
    });
  }

  String formatDueDate(String dueDate) {
    final originalFormat = DateFormat('yyyy-MM-dd');
    final newFormat = DateFormat('dd MMM yyyy');

    final dateTime = originalFormat.parse(dueDate);
    return newFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
      ),
      drawer: AppDrawer(drawerItems: _drawerItems),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.0.h, bottom: 12.0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0.w),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0.r),
                          ),
                        ),
                        child: const Text('TODAY'),
                      ),
                      SizedBox(width: 9.w), // Add spacing between buttons
                      OutlinedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: const Text('THIS WEEK'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0.w),
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.r),
                      ),
                    ),
                    child: const Text('FILTER'),
                  ),
                ),
              ],
            ),
          ),
          // ... (button row remains the same)
          SizedBox(height: 10.0.h),
          Expanded(
            child: _taskData == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemBuilder: (context, index) {
                var taskEntry = _taskData![index];
                if (taskEntry != null && taskEntry.containsKey('task')) {
                  var task = taskEntry['task'];
                  if (task != null && task.containsKey('task_title') && task.containsKey('user')) {
                    var taskTitle = task['task_title'] as String?;
                    var userName = task['user']['name'] as String?;

                    return SizedBox(
                      height: 80.h, // Adjust the height as needed
                      child: ListTile(
                        title: Text(
                          taskTitle ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: task['task_status_type_id'] == 1
                                ? Color(int.parse('0xFF${task['task_status_type']['color'].substring(1)}'))
                                : null,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 15.0.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     SizedBox(height: 8.h),
                                    Text(
                                      'Due ${task['due_date'] != null ? 'Due ${formatDueDate(task['due_date'])}' : 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                     SizedBox(height: 4.h),
                                    Text(
                                      'assigned by ${userName ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 38.0.h),
                                child: Transform.translate(
                                  offset: const Offset(0, -8),
                                  child: const Icon(Icons.arrow_forward_ios_rounded),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          _navigateToTaskDetailsScreen(task);
                          print('clicked task : $task');
                        },
                      ),
                    );
                  }
                }
                // If the task data is missing or doesn't match the expected structure
                return SizedBox();
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
                // ... (divider configuration remains the same)
              ),
              itemCount: _taskData!.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToCreateTaskScreen();
        },
        label: const Text('CREATE NEW'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xff018fff),
      ),
    );
  }


  void _navigateToTaskDetailsScreen(dynamic task) async {
    final shouldUpdate = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );

    if (shouldUpdate == true) {
      // Refresh the task data after updating
      fetchTaskData();
    }
  }
  void _navigateToCreateTaskScreen() async {
    final shouldCreate= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTask()),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      fetchTaskData();
    }
  }
}
