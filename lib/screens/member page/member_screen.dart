import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:prayojana_new/graphql_queries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../models/drawer_items.dart';
import 'package:http/http.dart' as http;

import '../../models/member_drawer.dart';
import '../../services/api_service.dart';
import 'member details/member profile/member_profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<dynamic>? _membersData;
  bool isLoading = false;
  bool isFilterButtonPressed = false;
  final scrollController = ScrollController();
  DateTime fromDate = DateTime.now(); // Initial "from" date
  DateTime toDate = DateTime.now().add(const Duration(days: 7)); // Initial "to" date (7 days from now)
  int page = 1;
  int fetchedLen = 10;
  Set<int> selectedStatusIds = {};
  Set<int> selectedPlanIds = {};
  List selectedCities = [];
  List<Map<String, dynamic>> memberStatusTypes = []; // Store task status types here
  List<Map<String, dynamic>> localityTypes = []; // Store task status types here
  List<Map<String, dynamic>>  planTypes = []; // Add this line to store the member names and IDs
  List<Map<String, dynamic>> roleTypes = [
    {'id': 1, 'name': 'Admin'},
    {'id': 2, 'name': 'Captain'},
    {'id': 4, 'name': 'Carebuddy'},
  ]; // Example list of role types
  int? roleId;



  Color getButtonColor(bool isPressed) =>
      isPressed ? const Color(0xff6b7280) : Colors.transparent;

  Color getButtonTextColor(bool isPressed) =>
      isPressed ? Colors.white : const Color(0xff6b7280);

  void updateButtonStates({
    bool filter = false,
  }) {
    setState(() {
      isFilterButtonPressed = filter;
    });
  }



  void handleFilterButtonPress() {
    updateButtonStates(filter: !isFilterButtonPressed);
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
                                      title:  Text('Locality',style: TextStyle(color: selectedTileIndex == 1 ?  const Color(0xff006bbf) : null)),
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = 1;
                                        });
                                      },
                                      tileColor: selectedTileIndex == 1 ? const Color(0xfff1f9ff) : null,
                                    ),
                                    ListTile(
                                      title:  Text('Plans',style: TextStyle(color: selectedTileIndex == 2 ?  const Color(0xff006bbf) : null)),
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = 2;
                                        });
                                      },
                                      tileColor: selectedTileIndex == 2 ? const Color(0xfff1f9ff) : null,
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
                                    Expanded(
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: selectedTileIndex == 0
                                            ? memberStatusTypes.length
                                            : selectedTileIndex == 1
                                            ? localityTypes.length
                                            : planTypes.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          String title;
                                          int? itemId; // Make itemId nullable

                                          if (selectedTileIndex == 0) {
                                            title = memberStatusTypes[index]['name'];
                                            itemId = memberStatusTypes[index]['id'];
                                          } else if (selectedTileIndex == 1) {
                                            title = localityTypes[index]['city'];
                                          } else {
                                            title = planTypes[index]['name'];
                                            itemId = planTypes[index]['id'];
                                          }

                                          return ListTile(
                                            title: Row(
                                              children: [
                                                Checkbox(
                                                  value: selectedTileIndex == 0
                                                      ? selectedStatusIds.contains(itemId)
                                                      : selectedTileIndex == 1
                                                      ? selectedCities.contains(title)
                                                      : selectedPlanIds.contains(itemId!),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        if (selectedTileIndex == 0) {
                                                          selectedStatusIds.add(itemId!);
                                                          print('selectedStatusIds - $selectedStatusIds');
                                                        } else if (selectedTileIndex == 1) {
                                                          selectedCities.add(title);
                                                          print('selectedCities - $selectedCities');
                                                        } else {
                                                          selectedPlanIds.add(itemId!);
                                                          print('selectedPlanIds - $selectedPlanIds');
                                                        }
                                                      } else {
                                                        if (selectedTileIndex == 0) {
                                                          selectedStatusIds.remove(itemId!);
                                                          print('removedStatusIds - $selectedStatusIds');
                                                        } else if (selectedTileIndex == 1) {
                                                          selectedCities.remove(title);
                                                          print('removedCities - $selectedCities');
                                                        } else {
                                                          selectedPlanIds.remove(itemId!);
                                                          print('removedPlanIds - $selectedPlanIds');
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
                                      selectedPlanIds.clear(); // Clear the selected IDs list
                                      selectedCities.clear();
                                      getRoleIdFromLocal();
                                      print('clearedCities - $selectedCities');
                                      print('clearedStatus - $selectedStatusIds');
                                      print('clearedMemberIds - $selectedPlanIds');
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
                                    _membersData = [];
                                    page = 1;
                                    await fetchMembersData(roleId,null, page,selectedStatusIds,selectedPlanIds,selectedCities);
                                    // ignore: use_build_context_synchronously
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



  Future<void> _navigateToMemberDetails(Map<String, dynamic> member) async {
    final updatedMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDrawer(member: member), // Pass the member data here
      ),
    );

    if (updatedMember != null) {
      final index = _membersData!.indexWhere((item) => item['id'] == updatedMember['id']);
      if (index != -1) {
        setState(() {
          _membersData![index] = updatedMember;
          selectedStatusIds.clear();
          selectedPlanIds.clear(); // Clear the selected IDs list
          selectedCities.clear();
          getRoleIdFromLocal();
        });
      }
    }
  }


  Future<void> openFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Dialog'),
          content: const Text('Your filter dialog content goes here'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getRoleIdFromLocal();
    fetchMembersData(null,null,null,null,null,null);
    fetchMemberStatusTypes();
    fetchPlanTypes();
    fetchLocality();
    scrollController.addListener(_scrollListener);
  }
  getRoleIdFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    roleId = prefs.getInt('roleId');
    print('roleID from local - $roleId');
  }


  Future<void> fetchMembersData(roleId,carebuddy , pageNo, statusList, plans, locality) async {
    var formattedLocality, formattedStatus , formattedPlans;

    if (statusList != null) {
      formattedStatus = statusList.join(',') ;
    }
    if (locality != null) {
      formattedLocality = locality.join(',');
    }
    if (plans != null) {
      formattedPlans = plans.join(',');
    }
    // Instantiate MemberApi
    MemberApi memberApi = MemberApi();

    // Fetch members data
    List<dynamic>? members = await memberApi.fetchMembersData(roleId , null, pageNo,formattedStatus,formattedPlans,formattedLocality);

    setState(() {
      _membersData = [...?_membersData, ...members!]; // Concatenate the new data
      print('PAGE NO $pageNo - _memberData $_membersData');
      print('newMembers - $members');
      fetchedLen = members.length;
      print('fetchedLen - $fetchedLen');
    });
    _membersData ??= [];
  }


  void fetchMemberStatusTypes() async {
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
        body: jsonEncode({'query': getMemberStatusTypesQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          memberStatusTypes = List<Map<String, dynamic>>.from(data['data']['member_status_types']);
        });
        print('memberStatusTypes - $memberStatusTypes');
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }

  void fetchPlanTypes() async {
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
        body: jsonEncode({'query': getPlansQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          planTypes = List<Map<String, dynamic>>.from(data['data']['plans']);
        });
        print('planTypes - $planTypes');
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }


  void fetchLocality() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.localityUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          localityTypes = List<Map<String, dynamic>>.from(data['data']);
        });
        print('localityTypes - $localityTypes');
      } else {
        print('API Error: ${response.reasonPhrase}');
        print(response.body);
        print(response.statusCode);
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: const Color(0xff006bbf),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.search,
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
        shadowColor: const Color(0xff006bbf),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.0.h,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
            child: _membersData == null
                ? const Center(child: CircularProgressIndicator())
                : _membersData!.isEmpty
                ? Center(
              child: Text(
                'There are no members.',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : ListView.builder(
              controller: scrollController ,
              itemCount: _membersData!.length,
              itemBuilder: (context, index) {
                final member = _membersData![index];
                final memberName = member['name'] ?? 'Name not available';
                final planName = member['plan_name'] ?? '';
                final nameParts = memberName.split(' ');
                final memberLastName = nameParts.length > 1 ? nameParts.last : memberName;
                final planColor = member['plan_color'] ?? '';
                final mstName = member['mst_name'] ?? '';
                final mstColor = member['status_color'] ?? '';
                final familyName = member['family_name'] ?? memberLastName;
               // print('Familyname - $familyName');

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(30.w, 12.h, 16.w, 12.h), // Adjust left padding
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 15.0.h),
                        child: Row(
                          children: [
                            Text(
                              familyName == '' ? memberLastName : familyName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.0.w),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 4.0.h),
                                    decoration: BoxDecoration(
                                      color: planColor != null && planColor.isNotEmpty
                                          ? Color(int.parse(planColor.replaceAll("#", "0xFF")))
                                          : Colors.transparent, // Use transparent color if planColor is null or empty
                                      borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                                    ),
                                    child: Text(
                                      planName,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w,),
                                  Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 4.0.h),
                                    decoration: BoxDecoration(
                                      color: mstColor != null && mstColor.isNotEmpty
                                          ? Color(int.parse(mstColor.replaceAll("#", "0xFF")))
                                          : Colors.transparent, // Use transparent color if planColor is null or empty
                                      borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                                    ),
                                    child: Text(
                                      mstName,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style:  TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff01508e),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToMemberDetails(member);
                      },
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        fetchedLen == 10 ) { // Check if filter is not applied
      setState(() {
        isLoading = true; // Set loading state to true
      });
      page = page + 1;
      fetchMembersData(roleId,null, page,selectedStatusIds,selectedPlanIds,selectedCities).then((_) {
        setState(() {
          isLoading = false; // Set loading state to false after data is loaded
        });
      });
    }
  }

}

