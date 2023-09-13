import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import '../../summaries_chat.dart';

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
  final TextEditingController _timeController = TextEditingController();
  int? selectedTaskStatusTypeId; // Store the selected task status type ID
  int? serviceProviderId; // Store the selected service provider type ID
  int? serviceProviderTypeId;
  final _dropdownFocusNode = FocusNode();
  bool isLoading = false;
  FilePickerResult? result;
  PlatformFile? pickedfile;
  List<String> _fileNames = [];
  List<File> fileToDisplay = [];
  TimeOfDay? _selectedTime;


  Widget buildInfoRow(String title, Widget content) {
    return Row(
      children: [
        Container(
          width: 120.w, // Adjust this width as needed
          padding: EdgeInsets.only(left: 20.0.w,top: 15.0.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 200.w, // Adjust this width as needed
            padding: EdgeInsets.only(top: 15.0.h),
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
    final originalFormat = DateFormat('HH:mm:ss');
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
          'dueTime': _timeController.text,
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
    _dueDateController.text = formatDueDate(widget.task['due_date']);
    _timeController.text = formatTime(widget.task['due_time']);
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime!.format(context); // Update the text field
      });
    }
  }

  Future<void> pickFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.any,
        //allowMultiple: true, // Allow multiple files to be picked
        //allowedExtensions: ['png', 'pdf', 'jpeg', 'jpg'],
      );

      if (pickedFiles != null) {
        pickedFiles.files.forEach((pickedFile) {
          _fileNames.add(pickedFile.name);
          fileToDisplay.add(File(pickedFile.path.toString()));
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateAttachment(String fileType, String url) async {
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
        body: jsonEncode({
          'query': updateInteractionAttachmentsQuery,
          'variables': {
            'interactionId':widget.task['id'],
            'fileType': fileType,
            'url': url,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Attachment Updated Successfully');
        print('Response Body: ${response.body}');
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error updating attachment: $error');
    }
  }

  Future <void> _showAttachmentDialog(BuildContext context)async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Attachment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fileToDisplay.isNotEmpty) // Display the selected image if available
                      Column(
                        children: [
                          Image.file(
                            fileToDisplay.first, // Display the first selected image
                            width: 300.w, // Adjust the width as needed
                            height: 300.h, // Adjust the height as needed
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _fileNames.first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    fileToDisplay.clear();
                                    _fileNames.clear();
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    await pickFile();
                    // After pickFile is complete
                    if (fileToDisplay.isNotEmpty) {
                      final fileType = _fileNames.first.split('.').last;
                      const url = 'http://qwerty.com'; // Replace with the actual URL
                      _updateAttachment(
                        fileType,
                        url,
                      );
                    }// Call the pickFile() function when the "Add" button is pressed
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openChatPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SummariesChatPage(
          selectedInteractionMember: {},
          selectedTaskMember: widget.task, // Pass an empty map as selectedTaskMember
        ),
      ),
    );
  }


  String? selectedTaskStatusType; // Store the selected task status type

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> distinctServiceProviderTypes = [];
    for (var provider in serviceProviderTypes) {
      final serviceProviderId = provider['id'] as int;
      final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
      final serviceProviderTypeId = provider['service_provider_type']['id'];
      if (!distinctServiceProviderTypes.any((item) => item['service_provider_type']['name'] == serviceProviderTypeName)) {
        distinctServiceProviderTypes.add(provider);
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.0.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25.0.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Padding(
                        padding: EdgeInsets.only(left: 16.12.w, top: 12.0.h),
                        child: Icon(
                          Icons.close,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0.w, top: 20.0.h),
                      child: ElevatedButton(
                        onPressed: _updateTask,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0.w, right: 16.0.w),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 30.0.h, bottom: 30.0.h, left: 20.0.w),
                      child: Text(
                        widget.task['task_title']?? 'N/A',
                        style: TextStyle(
                          fontSize: 22.sp,
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
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xff006bbf),
                              ),
                            ),
                          ),
                      ],
                    )),
                    SizedBox(height: 10.h),
                    buildInfoRow('Due Date', TextFormField(
                      controller: _dueDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context); // Function to open date picker
                      },
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    )),
                    buildInfoRow('Time', TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () async {
                        await _selectTime(context);
                      },
                      decoration: InputDecoration(
                        hintText: 'Select Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                        ),
                        suffixIcon: const Icon(Icons.access_time), // Show time icon
                      ),
                    ),),
                    buildInfoRow( 'Assigned by', TextFormField(
                      initialValue: widget.task['user']['name'],
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 14.sp,
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
                    buildInfoRow( 'Service \nProvider', DropdownButtonFormField<int>(
                      value:null,//widget.task['service_provider']['service_provider_type']['id'],
                      items: distinctServiceProviderTypes.map((provider) {
                        final serviceProviderId = provider['id'] as int;
                        final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
                        //print(widget.task['service_provider']['service_provider_type']['id'],);
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
                    buildInfoRow('Add \nAttachment', Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          readOnly: true,
                          onTap: () async {
                            _showAttachmentDialog(context);
                          },
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Photos, documents etc..',
                            suffixIcon: Icon(Icons.add),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),),
                    buildInfoRow( 'Add Notes',TextFormField(
                      controller: _notesController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null, // Allow multiple lines of input
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'enter here',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openChatPage();
        },
        label: const Text('Summaries'),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Set the button size
      ),
    );
  }
}

