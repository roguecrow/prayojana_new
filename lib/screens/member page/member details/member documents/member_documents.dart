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
        print(isLoading);
        print(memberDocumentDetails);
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(isLoading);
      print(memberDocumentDetails);
      print('member documents details is empty');
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
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      )
          : memberDocumentDetails.isNotEmpty
          ? Padding(
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
                  memberDocumentDetails[index]['image'],
                  height: 150,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  memberDocumentDetails[index]['name'] ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      )
          : const Center(
        child: Text(
          'There are no documents to view',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

