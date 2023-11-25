  // ignore_for_file: unnecessary_null_comparison

  import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
import 'package:prayojana_new/screens/interactions%20page/update_interaction_details_new.dart';
import 'package:shared_preferences/shared_preferences.dart';
  import '../../constants.dart';
  import '../../graphql_queries.dart';
  import '../../models/drawer_items.dart';
import '../../services/api_service.dart';


import 'create_new_interaction_new.dart';

  class InteractionScreen extends StatefulWidget {
    const InteractionScreen({super.key});

    @override
    State<InteractionScreen> createState() => _InteractionScreenState();
  }

  class _InteractionScreenState extends State<InteractionScreen> {
    DateTime today = DateTime.now();
    List<Map<String, dynamic>> interactionStatusTypes = []; // Store task status types here
    List<Map<String, dynamic>> taskDueDateTypes = []; // Store task status types here
    Map<int, String> memberMap = {}; // Add this line to store the member names and IDs
    Set<int> selectedStatusIds = {};
    Set<int> selectedMemberIds = {};
    bool isLoading = false;
    bool isTodayButtonPressed = false;
    bool isWeekButtonPressed = false;
    bool isFilterButtonPressed = false;
    final scrollController = ScrollController();
    DateTime fromDate = DateTime.now(); // Initial "from" date
    DateTime toDate = DateTime.now().add(const Duration(days: 7)); // Initial "to" date (7 days from now)
    int page = 1;
    int fetchedLen = 10;
    List<Map<String, dynamic>> roleTypes = [
      {'id': 1, 'name': 'Admin'},
      {'id': 2, 'name': 'Captain'},
      {'id': 4, 'name': 'Carebuddy'},
    ];
    int? roleId;
    late DateTime startOfWeek;
    late DateTime endOfWeek;



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
        interactionMembers = [];
        await fetchInteractionData(null, null, null, null, null, null,null);
      } else {
        print('today');
        interactionMembers = [];
        today = DateTime.now();
        page = 1;
        await fetchInteractionData(today, today, null, page, null, null,roleId);
      }
      updateButtonStates(today: !isTodayButtonPressed, week: false, filter: false);
    }

    void handleWeekButtonPress() async {
      if (isWeekButtonPressed) {
        print('empty 2');
        interactionMembers = [];
        await fetchInteractionData(null, null, null, null, null, null,roleId);
      } else {
        interactionMembers = [];
        print('week');
         startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
         endOfWeek = startOfWeek.add(const Duration(days: 6));
        print(startOfWeek);
        print(endOfWeek);
        page = 1;
        await fetchInteractionData(startOfWeek, endOfWeek, null, page, null, null,roleId);
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
                                          title:  Text('Role',style: TextStyle(color: selectedTileIndex == 3 ?  const Color(0xff006bbf) : null)),
                                          onTap: () {
                                            setState(() {
                                              selectedTileIndex = 3;
                                            });
                                          },
                                          tileColor: selectedTileIndex == 3 ? const Color(0xfff1f9ff) : null,
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
                                  child: selectedTileIndex == 3
                                      ?ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: roleTypes.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(roleTypes[index]['name'] as String),
                                        tileColor: roleId == roleTypes[index]['id'] ? const Color(0xfff1f9ff) : null,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: roleId == roleTypes[index]['id']
                                              ? BorderRadius.circular(10.0) // Adjust the border radius as needed
                                              : BorderRadius.circular(0.0), // No border radius for unselected tiles
                                          side: roleId == roleTypes[index]['id']
                                              ? const BorderSide(color: Colors.blue, width: 1.0) // Border color and width for selected tile
                                              : BorderSide.none, // No border for unselected tiles
                                        ),
                                        onTap: () {
                                          setState(() {
                                            roleId = roleTypes[index]['id'] as int?;
                                            print(roleId);
                                          });
                                        },
                                      );
                                    },
                                  )

                                  : Column(
                                    children: [
                                      Visibility(
                                        visible: selectedTileIndex == 1, // Only show if selectedTileIndex is 1
                                        child: Padding(
                                          padding:  EdgeInsets.only(top: ScreenUtil().screenHeight * 0.20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () => _selectDate(context, true), // Show "from" date picker
                                                child: Text("From: ${formatDate(fromDate)}"),
                                              ),
                                              TextButton(
                                                onPressed: () => _selectDate(context, false), // Show "to" date picker
                                                child: Text("To: ${formatDate(toDate)}"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: selectedTileIndex == 0
                                              ? interactionStatusTypes.length
                                              : selectedTileIndex == 1
                                              ? taskDueDateTypes.length
                                              : memberMap.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            String title;
                                            int itemId;
                                            if (selectedTileIndex == 0) {
                                              title = interactionStatusTypes[index]['name'];
                                              itemId = interactionStatusTypes[index]['id'];
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
                                                      side: BorderSide(
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
                                    ],
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
                                        getRoleIdFromLocal();
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
                                      interactionMembers = [];
                                      page = 1;
                                      await fetchInteractionData(null, null, null, page, selectedStatusIds, selectedMemberIds,roleId);
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

    Future<void> _selectDate(BuildContext context, bool isFrom) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isFrom ? fromDate : toDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != (isFrom ? fromDate : toDate)) {
        setState(() {
          if (isFrom) {
            fromDate = picked;
          } else {
            toDate = picked;
          }
        });
      }
    }


    @override
    void initState() {
      super.initState();
      getRoleIdFromLocal();
      fetchInteractionData(null, null, null, null, null, null,null);
      fetchMemberNames();
      fetchInteractionStatusTypes(); // Fetch task status types when the screen initializes
      scrollController.addListener(_scrollListener);
    }
    List<dynamic>? interactionMembers;


    void fetchMemberNames() async {
      List<dynamic>? membersNames = await MemberApi().getMemberNames();
      if (membersNames != null) {
        memberMap = { for (var item in membersNames) item['id'] : item['name'] };
        setState(() {}); // Update the UI after fetching member names
      }
      print('memberMap  -- $memberMap');
    }

    getRoleIdFromLocal() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      roleId = prefs.getInt('roleId');
      print('roleID from local - $roleId');
    }

    String formatDate(DateTime date) {
      return DateFormat('yyyy-MM-dd').format(date);
    }

    Future<void> fetchInteractionData(from, to, carebuddy, pageNo, statusList, membersList,roleId) async {
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


      List<dynamic>? fetchedData = await InteractionApi().fetchInteractionDataTypes(formattedFrom,formattedTo, null, pageNo,formattedStatus , formattedMember,roleId);
      setState(() {
        interactionMembers = [...?interactionMembers, ...fetchedData!]; // Concatenate the new data
        print('PAGE NO $pageNo - interactionMembers $interactionMembers');
        print('newInteraction - $fetchedData');
        fetchedLen = fetchedData.length;
        print('fetchedLen - $fetchedLen');
      });
      interactionMembers ??= [];
    }


    void fetchInteractionStatusTypes() async {
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
          body: jsonEncode({'query': getInteractionStatusTypesQuery}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            interactionStatusTypes = List<Map<String, dynamic>>.from(data['data']['interaction_status_types']);
          });
          print(interactionStatusTypes);
        } else {
          print('API Error: ${response.reasonPhrase}');
        }
      } catch (error) {
        print('Error fetching task status types: $error');
      }
    }


    String formatDueDate(String? dueDate) {
      if (dueDate == null) {
        return 'N/A'; // Return a default value if date is null
      }

      final originalFormat = DateFormat('yyyy-MM-dd');
      final newFormat = DateFormat('dd MMM yyyy');

      try {
        final dateTime = originalFormat.parse(dueDate);
        return newFormat.format(dateTime);
      } catch (e) {
        print('Error formatting due date: $e');
        return 'N/A'; // Return a default value if formatting fails
      }
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff006bbf),
          title: const Text('Interactions'),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.search,
          //       color: Colors.white,
          //     ),
          //   ),
          // ],
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
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'FILTER',
                        style: TextStyle(color:Color(0xff6b7280)),
                      ),),
                  ),
                ],
              ),
            ),
            Expanded(
              child: interactionMembers == null
                  ? const Center(child: CircularProgressIndicator())
                  : interactionMembers!.isEmpty
                  ?  Center(child: Text('No data to show.',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ))
                  : ListView.separated(
                controller: scrollController ,
                itemCount: interactionMembers!.length,
                separatorBuilder: (context, index) => const Divider(
                  endIndent: 20,
                  indent: 20,
                  thickness: 1,
                  color: Colors.grey,
                ),

                itemBuilder: (context, index) {
                  final interactionMember = interactionMembers?[index];
                  final interaction = interactionMember;
                  int interactionId = interactionMember['id'];
                  final title = interactionMember['title'];
                  final date = interactionMember['interaction_date'];

                  return SizedBox(
                    height: 60.h,
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(20.w,6.h, 16.w, 12.h),
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 8.0.h),
                        child: Text(
                          title ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 10.0.h),
                        child: Text(
                          formatDueDate(date) ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(top: 5.h, right: 2.w),
                        child: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                      onTap: () {
                        print('interactionId - $interactionId');
                        _navigateToInteractionDetailsScreen(interactionId); // Pass the selected interaction data
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _navigateToCreateInteractionScreen();
          },
          label: const Text('CREATE NEW'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xff018fff),
        ),
      );
    }

    void _scrollListener() {
      if (!isLoading && scrollController.position.pixels == scrollController.position.maxScrollExtent && fetchedLen == 10) {
        setState(() {
          isLoading = true; // Set loading state to true
        });
        page = page + 1;
        if(isTodayButtonPressed) {
          fetchInteractionData(today, today, null, page, selectedStatusIds, selectedMemberIds,roleId).then((_) {
            setState(() {
              isLoading = false; // Set loading state to false after data is loaded
            });
          });
        }
        else if(isWeekButtonPressed) {
          fetchInteractionData(startOfWeek, endOfWeek, null, page, selectedStatusIds, selectedMemberIds,roleId).then((_) {
            setState(() {
              isLoading = false; // Set loading state to false after data is loaded
            });
          });
        }
        else {
          fetchInteractionData(null, null, null, page, selectedStatusIds, selectedMemberIds,roleId).then((_) {
            setState(() {
              isLoading = false; // Set loading state to false after data is loaded
            });
          });
        }
      }
    }


    void _navigateToInteractionDetailsScreen(int interactionId) async {
      final shouldUpdate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractionDetailsScreenNew(interactionId: interactionId,),
        ),
      );
      if(shouldUpdate == true) {
        interactionMembers = [];
        selectedStatusIds.clear();
        selectedMemberIds.clear(); // Clear the selected IDs list
        getRoleIdFromLocal();
        isTodayButtonPressed = false;
        isWeekButtonPressed = false;
        print('updated on reload');
        fetchInteractionData(null, null, null, null, null, null, null);
      }
    }


    void _navigateToCreateInteractionScreen() async {
      final shouldCreate= await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateInteractionNew()),
      );
      if (shouldCreate == true) {
        // Refresh the task data after updating
        interactionMembers = [];
        fetchInteractionData(null, null, null, null, null, null, null);
      }
      if (shouldCreate == false) {
        // Refresh the task data after updating
        interactionMembers = [];
        fetchInteractionData(null, null, null, null, null, null, null);
      }
    }
  }
