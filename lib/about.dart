import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('About App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
              child: Text(
                'Prayojana',
                style: TextStyle(
                  fontSize: 32.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
             SizedBox(height: 16.0.h),
            Center(
              child: Text(
                'Version: $version',
                style:  TextStyle(
                  fontSize: 20.0.sp,
                ),
              ),
            ),
            const Divider(),
             Text(
              'Description:',
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8.0.h),
             Text(
              'This app is designed exclusively for Carebuddy to help them track their members and their status.',
              style: TextStyle(
                fontSize: 16.0.sp,
              ),
            ),
             SizedBox(height: 16.0.h),

             Text(
              'Functionality:',
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8.0.h),
             Text(
              'The app provides features such as member tracking, status updates, and data management for effective care management.',
              style: TextStyle(
                fontSize: 16.0.sp,
              ),
            ),
             SizedBox(height: 16.0.h),
            // Add any additional information or sections as needed
          ],
        ),
      ),
    );
  }
}
