import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tasks page/create_new_task.dart';
import '../tasks page/create_new_task_new.dart';

class Member {
  final int id;
  final String name;

  Member({required this.id, required this.name});
}

class CreateInteractionNew extends StatefulWidget {
  const CreateInteractionNew({super.key});

  @override
  State<CreateInteractionNew> createState() => _CreateInteractionNewState();
}

class _CreateInteractionNewState extends State<CreateInteractionNew> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<Map<String, dynamic>> interactionStatusTypes = [];
  final List<Member> _selectedMembers = [];
  List<Map<String, dynamic>> interactionTypes = [];
  List<dynamic> serviceProviderTypes = [];
  int? selectedInteractionTypeId;
  int? selectedInteractionStatusTypeId;
  List<String> memberNames = [];
  Member? _selectedMember;
  List<Member> _availableMembers = []; // List of available members for the dropdown
  final _dropdownFocusNode = FocusNode();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String? selectedInteractionType;
  String? selectedInteractionStatusType;
  int? serviceProviderTypeId;
  int? serviceProviderId;
  TimeOfDay? _selectedTime;
  bool isLoading = false;
  late int careBuddyId;
  FilePickerResult? result;
  PlatformFile? pickedfile;
  List<String> _fileNames = [];
  List<File> fileToDisplay = [];


  @override
  void initState() {
    super.initState();
    _fetchInteractionTypes();
    _fetchServiceProviderTypes();
    _fetchAvailableMembers();
    _fetchInteractionStatusTypes();
  }

  Future<List<Member>> getAllMembers() async {
    String accessToken = await getFirebaseAccessToken();
    var headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.memberListUrl),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? memberData = responseData['memberData'];
      careBuddyId = responseData['user_id'];
      print(careBuddyId);

      if (memberData != null) {
        List<Member> allMembers = memberData.map((member) {
          return Member(id: member['id'], name: member['name']);
        }).toList();
        print(allMembers);
        return allMembers;
      } else {
        print('List Empty');
        return [];
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
      return [];
    }
  }


  Future<void> _fetchAvailableMembers() async {
    List<Member> availableMembers = await getAllMembers();
    setState(() {
      _availableMembers = availableMembers;
    });
    for (Member member in _availableMembers) {
      print('Available Member: ${member.name}');
    }
  }

  void _handleMemberSelection(Member selectedMember) {
    // Handle the selected member
    print('Selected Member: ${selectedMember.name}');
    print('Selected MemberId: ${selectedMember.id}');

    if (!_selectedMembers.any((element) => element.id == selectedMember.id)) {
      setState(() {
        _selectedMembers.add(selectedMember);
        print('Selected Members List:');
        _selectedMembers.forEach((selected) {
          print('Name: ${selected.name}, ID: ${selected.id}');
        });
      });
    }
  }

  Future<void> uploadFile(String path) async {
    var url = 'https://s3.ap-south-1.amazonaws.com/prayojana.attachments/Attachments';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    File file = File(path);
    List<int> bytes = await file.readAsBytes();
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: 'file.jpg');

    request.files.add(multipartFile);
    request.fields.addAll({'key': path.split('/').last, 'acl': 'public-read'});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      print('File uploaded successfully!');
    } else {
      print('Error uploading file. Status code: ${response.statusCode}');
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


  Widget buildInfoColumn(Widget content, String assetImagePath) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 15.h, right: 20.w),
      child: Column(
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

  Future<void> _insertInteraction() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      var headers = {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      };

      var request = http.Request(
        'POST',
        Uri.parse(ApiConstants.graphqlUrl),
      );

      // Construct your GraphQL mutation here
      String graphQLMutation = '''
      mutation MyMutation {
        insert_interaction_members(objects: {
          member_id: ${_selectedMember!.id},
          interaction: {
            data: {
              carebuddy_id: $careBuddyId,
              interaction_date: "${_dueDateController.text}",
              interaction_time: "${_timeController.text}",
              interaction_type_id: $selectedInteractionTypeId,
              notes: "${_notesController.text}",
              title: "${_taskTitleController.text}",
              interaction_attachements: {
                data: {
                  url: "https://qwerty1234gy"
                }
              },
              interaction_status_type_id: "$selectedInteractionStatusTypeId",
            }
          }
        }) {
          returning {
            interaction {
              title
              notes
              carebuddy_id
              interaction_date
              interaction_time
              interaction_type_id
              interaction_status_type_id
              interaction_attachements {
                url
                id
                interaction_id
              }
              member_summaries {
                notes
                member_id
              }
              interaction_status_type {
                name
                id
              }
              interaction_type {
                id
                name
              }
            }
            member {
              name
              is_active
            }
          }
        }
      }
    ''';

      request.body = jsonEncode({'query': graphQLMutation});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        Map<String, dynamic> responseData = json.decode(responseString);
        print('Inserted Interaction Data: $responseData');
        Navigator.pop(context, true); // Print the inserted interaction data
        // Perform any necessary UI updates or navigation here
      } else {
        print('API Error: ${response.reasonPhrase}');
        // Handle error scenario here
      }
    } catch (error) {
      print('Error inserting interaction: $error');
    }
  }



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
                        padding: EdgeInsets.only(left: 16.12.w, top: 10.0.h),
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
                          _insertInteraction(); // Call the method to send data to the server
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                        ),
                        child: Text(
                          'Schedule',
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
                padding: EdgeInsets.only(top:25.0.h,left: 20.0.w,right: 20.0.w,bottom: 15.0.h),
                child: TextFormField(
                  controller: _taskTitleController,
                  maxLength: 35, // Set the maximum length to 30 characters
                  decoration: InputDecoration(
                    hintText: 'Interaction Title',
                    hintStyle: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff999999)
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Task title is required';
                    }
                    return null;
                  },
                ),
              ),
              buildInfoColumn(InputDecorator(
                decoration: const InputDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<Member>(
                    hint: const Text('Select Member'),
                    isExpanded: true,
                    value: _selectedMember,
                    onChanged: (Member? selectedMember) {
                      if (selectedMember != null) {
                        _handleMemberSelection(selectedMember);
                        setState(() {
                          _selectedMember = selectedMember;
                        });
                      }
                    },
                    items: _availableMembers.map((Member member) {
                      return DropdownMenuItem<Member>(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250.h,
                      width: 250.w, // Adjust this value to make the dropdown smaller
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: Colors.white,
                      ),
                    ),
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                    selectedItemBuilder: (BuildContext context) {
                      return _availableMembers.map<Widget>((Member member) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            backgroundColor: Color(0xffe1f2ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Adjust the radius to make it more squared
                            ),
                            label: Text(
                              member.name,
                              style: const TextStyle(
                                color: Color(0xff374151), // Customize the color as needed
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),'assets/icons/Users.png',),
              buildInfoColumn(TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: () {
                  _selectDate(context); // Function to open date picker
                },
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                decoration: const InputDecoration(
                  label: Text('Date*'),
                  //fillColor: Colors.grey[300],
                  hintText: '08 Aug 2023',
                ),
              ),'assets/icons/Calendar.png',),
              buildInfoColumn(TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () async {
                  await _selectTime(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Select Time',
                ),
              ),'assets/icons/Clock.png',),
              buildInfoColumn(DropdownButtonFormField2<int>(
                focusNode: _dropdownFocusNode,
                value: selectedInteractionTypeId,
                items: interactionTypes.map((statusType) {
                  //print('type id ${widget.selectedInteractionMember['interaction']['interaction_type_id']}');
                  print('selectedInteractionTypeId $selectedInteractionTypeId');
                  print('typename ${statusType['name']}');
                  //print(widget.selectedInteractionMember['interaction']['id']);
                  return DropdownMenuItem<int>(
                    value: statusType['id'],
                    child: Text(
                      statusType['name'],
                    ),
                  );
                }).toList(),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                ),
                iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
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
                decoration: const InputDecoration(
                  label: Text('Interaction Types'),
                  //filled: true,
                  hintText: 'select',
                ),
              ),'assets/icons/Chat alt 2.png'),
              // const Padding(
              //   padding: EdgeInsets.only(top: 20.0),
              //   child: Divider(// Adjust the height to control the thickness
              //     color: Colors.grey,  // Set the color of the divider
              //     endIndent: 20,
              //     indent: 20,
              //     //thickness: 1/2,
              //   ),
              // ),
              buildInfoColumn(DropdownButtonFormField2<int>(
                focusNode: _dropdownFocusNode,
                value: selectedInteractionStatusTypeId,
                hint: const Text('select'),
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
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                ),
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
                decoration: const InputDecoration(
                  label: Text('Status'),
                ),
              ),'assets/icons/Lightning bolt.png'),
              buildInfoColumn(TextFormField(
                controller: _notesController, // Attach the TextEditingController
                maxLength: 40, // Set the maximum length to 30 characters
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                maxLines: null, // Allow multiple lines of input
                decoration: const InputDecoration(
                  hintText: 'Add Notes...',
                  label: Text('Notes'),
                ),
              ),'assets/icons/Document add.png'),
              buildInfoColumn( Stack(
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
                    decoration: const InputDecoration(
                      label: Text('Attachments'),
                      hintText: 'Photos, documents etc..',
                      suffixIcon: Icon(Icons.add),
                    ),
                  ),
                ],
              ),'assets/icons/Paper clip.png'),

              Align(
                alignment: Alignment.bottomLeft, // Adjust the alignment as needed
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0.w,top: 30.h),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTaskNew(), // Pass the memberId
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
            ],
          ),
        ),
      ),

    );
  }
}
