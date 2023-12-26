import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class EditUserProfile extends StatefulWidget {
  final List<dynamic> userDetails;

  const EditUserProfile({Key? key, required this.userDetails}) : super(key: key);

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    print(widget.userDetails);
  }
  final TextEditingController dobController = TextEditingController();
  final TextEditingController wPhoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  int? userId;


  Future<void> fetchUserDetails() async {
    // Assuming that 'assistance' is a Map<String, dynamic>
    setState(() {
      dobController.text = widget. userDetails[0]['people'][0]['dob']  ?? '';
      wPhoneController.text = widget.userDetails[0]['people'][0]['whatsapp']  ?? '';
      cityController.text = widget.userDetails[0]['people'][0]['city'] ?? '';
      countryController.text = widget.userDetails[0]['people'][0]['country'] ?? '';
      emailController.text = widget.userDetails[0]['people'][0]['email'] ?? '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    print(userId);
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

  Future<void> _updateUserDetails() async {
      if (dobController.text.isEmpty ||
          cityController.text.isEmpty ||
          countryController.text.isEmpty ||
          emailController.text.isEmpty ||
          wPhoneController.text.isEmpty) {
        // Show a dialog box indicating that all fields are required
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Required Fields'),
              content: Text('Please fill in all the required fields.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
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
        'query': updatePeopleMutation, // Using the updated mutation query
        'variables': {
          'userId': userId, // Replace with the ID of the user you want to update
          'dob': dobController.text, // Assuming dobController contains the updated value
          'city': cityController.text, // Assuming cityController contains the updated value
          'country': countryController.text, // Assuming countryController contains the updated value
          'email': emailController.text, // Assuming emailController contains the updated value
          'whatsapp': wPhoneController.text, // Assuming whatsappController contains the updated value
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['update_people']['affected_rows'];

      if (affectedRows > 0) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
        // Data successfully updated
        print('Data updated successfully');
        print(response.body);
      } else {
        // Data update failed
        print('Failed to update data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
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
                          _updateUserDetails();
                          //checkField();
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
                    SizedBox(height: 25.h),
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
                    buildInfoRow( 'WhatsApp Number',TextFormField(
                      controller: wPhoneController, // Attach the TextEditingController
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
                    buildInfoRow( 'City',TextFormField(
                      controller: cityController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        hintText: 'Enter City',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Country',TextFormField(
                      controller: countryController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        hintText: 'Enter Country',
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
                        hintText: 'Enter Email',
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
    );
  }
}
