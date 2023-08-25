import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prayojana_new/services/api_service.dart';
import '../../graphql_queries.dart';

class MemberDetails extends StatefulWidget {
  const MemberDetails({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _interactionNotesController;
  late TextEditingController _taskNotesController; // Add this line

  late BuildContext _storedContext;

  @override
  void initState() {
    super.initState();
    print('Clicked Member ID: ${widget.member['id']}');
    _nameController = TextEditingController(text: widget.member['name']);
    _phoneController = TextEditingController(text: widget.member['phone']);
    _addressController = TextEditingController(text: widget.member['address1']);

    // Check if interaction_members list is not empty before accessing its first element
    if (widget.member['interaction_members'] != null && widget.member['interaction_members'].isNotEmpty) {
      _interactionNotesController = TextEditingController(text: widget.member['interaction_members'][0]['interaction']['notes']);
    } else {
      _interactionNotesController = TextEditingController(); // Set a default value if the list is empty
    }

    // Initialize the task notes controller
    _taskNotesController = TextEditingController(
      text: widget.member['task_members'] != null && widget.member['task_members'].isNotEmpty
          ? widget.member['task_members'][0]['task']['task_notes']
          : '', // Set an empty string if the list is empty
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _interactionNotesController.dispose();
    _taskNotesController.dispose(); // Dispose the task notes controller
    super.dispose();
  }

  Future<void> _updateMemberDetails() async {
    final Map<String, dynamic> updatedMemberData = {
      'id': widget.member['id'],
      'name': _nameController.text,
      'phone': _phoneController.text,
      'interactionNotes': _interactionNotesController.text,
      'taskNotes': _taskNotesController.text,
      'taskId': widget.member['task_members'] != null && widget.member['task_members'].isNotEmpty
          ? widget.member['task_members'][0]['task']['id']
          : null, // Provide taskId if available, otherwise set to null
      'interactionId': widget.member['interaction_members'] != null &&
          widget.member['interaction_members'].isNotEmpty
          ? widget.member['interaction_members'][0]['interaction']['id']
          : null, // Provide interactionId if available, otherwise set to null

    };

    final http.Response response = await MemberApi.postRequest(combinedMutation, updatedMemberData);

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      Map<String, dynamic>? updatedMember = responseData['data']?['update_members_by_pk'];
      print('Updated Member Data: $updatedMember');
      print(responseData);
      if (updatedMember != null) {
        // Update the local data with the new member data here if needed

        // Pop the screen and return the updated member data
        Navigator.pop(_storedContext, updatedMember);
      } else {
        print('not updated');
        // Handle the case when the response does not contain updated member data
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
      // Handle the API error and show an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    _storedContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text field for name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            // Text field for phone
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            // Text field for address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            // Text field for task notes
            TextField(
              controller: _taskNotesController,
              decoration: const InputDecoration(labelText: 'Task Notes'),
            ),
            // Text field for interaction notes
            TextField(
              controller: _interactionNotesController,
              decoration: const InputDecoration(labelText: 'Interaction Notes'),
            ),
            // Add more text fields for other member details if needed
            ElevatedButton(
              onPressed: _updateMemberDetails,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
