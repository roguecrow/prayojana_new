import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../summaries_chat.dart';
import '../tasks page/create_new_task.dart';
import '../tasks page/create_new_task_new.dart';

class InteractionDetailsScreenNew extends StatefulWidget {

  final Map<String, dynamic> selectedInteractionMember;

  const InteractionDetailsScreenNew({
    Key? key,
    required this.selectedInteractionMember,
  }) : super(key: key);

  @override
  State<InteractionDetailsScreenNew> createState() => _InteractionDetailsScreenNewState();
}

class _InteractionDetailsScreenNewState extends State<InteractionDetailsScreenNew> {
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
  List<String> interactionSummaries = [];

  // final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _interactionController = TextEditingController();
  final TextEditingController _interactionSummaryController = TextEditingController();




  @override
  void initState() {
    super.initState();
    _dueDateController.text = formatDueDate(widget.selectedInteractionMember['interaction']['interaction_date'] ?? '');
    _interactionController.text = widget.selectedInteractionMember['interaction']['title'];
    _notesController.text = widget.selectedInteractionMember['interaction']['notes'];
    _fetchMemberName();
    _fetchInteractionTypes();
    _fetchInteractionStatusTypes();
    _loadInteractionMemberSummaries();
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
              title: const Text('Add Attachment'),
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
                      child: const Text('Camera'),
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
              interactionSummaries.add(notes);
            });
          }
        }
      }
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
          'memberId': widget.selectedInteractionMember['member_id'],
          'notes': message,
          'interactionId': widget
              .selectedInteractionMember['interaction']['id'],
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




  @override
  Widget build(BuildContext context) {
    // final selectedInteractionMember = widget.selectedInteractionMember;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
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
                    padding: EdgeInsets.only(top: 30.0.h, bottom: 20.0.h, left: 20.0.w),
                    child: Text(
                      widget.selectedInteractionMember['interaction']['title'],
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
                    maxLengthEnforcement: MaxLengthEnforcement.enforced, // Enforce the maximum length
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    maxLength: 30, // Set the maximum length to 30 characters
                    decoration: const InputDecoration(
                      label: Text('Edit Title'),
                    ),
                  ),'assets/icons/Interactions (1).png'),

                  buildInfoColumn( '', DropdownButtonFormField2<int>(
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
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
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
                    children: [
                      TextFormField(
                        readOnly: true,
                        onTap: () async {
                          _showAttachmentDialog(context);
                        },
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                        decoration: const InputDecoration(
                          label: Text('Attachment'),
                          suffixIcon: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),'assets/icons/Paper clip.png'),

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
                                builder: (context) => CreateTaskNew(memberId: widget.selectedInteractionMember['member_id']), // Pass the memberId
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
                                _handleSubmitted(_interactionSummaryController.text);
                                _interactionSummaryController.clear();
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
