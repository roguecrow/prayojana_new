// ignore_for_file: avoid_init_to_null

import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:prayojana_new/constants.dart';
import 'package:http/http.dart' as http;
import 'package:prayojana_new/screens/tasks%20page/update_task_details_new.dart';
import 'package:prayojana_new/services/api_service.dart';
import '../../graphql_queries.dart';
import '../../models/drawer_items.dart';
import 'create_new_task_new.dart';


class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic>? _taskData;
  DateTime today = DateTime.now();
  List<Map<String, dynamic>> taskStatusTypes = []; // Store task status types here
  List<Map<String, dynamic>> taskDueDateTypes = []; // Store task status types here
  Map<int, String> memberMap = {}; // Add this line to store the member names and IDs
  Set<int> selectedStatusIds = {};
  Set<int> selectedMemberIds = {};
  bool isLoading = false;
  DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  late DateTime endOfWeek;
  bool isTodayButtonPressed = false;
  bool isWeekButtonPressed = false;
  bool isFilterButtonPressed = false;

  Color getButtonColor(bool isPressed) =>
      isPressed ? const Color(0xff6b7280) : Colors.transparent;

  Color getButtonTextColor(bool isPressed) =>
      isPressed ? Colors.white : const Color(0xff6b7280);

  void updateButtonStates({
    bool today = false,
    bool week = false,
    bool filter = false,
  }) {
    setState(() {
      isTodayButtonPressed = today;
      isWeekButtonPressed = week;
      isFilterButtonPressed = filter;
    });
  }

  void handleTodayButtonPress() async {
    if (isTodayButtonPressed) {
      print('empty 1');
      await fetchTaskData(null, null, null, null, null, null);
    } else {
      print('today');
      DateTime today = DateTime.now();
      await fetchTaskData(today, today, null, null, null, null);
    }
    updateButtonStates(today: !isTodayButtonPressed, week: false, filter: false);
  }

  void handleWeekButtonPress() async {
    if (isWeekButtonPressed) {
      print('empty 2');
      await fetchTaskData(null, null, null, null, null, null);
    } else {
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      print('week');
      await fetchTaskData(startOfWeek, endOfWeek, null, null, null, null);
    }
    updateButtonStates(today: false, week: !isWeekButtonPressed, filter: false);
  }

  // Define a set to store the selected item IDs




  void handleFilterButtonPress() {
    updateButtonStates(today: false, week: false, filter: !isFilterButtonPressed);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        int selectedTileIndex = 2; // Track the index of the selected tile

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: ScreenUtil().screenHeight * 0.75,
                  child: Padding(
                    padding: EdgeInsets.all(10.0.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.0.w, bottom: 8.h),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 2,
                              child: Container(
                                height: ScreenUtil().screenHeight * 0.75 - 120.0.h,
                                //width: 120.0.w,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.transparent),
                                    right: BorderSide(color: Color(0xFFB5B8BF), width: 1.0),
                                    top: BorderSide(color: Colors.transparent),
                                    bottom: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    ListTile(
                                      title:  Text('Status',style: TextStyle(color: selectedTileIndex == 0 ?  const Color(0xff006bbf) : null),),
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = 0;
                                        });
                                      },
                                      tileColor: selectedTileIndex == 0 ? const Color(0xfff1f9ff) : null,
                                    ),
                                    ListTile(
                                      title:  Text('Due Date',style: TextStyle(color: selectedTileIndex == 1 ?  const Color(0xff006bbf) : null)),
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = 1;
                                        });
                                      },
                                      tileColor: selectedTileIndex == 1 ? const Color(0xfff1f9ff) : null,
                                    ),
                                    ListTile(
                                      title:  Text('Members',style: TextStyle(color: selectedTileIndex == 2 ?  const Color(0xff006bbf) : null)),
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = 2;
                                        });
                                      },
                                      tileColor: selectedTileIndex == 2 ? const Color(0xfff1f9ff) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              color: Colors.black,
                              thickness: 2.0,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 3,
                              child: SizedBox(
                                height: ScreenUtil().screenHeight * 0.75 - 120.0.h,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: selectedTileIndex == 0
                                      ? taskStatusTypes.length
                                      : selectedTileIndex == 1
                                      ? taskDueDateTypes.length
                                      : memberMap.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    String title;
                                    int itemId;
                                    if (selectedTileIndex == 0) {
                                      title = taskStatusTypes[index]['name'];
                                      itemId = taskStatusTypes[index]['id'];
                                    } else if (selectedTileIndex == 1) {
                                      title = taskDueDateTypes[index]['name'];
                                      itemId = taskDueDateTypes[index]['id'];
                                    } else {
                                      title = memberMap.values.toList()[index];
                                      itemId = memberMap.keys.toList()[index];
                                    }
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Checkbox(
                                            value: selectedTileIndex == 0
                                                ? selectedStatusIds.contains(itemId)
                                                : selectedMemberIds.contains(itemId),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  if (selectedTileIndex == 0) {
                                                    selectedStatusIds.add(itemId);
                                                    print('selectedStatusIds - $selectedStatusIds');
                                                  } else if (selectedTileIndex == 2) {
                                                    selectedMemberIds.add(itemId);
                                                    print('selectedMemberIds - $selectedMemberIds');
                                                  }
                                                } else {
                                                  if (selectedTileIndex == 0) {
                                                    selectedStatusIds.remove(itemId);
                                                    print('removedStatusIds - $selectedStatusIds');
                                                  } else if (selectedTileIndex == 2) {
                                                    selectedMemberIds.remove(itemId);
                                                    print('removedMemberIds - $selectedMemberIds');
                                                  }
                                                }
                                              });
                                            },
                                            activeColor: const Color(0xff7fd9b2),
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0.r),
                                              side:  BorderSide(
                                                color: const Color(0xffd1d5db),
                                                width: 1.0.w,
                                              ),
                                            ),
                                          ),
                                          Text(title),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            width: ScreenUtil().screenWidth,
                            height: 100.h,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFB5B8BF), // Border color
                                  width: 1.0, // Border width
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedStatusIds.clear();
                                      selectedMemberIds.clear(); // Clear the selected IDs list
                                      print('clearedStatus - $selectedStatusIds');
                                      print('clearedMemberIds - $selectedMemberIds');
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    minimumSize: Size(80.w, 30.0.h), // Set your custom width and height
                                  ),
                                  child: Text('CLEAR', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    print('apply');
                                    await fetchTaskData(null, null, null, null, selectedStatusIds, selectedMemberIds);
                                    Navigator.pop(context); // Close the bottom sheet
                                    // Handle apply button press
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(80.w, 30.0.h), // Set your custom width and height
                                  ),
                                  child: Text('Apply',style: TextStyle(fontSize:14.sp)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    print('inistaste');
    fetchTaskData(null, null, null, null, null, null);
    fetchMemberNames();
    _fetchTaskStatusTypes(); // Fetch task status types when the screen initializes
  }

  void fetchMemberNames() async {
    List<dynamic>? membersNames = await MemberApi().getMemberNames();
    if (membersNames != null) {
      memberMap = { for (var item in membersNames) item['id'] : item['name'] };
      setState(() {}); // Update the UI after fetching member names
    }
    print('memberMap  -- $memberMap');
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> fetchTaskData(from, to, carebuddy, pageNo, statusList, membersList) async {
    var formattedFrom = null, formattedTo= null;
    // ignore: prefer_typing_uninitialized_variables
    var formattedMember, formattedStatus;
    if(from != null && to!= null) {
      print('task 1');
      formattedFrom = formatDate(from);
      formattedTo = formatDate(to);
    }
    if(statusList != null) {
      formattedStatus = statusList.join(',');
    }
    if (membersList != null) {
      formattedMember = membersList.join(',');
    }


    List<dynamic>? newTasks = await MemberApi().fetchTaskMembersData(formattedFrom,formattedTo, null, null,formattedStatus , formattedMember);
    setState(() {
      _taskData = newTasks;
    });

    _taskData ??= [];

  }

  void _fetchTaskStatusTypes() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getTaskStatusTypesQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          taskStatusTypes = List<Map<String, dynamic>>.from(data['data']['task_status_types']);
        });
        print(taskStatusTypes);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
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
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0.w),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: handleTodayButtonPress,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0.r),
                          ),
                          backgroundColor: getButtonColor(isTodayButtonPressed),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(color: getButtonTextColor(isTodayButtonPressed)),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      OutlinedButton(
                        onPressed: handleWeekButtonPress,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          backgroundColor: getButtonColor(isWeekButtonPressed),
                        ),
                        child: Text(
                          'THIS WEEK',
                          style: TextStyle(color: getButtonTextColor(isWeekButtonPressed)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0.w),
                  child: OutlinedButton(
                    onPressed: handleFilterButtonPress,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.r),
                      ),
                      backgroundColor: getButtonColor(isFilterButtonPressed),
                    ),
                    child: Text(
                      'FILTER',
                      style: TextStyle(color: getButtonTextColor(isFilterButtonPressed)),
                    ),),
                ),
              ],
            ),
          ),
          Expanded(
            child: _taskData == null
                ? const Center(child: CircularProgressIndicator())
                : _taskData!.isEmpty
                ? const Center(child: Text('No data to show.'))
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                  var taskEntry = _taskData![index];
                  if (taskEntry != null &&
                      taskEntry.containsKey('task_title')) {
                    var taskTitle = taskEntry['task_title'];
                    var dueDate = taskEntry['due_date'];
                    var taskStatusType = taskEntry['tst_name'];
                    var spName = taskEntry['sp_name'];
                    var statusColor = taskEntry['tst_color'];
                    var taskId = taskEntry['id'];

                    return SizedBox(
                      height: 80.h, // Adjust the height as needed
                      child: ListTile(
                        title: Text(
                          taskTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: taskStatusType == 'Over due'
                                ? Color(int.parse('0xFF${statusColor.substring(1)}'))
                                : Colors.black,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 15.0.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              Text(
                                'Due ${formatDueDate(dueDate)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Assigned to: $spName',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing:  Padding(
                          padding: EdgeInsets.only(top: 20.0.h,right: 8.w),
                          child: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                        onTap: () {
                          _navigateToTaskDetailsScreen(taskId);
                          //TaskApi().getTaskDetails(taskId);
                        },

                      ),
                    );
                  }
                // If the task data is missing or doesn't match the expected structure
                return const SizedBox();
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
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


  void _navigateToTaskDetailsScreen(int taskId) async {
    print(taskId);
    final shouldUpdate= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  NewTaskDetailsScreen(taskId: taskId)),
    );
    if (shouldUpdate == true) {
      if(selectedMemberIds.isNotEmpty || selectedStatusIds.isNotEmpty){
        fetchTaskData(null, null, null, null, selectedStatusIds, selectedMemberIds);
      }
      else {
        fetchTaskData(null,null, null, null, null, null);
      }
      // Refresh the task data after updating
    }
  }
  void _navigateToCreateTaskScreen() async {
    final shouldCreate= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskNew()),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      fetchTaskData(null,null, null, null, null, null);
    }
  }
}

