import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:convert';

import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../models/attachment_done_bar.dart';
import '../../models/summaries_chat.dart';
import '../../services/api_service.dart';

class NewTaskDetailsScreen extends StatefulWidget {
  final int taskId;

  const NewTaskDetailsScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<NewTaskDetailsScreen> createState() => _NewTaskDetailsScreenState();
}


class _NewTaskDetailsScreenState extends State<NewTaskDetailsScreen> {
  final TextEditingController _dueDateController = TextEditingController();
  List<String> memberNames = [];
  List<Map<String, dynamic>> taskStatusTypes = []; // Store task status types here
  List<dynamic> serviceProviderTypes = []; // Store service provider types here
  String? selectedServiceProviderType;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _taskSummaryController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController(); // Add this line
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
  String fileName = ''; // Add this line
  List<String> taskSummaries = [];
  var memberId;
  Map<String, dynamic> tasks = {}; // Add this line
  bool _isMounted = true;
  File? pickedFile; // Store the picked file
  String? pickedFileName; // Store the file name
  String? attachmentUrl;
  var fileUrl;
  String? errorAttachment;
  String? fileType;
  bool isFormChanged = false;




  Widget buildInfoColumn(String title, Widget content, String assetImagePath) {
    if(title.isEmpty)
      print(title);
    return Padding(
      padding: EdgeInsets.only( left: 20.w,top: 20.h),
      child: title.isNotEmpty ?
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Image.asset(
                  assetImagePath, // Provide the path to your asset here
                  width: 20.sp, // Set the desired width
                  height: 20.sp, // Set the desired height
                  color: const Color(0xff999999), // Set the color if needed
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          Padding(
            padding:  EdgeInsets.only(left: 36.0.w),
            child: Container(
              child: content,
            ),
          ),
        ],
      ) : Row(
        children: [
          Image.asset(
            assetImagePath, // Provide the path to your asset here
            width: 20.sp, // Set the desired width
            height: 20.sp, // Set the desired height
            color: const Color(0xff999999), // Set the color if needed
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Container(
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Function to format due date
  String formatDueDate(String dueDate) {
    final originalFormat = DateFormat('yyyy-MM-dd');
    final newFormat = DateFormat('dd MMM yyyy');

    final dateTime = originalFormat.parse(dueDate);
    return newFormat.format(dateTime);
  }

  String formatTime(String? time) {
    if (time == null) {
      return ''; // Or any default value you want to use for empty time
    }

    final originalFormat = DateFormat('HH:mm:ss');
    final newFormat = DateFormat('hh:mm a');

    final dateTime = originalFormat.parse(time);
    return newFormat.format(dateTime);
  }




  Future<void> _updateTask() async {
    String accessToken = await getFirebaseAccessToken();
    if (selectedTaskStatusTypeId == null || serviceProviderId == null) {
      print(selectedTaskStatusTypeId);
      print(serviceProviderId);
      // Display an error message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select all fields before updating.'),
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
        'query': updateTaskQuery,
        'variables': {
          'taskId': widget.taskId,
          'taskTitle': tasks['task_title'],
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

  Future<void> fetchTaskDetails() async {
    print('TASK ID  - ${widget.taskId}');
    List<dynamic> taskDetails = await TaskApi().getTaskDetails(widget.taskId);

    // Now you can use the taskDetails list in this page
    if (taskDetails.isNotEmpty) {
       tasks = taskDetails[0];
       _dueDateController.text = formatDueDate(tasks['due_date']);
       _timeController.text = formatTime(tasks['due_time']);
       _notesController.text = tasks['task_notes'] ?? '';
       selectedTaskStatusTypeId = tasks['task_status_type_id'];
       fileUrl = tasks['task_attachements'][0]['url'];
       print('fileUrl - $fileUrl');
       if (fileUrl != null) {
         List<String> parts = fileUrl.split('/');
         String fileName = fileUrl == 'null' ? '' : parts.last;
         print(fileName);
         String last20Chars = fileName.length <= 25 ? fileName : fileName.substring(fileName.length - 25);
         print(last20Chars);
         fileNameController.text = last20Chars;
       }
       print('selectedTaskStatusTypeId - $selectedTaskStatusTypeId');
       serviceProviderId = tasks['service_provider_id'];
       print('serviceProviderId - $serviceProviderId');

       print('Tasks - $tasks');
       _fetchMemberNames();
       _loadTaskMemberSummaries();

      // Do something with the task details
    }
  }


  @override
  void initState() {
    super.initState();
    fetchTaskDetails();
    _fetchTaskStatusTypes(); // Fetch task status types when the screen initializes
    _fetchServiceProviderTypes();
  }


  Future<void> _fetchServiceProviderTypes() async {
    try {
      final http.Response response = await TaskApi.fetchServiceProviderTypes();

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
    final taskMembers = tasks['task_members'] as List<dynamic>?;

    if (taskMembers != null) {
      setState(() {
        memberNames = taskMembers
            .map((member) => member['member']?['name'] as String?)
            .where((name) => name != null)
            .map((name) => name!)
            .toList();

        if (taskMembers.isNotEmpty) {
          memberId = taskMembers[0]['member_id'];
          print('memberID - $memberId');
        }
      });
    }

    print("members: $taskMembers");
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
    DateTime initialDate = DateTime.now();
    if (_dueDateController.text.isNotEmpty) {
      initialDate = DateFormat('dd MMM yyyy').parse(_dueDateController.text);
    }
    if (initialDate.isBefore(DateTime.now())) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
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


  Future<void> _updateAttachment(String fileType, String url) async {
    print('fileType - $fileType');
    print('url - $url');
    setState(() {
      _fileNames.add(fileName);
    });
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
          'query': updateTaskAttachmentsQuery,
          'variables': {
            'taskId':widget.taskId,
            'fileType': fileType,
            'url': url,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Attachment Updated Successfully');
        print('Response Body: ${response.body}');
        // ignore: use_build_context_synchronously
        showCustomAttachmentAddedBar(context, "Added");
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error updating attachment: $error');
    }

  }



  Future<void> _showAttachmentDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.h),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Text(
                          'Add Attachment',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Divider(
                          height: 20.0.h,
                          thickness: 1,
                        ),
                        // if (fileUrl != null && fileUrl != 'null')
                        Column(
                          children: [
                            pickedFile != null
                                ? Image.file(
                              pickedFile!,
                              width: 300.w,
                              height: 300.h,
                            )
                                : fileUrl != null && fileUrl != 'null'
                                ? Image.network(
                              fileUrl,
                              width: 300.w,
                              height: 300.h,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            )
                                : const SizedBox.shrink(),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      pickedFileName == null ? fileNameController.text : pickedFileName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // IconButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       pickedFile = null;
                                //       pickedFileName = null;
                                //       fileNameController.clear();
                                //     });
                                //   },
                                //   icon: const Icon(Icons.delete),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the bottom sheet
                                  },
                                  icon: const Icon(Icons.cancel),
                                  iconSize: 30.sp,
                                  color: Colors.red, // Customize the color as needed
                                ),
                                Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    pickedFile = await pickImageFromCamera();
                                    pickedFileName = pickedFile?.path.split('/').last;
                                    String? trimmedText = pickedFileName!.length <= 20
                                        ? pickedFileName
                                        : pickedFileName?.substring(0, 20);
                                    fileType = pickedFile?.path.split('.').last;

                                    setState(() {
                                      fileNameController.text = '$trimmedText.$fileType';
                                    });
                                    Navigator.of(context).pop(); // Close the bottom sheet
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  iconSize: 30.sp,
                                  color: Colors.blue, // Customize the color as needed
                                ),
                                Text(
                                  'Camera',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    pickedFile = await pickFile();
                                    pickedFileName = pickedFile?.path.split('/').last;
                                    fileType = pickedFile?.path.split('.').last;
                                    String? trimmedText = pickedFileName!.length <= 20
                                        ? pickedFileName
                                        : pickedFileName?.substring(0, 20);
                                    if (_isMounted) {
                                      setState(() {
                                        fileNameController.text = '$trimmedText.$fileType';
                                      });
                                    }
                                    Navigator.of(context).pop(); // Close the bottom sheet
                                  },
                                  icon: const Icon(Icons.add),
                                  iconSize: 30.sp,
                                  color: Colors.green, // Customize the color as needed
                                ),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  Future<File?> pickFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.any,
        //allowMultiple: true, // Allow multiple files to be picked
        //allowedExtensions: ['png', 'pdf', 'jpeg', 'jpg'],
      );

      if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
        return File(pickedFiles.files.first.path ?? '');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return null;
  }



  void _loadTaskMemberSummaries() {
    if (tasks.containsKey('member_summaries')) {
      print('task summaries $tasks');

      List<dynamic>? memberSummaries = tasks['member_summaries'];
      print(tasks['id']);

      if (tasks['task'] != null) {
        List<dynamic> taskMembers = tasks['task']['task_members'];
        print('taskMembers - $taskMembers');
        if (taskMembers.isNotEmpty) {
          memberId = taskMembers[0]['member']['id'];
          print('memberID - $memberId');
        }
      }

      if (memberSummaries != null) {
        // Iterate through member summaries and extract notes
        for (var summary in memberSummaries) {
          String? notes = summary['notes'];
          if (notes != null) {
            setState(() {
              taskSummaries.add(notes);
            });
          }
        }
      }
    } else {
      print('Member summaries not found in tasks.');
    }
  }



  void _handleSubmitted(String message) async {

    if(message.isNotEmpty) {
      setState(() {
        taskSummaries.add(message);
      });

      try {
        String accessToken = await getFirebaseAccessToken();
        // Define your GraphQL mutation with variables
        String mutation = ''; // Initialize to a default value
        Map<String, dynamic> variables = {}; // Initialize to an empty map
        // If selectedTaskMember has data, use task-related variables
        mutation =
            insertTaskChatSummaries; // Define your task-specific mutation
        variables = {
          'taskId': widget.taskId,
          'memberId': memberId,
          'notes': message,
          // Add other task-related variables as needed
        };

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
    else {
      print('empty summary');
      }
  }

  Future<void> uploadFile(String pickedFileName, String filePath) async {
    print(pickedFileName);
    print(filePath);
    try {
      String accessToken = await getFirebaseAccessToken();
      var request = http.MultipartRequest(
        'POST',
        //Uri.parse('https://prayojana-api-v1.slashdr.com/rest/files/upload/member/$memberId?image'),
        Uri.parse(ApiConstants.awsUrl(memberId)),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        filePath,
        contentType: MediaType('image', 'jpg'),
      ));
      request.headers.addAll({
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      });

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        String responseBody = response.body;
        Map<String, dynamic> responseData = json.decode(responseBody);
        String? attachmentUrl = responseData['data']['image'];
        print(await response.body);
        print(attachmentUrl);
        print(fileType);
        if (fileType != null && attachmentUrl != null) {
          _updateAttachment(fileType!, attachmentUrl);
        } else {
          print('fileType or attachmentUrl is null');
        }
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }



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
      body: tasks.isEmpty ?
      Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      ) :
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.0.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0.h),
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
                      padding: EdgeInsets.only(right: 20.0.w, top: 25.0.h),
                      child: ElevatedButton(
                        onPressed: isFormChanged ? _updateTask : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                          backgroundColor: isFormChanged ? Colors.blue : Colors.grey, // Change colors as needed
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
                padding: EdgeInsets.only(left: 10.0.w, right: 16.0.w),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 20.0.h, bottom: 10.0.h, left: 20.0.w),
                      child: Text(
                        tasks['task_title'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: tasks['task_status_type_id'] == 1
                              ? Color(int.parse('0xFF${tasks['task_status_type']['color'].substring(1)}'))
                              : Colors.black, // Change to default color if condition is not met
                        ),
                      ),
                    ),
                    buildInfoColumn('Members', Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (String memberName in memberNames)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              backgroundColor: const Color(0xffe1f2ff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Adjust the radius to make it more squared
                              ),
                              label: Text(
                                memberName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
                      ],
                    ), 'assets/icons/Users.png',),

                    buildInfoColumn('Due Date', InkWell(
                      onTap: () {
                        _selectDate(context); // Function to open date picker
                        isFormChanged = true;

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dueDateController.text, // Display selected date
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        ],
                      ),
                    ),'assets/icons/Calendar.png',),


                    buildInfoColumn('Time', InkWell(
                      onTap: () async {
                        await _selectTime(context);
                        isFormChanged = true;

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _timeController.text, // Display selected time
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        ],
                      ),
                    ), 'assets/icons/Clock.png',),

                    buildInfoColumn('Assigned by', Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            backgroundColor: const Color(0xfff8e4ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Adjust the radius to make it more squared
                            ),
                            label: Text(
                              tasks['user']['name'] ?? 'N/A', // Added a null check for user name
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),'assets/icons/User circle.png'),
                buildInfoColumn ('', DropdownButtonFormField2<int>(
                      focusNode: _dropdownFocusNode,
                      value: selectedTaskStatusTypeId ?? tasks['task_status_type_id'],
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
                  iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                  dropdownStyleData: DropdownStyleData(
                        maxHeight: 200.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                      ),
                      decoration:  InputDecoration(
                        label: const Text('Status'),
                        labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp),

                      ),
                      onChanged: (newValue) {
                        setState(() {
                          isFormChanged = true;
                          _dropdownFocusNode.unfocus();
                          selectedTaskStatusTypeId = newValue;
                          selectedTaskStatusType = taskStatusTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                          print(newValue);
                          print(selectedTaskStatusTypeId);
                          print(selectedTaskStatusType);
                        });
                      },
                    ),'assets/icons/Lightning bolt.png',),
                    buildInfoColumn( '', DropdownButtonFormField2<int>(
                      hint: SizedBox(
                        //Set a fixed width for the hint text
                        child: Text(
                          tasks['service_provider']['service_provider_type']['name'],
                          style: const TextStyle(fontWeight: FontWeight.normal),
                          maxLines: 1, // Limit to one line
                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                        ),
                      ),                      value:null,//widget.task['service_provider']['service_provider_type']['id'],
                      items: distinctServiceProviderTypes.map((provider) {
                        final serviceProviderId = provider['id'] as int;
                        final serviceProviderTypeName = provider['service_provider_type']['name'] as String;
                        //print(widget.task['service_provider']['service_provider_type']['id'],);
                        //print(serviceProviderTypeName);
                        //print(provider['service_provider_type_id']);
                        return DropdownMenuItem<int>(
                          value: serviceProviderId,
                          child: SizedBox(
                            width: 200.w, // Set a fixed width for the DropdownMenuItem
                            child: Text(
                              serviceProviderTypeName,
                              maxLines: 1, // Limit to one line
                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                            ),
                          ),
                        );
                      }).toList(),
                      iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                      ),
                      decoration:  InputDecoration(
                        label: const Text('Service Provider'),
                        labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          serviceProviderId = newValue;
                          isFormChanged = true;

                        });
                      },
                    ),'assets/icons/Briefcase.png',),
                    buildInfoColumn('', Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: fileNameController,
                          readOnly: true,
                          onTap: () async {
                            _showAttachmentDialog(context);
                            isFormChanged = true;

                          },
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                          decoration:  InputDecoration(
                            label: const Text('Attachments'),
                            labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp,color: Colors.blue),
                            hintText: 'Photos, documents etc..',
                            suffixIcon:  IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: Colors.blue,
                              onPressed: () {
                                if(pickedFile!=null) {
                                  print('on pressed - $pickedFile');
                                  var filepath = pickedFile!.path;
                                  uploadFile(pickedFileName!, pickedFile!.path);
                                }
                              },
                            )
                            //suffixIcon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),'assets/icons/Paper clip.png',),
                    buildInfoColumn( '',TextFormField(
                      controller: _notesController,
                      onChanged: (text) {
                        setState(() {
                          isFormChanged = true;
                        });
                      },
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Notes'),
                          ],
                        ),
                        labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                        hintText: 'enter here',
                      ),
                    ),'assets/icons/Document add.png',),
                    buildInfoColumn(
                      'Summaries',
                      Column(
                        children: [
                          TextField(
                            controller: _taskSummaryController, // Attach the TextEditingController
                            onSubmitted: _handleSubmitted,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                            maxLines: null, // Allow multiple lines of input
                            decoration:  InputDecoration(
                              labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp),
                              hintText: 'enter here',
                              suffixIcon: IconButton(
                                icon:const Icon(Icons.add),
                                color: const Color(0xff999999),
                                onPressed: () {
                                  if(_taskSummaryController.text.isNotEmpty) {
                                    _handleSubmitted(_taskSummaryController.text);
                                    _taskSummaryController.clear();
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h,),
                          IntrinsicHeight(
                            child: Column(
                              children: List.generate(taskSummaries.length, (index) {
                                return Container(
                                  width: ScreenUtil().screenWidth,
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfffdf9dc), // Customize the background color as needed
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(16.0.h), // Add padding to the text
                                          child: Text(
                                            taskSummaries[index],
                                            style: TextStyle(
                                              fontSize: 12.sp, // Set font size to 12
                                              fontWeight: FontWeight.w400, // Set font weight
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      'assets/icons/document.png',
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

  String? selectedTaskStatusType; // Store the selected task status type
}
