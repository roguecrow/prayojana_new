import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
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
  List<Map<String, dynamic>> medicalCentersList = [];
  String? selectedMedicalCenterId;
  late int medicalCentersId = 0; // Or whatever initial value makes sense in your application


  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable

  @override
  void initState() {
    super.initState();
    fetchMedicalCenterIds();
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



  Future fetchMedicalCenterIds() async {
    String accessToken = await getFirebaseAccessToken();
    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': medicalCenterIds,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> medicalCenters = responseData['data']['medical_centers'];

      for (var center in medicalCenters) {
        medicalCentersList.add({'id': center['id'], 'name': center['name']});
      }

      print('MEDICAL CENTER - $medicalCentersList');

    } else {
      throw Exception('Failed to load medical center IDs');
    }
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
        print('SelectedmedicalcentersId - $medicalCentersId');
        print('MEDICAL CENTERS - $medicalCenters');
        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }

  void _showUpdateSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message,style: GoogleFonts.inter(),),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
      ),
      margin: const EdgeInsets.all(10), // Adjust the margin as needed
      behavior: SnackBarBehavior.floating, // Makes the snackbar float above the bottom
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      animation: _snackBarFadeAnimation(), // Use a custom animation
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Animation<double> _snackBarFadeAnimation() {
    return CurvedAnimation(
      parent: const AlwaysStoppedAnimation(1),
      curve: Curves.easeOut, // Adjust the curve as needed
    );
  }


  Future<void> _updateMemberMedicalCenterDetails(int id, int memberId, int medicalCenterId) async {
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
        'query': updateMemberMedicalCenterDetails,
        'variables': {
          'id': id,
          'member_id': memberId,
          'medical_center_id': medicalCenterId,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['update_member_medical_center']['affected_rows'];
      print(affectedRows);
      print(responseString);

      if (affectedRows > 0) {
        // Data successfully updated
        _fetchMemberHealthDetails();
        Navigator.pop(context, true);
        print('Data updated successfully');
        // ignore: use_build_context_synchronously
        _showUpdateSnackBar(context, "Medical Center updated successfully");

      } else {
        // Data update failed
        print('Failed to update data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }



  void _showDoctorInfo(BuildContext context, dynamic doctor) {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
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
               Divider(
                height: 12.0.h,
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
                    constraints: const BoxConstraints(
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


  void _editMedicalCenter(BuildContext context, dynamic center) {
    print('centers - $center');
    medicalCentersId = center['id'];
    print(medicalCentersId);
    selectedMedicalCenterId = center['medical_center']['id'].toString();
    print(center['medical_center']);
    print(selectedMedicalCenterId);
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      isScrollControlled: true, // Allow the sheet to take up the full screen height
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  'Edit Medical Center',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Divider(
                  height: 12.0.h,
                  thickness: 1,
                ),
                // Add a DropdownButtonFormField for editing
                Padding(
                  padding: EdgeInsets.only(bottom: 100.0.h, top: 12.h),
                  child: DropdownButtonFormField2<String>(
                    value: selectedMedicalCenterId, // Set the selected value based on your logic
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMedicalCenterId = newValue;
                        print('updated selectedMedicalCenterId - $selectedMedicalCenterId');
                      });
                    },
                    items: medicalCentersList
                        .map<DropdownMenuItem<String>>((Map<String, dynamic> center) {
                      return DropdownMenuItem<String>(
                        value: center['id'].toString(), // Use the ID as the value
                        child: Text(
                          center['name'],
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 150.h,
                     // width: 300.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      label: const Text('Select Medical Center'),
                      hintText: 'Select Medical Center',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
               // const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0.h),
                  child: ElevatedButton(
                    onPressed: () {
                      _updateMemberMedicalCenterDetails(medicalCentersId,widget.member['id'],int.parse(selectedMedicalCenterId!));
                      // Add logic to handle the edit operation
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Change the text color
                      minimumSize: const Size(double.maxFinite, 50), // Set the button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r), // Adjust the border radius as needed
                      ),
                      elevation: 3, // Add some shadow
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  void _showMedicalCenterInfo(BuildContext context, dynamic center) {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
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
                    onPressed: ()  {
                      print('Edit Note Button Pressed'); // Add this line
                      _editMedicalCenter(context, center);
                    },
                    icon: const Icon(Icons.edit_note),
                  ),

                ],
              ),
               Divider(
                height: 12.0.h,
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
                if (memberHealthDetails.isEmpty)
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

