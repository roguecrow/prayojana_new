import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderDrawer extends StatefulWidget {
  final Map<String, dynamic> member;

  const HeaderDrawer({Key? key, required this.member}) : super(key: key);
  @override
  _HeaderDrawerState createState() => _HeaderDrawerState();
}

class _HeaderDrawerState extends State<HeaderDrawer> {
  String? memberName;
  String? phone;
  String? firstName;

  void initState() {
    super.initState();
    loadMemberDetails();
  }

  void loadMemberDetails() async {
    print('Clicked Member ID: ${widget.member['id']}');

    widget.member.forEach((key, value) {
      print('$key: $value');
    });
    memberName = widget.member['name'] != null && widget.member['name'] != ''
        ? widget.member['name']
        : 'N/A';
    List<String> nameParts = memberName!.split(' ');
    if (nameParts.isNotEmpty) {
      firstName = nameParts[0];
      print(firstName);
    }
    phone = widget.member['phone'] != null && widget.member['phone'] != ''
        ? widget.member['phone']
        : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff006bbf),
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: widget.member['imagePath'] != null && widget.member['imagePath'] != ''
                  ? DecorationImage(
                image: AssetImage(widget.member['imagePath']),
              )
                  : null, // No image provided, set image to null
            ),
            child: widget.member['imagePath'] == null || widget.member['imagePath'] == ''
                ? Icon(Icons.person, size: 50.h, color: Colors.white) // Show profile icon if no image
                : null,
          ),
          Text(
            memberName!.length > 15 ? firstName! : memberName!,
            style: TextStyle(color: Colors.white, fontSize: 25.sp),
          ),

          const SizedBox(height: 4),
          Text(
            phone!,
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}