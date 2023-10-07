import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../services/api_service.dart';

class MemberDocuments extends StatefulWidget {
  const MemberDocuments({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberDocuments> createState() => _MemberDocumentsState();
}

class _MemberDocumentsState extends State<MemberDocuments> {
  List<dynamic> memberDocumentDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberDocumentsDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchMemberDocumentsDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? documentDetails = await MemberApi().fetchMemberDocumentsDetails(memberId);
    if (documentDetails != null && documentDetails.isNotEmpty) {
      setState(() {
        memberDocumentDetails = documentDetails;
        isLoading = false;
        print(memberDocumentDetails);
      });
    } else {
      print('Error fetching member details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child:  SizedBox(
          height: 50,
          width: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulseSync, /// Required, The loading type of the widget
            colors: [Color(0xff006bbf)],       /// Optional, The color collections
          ),
        ),
      ) // Add a loading indicator while data is being fetched
          : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.h,
        ),
        itemCount: memberDocumentDetails.length,
        itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  memberDocumentDetails[index]['image'], // Assuming 'image' is the URL of the document
                  height: 150, // Adjust the height as needed
                  width: 200, // Adjust the width as needed
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
                const SizedBox(height: 10),
                Text(
                  memberDocumentDetails[index]['name'] ?? 'N/A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
        },
      ),
          ),
    );
  }
}

