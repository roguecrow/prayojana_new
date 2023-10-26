import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {


  final Map<String, dynamic> userDetails;

  const ProfilePage({Key? key, required this.userDetails}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  Widget buildLabelValueWidget(String label, String value) {
    return Padding(
      padding:  EdgeInsets.only(top:8.0.h,bottom: 8.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style:  TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h,),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                value,
                style:  TextStyle(
                  fontSize: 16.sp,
                ),
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
      ),
      body: Padding(
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
                    backgroundImage: const AssetImage('assets/profile_placeholder.png'),
                   // You can replace this with the actual profile photo URL
                  ),
                  Text(
                    widget.userDetails['data']['name'],
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding:  EdgeInsets.only(top: 20.0.h),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                      children: [
                        Text(
                          'Personal Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color:  Color(0xfff1f9ff), // Set your desired color
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Date of Birth', widget.userDetails['data']['dob'] ?? 'No Info'),
                                buildLabelValueWidget('City', widget.userDetails['data']['city']  ?? 'No Info'),
                                buildLabelValueWidget('Country', widget.userDetails['data']['Country'] ?? 'No Info'),
                                buildLabelValueWidget('City', widget.userDetails['data']['city']  ?? 'No Info'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                      children: [
                        Text(
                          'Contact Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color: const  Color(0xfff1f9ff), // Set your desired color
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Email', widget.userDetails['data']['email'] ?? 'No Info'),
                                buildLabelValueWidget('Phone Number', widget.userDetails['data']['mobile_number'] ?? 'No Info'),
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
      ),
    );
  }
}
