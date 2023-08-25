import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class InteractionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> selectedInteractionMember;

  const InteractionDetailsScreen({
    Key? key,
    required this.selectedInteractionMember,
  }) : super(key: key);

  @override
  State<InteractionDetailsScreen> createState() => _InteractionDetailsScreenState();
}

class _InteractionDetailsScreenState extends State<InteractionDetailsScreen> {
  List<Map<String, dynamic>> interactionTypes = [];
  List<Map<String, dynamic>> interactionStatusTypes = [];
  int? selectedInteractionTypeId;
  int? selectedInteractionStatusTypeId;
  List<String> memberNames = [];
  final _dropdownFocusNode = FocusNode();
  // final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();





  @override
  void initState() {
    super.initState();
    _dueDateController.text = formatDueDate(widget.selectedInteractionMember['interaction']['interaction_date'] ?? '');
    _taskController.text = widget.selectedInteractionMember['interaction']['title'];
    _notesController.text = widget.selectedInteractionMember['interaction']['notes'];
    _fetchMemberName();
    _fetchInteractionTypes();
    _fetchInteractionStatusTypes();
  }



  void _fetchMemberName() {
    final memberName = widget.selectedInteractionMember['member']['name'] as String?;
    if (memberName != null) {
      setState(() {
        memberNames = [memberName];
      });
    }
    print(memberNames);
  }

  void _fetchInteractionTypes() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getInteractionTypesQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          interactionTypes = List<Map<String, dynamic>>.from(data['data']['interaction_types']);
        });
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }

  void _fetchInteractionStatusTypes() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getInteractionStatusTypesQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          interactionStatusTypes = List<Map<String, dynamic>>.from(data['data']['interaction_status_types']);
        });
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }


  Widget buildInfoRow(String title, Widget content) {
    return Row(
      children: [
        Container(
          width: 120, // Adjust this width as needed
          padding: const EdgeInsets.only(left: 20.0,top: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 200, // Adjust this width as needed
            padding: const EdgeInsets.only(top: 15.0),
            child: content,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDateController) {
      setState(() {
        _dueDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }


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



  Future<void> _updateInteraction() async {
    String accessToken = await getFirebaseAccessToken();

    if (selectedInteractionStatusTypeId == null) {
      // Display an error message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select an Interaction status type before updating.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String dueDateText = _dueDateController.text ?? '';
    String notesText = _notesController.text ?? '';

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'query': updateInteractionQuery,
        'variables': {
          'id': widget.selectedInteractionMember['interaction']['id'],
          'interactionTypeId': selectedInteractionTypeId,
          'interactionStatusTypeId': selectedInteractionStatusTypeId,
          'newNotes': _notesController.text,
          'newTitle': _taskController.text,
          'newInteractionDate': _dueDateController.text,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Interaction Updated Successfully');
      print('Response Body: ${response.body}');
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }



  String? selectedInteractionType;
  String? selectedInteractionStatusType;

  @override
  Widget build(BuildContext context) {
   // final selectedInteractionMember = widget.selectedInteractionMember;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 16.12, top: 16.0),
                        child: Icon(
                          Icons.close,
                          size: 32,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0, top: 25.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _updateInteraction();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 50.0, bottom: 37.0, left: 20.0),
                      child: Text(
                        widget.selectedInteractionMember['interaction']['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildInfoRow('Members', Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (String memberName in memberNames)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              memberName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xff006bbf),
                              ),
                            ),
                          ),
                      ],
                    )),
                    const SizedBox(height: 18),
                    buildInfoRow( 'Task Title',TextFormField(
                      controller: _taskController, // Attach the TextEditingController
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow('Date', TextFormField(
                      controller: _dueDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context); // Function to open date picker
                      },
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    )),
                    buildInfoRow( 'Type', DropdownButtonFormField<int>(
                      focusNode: _dropdownFocusNode,
                      value: selectedInteractionTypeId ?? widget.selectedInteractionMember['interaction']['interaction_type_id'],
                      items: interactionTypes.map((statusType) {
                        print('type id ${widget.selectedInteractionMember['interaction']['interaction_type_id']}');
                        print('selectedInteractionTypeId $selectedInteractionTypeId');
                        print('typename ${statusType['name']}');
                        print(widget.selectedInteractionMember['interaction']['id']);
                        return DropdownMenuItem<int>(
                          value: statusType['id'],
                          child: Text(
                            statusType['name'],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _dropdownFocusNode.unfocus();
                          selectedInteractionTypeId = newValue;
                          selectedInteractionType = interactionTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                          print('newValue $newValue');
                          print('selectedInteractionTypeId $selectedInteractionTypeId');
                          print('selectedInteractionType $selectedInteractionType');
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow('Status', DropdownButtonFormField<int>(
                      focusNode: _dropdownFocusNode,
                      value: selectedInteractionStatusTypeId ?? (widget.selectedInteractionMember['interaction'] != null
                          ? widget.selectedInteractionMember['interaction']['interaction_status_type_id']
                          : null),
                      items: interactionStatusTypes.map((statusType) {
                        // print('updated interaction_status_types ${(widget.selectedInteractionMember['interaction']['interaction_status_type'] != null
                        //     ? widget.selectedInteractionMember['interaction']['interaction_status_type']['id']
                        //     : null)}');
                        final colorString = statusType['color'] as String;
                        final color = Color(int.parse('0xFF${colorString.substring(1)}'));
                        final textColor = statusType['id'] == 1 ? Colors.black : color;

                        final id = statusType['id'];
                        final name = statusType['name'];

                        return DropdownMenuItem<int>(

                          value: id,
                          child: Text(
                            name,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _dropdownFocusNode.unfocus();
                          selectedInteractionStatusTypeId = newValue;
                          selectedInteractionStatusType = interactionStatusTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                          print('newvalue $newValue');
                          print('selectedInteractionStatusTypeId $selectedInteractionStatusTypeId');
                          print('selectedInteractionStatusType $selectedInteractionStatusType');
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    // buildInfoRow( 'Location',TextFormField(
                    //   controller: _locationController, // Attach the TextEditingController
                    //   style: const TextStyle(
                    //     fontSize: 16,
                    //   ),
                    //   maxLines: null, // Allow multiple lines of input
                    //   decoration: InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8.0),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //   ),
                    // ),),
                    buildInfoRow( 'Add Notes',TextFormField(
                      controller: _notesController, // Attach the TextEditingController
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),),
                    buildInfoRow( 'Add Attachment', Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Photos,documents etc..',
                            //fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Handle the add icon button press
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.grey, // You can adjust the color of the add icon here
                          ),
                        ),
                      ],
                    ),),
                    // ... Other details you want to display
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,top: 30.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center, // Adjust the alignment as needed
                      child: Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Respond to button press
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("New Task",
                            style: TextStyle(
                                color: Color(0xff006bbf)
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                            backgroundColor: const Color(0xffe1f2ff),// Adjust the padding as needed
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// buildInfoRow( 'Assigned by', TextFormField(
//   initialValue: widget.task['user']['name'],
//   readOnly: true,
//   style: const TextStyle(
//     fontSize: 16,
//   ),
//   decoration: InputDecoration(
//     filled: true,
//     fillColor: Colors.grey[300],
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8.0),
//       borderSide: BorderSide.none,
//     ),
//   ),
// )),

// buildInfoRow( 'Service Provider', DropdownButtonFormField<int>(
//   value: null,
//   items: distinctServiceProviderTypes.map((provider) {
//     final serviceProviderId = provider['id'] as int;
//     final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
//     //print(widget.task['service_provider_type_id'],);
//     //print(serviceProviderTypeName);
//     //print(provider['service_provider_type_id']);
//     return DropdownMenuItem<int>(
//       value: serviceProviderId,
//       child: Text(serviceProviderTypeName),
//     );
//   }).toList(),
//   onChanged: (newValue) {
//     setState(() {
//       serviceProviderId = newValue;
//     });
//   },
//   decoration: InputDecoration(
//     filled: true,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8.0),
//       borderSide: const BorderSide(color: Colors.grey),
//     ),
//   ),
// ),),


// ... Repeat similar lines for other rows