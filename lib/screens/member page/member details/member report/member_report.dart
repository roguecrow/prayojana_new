import 'package:flutter/material.dart';

class MemberReport extends StatefulWidget {
  const MemberReport({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberReport> createState() => _MemberReportState();
}

class _MemberReportState extends State<MemberReport> {

  void initState() {
    super.initState();
    print('Clicked Member ID: ${widget.member['id']}');

    widget.member.forEach((key, value) {
      print('$key: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('MemberReport')),
    );
  }
}
