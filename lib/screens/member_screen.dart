
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prayojana_new/constants.dart';

import '../graphql_queries.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<dynamic>? _membersData; // Store the fetched members data

  @override
  void initState() {
    super.initState();
    fetchMembersData(); // Call the function to fetch members data when the screen loads
  }

  Future<void> fetchMembersData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Hasura-Client-Name': 'hasura-console',
      'x-hasura-admin-secret': 'myadminsecret',
      'Authorization': 'Bearer nkknkj', // Replace 'nkknkj' with your actual JWT token
    };
    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.graphUrl),
    );

    request.body = graphQLQuery;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? members = responseData['data']?['members'];
      setState(() {
        // Update the member list with the fetched data
        _membersData = members;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  List<Widget> buildMemberList(List<dynamic>? data) {
    if (data == null || data.isEmpty) {
      return []; // Return an empty list if data is null or empty
    }

    return data.map((member) {
      return Card(
        child: ListTile(
          title: Text(member['name'] ?? 'Name not available'), // Use a default value if 'name' is null
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${member['phone'] ?? 'N/A'}"),
              Text("Address: ${member['address1'] ?? 'N/A'}, ${member['address2'] ?? 'N/A'}, ${member['address3'] ?? 'N/A'}"),
              Text("Alternate Number: ${member['alternate_number'] ?? 'N/A'}"),
              Text("Area: ${member['area'] ?? 'N/A'}"),
              Text("Blood Group: ${member['blood_group'] ?? 'N/A'}"),
              Text("City: ${member['city'] ?? 'N/A'}"),
              Text("DOB: ${member['dob'] ?? 'N/A'}"),
              Text("Gender: ${member['gender'] ?? 'N/A'}"),
            ],
          ),
          // Add other fields to display here
        ),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.offline_bolt,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text('Item01'),
                    ),
                  ],
                ),
              ),
              // Add more popup menu items if needed
            ],
          ),
        ],
        shadowColor: Colors.black45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color:Colors.black87,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(
                  child:Text('LOGO',style:TextStyle(
                    color: Colors.white,
                  ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list,
                  color: Colors.white,
                ),
                title: const Text('Dashboard',style:TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                ),
                onTap: (){
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => const FirstPage())
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list,
                  color: Colors.white,
                ),
                title: const Text('Calender',style:TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  // PageRouteBuilder(
                  //   pageBuilder: (context, animation, secondaryAnimation) =>
                  //   const SecondPage(),
                  //   transitionDuration: const Duration(milliseconds: 500),
                  //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //     return PositionedTransition(
                  //       rect: RelativeRectTween(
                  //         begin: RelativeRect.fromSize(
                  //           const Rect.fromLTWH(0, 0, 0, 0),
                  //           const Size(0, 0),
                  //         ),
                  //         end: RelativeRect.fromSize(
                  //           const Rect.fromLTWH(0, 0, 1, 1),
                  //           const Size(1, 1),
                  //         ),
                  //       ).animate(animation),
                  //       child: child,
                  //     );
                  //   },
                  // ),
                  //);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.list,
                  color: Colors.white,
                ),
                title: const Text(
                  'Interactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //     const ThirdPage(),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //       return FadeTransition(
                  //         opacity: animation,
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  // );
                },
              ),

              ListTile(
                leading: const Icon(Icons.list,
                  color: Colors.white,
                ),
                title: const Text('Tasks',style:TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //     const FourthPage(),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //       return SlideTransition(
                  //         position: Tween<Offset>(
                  //           begin: const Offset(1.0, 0.0),
                  //           end: Offset.zero,
                  //         ).animate(animation),
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list,
                  color: Colors.white,
                ),
                title: const Text('Members',style:TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //     const FifthPage(),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //       return RotationTransition(
                  //         turns: Tween<double>(
                  //           begin: 0.0,
                  //           end: 1.0,
                  //         ).animate(animation),
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  //);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list,
                  color: Colors.white,
                ),
                title: const Text('Reports',style:TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //     const FifthPage(),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //       return RotationTransition(
                  //         turns: Tween<double>(
                  //           begin: 0.0,
                  //           end: 1.0,
                  //         ).animate(animation),
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  //);
                },
              ),
            ],
          ),
        ),
      ),
      body: _membersData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: buildMemberList(_membersData),
      ),
    );
  }
}

