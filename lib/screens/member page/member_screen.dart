import 'package:flutter/material.dart';
import '../../models/drawer_items.dart';
import '../../models/member_drawer.dart';
import '../../services/api_service.dart';
import 'member details/member profile/member_profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<dynamic>? _membersData;

  Future<void> _navigateToMemberDetails(Map<String, dynamic> member) async {
    final updatedMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDrawer(member: member), // Pass the member data here
      ),
    );

    if (updatedMember != null) {
      final index = _membersData!.indexWhere((item) => item['id'] == updatedMember['id']);
      if (index != -1) {
        setState(() {
          _membersData![index] = updatedMember;
        });
      }
    }
  }


  Future<void> openFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Dialog'),
          content: const Text('Your filter dialog content goes here'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMembersData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchMembersData(); // Fetch data every time the screen is viewed
  }


  Future<void> fetchMembersData() async {
    MemberApi memberApi = MemberApi();
    List<dynamic>? members = await memberApi.fetchMembersData();
    setState(() {
      _membersData = members;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: const Color(0xff006bbf),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        shadowColor: const Color(0xff006bbf),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0.w),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: (){},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0.r),
                          ),
                          //backgroundColor: getButtonColor(isTodayButtonPressed),
                        ),
                        child: const Text(
                          'LOCATION',
                          //style: TextStyle(color: getButtonTextColor(isTodayButtonPressed)),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      OutlinedButton(
                        onPressed: (){},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          //backgroundColor: getButtonColor(isWeekButtonPressed),
                        ),
                        child: const Text(
                          'STATUS',
                         // style: TextStyle(color: getButtonTextColor(isWeekButtonPressed)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0.w),
                  child: OutlinedButton(
                    onPressed: (){},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.r),
                      ),
                     // backgroundColor: getButtonColor(isFilterButtonPressed),
                    ),
                    child: const Text(
                      'PLAN',
                     // style: TextStyle(color: getButtonTextColor(isFilterButtonPressed)),
                    ),),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          Expanded(
            child: _membersData == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _membersData!.length,
              itemBuilder: (context, index) {
                final member = _membersData![index];
                final familyName = member['family_name'] ?? 'N/A';
                final memberName = member['name'] ?? 'Name not available';
                final planName = member['plan_name'] ?? 'N/A';
                final planColor = member['plan_color'] ?? '';


                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(60.w, 12.h, 16.w, 12.h), // Adjust left padding
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 15.0.h),
                        child: Row(
                          children: [
                            Text(
                              familyName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.0.w),
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 4.0.h),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(planColor.replaceAll("#", "0xFF"))),
                                  borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                                ),
                                child: Text(
                                  planName,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style:  TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff01508e),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToMemberDetails(member);
                      },
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

