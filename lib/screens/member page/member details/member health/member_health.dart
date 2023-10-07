import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../services/api_service.dart';
import '../member profile/member_profile_edit.dart';
import 'member_health_edit.dart';

class MemberHealth extends StatefulWidget {
  const MemberHealth({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberHealth> createState() => _MemberHealthState();
}

class _MemberHealthState extends State<MemberHealth> {
  List<dynamic> memberHealthDetails = []; // Add this line
  List<dynamic> doctors = []; // Add this line
  List<dynamic> medicalCenters = []; // Add this line


  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberHealthDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _fetchMemberHealthDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? healthDetails = await MemberApi().fetchMemberHealthDetails(memberId);
    if (healthDetails != null && healthDetails.isNotEmpty) {
      setState(() {
        memberHealthDetails = healthDetails;
        doctors = memberHealthDetails[0]['member_doctors'] ?? [];
        medicalCenters = memberHealthDetails[0]['member_medical_centers'] ?? [];
        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }


  void _showDoctorInfo(BuildContext context, dynamic doctor) {
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
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: Text(doctor['doctor']['name']),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Mobile Number'),
                subtitle: Text(doctor['doctor']['mobile_number']),
              ),
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Notes'),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100, // Adjust the maximum height as needed
                    ),
                    child: Text(doctor['doctor']['notes']),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Address'),
                subtitle: Text(doctor['doctor']['doctor_addresses'][0]['address']),
              ),
            ],
          ),
        );
      },
    );
  }


  void _showMedicalCenterInfo(BuildContext context, dynamic center) {
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
              ListTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text('Medical Center Name'),
                subtitle: Text(center['medical_center']['name'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(center['medical_center']['phone'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Address'),
                subtitle: Text(center['medical_center']['address'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.type_specimen),
                title: const Text('Type'),
                subtitle: Text(center['medical_center']['medical_center_type']['name'] ?? 'N/A'),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding:  EdgeInsets.all(10.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 14.0.sp),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.0.sp),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      )
          : ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Health Information',
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
                _buildInfoRow('Blood Group', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['blood_group'] != null ? memberHealthDetails[0]['blood_group'] : 'N/A'),
                _buildInfoRow('Vitacuro ID', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['vitacuro_id'] != null ? memberHealthDetails[0]['vitacuro_id'] : 'N/A'),
                _buildInfoRow('Date Of Birth', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['dob'] != null ? memberHealthDetails[0]['dob'] : 'N/A'),
                _buildInfoRow('History', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['medical_history'] != null ? memberHealthDetails[0]['medical_history'] : 'N/A'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Text(
              'Doctors',
              style: TextStyle(color: Colors.grey[600], fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 200.0.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Scrollbar(
              child: doctors.isEmpty
                  ? Center(
                child: Text(
                  'No doctors information available',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  dynamic doctor = doctors[index];
                  return InkWell(
                    onTap: () {
                      _showDoctorInfo(context, doctor);
                    },
                    splashColor: Colors.blue,
                    highlightColor: Colors.blue,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                      child: ListTile(
                        title: Text(
                          doctor['doctor']['name'] ?? 'N/A',
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
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Medical Centers',
              style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 200.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Scrollbar(
              child: medicalCenters.isEmpty
                  ? Center(
                child: Text(
                  'No medical center information available',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: medicalCenters.length,
                itemBuilder: (context, index) {
                  dynamic center = medicalCenters[index];
                  return InkWell(
                    onTap: () {
                      _showMedicalCenterInfo(context, center);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          center['medical_center']['name'] ?? 'N/A',
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
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Insurance',
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
                _buildInfoRow('Insure', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['insurer'] : 'N/A'),
                _buildInfoRow('Policy Number', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['policy_number'] : 'N/A'),
                _buildInfoRow('Valid Till', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['valid_till'] : 'N/A'),
                _buildInfoRow('Agent Name', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['agent_name'] : 'N/A'),
                _buildInfoRow('Agent Number', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['agent_number'] : 'N/A'),
                if (memberHealthDetails.isEmpty || memberHealthDetails[0]['member_insurances'] == null || memberHealthDetails[0]['member_insurances'].isEmpty)
                  Center(
                    child: Text(
                      'No insurance information available.',
                      style: TextStyle(fontSize: 14.0.sp),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !isLoading, // Show the button only if isLoading is false
        child: FloatingActionButton.extended(
          onPressed: () {
            _navigateToMemberHealthEdit();
          },
          label: const Text('EDIT'),
          icon: const Icon(Icons.edit_outlined),
          backgroundColor: const Color(0xff018fff),
        ),
      ),
    );
  }


  void  _navigateToMemberHealthEdit() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberHealth(memberHealthDetails: memberHealthDetails),
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberHealthDetails();
    }
  }
}

