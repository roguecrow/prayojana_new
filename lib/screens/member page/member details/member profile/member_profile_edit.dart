import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
import '../../../../services/api_service.dart';

class EditMemberProfile extends StatefulWidget {
  final List<dynamic> memberDetails;

  const EditMemberProfile({Key? key, required this.memberDetails}) : super(key: key);

  @override
  State<EditMemberProfile> createState() => _EditMemberProfileState();
}

class _EditMemberProfileState extends State<EditMemberProfile> {
  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable
  String selectedGender = '';
  String selectedSalutation = ''; // Add this variable to store the selected value
  final TextEditingController nameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController emContactController = TextEditingController();
  final TextEditingController historyController = TextEditingController();
  final TextEditingController salutationController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController =  TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController whatsAppController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController landLineController = TextEditingController();
  final TextEditingController alternativeNoController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController address3Controller = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController vitacureIdController = TextEditingController();
  final TextEditingController dependenciesController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController relationToClient = TextEditingController();
  final TextEditingController memberShipIDController = TextEditingController();
  final TextEditingController planController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.memberDetails != null) {
      print(widget.memberDetails[0]['id']);
      print(widget.memberDetails);
      _fetchMemberDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchMemberDetails() async {
    if (widget.memberDetails.isNotEmpty) {
      setState(() {

        for (var clientMember in widget.memberDetails[0]['client_members']) {
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
        nameController.text = widget.memberDetails[0]['name'] ?? '';
        familyNameController.text = widget.memberDetails[0]['client_members'][0]['client']['family_name'] ?? '';
        emContactController.text = widget.memberDetails[0]['emergency_phone_number'] ?? '';
        historyController.text = widget.memberDetails[0]['medical_history'] ?? '';
        salutationController.text = widget.memberDetails[0]['salutation'] ?? '';
        genderController.text = widget.memberDetails[0]['gender'] ?? '';
        dobController.text = widget.memberDetails[0]['dob'] ?? '';
        mobileController.text = widget.memberDetails[0]['phone'] ?? '';
        whatsAppController.text = widget.memberDetails[0]['whatsapp'] ?? '';
        emailController.text = widget.memberDetails[0]['email'] ?? '';
        landLineController.text = widget.memberDetails[0]['landline'] ?? '';
        alternativeNoController.text = widget.memberDetails[0]['alternate_number'] ?? '';
        pinCodeController.text = widget.memberDetails[0]['zip'] ?? '';
        address1Controller.text = widget.memberDetails[0]['address1'] ?? '';
        address2Controller.text = widget.memberDetails[0]['address2'] ?? '';
        address3Controller.text = widget.memberDetails[0]['address3'] ?? '';
        areaController.text = widget.memberDetails[0]['area'] ?? '';
        cityController.text = widget.memberDetails[0]['city'] ?? '';
        stateController.text = widget.memberDetails[0]['state'] ?? '';
        locationController.text = widget.memberDetails[0]['location'] ?? '';
        bloodGroupController.text = widget.memberDetails[0]['blood_group'] ?? '';
        vitacureIdController.text = widget.memberDetails[0]['vitacuro_id'] ??'';
        dependenciesController.text = widget.memberDetails[0]['dependencies'] ?? '';
        clientNameController.text = widget.memberDetails[0]['client_members'][0]['client']['name'] ?? '';
        relationToClient.text = widget.memberDetails[0]['client_members'][0]['relationship'] ?? '';
        memberShipIDController.text = widget.memberDetails[0]['client_members'][0]['client']['prid'] ?? '';
        planController.text = planName ?? '';

      });
    } else {
      print('Error fetching member details');
    }
  }

  Future<void> _updateMemberDetails() async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, dynamic> updatedMemberData = {
      'memberId': widget.memberDetails[0]['id'],
      'newName': nameController.text,
      'emergencyPhoneNumber': emContactController.text,
      'medicalHistory': historyController.text,
      'salutation': salutationController.text,
      'gender': genderController.text,
      'dob': dobController.text,
      'phone': mobileController.text,
      'whatsapp': whatsAppController.text,
      'email': emailController.text,
      'landline': landLineController.text,
      'alternateNumber': alternativeNoController.text,
      'zip': pinCodeController.text,
      'address1': address1Controller.text,
      'address2': address2Controller.text,
      'address3': address3Controller.text,
      'area': areaController.text,
      'city': cityController.text,
      'state': stateController.text,
      'location': locationController.text,
      'bloodGroup': bloodGroupController.text,
      'vitacuroId': vitacureIdController.text,
      'dependencies': dependenciesController.text,
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
        'query': updateMemberDetails,
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
        _fetchMemberDetails();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dobController) {
      setState(() {
        dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Scrollbar(
        child: SingleChildScrollView(
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
                            _updateMemberDetails();
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
                      buildInfoRow( 'Full Name',TextFormField(
                        controller: nameController, // Attach the TextEditingController
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
                      buildInfoRow( 'Emergency Contact',TextFormField(
                        controller: emContactController, // Attach the TextEditingController
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
                      buildInfoRow('Salutation', DropdownButtonFormField2<String>(
                        value: salutationController.text.isNotEmpty ? salutationController.text : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            salutationController.text = newValue ?? '';
                          });
                        },
                        items: <String>['Mr.','Mrs.', 'Ms.', 'Master.', 'Baby.', 'Dr.', 'Prof.Dr.', 'B/O.', 'D/O.',]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),),
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
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      )),
                  buildInfoRow('Gender', DropdownButtonFormField2<String>(
                    value: genderController.text.isNotEmpty ? genderController.text : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        genderController.text = newValue ?? '';
                      });
                    },
                    items: <String>['Male', 'Female', 'Others']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
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
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    validator: (String? value) {
                      if (value != null && !['Male', 'Female', 'Others'].contains(value)) {
                        return 'Invalid gender';
                      }
                      return null;
                    },
                  ),),
                      buildInfoRow( 'Date Of Birth',TextFormField(
                        controller: dobController,
                        readOnly: true,
                        onTap: () {
                          _selectDate(context); // Function to open date picker
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
                      buildInfoRow(
                        'Mobile',
                        TextFormField(
                          controller: mobileController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(14), // Limit to 14 characters
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only numbers
                          ],
                          style: TextStyle(fontSize: 14.sp),
                          maxLines: null,
                          keyboardType: TextInputType.phone,
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
                      buildInfoRow( 'What\'s App',TextFormField(
                        controller: whatsAppController, // Attach the TextEditingController
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
                      buildInfoRow( 'Email',TextFormField(
                        controller: emailController, // Attach the TextEditingController
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
                      buildInfoRow( 'Landline',TextFormField(
                        controller: landLineController, // Attach the TextEditingController
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
                      buildInfoRow( 'Alternative Number',TextFormField(
                        controller: alternativeNoController, // Attach the TextEditingController
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
                      buildInfoRow( 'Pin Code',TextFormField(
                        controller: pinCodeController, // Attach the TextEditingController
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
                      buildInfoRow( 'Address Line 1',TextFormField(
                        controller: address1Controller, // Attach the TextEditingController
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
                      buildInfoRow( 'Address Line 2',TextFormField(
                        controller: address2Controller, // Attach the TextEditingController
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
                      buildInfoRow( 'Address Line 3',TextFormField(
                        controller: address3Controller, // Attach the TextEditingController
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
                      buildInfoRow( 'Area',TextFormField(
                        controller: areaController, // Attach the TextEditingController
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
                      buildInfoRow( 'City',TextFormField(
                        controller: cityController, // Attach the TextEditingController
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
                      buildInfoRow( 'State',TextFormField(
                        controller: stateController, // Attach the TextEditingController
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
                      buildInfoRow( 'Location',TextFormField(
                        controller: locationController, // Attach the TextEditingController
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
                      buildInfoRow( 'VITACURO ID',TextFormField(
                        controller: vitacureIdController, // Attach the TextEditingController
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
                      buildInfoRow( 'Dependencies',TextFormField(
                        controller: dependenciesController, // Attach the TextEditingController
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
