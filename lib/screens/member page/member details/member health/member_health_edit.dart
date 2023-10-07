import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
import '../../../../services/api_service.dart';

class EditMemberHealth extends StatefulWidget {
  final List<dynamic> memberHealthDetails;

  const EditMemberHealth({Key? key, required this.memberHealthDetails}) : super(key: key);

  @override
  State<EditMemberHealth> createState() => _EditMemberHealthState();
}

class _EditMemberHealthState extends State<EditMemberHealth> {
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController vitacuroIdController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController historyController = TextEditingController();
  final TextEditingController insureController = TextEditingController();
  final TextEditingController policyNumberController = TextEditingController();
  final TextEditingController validTillController =  TextEditingController();
  final TextEditingController agentNameController = TextEditingController();
  final TextEditingController agentNumberController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.memberHealthDetails != null) {
      print(widget.memberHealthDetails[0]['id']);
      print(widget.memberHealthDetails);
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
    if (widget.memberHealthDetails.isNotEmpty) {
      setState(() {

        bloodGroupController.text = widget.memberHealthDetails[0]['blood_group'] ?? '';
        vitacuroIdController.text = widget.memberHealthDetails[0]['vitacuro_id'] ?? '';
        dobController.text = widget.memberHealthDetails[0]['dob'] ?? '';
        historyController.text = widget.memberHealthDetails[0]['medical_history'] ?? '';
        insureController.text = widget.memberHealthDetails[0]['member_insurances'][0]['insurer'] ?? '';
        policyNumberController.text = widget.memberHealthDetails[0]['member_insurances'][0]['policy_number'] ?? '';
        validTillController.text = widget.memberHealthDetails[0]['member_insurances'][0]['valid_till'] ?? '';
        agentNameController.text = widget.memberHealthDetails[0]['member_insurances'][0]['agent_name'] ?? '';
        agentNumberController.text = widget.memberHealthDetails[0]['member_insurances'][0]['agent_number'] ?? '';

      });
    } else {
      print('Error fetching member details');
    }
  }


  Future<void> _updateMemberInsuranceDetails() async {
    String accessToken = await getFirebaseAccessToken();

    if (widget.memberHealthDetails == null || widget.memberHealthDetails.isEmpty) {
      print('Error: memberHealthDetails is null or empty');
      return;
    }

    final Map<String, dynamic> updatedMemberData = {
      'memberId': widget.memberHealthDetails[0]['id'],
      'insurer': insureController.text,
      'policyNumber': policyNumberController.text,
      'validTill': validTillController.text,
      'agentName': agentNameController.text,
      'agentNumber': agentNumberController.text,
    };

    if (updatedMemberData['memberId'] == null) {
      print('Invalid memberId');
      return;
    }

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': updateMemberInsurancesDetails,
        'variables': updatedMemberData,
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? updatedMember =
      responseData['data']?['update_members']?['returning'];

      if (updatedMember != null) {
        // Print the affected rows

        print('updated data $updatedMember');
        print('Affected Rows: ${updatedMember.length}');

        // Update the local data with the new member data here if needed

        // Pop the screen and return the updated member data
        Navigator.pop(context, true);
        _fetchMemberHealthDetails();
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



  Future<void> _updateMemberHealthDetails() async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, dynamic> updatedMemberData = {
      'memberId': widget.memberHealthDetails[0]['id'],
      'bloodGroup': bloodGroupController.text,
      'vitacuroId': vitacuroIdController.text,
      'medicalHistory': historyController.text,
      'dob': dobController.text,
    };

    if (updatedMemberData['memberId'] == null) {
      print('Invalid memberId');
      return;
    }

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': updateMemberHealthDetails,
        'variables': updatedMemberData,
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? updatedMember =
      responseData['data']?['update_members']?['returning'];

      if (updatedMember != null) {
        // Print the affected rows

        print('updated data $updatedMember');
        print('Affected Rows: ${updatedMember.length}');

        // Update the local data with the new member data here if needed

        // Pop the screen and return the updated member data
        Navigator.pop(context, true);
        _fetchMemberHealthDetails();
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



  Widget buildInfoRow(String title, Widget content) {
    return Row(
      children: [
        Container(
          width: 120.w, // Adjust this width as needed
          padding: EdgeInsets.only(left: 20.0.w,top: 15.0.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 200.w, // Adjust this width as needed
            padding: EdgeInsets.only(top: 15.0.h),
            child: content,
          ),
        ),
      ],
    );
  }

  void _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.0.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25.0.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Padding(
                        padding: EdgeInsets.only(left: 16.12.w, top: 12.0.h),
                        child: Icon(
                          Icons.close,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0.w, top: 20.0.h),
                      child: ElevatedButton(
                        onPressed: () {
                          _updateMemberHealthDetails();
                          _updateMemberInsuranceDetails();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0.w, right: 16.0.w),
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    buildInfoRow(
                      'Blood Group',
                      DropdownButtonFormField2<String>(
                        value: bloodGroupController.text.isNotEmpty ? bloodGroupController.text : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            bloodGroupController.text = newValue ?? '';
                          });
                        },
                        items: <String>['A+ve', 'B+ve', 'O+ve', 'AB+ve', 'A-ve', 'B-ve', 'O-ve', 'AB-ve']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200.h,
                          width: 200.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    buildInfoRow( 'Vitacuro ID',TextFormField(
                      controller: vitacuroIdController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Date Of Birth',TextFormField(
                      controller: dobController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, dobController); // Function to open date picker
                      },
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),),
                    buildInfoRow( 'History',TextFormField(
                      controller: historyController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Insure',TextFormField(
                      controller: insureController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Policy Number',TextFormField(
                      controller: policyNumberController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Valid Till',TextFormField(
                      controller: validTillController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, validTillController); // Function to open date picker
                      },
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),),
                    buildInfoRow( 'Agent Name',TextFormField(
                      controller: agentNameController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Agent Number',TextFormField(
                      controller: agentNumberController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    // buildInfoRow( 'Card',TextFormField(
                    //   controller: address1Controller, // Attach the TextEditingController
                    //   style: TextStyle(
                    //     fontSize: 14.sp,
                    //   ),
                    //   maxLines: null, // Allow multiple lines of input
                    //   decoration: InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //   ),
                    // ),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
