import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prayojana_new/screens/user_profile/edit_user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {


  final Map<String, dynamic> userDetails;

  const ProfilePage({Key? key, required this.userDetails}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> userDetails = [];
  int? userId;
  String userName = '';
  String firstLetter = '';


  @override
  void initState() {
    super.initState();
    //print(widget.userDetails);
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     userId = prefs.getInt('userId')!;
     print(userId);

    try {
      String accessToken = await getFirebaseAccessToken();

      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': getUserProfile(userId!), // Use the updateUserProfile function
          'variables': {'userId': userId},
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        setState(() {
          userDetails = List<Map<String, dynamic>>.from(data['data']['users']);
           userName = userDetails[0]['name'];
           firstLetter = userName[0];
        });
         print('userDetails - $userDetails');
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }


  Widget buildLabelValueWidget(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.h, bottom: 8.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align label to the left, value to the right
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w), // Add some space between label and value
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: const Color(0xfff1f9ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Profile'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _navigateToUpdateProfile();
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: userDetails.isNotEmpty ?
      Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 50.w,
                    //backgroundImage: const AssetImage('assets/profile_placeholder.png'),
                    // You can replace this with the actual profile photo URL
                    child: Center(child: Text(firstLetter,style: TextStyle(fontSize: 50.sp),)),
                  ),
                  Text(
                    userDetails[0]['name'], // Access the name from userDetails
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0.h),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color:  const Color(0xfff1f9ff),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Date of Birth', userDetails[0]['people'][0]['dob'] ?? 'No Info'), // Accessing Date of Birth
                                buildLabelValueWidget('City', userDetails[0]['people'][0]['city'] ?? 'No Info'), // Accessing City
                                buildLabelValueWidget('Country', userDetails[0]['people'][0]['country'] ?? 'No Info'), // Accessing Country
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color: const  Color(0xfff1f9ff),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Email', userDetails[0]['people'][0]['email'] ?? 'No Info'), // Accessing Email
                                buildLabelValueWidget('Phone Number', userDetails[0]['mobile_number'] ?? 'No Info'), // Accessing Phone Number
                                buildLabelValueWidget('What\'sApp Number', userDetails[0]['people'][0]['whatsapp'] ?? 'No Info'), // Accessing WhatsApp Number
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  void _navigateToUpdateProfile() async {
    final shouldUpdate= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserProfile(userDetails: userDetails,),),
    );

    if (shouldUpdate == true) {
      loadUserData();
    }
  }
}
