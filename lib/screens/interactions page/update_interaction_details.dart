import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';

import '../../summaries_chat.dart';
import '../tasks page/create_new_task.dart';

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  List<Map<String, dynamic>> interactionTypes = [];
  List<Map<String, dynamic>> interactionStatusTypes = [];
  int? selectedInteractionTypeId;
  int? selectedInteractionStatusTypeId;
  List<String> memberNames = [];
  final _dropdownFocusNode = FocusNode();
  bool isLoading = false;
  FilePickerResult? result;
  PlatformFile? pickedfile;
  List<String> _fileNames = [];
  List<File> fileToDisplay = [];
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
            'interactionId': widget.selectedInteractionMember['interaction']['id'],
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


  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        fileToDisplay.add(File(pickedFile.path));
      });
    }
  }



  Future<void> _showAttachmentDialog(BuildContext context) async {
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
                              if (_fileNames.isNotEmpty) // Add this condition
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the dialog
                        await pickImageFromCamera();
                        // After pickImageFromCamera is complete
                        if (fileToDisplay.isNotEmpty) {
                          final fileType = _fileNames.first.split('.').last;
                          const url = 'http://qwerty.com'; // Replace with the actual URL
                          await _updateAttachment(
                            fileType,
                            url,
                          );
                        }
                      },
                      child: Text('Camera'),
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
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }





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

  void _openChatPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SummariesChatPage(
          selectedInteractionMember: widget.selectedInteractionMember,
          selectedTaskMember: {}, // Pass an empty map as selectedTaskMember
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
   // final selectedInteractionMember = widget.selectedInteractionMember;
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
                        onPressed: () {
                          _updateInteraction();
                        },
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
                        widget.selectedInteractionMember['interaction']['title'],
                        style: TextStyle(
                          fontSize: 24.sp,
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
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xff006bbf),
                              ),
                            ),
                          ),
                      ],
                    )),
                    SizedBox(height: 15.h),
                    buildInfoRow( 'Task Title',TextFormField(
                      controller: _taskController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
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
                    buildInfoRow( 'Type', DropdownButtonFormField<int>(
                      focusNode: _dropdownFocusNode,
                      value: selectedInteractionTypeId ?? widget.selectedInteractionMember['interaction']['interaction_type_id'],
                      items: interactionTypes.map((statusType) {
                        print('type id ${widget.selectedInteractionMember['interaction']['interaction_type_id']}');
                        print('selectedInteractionTypeId $selectedInteractionTypeId');
                        print('typename ${statusType['name']}');
                        print(widget.selectedInteractionMember['interaction']['id']);
                        print(widget.selectedInteractionMember['member_id']);
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
                    buildInfoRow( 'Add Notes',TextFormField(
                      controller: _notesController, // Attach the TextEditingController
                      style: TextStyle(
                        fontSize: 14.sp,
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
                            suffixIcon: const Icon(Icons.add),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),),
                    // ... Other details you want to display
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0.w,top: 30.0.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20.0.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center, // Adjust the alignment as needed
                      child: Padding(
                        padding: EdgeInsets.only(left: 45.0.w),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateTask(memberId: widget.selectedInteractionMember['member_id']), // Pass the memberId
                              ),
                            );
                          },
                          icon: Icon(Icons.add, size: 16.sp),
                          label: const Text("New Task",
                            style: TextStyle(
                                color: Color(0xff006bbf),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
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

