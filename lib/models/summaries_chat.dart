import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:prayojana_new/constants.dart';
import 'package:prayojana_new/graphql_queries.dart';
import 'package:prayojana_new/screens/interactions%20page/interaction_screen.dart';
import 'package:prayojana_new/services/api_service.dart';

class SummariesChatPage extends StatefulWidget {
  final Map<String, dynamic> selectedInteractionMember;// Add this line
  final Map<String, dynamic> selectedTaskMember;// Add this line


  SummariesChatPage({
    required this.selectedInteractionMember, // Add this line
    required this.selectedTaskMember, // Add this line

  });

  @override
  _SummariesChatPageState createState() => _SummariesChatPageState();
}


class _SummariesChatPageState extends State<SummariesChatPage> {
  final TextEditingController _textController = TextEditingController();
  List<String> chatMessages = [];
  var memberId;

  @override
  void initState() {
    super.initState();
    // Get member summaries and add them to chatMessages
    //_loadMemberSummaries();

    // Check if selectedInteractionMember has data
    if (widget.selectedInteractionMember != null &&
        widget.selectedInteractionMember.containsKey('interaction') &&
        widget.selectedInteractionMember['interaction'] != null) {
      _loadInteractionMemberSummaries();
    }
    // Check if selectedTaskMember has data
    else if (widget.selectedTaskMember != null) {
      _loadTaskMemberSummaries();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshData();
  }

  void _refreshData() {
    // Clear existing chatMessages before fetching new data
    setState(() {
      chatMessages.clear();
    });

    // Load member summaries again
    if (widget.selectedInteractionMember != null &&
        widget.selectedInteractionMember.containsKey('interaction') &&
        widget.selectedInteractionMember['interaction'] != null) {
      _loadInteractionMemberSummaries();
    }
    // Load task summaries again
    else if (widget.selectedTaskMember != null) {
      _loadTaskMemberSummaries();
    }
  }


  // Function to load member summaries
  void _loadInteractionMemberSummaries() {
    // You can access the selectedInteractionMember using widget.selectedInteractionMember
    // Assuming member_summaries is an array of objects
    print('interaction summaries ${widget.selectedInteractionMember}');
    if(widget.selectedInteractionMember!=null){
      List<dynamic>? memberSummaries = widget
          .selectedInteractionMember['interaction']['member_summaries'];

      if (memberSummaries != null) {
        // Iterate through member summaries and extract notes
        for (var summary in memberSummaries) {
          String? notes = summary['notes'];
          if (notes != null) {
            setState(() {
              chatMessages.add(notes);
            });
          }
        }
      }
    }
  }

  void _loadTaskMemberSummaries() {
    print('task summaries ${widget.selectedTaskMember}');
    if (widget.selectedTaskMember != null) {
      // Check if selectedTaskMember is not null
      List<dynamic>? memberSummaries = widget.selectedTaskMember['member_summaries'];
      print(widget.selectedTaskMember['id']);
      if (widget.selectedTaskMember != null) {
        List<dynamic> taskMembers = widget.selectedTaskMember['task_members'];
        if (taskMembers.isNotEmpty) {
          memberId = taskMembers[0]['member']['id'];

          print(memberId);
        }
      }


      if (memberSummaries != null) {
        // Iterate through member summaries and extract notes
        for (var summary in memberSummaries) {
          String? notes = summary['notes'];
          if (notes != null) {
            setState(() {
              chatMessages.add(notes);
            });
          }
        }
      }
    }
  }

  void _handleBackButtonPressed() {
    // Add any actions you want to perform when the back button is pressed
    // For example, if you want to update data before navigating back:
    // _updateData();
    Navigator.pop(context, true); // Pass true if data was updated
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Member Summaries'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _handleBackButtonPressed,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft, // Always left-aligned
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        chatMessages[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 2.0),
          Container(
            decoration: BoxDecoration(color: Theme
                .of(context)
                .cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme
          .of(context)
          .primaryColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a note',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _handleSubmitted(_textController.text);
                _textController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }


  void _handleSubmitted(String message) async {
    setState(() {
      chatMessages.add(message);
    });

    try {
      String accessToken = await getFirebaseAccessToken();
      // Define your GraphQL mutation with variables
      String mutation = ''; // Initialize to a default value
      Map<String, dynamic> variables = {}; // Initialize to an empty map

      if (widget.selectedInteractionMember != null &&
          widget.selectedInteractionMember.containsKey('interaction') &&
          widget.selectedInteractionMember['interaction'] != null) {
        // If selectedInteractionMember has data, use interaction-related variables
        mutation = insertInChatSummaries;
        variables = {
          'memberId': widget.selectedInteractionMember['member_id'],
          'notes': message,
          'interactionId': widget
              .selectedInteractionMember['interaction']['id'],
        };
      } else if (widget.selectedTaskMember != null) {
        // If selectedTaskMember has data, use task-related variables
        mutation =
            insertTaskChatSummaries; // Define your task-specific mutation
        variables = {
          'taskId': widget.selectedTaskMember['id'],
          'memberId': memberId,
          'notes': message,
          // Add other task-related variables as needed
        };
      }

      // Make the HTTP POST request
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        // Replace with your GraphQL endpoint
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken', // Include your access token
        },
        body: jsonEncode({
          'query': mutation,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Mutation Response: $data');
      } else {
        print('Mutation Failed: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error performing GraphQL mutation: $error');
    }
  }
}

