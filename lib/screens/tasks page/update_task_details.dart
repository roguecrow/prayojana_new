import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final dynamic task;

  const TaskDetailsScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TextEditingController _dueDateController = TextEditingController();
  List<String> memberNames = [];
  List<Map<String, dynamic>> taskStatusTypes = []; // Store task status types here
  List<dynamic> serviceProviderTypes = []; // Store service provider types here
  String? selectedServiceProviderType;
  final TextEditingController _notesController = TextEditingController();
  int? selectedTaskStatusTypeId; // Store the selected task status type ID
  int? serviceProviderId; // Store the selected service provider type ID
  int? serviceProviderTypeId;
  final _dropdownFocusNode = FocusNode();


  Widget buildInfoRow(String title, Widget content) {
    return Row(
      children: [
        Container(
          width: 120, // Adjust this width as needed
          padding: const EdgeInsets.only(left: 20.0),
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
            padding: const EdgeInsets.all(8.0),
            child: content,
          ),
        ),
      ],
    );
  }


  // Function to format due date
  String formatDueDate(String dueDate) {
    final originalFormat = DateFormat('yyyy-MM-dd');
    final newFormat = DateFormat('dd MMM yyyy');

    final dateTime = originalFormat.parse(dueDate);
    return newFormat.format(dateTime);
  }

  String formatTime(String time) {
    final originalFormat = DateFormat('HH:mm:ss.SSSSSS');
    final newFormat = DateFormat('hh:mm a');

    final dateTime = originalFormat.parse(time);
    return newFormat.format(dateTime);
  }

  Future<void> _updateTask() async {
    String accessToken = await getFirebaseAccessToken();
    if (selectedTaskStatusTypeId == null) {
      // Display an error message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select a task status type before updating.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'query': updateTaskQuery,
        'variables': {
          'taskId': widget.task['id'],
          'taskTitle': widget.task['task_title'],
          'dueDate': _dueDateController.text,
          'taskStatusTypeId': selectedTaskStatusTypeId, // Use selected task status type
          'serviceProviderId': serviceProviderId, // Use selected service provider type
          'taskNotes': _notesController.text,
        },
      }),
    );
    print(serviceProviderId);
    print(selectedTaskStatusTypeId);

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      Navigator.pop(context, true);
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }

  @override
  void initState() {
    super.initState();
    _dueDateController.text = widget.task['due_date'];
    _notesController.text = widget.task['task_notes'] ?? '';
    _fetchMemberNames();
    _fetchTaskStatusTypes(); // Fetch task status types when the screen initializes
    _fetchServiceProviderTypes();
  }


  Future<void> _fetchServiceProviderTypes() async {
    try {
      final http.Response response = await Taskapi.fetchServiceProviderTypes();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final providers = data['data']['service_providers'] as List<dynamic>;

        setState(() {
          serviceProviderTypes = providers;
          serviceProviderTypeId = providers.isNotEmpty
              ? providers[0]['service_provider_type_id'] as int
              : null;
        });
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching service provider types: $error');
    }
  }
  // Fetch and populate member names from the task
  void _fetchMemberNames() {
    final taskMembers = widget.task['task_members'] as List<dynamic>?;
    if (taskMembers != null) {
      setState(() {
        memberNames = taskMembers
            .map((member) => member['member']?['name'] as String?)
            .where((name) => name != null)
            .map((name) => name!)
            .toList();
      });
    }
    print(memberNames);
  }


  // Fetch and populate task status types
  void _fetchTaskStatusTypes() async {
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
        body: jsonEncode({'query': getTaskStatusTypesQuery}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          taskStatusTypes = List<Map<String, dynamic>>.from(data['data']['task_status_types']);
        });
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }

  String? selectedTaskStatusType; // Store the selected task status type

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> distinctServiceProviderTypes = [];
    for (var provider in serviceProviderTypes) {
      final serviceProviderId = provider['id'] as int;
      final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
      if (!distinctServiceProviderTypes.any((item) => item['service_provider_type']['name'] == serviceProviderTypeName)) {
        distinctServiceProviderTypes.add(provider);
      }
    }
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
                        onPressed: _updateTask,
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
                        widget.task['task_title'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.task['task_status_type_id'] == 1
                              ? Color(int.parse('0xFF${widget.task['task_status_type']['color'].substring(1)}'))
                              : null,
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
                    buildInfoRow('Due Date', TextFormField(
                      initialValue: formatDueDate(widget.task['due_date']),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )),
                    buildInfoRow('Time', TextFormField(
                      initialValue: formatTime(widget.task['due_time']),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )),
                    buildInfoRow( 'Assigned by', TextFormField(
                      initialValue: widget.task['user']['name'],
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )),
                    buildInfoRow( 'Status', DropdownButtonFormField<int>(
                      focusNode: _dropdownFocusNode,
                      value: selectedTaskStatusTypeId ?? widget.task['task_status_type_id'],
                      items: taskStatusTypes.map((statusType) {
                        final colorString = statusType['color'] as String;
                        final color = Color(int.parse('0xFF${colorString.substring(1)}'));
                        final textColor = statusType['name'] == 'Canceled' ? Colors.black : color;
                        //print(widget.task['service_provider']['service_provider_type']['id']);
                        // print(serviceProviderTypeId);
                        //print(statusType['name']);
                        return DropdownMenuItem<int>(
                          value: statusType['id'],
                          child: Text(
                            statusType['name'],
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _dropdownFocusNode.unfocus();
                          selectedTaskStatusTypeId = newValue;
                          selectedTaskStatusType = taskStatusTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                          print(newValue);
                          print(selectedTaskStatusTypeId);
                          print(selectedTaskStatusType);
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
                    buildInfoRow( 'Service Provider', DropdownButtonFormField<int>(
                      value: null,
                      items: distinctServiceProviderTypes.map((provider) {
                        final serviceProviderId = provider['id'] as int;
                        final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
                        //print(widget.task['service_provider_type_id'],);
                        //print(serviceProviderTypeName);
                        //print(provider['service_provider_type_id']);
                        return DropdownMenuItem<int>(
                          value: serviceProviderId,
                          child: Text(serviceProviderTypeName),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          serviceProviderId = newValue;
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
                            fillColor: Colors.grey[300],
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
                    // ... Repeat similar lines for other rows
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

