import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:prayojana_new/graphql_queries.dart';
import '../../../../constants.dart';
import '../../../../services/api_service.dart';

class MemberInterest extends StatefulWidget {
  const MemberInterest({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberInterest> createState() => _MemberInterestState();
}

class _MemberInterestState extends State<MemberInterest> {

  List<dynamic> memberInterestDetails = []; // Add this line
  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable
  List<dynamic> interests = [];
  late bool isActive;
  int selectedInterestTypeId = -1; // Initialize with -1 to represent no selection
  List<Map<String, dynamic>> interestTypes = []; // List to store interest types\
  List<dynamic>? fetchedInterestTypes = [];
  List<int> selectedInterestIds = []; // Step 1: Initialize the list
  List<int> deletedInterestTypeIds = [];
  List<int> savedInterestTypeIds = [];




  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberInterestDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _fetchMemberInterestDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? interestDetails = await MemberApi().fetchMemberInterestDetails(memberId);
    if (interestDetails != null && interestDetails.isNotEmpty) {
      List<dynamic>? memberInterests = interestDetails[0]['interests'];
      List<int> savedIds = memberInterests!.map((interest) => interest['interest_type_id']).cast<int>().toList();

      setState(() {
        memberInterestDetails = interestDetails;
        interests = memberInterests;
        savedInterestTypeIds = savedIds;
        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
    await _fetchInterestTypes(); // Fetch interest types after member interests are fetched

  }




  void _showUndoSnackBar(BuildContext context, dynamic interest, int index, int memberId) {
    final snackBar = SnackBar(
      content: const Text("Interest deleted"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
      ),
      margin: const EdgeInsets.all(10), // Adjust the margin as needed
      behavior: SnackBarBehavior.floating, // Makes the snackbar float above the bottom
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      animation: _snackBarFadeAnimation(), // Use a custom animation
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Undo action
          deletedInterestTypeIds.add(interest['interest_type_id']);
          _insertMemberInterestDetails(deletedInterestTypeIds, memberId);
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Animation<double> _snackBarFadeAnimation() {
    return CurvedAnimation(
      parent: const AlwaysStoppedAnimation(1),
      curve: Curves.easeOut, // Adjust the curve as needed
    );
  }




  Future<void> _fetchInterestTypes() async {
    try {
      fetchedInterestTypes = await MemberApi().fetchInterestDetails();
      if (fetchedInterestTypes != null) {
        fetchedInterestTypes = fetchedInterestTypes!.toSet().toList();

        // Filter out saved interest types
        if (savedInterestTypeIds.isNotEmpty) {
          print(savedInterestTypeIds);
          fetchedInterestTypes!.removeWhere((interestType) {
            return savedInterestTypeIds.contains(interestType['id']);
          });
        }

        print('fetchedInterestTypes  - $fetchedInterestTypes');
      }
    } catch (error) {
      print('Error fetching interest types: $error');
    }
  }


  Future<void> _updateMemberInterestDetails(int interestId) async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, dynamic> updatedMemberData = {
      'id': interestId,
      'isActive': isActive,
    };

    if (updatedMemberData['id'] == null) {
      print('Invalid Id');
      return;
    }

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': updateMemberInterestDetails,
        'variables': updatedMemberData,
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? updatedMemberInterest =
      responseData['data']?['update_interests']?['returning'];

      if (updatedMemberInterest != null) {
        // Print the affected rows

        print('updated data $updatedMemberInterest');
        print('Affected Rows: ${updatedMemberInterest.length}');

        // Update the local data with the new member data here if needed

        // Pop the screen and return the updated member data
        _fetchMemberInterestDetails();
      } else {
        String responseString = response.body;
        print('Response from Server: $responseString'); // Add this line
        print('not updated');
        // Handle the case when the response does not contain updated member data
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
      // Handle the API error and show an error message to the user if needed
    }
  }


  Future<void> _insertMemberInterestDetails(List<int> interestTypeIds, int memberId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': r'''
        mutation InsertInterests($interests: [interests_insert_input!]!) {
          insert_interests(objects: $interests) {
            affected_rows
            returning {
              id
              interest_type_id
              member_id
            }
          }
        }
      ''',
        'variables': {
          'interests': interestTypeIds.map((id) => {'interest_type_id': id, 'is_active': true, 'member_id': memberId}).toList(),
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? insertedInterests = responseData['data']?['insert_interests']?['returning'];

      if (insertedInterests != null) {
        // Print the affected rows
        print('Inserted data $insertedInterests');
        print('Affected Rows: ${insertedInterests.length}');

        // Update the local data with the new member data here if needed

        _fetchMemberInterestDetails();
        interestTypeIds.clear();
      } else {
        String responseString = response.body;
        print('Response from Server: $responseString'); // Add this line
        print('not inserted');
        // Handle the case when the response does not contain inserted member data
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
      // Handle the API error and show an error message to the user if needed
    }
  }




  void _showInterestDetails(BuildContext context, dynamic interest, int interestId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Interest Details',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Divider(
                  height: 30.0,
                  thickness: 1,
                ),
                ListTile(
                  leading: const Icon(Icons.interests),
                  title: const Text('Interest Type'),
                  subtitle: Text(interest['interest_type']['name'] ?? 'N/A'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        isActive = false;
                        await _updateMemberInterestDetails(interestId);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _insertInterestType() {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Interest',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Divider(
                          height: 30.0,
                          thickness: 1,
                        ),
                        Container(
                          height: 200.h,
                          width: 250.h,
                          padding: EdgeInsets.all(10.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: fetchedInterestTypes != null && fetchedInterestTypes!.isNotEmpty
                                ? Wrap(
                              spacing: 8.0.w,
                              runSpacing: 8.0.w,
                              children: fetchedInterestTypes!.map((interestType) {
                                final id = interestType['id'];
                                final isSelected = selectedInterestIds.contains(id);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedInterestIds.remove(id);
                                      } else {
                                        selectedInterestIds.add(id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 10.0.h),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue[200] : Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded( // Added Expanded here
                                          child: Text(
                                            interestType['name'],
                                            style: TextStyle(fontSize: 16.sp),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                        if (isSelected) const Icon(Icons.check, color: Colors.blue),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                                : Padding(
                              padding: EdgeInsets.only(top: 80.h),
                              child: Center(
                                child: Text('No interests available...', style: TextStyle(fontSize: 16.sp)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0.h),
                    child: OutlinedButton.icon(
                      onPressed: selectedInterestIds.isNotEmpty
                          ? () async {
                        List<int> uniqueInterestIds = selectedInterestIds.toSet().toList();
                        await _insertMemberInterestDetails(uniqueInterestIds, widget.member['id']);

                        // Clear selectedInterestIds after inserting
                        setState(() {
                          selectedInterestIds.clear();
                        });
                        Navigator.pop(context);
                      }
                          : null, // Disable button if selectedInterestIds is empty
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),
                        backgroundColor: selectedInterestIds.isNotEmpty ? const Color(0xff006bbf) : Colors.grey,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0.r),
                        ),
                      ),
                      icon:  Icon(Icons.add, size: 16.sp,color: Colors.white,),
                      label: const Text(
                        'Interest',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
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
  Widget build(BuildContext context) {
    _storedContext = context;
    return Scaffold(
      body: isLoading
          ? const Center(
        child:  SizedBox(
          height: 50,
          width: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulseSync, /// Required, The loading type of the widget
            colors: [Color(0xff006bbf)],       /// Optional, The color collections
          ),
        ),
      )
          : Scrollbar(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 20,),
            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Interest Type',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: ScreenUtil().screenHeight / 1.0.h,
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Scrollbar(
                child: interests.isEmpty
                    ? Center(
                  child: Text(
                    'No Interests available',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    dynamic interest = interests[index];
                    return Slidable(
                      key: ValueKey(interest['id']),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () async {
                          isActive = false;
                          await _updateMemberInterestDetails(interest['id']); // Show snackbar on delete
                          // ignore: use_build_context_synchronously
                          _showUndoSnackBar(context, interest, index, widget.member['id']);
                        }),
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.circular(10.0.r),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            onPressed: (BuildContext context) async {
                              isActive = false;
                              await _updateMemberInterestDetails(interest['id']); // Show snackbar on delete
                              // ignore: use_build_context_synchronously
                              _showUndoSnackBar(context, interest, index, widget.member['id']);
                            },
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          _showInterestDetails(context, interest, interest['id']);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0.1,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              interest['interest_type']['name'] ?? 'N/A',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 12.0.h,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: !isLoading, // Show the button only if isLoading is false
        child: FloatingActionButton.extended(
          onPressed: () {
            _insertInterestType();
          },
          label: const Text('NEW'),
          icon: const Icon(Icons.create),
          backgroundColor: const Color(0xff018fff),
        ),
      ),
    );
  }
}
