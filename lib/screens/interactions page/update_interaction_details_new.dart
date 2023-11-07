import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../models/summaries_chat.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import '../tasks page/create_new_task_new.dart';

class InteractionDetailsScreenNew extends StatefulWidget {

  final int interactionId;

  const InteractionDetailsScreenNew({Key? key, required this.interactionId}) : super(key: key);

  @override
  State<InteractionDetailsScreenNew> createState() => _InteractionDetailsScreenNewState();
}

class _InteractionDetailsScreenNewState extends State<InteractionDetailsScreenNew> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final TextEditingController fileNameController = TextEditingController(); // Add this line
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
  List<String> interactionSummaries = [];
  Map<String, dynamic> selectedInteractionMember = {}; // Add this line
  bool isFormChanged = false;
  bool _isMounted = true;
  File? pickedFile; // Store the picked file
  String? pickedFileName; // Store the file name
  String? attachmentUrl;
  String? errorAttachment;
  String? fileType;
  var fileUrl;




  // final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _interactionController = TextEditingController();
  final TextEditingController _interactionSummaryController = TextEditingController();



  @override
  void initState() {
    super.initState();
    fetchInteractionDetails();
    _fetchInteractionTypes();
    _fetchInteractionStatusTypes();
  }

  Future<void> fetchInteractionDetails() async {
    List<dynamic> interactionDetails = await InteractionApi().getInteractionDetails(widget.interactionId);
    // Now you can use the taskDetails list in this page
    if (interactionDetails.isNotEmpty) {
      selectedInteractionMember = interactionDetails[0];
      _dueDateController.text = formatDueDate(selectedInteractionMember['interaction']['interaction_date'] ?? '');
      _interactionController.text = selectedInteractionMember['interaction']['title'];
      _notesController.text = selectedInteractionMember['interaction']['notes'];
      selectedInteractionStatusTypeId = selectedInteractionMember['interaction']['interaction_status_type_id'];
      selectedInteractionTypeId = selectedInteractionMember['interaction']['interaction_type_id'];
      //fileUrl = selectedInteractionMember['interaction']['interaction_attachements']['url'];
      //print('fileUrl - $fileUrl');

      print('selectedInteractionMember - $selectedInteractionMember');
      _fetchMemberName();
      _loadInteractionMemberSummaries();
      // Do something with the task details
    }
  }

  void _fetchMemberName() {
    final memberName = selectedInteractionMember['member']['name'] as String?;
    if (memberName != null) {
      setState(() {
        memberNames = [memberName];
      });
    }
    print('memberName - $memberNames');
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
        print(interactionStatusTypes);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching task status types: $error');
    }
  }


  Future<void> _updateAttachment(String fileType, String url) async {
    print('fileType - $fileType');
    print('url - $url');
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
            'interactionId': selectedInteractionMember['interaction']['id'],
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





  Future<void> _showAttachmentDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Attachment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pickedFile != null && pickedFile!.path.endsWith('.jpg')) // Check if the picked file is an image
                      Column(
                        children: [
                          pickedFile != null
                              ? Image.file(
                            pickedFile!,
                            width: 300.w,
                            height: 300.h,
                          )
                              : fileUrl != null
                              ? Image.network(
                            fileUrl,
                            width: 300.w,
                            height: 300.h,
                          )
                              : SizedBox.shrink(),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pickedFileName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    pickedFile = null;
                                    pickedFileName = null;
                                    fileNameController.clear();
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (pickedFile != null && !pickedFile!.path.endsWith('.jpg')) // Check if the picked file is not an image
                      Column(
                        children: [
                          Text(
                            pickedFileName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'File type: ${pickedFile?.path.split('.').last}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    pickedFile = null;
                                    pickedFileName = null;
                                    fileNameController.clear();
                                  });
                                },
                                icon: const Icon(Icons.delete),
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
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        pickedFile = await pickImageFromCamera();
                        pickedFileName = pickedFile?.path.split('/').last;
                        String? trimmedText = pickedFileName!.length <= 20
                            ? pickedFileName
                            : pickedFileName?.substring(0, 20);
                        String? fileType = pickedFile?.path.split('.').last;

                        setState(() {
                          fileNameController.text = '$trimmedText.$fileType';
                        });
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Camera'),
                    ),
                    TextButton(
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
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Add'),
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


  Widget buildInfoColumn(String title, Widget content, String assetImagePath) {
    if(title.isEmpty)
      print(title);
    return Padding(
      padding: EdgeInsets.only( left: 20.w,top: 15.h),
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



  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_dueDateController.text.isNotEmpty) {
      initialDate = DateFormat('dd MMM yyyy').parse(_dueDateController.text);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
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

  void _loadInteractionMemberSummaries() {
    // You can access the selectedInteractionMember using widget.selectedInteractionMember
    // Assuming member_summaries is an array of objects
    print('interaction summaries ${selectedInteractionMember}');
    if(selectedInteractionMember!=null){
      List<dynamic>? memberSummaries = selectedInteractionMember['interaction']['member_summaries'];

      if (memberSummaries != null) {
        // Iterate through member summaries and extract notes
        for (var summary in memberSummaries) {
          String? notes = summary['notes'];
          if (notes != null) {
            setState(() {
              interactionSummaries.add(notes);
            });
          }
        }
      }
    }
  }



  Future<void> _updateInteraction() async {
    String accessToken = await getFirebaseAccessToken();

    if (selectedInteractionStatusTypeId == null || selectedInteractionTypeId == null || _dueDateController.text.isEmpty || _interactionController.text.isEmpty || _interactionController.text == '') {
      // Display an error message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please ensure all the field are filled .'),
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
          'id': selectedInteractionMember['interaction']['id'],
          'interactionTypeId': selectedInteractionTypeId,
          'interactionStatusTypeId': selectedInteractionStatusTypeId,
          'newNotes': _notesController.text,
          'newTitle': _interactionController.text,
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



  void _handleSubmitted(String message) async {
    setState(() {
      interactionSummaries.add(message);
    });

    try {
      String accessToken = await getFirebaseAccessToken();
      // Define your GraphQL mutation with variables
      String mutation = ''; // Initialize to a default value
      Map<String, dynamic> variables = {}; // Initialize to an empty map
        // If selectedInteractionMember has data, use interaction-related variables
        mutation = insertInChatSummaries;
        variables = {
          'memberId': selectedInteractionMember['member_id'],
          'notes': message,
          'interactionId': selectedInteractionMember['interaction']['id'],
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


  Future<void> uploadFile(String pickedFileName , String filePath) async {
    print(pickedFileName);
    print(filePath);
    try {
      String accessToken = await getFirebaseAccessToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://prayojana-api-v1.slashdr.com/rest/files/upload/member/50?image'),
      );
      request.files.add(await http.MultipartFile.fromPath(
          'image', filePath,
          contentType: MediaType('image', 'jpg')
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
        String attachmentUrl = responseData['data']['image'];
        print(await response.body);
        _updateAttachment(fileType!, attachmentUrl);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    // final selectedInteractionMember = widget.selectedInteractionMember;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: selectedInteractionMember == null || selectedInteractionMember.isEmpty ?
      Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      )
      : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0.h),
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
                        isFormChanged ? _updateInteraction() : null;
                      },
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
              padding: EdgeInsets.only(left: 16.0.w, right: 16.0.w),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 30.0.h, bottom: 20.0.h, left: 20.0.w),
                    child: Text(
                      selectedInteractionMember['interaction']['title'],
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
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
                  ),'assets/icons/Users.png'),
                  buildInfoColumn('Date', InkWell(
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
                  ),'assets/icons/Calendar.png'),

                  buildInfoColumn( '',TextFormField(
                    controller: _interactionController, // Attach the TextEditingController
                    onChanged: (text) {
                      setState(() {
                        isFormChanged = true;
                      });
                    },
                    maxLengthEnforcement: MaxLengthEnforcement.enforced, // Enforce the maximum length
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    maxLength: 35, // Set the maximum length to 30 characters
                    decoration: const InputDecoration(
                      label: Text('Edit Title'),
                    ),
                  ),'assets/icons/Interactions (1).png'),

                  buildInfoColumn( '', DropdownButtonFormField2<int>(
                    focusNode: _dropdownFocusNode,
                    value: selectedInteractionTypeId ?? selectedInteractionMember['interaction']['interaction_type_id'],
                    items: interactionTypes.map((statusType) {
                      print('type id ${selectedInteractionMember['interaction']['interaction_type_id']}');
                      print('selectedInteractionTypeId $selectedInteractionTypeId');
                      print('typename ${statusType['name']}');
                      print(selectedInteractionMember['interaction']['id']);
                      print(selectedInteractionMember['member_id']);
                      return DropdownMenuItem<int>(
                        value: statusType['id'],
                        child: Text(
                          statusType['name'],
                        ),
                      );
                    }).toList(),

                    onChanged: (newValue) {
                      setState(() {
                        isFormChanged = true;
                        _dropdownFocusNode.unfocus();
                        selectedInteractionTypeId = newValue;
                        selectedInteractionType = interactionTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                        print('newValue $newValue');
                        print('selectedInteractionTypeId $selectedInteractionTypeId');
                        print('selectedInteractionType $selectedInteractionType');
                      });
                    },
                    decoration:  InputDecoration(
                      label: const Text('Interaction Type'),
                      labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp),
                    ),
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                  ),'assets/icons/Chat alt 2.png'),
                  buildInfoColumn('', DropdownButtonFormField2<int>(
                    focusNode: _dropdownFocusNode,
                    value: selectedInteractionStatusTypeId ?? (selectedInteractionMember['interaction'] != null
                        ? selectedInteractionMember['interaction']['interaction_status_type_id']
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
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                    onChanged: (newValue) {
                      setState(() {
                        isFormChanged = true;
                        _dropdownFocusNode.unfocus();
                        selectedInteractionStatusTypeId = newValue;
                        selectedInteractionStatusType = interactionStatusTypes.firstWhere((statusType) => statusType['id'] == newValue)['name'];
                        print('newvalue $newValue');
                        print('selectedInteractionStatusTypeId $selectedInteractionStatusTypeId');
                        print('selectedInteractionStatusType $selectedInteractionStatusType');
                      });
                    },
                    decoration:  InputDecoration(
                      label: const Text('Status'),
                      labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                  ),'assets/icons/Lightning bolt.png'),
                  buildInfoColumn( '',TextFormField(
                    controller: _notesController, // Attach the TextEditingController
                    onChanged: (text) {
                      setState(() {
                        isFormChanged = true;
                      });
                    },
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    maxLength: 40, // Set the maximum length to 30 characters
                    maxLengthEnforcement: MaxLengthEnforcement.enforced, // Enforce the maximum length
                    decoration: const InputDecoration(
                      label: Text('Notes'),
                    ),
                  ),'assets/icons/Document add.png'),
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
                          labelStyle: TextStyle(fontWeight:FontWeight.w500,fontSize: 16.sp,),
                          hintText: 'Photos, documents etc..',
                          suffixIcon: IconButton(
                            icon:const Icon(Icons.add),
                            color: const Color(0xff999999),
                            onPressed: () {
                              isFormChanged = true;

                              print('on pressed - $pickedFile');
                              var filepath = pickedFile!.path;
                              // print('pickedFile path - $filepath');
                              uploadFile(pickedFileName! , pickedFile!.path);
                            },
                          ),
                          //suffixIcon: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),'assets/icons/Paper clip.png',),

                  Padding(
                    padding: EdgeInsets.only(top: 30.0.h,bottom: 25.h),
                    child: Align(
                      alignment: Alignment.bottomLeft, // Adjust the alignment as needed
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0.w),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateTaskNew(memberId: selectedInteractionMember['member_id']), // Pass the memberId
                              ),
                            );
                          },
                          icon: Icon(Icons.add, size: 16.sp),
                          label: const Text("Add New Task",
                            style: TextStyle(
                              color: Color(0xff006bbf),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                            backgroundColor: const Color(0xffe1f2ff),// Adjust the padding as needed
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  buildInfoColumn(
                    'Summaries',
                    Column(
                      children: [
                        TextField(
                          controller: _interactionSummaryController, // Attach the TextEditingController
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
                                if(_interactionSummaryController.text.isNotEmpty){
                                  _handleSubmitted(_interactionSummaryController.text);
                                  _interactionSummaryController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h,),
                        IntrinsicHeight(
                          child: Column(
                            children: List.generate(interactionSummaries.length, (index) {
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
                                          interactionSummaries[index],
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     _openChatPage();
      //   },
      //   label: const Text('Summaries'),
      //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Set the button size
      // ),
    );
  }
}
