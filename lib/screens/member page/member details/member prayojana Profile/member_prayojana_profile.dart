import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../services/api_service.dart';
import '../member profile/member_profile_edit.dart';

class MemberPrayojanaProfile extends StatefulWidget {

  const MemberPrayojanaProfile({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;


  @override
  State<MemberPrayojanaProfile> createState() => _MemberPrayojanaProfileState();
}

class _MemberPrayojanaProfileState extends State<MemberPrayojanaProfile> {

  List<dynamic> memberPrayojanaProfileDetails = []; // Add this line
  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable
  List<dynamic> planHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildInfoRow(String label, dynamic value, {double fontSize = 14.0, FontWeight? fontWeight}) {
    return Padding(
      padding: EdgeInsets.all(10.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          value is Widget
              ? value
              : Text(
            value ?? 'N/A',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      ),
    );
  }



  Future<void> _fetchMemberDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? planDetails = await MemberApi().fetchMemberPrayojanaProfileDetails(memberId);
    if (planDetails != null && planDetails.isNotEmpty) {
      List<dynamic>? clientPlanHistories = planDetails[0]['client_members'][0]['client']['client_plan_histories'];
      if (clientPlanHistories != null) {
        setState(() {
          memberPrayojanaProfileDetails = planDetails;
          planHistory = clientPlanHistories;
          print(memberPrayojanaProfileDetails);
          print('PlanHistory - $planHistory');
          isLoading = false;
        });
      } else {
        print('client_plan_histories is null');
      }
    } else {
      print('Error fetching member details');
    }
  }



  void _showPlanHistoryInfo(BuildContext context, dynamic planhistory) {
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
                  'Details',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Divider(
                  height: 30.0,
                  thickness: 1,
                ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.playlist_add_check_rounded),
                          title: const Text('Plan'),
                          subtitle: Text(
                            planhistory != null &&
                                planhistory['plan'] != null &&
                                planhistory['plan']['name'] != null
                                ? planhistory['plan']['name']
                                : 'N/A',
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.date_range),
                          title: const Row(
                            children: [
                              Text('Start Date'),
                              Spacer(), // Add a spacer to push the End Date to the right
                              Text('End Date'),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(planhistory['start_date'] ?? 'N/A'),
                              const Spacer(), // Add a spacer to push the End Date to the right
                              Text(planhistory['end_date'] ?? 'N/A'),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.date_range),
                          title: const Row(
                            children: [
                              Text('Plan Amount'),
                              Spacer(), // Add a spacer to push the End Date to the right
                              Text('Amount Paid'),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(planhistory['plan_amount']?.toString() ?? 'N/A'),
                              const Spacer(), // Add a spacer to push the End Date to the right
                              Text(planhistory['amount_paid']?.toString() ?? 'N/A'),
                            ],
                          ),
                        ),

                        ListTile(
                          leading: const Icon(Icons.date_range),
                          title: const Text('Payment Date'),
                          subtitle: Text(planhistory['payment_date'] ?? 'N/A'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.type_specimen),
                          title: const Text('Payment Type'),
                          subtitle: Text(planhistory['payment_type'] ?? 'N/A'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: const Text('Payment ID & Link'),
                          subtitle: Text('${planhistory['payment_id']} - ${planhistory['link']}' ?? 'N/A'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
                'Client Details',
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
                      'Salutation',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['salutation'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['salutation']
                          : 'N/A',
                      fontSize: 16.0.sp,
                    ),

                    _buildInfoRow(
                      'Full Name',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['name'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['name']
                          : 'N/A',
                      fontSize: 16.0.sp,
                    ),

                    _buildInfoRow(
                      'Gender',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['gender'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['gender']
                          : 'N/A',
                      fontSize: 14.0.sp,
                    ),

                    _buildInfoRow(
                      'Date Of Birth',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['dob'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['dob']
                          : 'N/A',
                      fontSize: 14.0.sp,
                    ),

                    _buildInfoRow(
                      'PRID',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['prid'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['prid']
                          : 'N/A',
                      fontSize: 14.0.sp,
                    ),

                    _buildInfoRow(
                      'Family Name',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['family_name'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['family_name']
                          : 'N/A',
                      fontSize: 14.0.sp,
                    ),

                    _buildInfoRow(
                      'Carebuddy Names',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: memberPrayojanaProfileDetails.isNotEmpty &&
                            memberPrayojanaProfileDetails[0]['member_carebuddies'] != null
                            ? memberPrayojanaProfileDetails[0]['member_carebuddies']
                            .map<Widget>((carebuddy) {
                          final userName = carebuddy['user'] != null && carebuddy['user']['name'] != null
                              ? carebuddy['user']['name']
                              : 'N/A';  // note this do not empty carebuddy name

                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.0.h), // Add some bottom padding
                            child: Text(
                              userName,
                              style: TextStyle(fontSize: 14.0.sp),
                            ),
                          );
                        }).toList()
                            : [const Text('N/A')],
                      ),
                      fontSize: 14.0.sp,
                    ),

                    _buildInfoRow(
                      'Status',
                      memberPrayojanaProfileDetails.isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['client_statuses'] != null && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['client_statuses'].isNotEmpty && memberPrayojanaProfileDetails[0]['client_members'][0]['client']['client_statuses'][0]['client_status_type'] != null
                          ? memberPrayojanaProfileDetails[0]['client_members'][0]['client']['client_statuses'][0]['client_status_type']['name']
                          : 'N/A',
                      fontSize: 14.0.sp,
                    ),
                  ],
              ),
            ),


            Padding(
              padding:  EdgeInsets.only(left: 22.0.w),
              child: Text(
                'Plan History',
                style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 250.0.h, // Set a fixed height
              margin: EdgeInsets.all(10.0.h),
              padding: EdgeInsets.all(8.0.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0.r),
              ),
              child: Scrollbar(
                child: planHistory.isEmpty
                    ? Center(
                  child: Text(
                    'No Plan History available',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
                    :ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: planHistory.length,
                  itemBuilder: (context, index) {
                    dynamic planhistory = planHistory[index];
                    final planName = planhistory['plan'] != null ? planhistory['plan']['name'] : 'N/A';

                    return InkWell(
                      onTap: () {
                        _showPlanHistoryInfo(context, planhistory);
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
                            planName ?? 'N/A',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 12.0.h,
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
    );
  }
  void _navigateToMemberProfileEdit() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberProfile(memberDetails: memberPrayojanaProfileDetails),
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberDetails();
    }
  }
}


