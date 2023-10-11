import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
import '../../../../services/api_service.dart';

class MemberAssistanceEdit extends StatefulWidget {
  final dynamic assistance; // Add a field to hold the assistance data

  MemberAssistanceEdit({Key? key, required this.assistance}) : super(key: key);

  @override
  State<MemberAssistanceEdit> createState() => _MemberAssistanceEditState();
}


class _MemberAssistanceEditState extends State<MemberAssistanceEdit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  bool isEmergencyAccess = false;
  bool isProxyAccess = false;

  @override
  void initState() {
    super.initState();
    fetchAssistanceDetails();
    print('Assistance : ${widget.assistance}');
    print(widget.assistance['id'],);
  }

  @override
  void dispose() {
    super.dispose();
  }


  void fetchAssistanceDetails() {
    // Assuming that 'assistance' is a Map<String, dynamic>
    nameController.text = widget.assistance['name'] ?? '';
    phoneController.text = widget.assistance['phone'] ?? '';
    locationController.text = widget.assistance['location'] ?? '';
    relationController.text = widget.assistance['relation'] ?? '';
    isEmergencyAccess = widget.assistance['is_emergency'] ?? false;
    isProxyAccess = widget.assistance['is_proxy_access'] ?? false;
  }


  Future<void> _updateMemberAssistanceDetails() async {
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
        'query': updateMemberAssistanceDetails,
        'variables': {
          'id': widget.assistance['id'], // Replace with the ID of the member assistance you want to update
          'name': nameController.text,
          'phone': phoneController.text,
          'relation': relationController.text,
          'is_emergency': isEmergencyAccess,
          'is_proxy_access': isProxyAccess,
          'location': locationController.text,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['update_member_assistances']['affected_rows'];

      if (affectedRows > 0) {
        Navigator.pop(context, true);
        // Data successfully updated
        print('Data updated successfully');
      } else {
        // Data update failed
        print('Failed to update data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }




  Widget buildInfoRow(String title, Widget content) {
    return Padding(
      padding:  EdgeInsets.only(top: 10.0.h),
      child: Row(
        children: [
          Container(
            width: 120.w, // Adjust this width as needed
            padding: EdgeInsets.only(left: 20.0.w, top: 15.0.h),
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
          ), // Add some horizontal space between title and content
          Expanded(
            child: Container(
              width: 200.w, // Adjust this width as needed
              padding: EdgeInsets.only(top: 15.0.h, left: 10.0), // Add some left padding for content
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  void checkField() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        locationController.text.isEmpty ||
        relationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Missing Information"),
            content: const Text("Please fill in all fields."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _updateMemberAssistanceDetails();
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
                          checkField();
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
                    buildInfoRow( 'Name',TextFormField(
                      controller: nameController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        hintText: 'Enter Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Phone',TextFormField(
                      controller: phoneController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      keyboardType: TextInputType.phone, // Set keyboardType to number
                      decoration: InputDecoration(
                        hintText: 'Enter Number',
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
                        hintText: 'Enter Location',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Relation',TextFormField(
                      controller: relationController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        hintText: 'Enter Relation',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    SizedBox(height: 20.h,),
                    Container(
                      decoration: BoxDecoration(
                        color:  Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 16.0.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Emergency Access',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Switch(
                                value: isEmergencyAccess,
                                onChanged: (value) {
                                  setState(() {
                                    isEmergencyAccess = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h,),
                    Container(
                      decoration: BoxDecoration(
                        color:  Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0.r),
                      ),
                      child: Padding(
                        padding:  EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 16.0.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Proxy Access',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Switch(
                                value: isProxyAccess,
                                onChanged: (value) {
                                  setState(() {
                                    isProxyAccess = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
