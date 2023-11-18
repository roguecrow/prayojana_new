import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final TextEditingController _interactionTitleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<Map<String, dynamic>> interactionStatusTypes = [];
  final List<Member> _selectedMembers = [];
  List<Map<String, dynamic>> interactionTypes = [];
  List<dynamic> serviceProviderTypes = [];
  int? selectedInteractionTypeId;
  int? selectedInteractionStatusTypeId = 2;
  List<String> memberNames = [];
  Member? _selectedMember;
  List<Member> _availableMembers = []; // List of available members for the dropdown
  final _dropdownFocusNode = FocusNode();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController(); // Add this line
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
  bool _isMounted = true;
  File? pickedFile; // Store the picked file
  String? pickedFileName; // Store the file name
  String? attachmentUrl;
  var fileUrl;
  String? errorAttachment;
  String? fileType;
  bool isFormChanged = false;



  @override
  void initState() {
    super.initState();
    getCareBuddyId();
    _fetchInteractionTypes();
    _fetchServiceProviderTypes();
    _fetchAvailableMembers();
    _fetchInteractionStatusTypes();
  }


  Future<void> getCareBuddyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    careBuddyId = userId ?? 0; // Use 0 as a default value (or choose a suitable default)
    print('from local - $careBuddyId');
  }


  Future<void> _fetchAvailableMembers() async {
    List<Member> availableMembers;
    List<dynamic>? memberData = await MemberApi().getMemberNames();
    if (memberData != null) {
      List<Member> allMembers = memberData.map((member) {
        return Member(id: member['id'], name: member['name']);
      }).toList();
      availableMembers = allMembers;
      print(allMembers);
    } else {
      availableMembers = [];
      print('List Empty');
    }

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

  Future<void> uploadFile(String pickedFileName , String filePath) async {
    print(pickedFileName);
    print(filePath);
    try {
      String accessToken = await getFirebaseAccessToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://prayojana-api-v1.slashdr.com/rest/files/upload/member/${_selectedMember!.id}?image'),
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
        attachmentUrl = responseData['data']['image'];
        print(await response.body);
        print(attachmentUrl);
        // _updateAttachment(fileType!, attachmentUrl);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error uploading file: $error');
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
                              : const SizedBox.shrink(),
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
          print(interactionStatusTypes);
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
      if (_interactionTitleController.text.isEmpty ||
          selectedInteractionTypeId == null ||
          selectedInteractionStatusTypeId == null ||
          _dueDateController.text.isEmpty ||
          _timeController.text.isEmpty ||
          _selectedMember == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Missing Information'),
              content: const Text('Please fill in all the required fields.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Return early if any data is missing
      }

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
              title: "${_interactionTitleController.text}",
              interaction_attachements: {
                data: {
                  url: "$attachmentUrl",
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
                  controller: _interactionTitleController,
                  maxLength: 30, // Set the maximum length to 30 characters
                  decoration: InputDecoration(
                    hintText: 'Interaction Title*',
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
                    hint: const Text('Select Member*'),
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
                            backgroundColor: const Color(0xffe1f2ff),
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
                  labelText: 'Select Time*',
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
                  label: Text('Interaction Types*'),
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
              buildInfoColumn(TextFormField(
                controller: _notesController, // Attach the TextEditingController
                maxLength: 100, // Set the maximum length to 30 characters
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                maxLines: null, // Allow multiple lines of input
                decoration: const InputDecoration(
                  hintText: 'Add Notes...',
                  label: Text('Notes'),
                ),
              ),'assets/icons/Document add.png'),
              buildInfoColumn(
                TextFormField(
                  controller: fileNameController,
                  readOnly: true,
                  onTap: () async {
                    _showAttachmentDialog(context);
                  },
                  decoration: InputDecoration(
                      labelText: 'Add an Attachment',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon:const Icon(Icons.add),
                        color: const Color(0xff999999),
                        onPressed: () {

                          print('on pressed - $pickedFile');
                          var filepath = pickedFile!.path;
                          // print('pickedFile path - $filepath');
                          uploadFile(pickedFileName! , pickedFile!.path);
                        },
                      )
                  ),
                ),
                'assets/icons/Paper clip.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
