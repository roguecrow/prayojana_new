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

  @override
  void initState() {
    super.initState();
    _fetchInterestTypes();
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
      setState(() {
        memberInterestDetails = interestDetails;
        interests = memberInterests!;
        print(interests);
        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }



  void _showUndoSnackBar(BuildContext context, dynamic interest, int index, int memberId) {
    final snackBar = SnackBar(
      content: Text("Interest deleted"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
      ),
      margin: EdgeInsets.all(10), // Adjust the margin as needed
      behavior: SnackBarBehavior.floating, // Makes the snackbar float above the bottom
      duration: Duration(seconds: 2), // Adjust the duration as needed
      animation: _snackBarFadeAnimation(), // Use a custom animation
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Undo action
          _insertMemberInterestDetails(interest['interest_type_id'], memberId);
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
      if(fetchedInterestTypes != null){
        fetchedInterestTypes = fetchedInterestTypes!.toSet().toList();
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


  Future<void> _insertMemberInterestDetails(int interestTypeId , int memberId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic> {
        'query': r'''
        mutation MyMutation($interestTypeId: Int!, $memberId: Int!) {
          insert_interests(objects: {interest_type_id: $interestTypeId, is_active: true, member_id: $memberId}) {
            affected_rows
            returning {
              id
              interest_type_id
              is_active
              member_id
            }
          }
        }
      ''',
        'variables': {
          'interestTypeId': interestTypeId,
          'memberId': memberId,
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

        // Pop the screen and return the updated member data
        _fetchMemberInterestDetails();
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {
                //         Navigator.pop(context);
                //       },
                //       child: const Text('Cancel'),
                //     ),
                //     ElevatedButton(
                //       onPressed: () async {
                //         isActive = false;
                //         await _updateMemberInterestDetails(interestId);
                //         Navigator.pop(context);
                //       },
                //       child: const Text('Delete'),
                //     ),
                //   ],
                // ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: ScreenUtil().screenHeight / 1.5.h,
          padding: const EdgeInsets.all(16),
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
              selectedInterestTypeId != null
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fetchedInterestTypes
                          ?.firstWhere(
                            (type) => type['id'] == selectedInterestTypeId,
                        orElse: () => {'name': 'Unknown'},
                      )['name'] ??
                          'Unknown',
                      style: TextStyle(color: Colors.white),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       selectedInterestTypeId = -1;
                    //     });
                    //   },
                    //   icon: Icon(
                    //     Icons.close,
                    //     color: Colors.white,
                    //     size: 16,
                    //   ),
                    // ),
                  ],
                ),
              )
                  : SizedBox.shrink(),
              DropdownButtonFormField2(
                value: selectedInterestTypeId,
                items: fetchedInterestTypes?.map((interestType) {
                  return DropdownMenuItem(
                    value: interestType['id'],
                    child: Text(interestType['name']),
                  );
                }).toList() ??
                    [],
                // Rest of your code...
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 60.0.h),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _insertMemberInterestDetails(
                          selectedInterestTypeId, widget.member['id']);
                      Navigator.pop(context);
                    },
                    child: const Text('Create Interest'),
                  ),
                ),
              ),
            ],
          ),
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

