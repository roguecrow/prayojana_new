import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20profile/member_profile_edit.dart';
import 'package:prayojana_new/services/api_service.dart';
import 'package:intl/intl.dart';
import '../../../../other_app_navigator.dart';


class MemberProfile extends StatefulWidget {
  const MemberProfile({Key? key, required this.member, required this.memberId}) : super(key: key);

  final Map<String, dynamic> member;
  final int memberId;

  @override
  State<MemberProfile> createState() => _MemberProfileState();
}



class _MemberProfileState extends State<MemberProfile> {
  List<dynamic> memberDetails = []; // Add this line
  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable
  var memberId;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberDetails(widget.memberId);
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  String formatDob(String dob) {
    if (dob == null || dob.isEmpty || dob == 'N/A') return 'N/A';

    try {
      // Split the date string by spaces
      List<String> parts = dob.split(' ');

      // Take the relevant parts: Sat Aug 12 1939
      String formattedDob = '${parts[0]} ${parts[1]} ${parts[2]} ${parts[3]}';

      return formattedDob;
    } catch (e) {
      print('Error parsing date: $e');
      return dob;
    }
  }



  Widget _buildInfoRow(String label, String? value, {double fontSize = 14.0, FontWeight? fontWeight}) {
    return Padding(
      padding: EdgeInsets.all(10.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          value != null && label.toLowerCase() == 'location'
              ? GestureDetector(
            onLongPress: () {
              _copyToClipboard(context, value);
            },
            onTap: () {
              MapUtils.openMap(value);
              print('Location clicked: $value');
            },
            child: Container(
              width: 130.w, // Set a maximum width for the value text
              child: Text(
                value.length > 20 ? '${value.substring(0, 20)}...' : value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
              : label.toLowerCase() == 'mobile' ||
              label.toLowerCase() == 'emergency contact' ||
              label.toLowerCase() == 'alternative mobile' ||
              label.toLowerCase() == 'what\'s app' ||
              label.toLowerCase() == 'landline'
              ? GestureDetector(
            onLongPress: () {
              _copyToClipboard(context, value);
            },
            onTap: () {
              makeCall.makePhoneCall('tel:$value');
            },
            child: Container(
              width: 130.w, // Set a maximum width for the value text
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.blue, // Style it as a link
                  decoration: TextDecoration.underline, // Underline it
                ),
              ),
            ),
          )
              : Container(
            width: 130.w, // Set a maximum width for the value text
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showCustomTopSnackbar(context, '$text] Copied To Clipboard');
  }

  void showCustomTopSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50.0.h,
        left: 16.0.w,
        right: 16.0.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 6.0.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // 50% transparent red
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }



  Future<void> _fetchMemberDetails(memId) async {

    if(memId == 0) {
      memberId = widget.member['id'];
    }
    else {
      memberId = memId;
    }
    print('Clicked Member ID: $memberId');
    List<dynamic>? details = await MemberApi().fetchMemberDetails(memberId);
    if (details != null && details.isNotEmpty) {
      setState(() {
        memberDetails = details;
        isLoading = false;

        for (var clientMember in memberDetails[0]['client_members']) {
          var clientPlans = clientMember['client']['client_plans'];
          if (clientPlans != null && clientPlans.isNotEmpty) {
            for (var clientPlan in clientPlans) {
              planName = clientPlan['plan']['name'];
              print('Plan Name: $planName');
            }
          } else {
            planName = 'No Plan';
            print('No Client Plans');
          }
        }
      });
    } else {
      print('Error fetching member details');
    }
  }



  @override
  Widget build(BuildContext context) {
    _storedContext = context;
    return Scaffold(
      body: isLoading
          ? Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
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
                'Quick Summary',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(10.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Full Name',
                    memberDetails.isNotEmpty && memberDetails[0] != null && memberDetails[0]['name'] != null
                        ? memberDetails[0]['name']
                        : null, // Pass null if the value is not available
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  _buildInfoRow(
                    'Family Name',
                    memberDetails.isNotEmpty &&
                        memberDetails[0]['client_members'] != null &&
                        memberDetails[0]['client_members'][0]['client'] != null
                        ? memberDetails[0]['client_members'][0]['client']['family_name']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Carebuddy name',
                    memberDetails.isNotEmpty &&
                        memberDetails[0]['member_carebuddies'] != null &&
                        memberDetails[0]['member_carebuddies'][0]['user'] != null
                        ? memberDetails[0]['member_carebuddies'][0]['user']['name']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Emergency Contact',
                    memberDetails.isNotEmpty &&
                        memberDetails[0]['emergency_phone_number'] != null
                        ? memberDetails[0]['emergency_phone_number']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'History',
                    memberDetails.isNotEmpty &&
                        memberDetails[0]['medical_history'] != null
                        ? memberDetails[0]['medical_history']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),


            Padding(
        padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Name & DOB',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Salutation',
                    memberDetails.isNotEmpty ? memberDetails[0]['salutation'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Full Name',
                    memberDetails.isNotEmpty ? memberDetails[0]['name'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Gender',
                    memberDetails.isNotEmpty ? memberDetails[0]['gender'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Date Of Birth',
                    formatDob(
                      memberDetails.isNotEmpty &&
                          memberDetails[0]['dob'] != null &&
                          memberDetails[0]['dob'].isNotEmpty
                          ? memberDetails[0]['dob']
                          : 'N/A',
                    ),
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),

            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Contacts',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Mobile',
                    memberDetails.isNotEmpty ? memberDetails[0]['phone'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'What\'s App',
                    memberDetails.isNotEmpty ? memberDetails[0]['whatsapp'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Email',
                    memberDetails.isNotEmpty ? memberDetails[0]['email'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Landline',
                    memberDetails.isNotEmpty ? memberDetails[0]['landline'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Alternative Mobile',
                    memberDetails.isNotEmpty ? memberDetails[0]['alternate_number'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),


            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Address',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Pin',
                    memberDetails.isNotEmpty ? memberDetails[0]['zip'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),

                  Column(
                    children: [
                      _buildInfoRow(
                        'Address',
                        memberDetails.isNotEmpty ? ' ${memberDetails[0]['address1']}, ${memberDetails[0]['address2']}, ${memberDetails[0]['address3']}' : 'N/A',
                        fontSize: 14.0.sp,
                      ),
                    ],
                  ),
                  // _buildInfoRow(
                  //   'Address Line 1',
                  //   memberDetails.isNotEmpty ? memberDetails[0]['address1'] : 'N/A',
                  //   fontSize: 14.0.sp,
                  // ),
                  // _buildInfoRow(
                  //   'Address Line 2',
                  //   memberDetails.isNotEmpty ? memberDetails[0]['address2'] : 'N/A',
                  //   fontSize: 14.0.sp,
                  // ),
                  // _buildInfoRow(
                  //   'Address Line 3',
                  //   memberDetails.isNotEmpty ? memberDetails[0]['address3'] : 'N/A',
                  //   fontSize: 14.0.sp,
                  // ),
                  _buildInfoRow(
                    'Area',
                    memberDetails.isNotEmpty ? memberDetails[0]['area'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'City',
                    memberDetails.isNotEmpty ? memberDetails[0]['city'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  // _buildInfoRow(
                  //   'State',
                  //   memberDetails.isNotEmpty ? memberDetails[0]['state'] : 'N/A',
                  //   fontSize: 14.0.sp,
                  // ),
                  _buildInfoRow(
                    'Location',
                    memberDetails.isNotEmpty ? memberDetails[0]['location'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),

            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Health',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Blood Group',
                    memberDetails.isNotEmpty ? memberDetails[0]['blood_group'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'VITACURO ID',
                    memberDetails.isNotEmpty ? memberDetails[0]['vitacuro_id'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Dependencies',
                    memberDetails.isNotEmpty ? memberDetails[0]['dependencies'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Family Details',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Client Name',
                    memberDetails.isNotEmpty ? memberDetails[0]['client_members'][0]['client']['name'] : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Relationship to Client',
                    memberDetails.isNotEmpty &&
                        memberDetails[0]['client_members'][0]['relationship'] != null &&
                        memberDetails[0]['client_members'][0]['relationship'].isNotEmpty
                        ? memberDetails[0]['client_members'][0]['relationship']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Membership to ID',
                    memberDetails.isNotEmpty && memberDetails[0]['client_members'] != null && memberDetails[0]['client_members'][0]['client'] != null
                        ? memberDetails[0]['client_members'][0]['client']['prid']
                        : 'N/A',
                    fontSize: 14.0.sp,
                  ),
                  _buildInfoRow(
                    'Plan',
                    planName ?? 'N/A',
                    fontSize: 14.0.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: !isLoading, // Show the button only if isLoading is false
        child: FloatingActionButton.extended(
          onPressed: () {
            _navigateToMemberProfileEdit();
          },
          label: const Text('EDIT'),
          icon: const Icon(Icons.edit_outlined),
          backgroundColor: const Color(0xff018fff),
        ),
      ),

    );
  }

  void _navigateToMemberProfileEdit() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberProfile(memberDetails: memberDetails),
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberDetails(memberId);
    }
  }
}






// Padding(
//   padding: EdgeInsets.only(left: 25.0),
//   child: Text(
//     'Notes',
//     style: TextStyle(color: Colors.grey[600]),
//   ),
// ),
// Container(
//   margin: EdgeInsets.all(15.0),
//   padding: EdgeInsets.all(15.0),
//   decoration: BoxDecoration(
//     color: Colors.grey[200],
//     borderRadius: BorderRadius.circular(8),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//   ),
// ),








