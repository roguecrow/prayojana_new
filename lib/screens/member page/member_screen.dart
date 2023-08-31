import 'package:flutter/material.dart';
import 'package:prayojana_new/drawer_items.dart';
import '../../services/api_service.dart';
import 'member_details.dart';
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
        builder: (context) => MemberDetails(member: member),
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

  Future<void> fetchMembersData() async {
    MemberApi memberApi = MemberApi();
    List<dynamic>? members = await memberApi.fetchMembersData();
    setState(() {
      _membersData = members;
    });
  }

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Dashboard',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Members',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Interactions',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Tasks',
      onTap: () {},
    ),
    DrawerItem(
      icon: const Icon(Icons.list, color: Colors.white),
      title: 'Reports',
      onTap: () {},
    ),
  ];

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
      drawer: AppDrawer(drawerItems: _drawerItems),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0.h,bottom: 10.h),
            child: SizedBox(
              width: ScreenUtil().screenWidth, // Set the width to the screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.w),
                      ),
                    ),
                    child: const Text('LOCALITY'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.w),
                      ),
                    ),
                    child: const Text('STATUS'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.w),
                      ),
                    ),
                    child: const Text('PLAN'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0.w),
                      ),
                    ),
                    child: const Text('CAREBUDDY'),
                  ),
                ],
              ),
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
                final familyName = member['client_members'] != null && member['client_members'].isNotEmpty
                    ? member['client_members'][0]['client'] != null
                    ? member['client_members'][0]['client']['family_name'] ?? 'N/A'
                    : 'N/A'
                    : 'N/A';

                final memberName = member['name'] ?? 'Name not available';

                final plans = member['client_members'] != null && member['client_members'].isNotEmpty
                    ? member['client_members'][0]['client'] != null
                    ? member['client_members'][0]['client']['client_plans']
                    : []
                    : [];

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
                            Wrap(
                              spacing: 8.0,
                              children: plans.map<Widget>((plan) {
                                final planName =
                                plan['plan'] != null ? plan['plan']['name'] ?? 'Unknown Plan' : 'Unknown Plan';
                                final planColor =
                                plan['plan'] != null ? plan['plan']['color'] ?? '#000000' : '#000000';

                                return Padding(
                                  padding: EdgeInsets.only(left: 8.0.w),
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
                                );
                              }).toList(),
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

