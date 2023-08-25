  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
  import 'package:prayojana_new/screens/interactions%20page/update_interaction_details.dart';
  import '../../drawer_items.dart';
  import '../../graphql_queries.dart';
  import '../../services/api_service.dart';
  import 'create_new_interaction.dart';
  import 'package:prayojana_new/constants.dart';
  import 'dart:convert';

  class InteractionScreen extends StatefulWidget {
    const InteractionScreen({super.key});

    @override
    State<InteractionScreen> createState() => _InteractionScreenState();
  }

  class _InteractionScreenState extends State<InteractionScreen> {


    @override
    void initState() {
      super.initState();
      fetchDataTypes();
    }
    List<dynamic> interactionMembers = [];
    Future<void> fetchDataTypes() async {
      String accessToken = await getFirebaseAccessToken();
      final Map<String, String> headers = {
        'Hasura-Client-Name': 'hasura-console',
        'x-hasura-admin-secret': 'myadminsecret',
        'content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      const String url = ApiConstants.graphqlUrl;

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'query': getInteractionQuery, 'variables': {}}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> fetchedInteractionMembers = responseData['data']['interaction_members'];

        //print('fetchedInteractionMembers: $fetchedInteractionMembers'); // Add this line

        setState(() {
          interactionMembers = fetchedInteractionMembers;
        });
      } else {
        print('Error fetching data: ${response.reasonPhrase}');
      }

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

    String formatDueDate(String? dueDate) {
      if (dueDate == null) {
        return 'N/A'; // Return a default value if date is null
      }

      final originalFormat = DateFormat('yyyy-MM-dd');
      final newFormat = DateFormat('dd MMM yyyy');

      try {
        final dateTime = originalFormat.parse(dueDate);
        return newFormat.format(dateTime);
      } catch (e) {
        print('Error formatting due date: $e');
        return 'N/A'; // Return a default value if formatting fails
      }
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff006bbf),
          title: const Text('Interaction'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
        drawer: AppDrawer(drawerItems: _drawerItems),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: const Text('TODAY'),
                        ),
                        const SizedBox(width: 9), // Add spacing between buttons
                        OutlinedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: const Text('THIS WEEK'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: const Text('FILTER'),
                    ),
                  ),
                ],
              ),
            ),
            // ... (button row remains the same)
            const SizedBox(height: 16.0),
            Expanded(
              child: interactionMembers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                itemCount: interactionMembers.length,
                separatorBuilder: (context, index) => const Divider(
                  endIndent: 20,
                  indent: 20,
                  thickness: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final interactionMember = interactionMembers[index];
                  final title = interactionMember['interaction']['title'];
                  final date = interactionMember['interaction']['interaction_date'];
                  //print('interaction details :$interactionMember');

                  return SizedBox(
                    height: 80,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(30, 12, 16, 12),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          title ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          formatDueDate(date) ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      onTap: () {
                        _navigateToInteractionDetailsScreen(interactionMember); // Pass the selected interaction data
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _navigateToCreateInteractionScreen();
          },
          label: const Text('CREATE NEW'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xff018fff),
        ),
      );
    }

    void _navigateToInteractionDetailsScreen(Map<String, dynamic> interactionMember) async {
      final shouldUpdate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractionDetailsScreen(
            selectedInteractionMember: interactionMember,
          ),
        ),
      );

      if (shouldUpdate == true) {
        fetchDataTypes();
      }
    }

    void _navigateToCreateInteractionScreen() async {
      final shouldCreate= await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateInteraction()),
      );
      if (shouldCreate == true) {
        // Refresh the task data after updating
        fetchDataTypes();
      }
    }
  }

