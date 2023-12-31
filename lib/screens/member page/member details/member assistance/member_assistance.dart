import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20assistance/member_assistance_edit.dart';
import 'package:prayojana_new/screens/member%20page/member%20details/member%20assistance/member_assistance_new.dart';

import '../../../../services/api_service.dart';

class MemberAssistance extends StatefulWidget {

  const MemberAssistance({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;


  @override
  State<MemberAssistance> createState() => _MemberAssistanceState();
}

class _MemberAssistanceState extends State<MemberAssistance> {
  List<dynamic> memberAssistanceDetails = []; // Add this line
  List<dynamic> assistances = []; // Add this line

  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable



  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberAssistanceDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _fetchMemberAssistanceDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? assistanceDetails = await MemberApi().fetchMemberAssistanceDetails(memberId);
    if (assistanceDetails != null && assistanceDetails.isNotEmpty) {
      List<dynamic> assistanceList = assistanceDetails[0]['member_assistances'];
      print('assistanceList - $assistanceList');

      setState(() {
        memberAssistanceDetails = assistanceDetails;
        assistances = assistanceList;
        print('memberAssistanceDetails - $memberAssistanceDetails');

        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }


  void _showAssistanceInfo(BuildContext context, dynamic assistance) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left: 12.0.h),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                     await _navigateToEditPage(context, assistance);
                     Navigator.pop(context);
                      // Add your edit logic here
                    },
                    icon: const Icon(Icons.edit_note),
                  ),
                ],
              ),
              Divider(
                height: 12.0.h, // Reduced height of the divider
                thickness: 1,
              ),
              SizedBox( // Wrap the SingleChildScrollView with a SizedBox to limit its height
                height: 280.0.h, // Adjust the height as needed
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Name'),
                        subtitle: Text(assistance['name'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Location'),
                        subtitle: Text(assistance['location'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(assistance['phone'] ?? 'N/A'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Relation'),
                        subtitle: Text(assistance['relation'] ?? 'N/A' ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.emergency),
                        title: const Text('Is Emergency Access'),
                        trailing: assistance['is_emergency'] == true
                            ? const Icon(Icons.check, color: Colors.green) // Display green checkmark
                            : const Icon(Icons.close, color: Colors.red), // Display red 'x'
                      ),
                      ListTile(
                        leading: const Icon(Icons.accessibility),
                        title: const Text('is Proxy Access'),
                        trailing: assistance['is_proxy_access'] == true
                            ? const Icon(Icons.check, color: Colors.green) // Display green checkmark
                            : const Icon(Icons.close, color: Colors.red), // Display red 'x'
                      ),
                    ],
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
          : ListView(
        physics: const BouncingScrollPhysics(),
        children: [
           SizedBox(height: 20.h,),
          Padding(
            padding:  EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Assistance Members',
              style: TextStyle(color: Colors.grey[600], fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height:ScreenUtil().screenHeight/1.25, // Set a fixed height
            margin:  EdgeInsets.all(10.0.h),
            padding:  EdgeInsets.all(10.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Scrollbar(
              child: assistances.isEmpty
                  ? Center(
                child: Text(
                  'No assistance information available',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assistances.length,
                itemBuilder: (context, index) {
                  dynamic assistance = assistances[index];
                  return InkWell(
                    onTap: () {
                      _showAssistanceInfo(context, assistance);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(
                         assistance['name'] ?? 'N/A',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing:  Icon(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToMemberAssistanceCreate();
        },
        label: const Text('NEW'),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: const Color(0xff018fff),
      ),

    );
  }
  void  _navigateToMemberAssistanceCreate() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMemberAssistance(memberId: widget.member['id']), // Pass memberId
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberAssistanceDetails();
    }
  }

  Future<void> _navigateToEditPage(BuildContext context, dynamic assistance) async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberAssistanceEdit(assistance: assistance),
      ),
    );
    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberAssistanceDetails();
    }
  }
}
