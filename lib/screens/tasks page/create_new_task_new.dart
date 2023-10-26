import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Member {
  final int id;
  final String name;

  Member({required this.id, required this.name});
}
class CreateTaskNew extends StatefulWidget {
  final int? memberId; // Add the memberId parameter

  const CreateTaskNew({Key? key, this.memberId}) : super(key: key);

  @override
  State<CreateTaskNew> createState() => _CreateTaskNewState();
}

class _CreateTaskNewState extends State<CreateTaskNew> {


  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskNotesController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<Member> _selectedMembers = [];
  List<dynamic> serviceProviderTypes = [];
  Member? _selectedMember;
  List<Member> _availableMembers = []; // List of available members for the dropdown
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? serviceProviderTypeId;
  int? serviceProviderId;
  int taskStatusTypeId = 1;
  late int careBuddyId;
  int createdBy = 8;
  bool isLoading = false;
  FilePickerResult? result;
  PlatformFile? pickedfile;
  List<String> _fileNames = [];
  List<File> fileToDisplay = [];

  @override
  void initState() {
    super.initState();
    getCareBuddyId();
    _fetchAvailableMembers();
    _fetchServiceProviderTypes();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('dd MMM yyyy').format(_selectedDate!); // Update the text field
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

  Future<void> _insertTask() async {
    print('carebuddy - $careBuddyId');
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

    String graphQLMutation = '''
  {
    "query": "mutation MyMutation{ insert_task_members(objects: {task: { data: { carebuddy_id: $careBuddyId, task_title: \\"${_taskTitleController.text}\\", task_notes: \\"${_notesController.text}\\", service_provider_id: $serviceProviderId, task_status_type_id: 1, created_by: $careBuddyId, task_attachements: {data: {file_type: \\"pdf\\", url: \\"http://cggvbhbbn\\"}}, due_date: \\"${_dueDateController.text}\\", due_time: \\"${_timeController.text}\\" } }, member_id: ${_selectedMember!.id} })
    { returning 
    { 
    task 
    { carebuddy_id 
    task_title
    task_notes
    interaction_id
    service_provider_id
    task_status_type_id
    created_by
    user{ name 
    }
    task_attachements 
    { 
    file_type
    url
    task_id
    } 
    id 
    due_date
    due_time
    task_status_type
    { name 
    } 
    service_provider 
    {
    name 
    service_provider_type_id 
    service_provider_type
    { 
    name
    } 
    } 
    } 
    member_id 
    member 
    {
    name
    }
    }
    }
    }",
    "variables": {}
  }
''';


    request.body = graphQLMutation;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      print('Inserted Task Data: $responseData');
      Navigator.pop(context, true);// Print the inserted task data
      // Perform any necessary UI updates or navigation here
    } else {
      print('API Error: ${response.reasonPhrase}');
      // Handle error scenario here
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

  String formatTime(String? time) {
    if (time == null) {
      return ''; // Or any default value you want to use for empty time
    }

    final originalFormat = DateFormat('HH:mm:ss');
    final newFormat = DateFormat('hh:mm a');

    final dateTime = originalFormat.parse(time);
    return newFormat.format(dateTime);
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


  Widget buildInfoColumn(Widget content, String assetImagePath) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
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



  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskNotesController.dispose();
    super.dispose();
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
                          _insertTask();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 22.w),
                        ),
                        child: Text(
                          'Done',
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
                padding: EdgeInsets.only(left: 20.0.w ,right:20.0.w,top: 40.0.h),
                child: TextFormField(
                  controller: _taskTitleController,
                  decoration: InputDecoration(
                    hintText: 'Task Title',
                    hintStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600 ,
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
              // const SizedBox(height: 40.0),
              // if (_selectedMembers.isNotEmpty)
              //   Wrap(
              //     spacing: 8.0,
              //     children: _selectedMembers.map((Member member) {
              //       return Chip(
              //         label: Text(member.name),
              //         onDeleted: () {
              //           setState(() {
              //             _selectedMembers.remove(member);
              //             print('Selected Member: $_selectedMembers');
              //           });
              //         },
              //       );
              //     }).toList(),
              //   ),

              buildInfoColumn(InputDecorator(
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: 16.sp),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
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
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                    items: _availableMembers.map((Member member) {
                      return DropdownMenuItem<Member>(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250.h,
                      width: 250.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return _availableMembers.map<Widget>((Member member) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:  EdgeInsets.only(right: 6.0.h),
                            child: Chip(
                              backgroundColor: const Color(0xffe1f2ff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Adjust the radius to make it more squared
                              ),
                              label: Text(
                                member.name,
                                style: const TextStyle(
                                  color: Color(0xff374151),// Customize the color as needed
                                ),
                              ),
                              // onDeleted: () {
                              //   setState(() {
                              //     _selectedMembers.remove(member);
                              //   });
                              // },
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),'assets/icons/Users.png'),

              buildInfoColumn(TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: () async {
                  await _selectDate(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Due Date *',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),'assets/icons/Calendar.png',),


              buildInfoColumn(TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () async {
                  await _selectTime(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Time',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),'assets/icons/Clock.png',),

              buildInfoColumn(InputDecorator(
                decoration: InputDecoration(
                  //labelText: 'Service Provider*',
                  labelStyle: TextStyle(fontSize: 18.sp),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    hint: const Text('Service Provider'),
                    isExpanded: true,
                    value: serviceProviderId,
                    iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down),),
                    onChanged: (newValue) {
                      setState(() {
                        serviceProviderId = newValue;
                      });
                    },
                    items: distinctServiceProviderTypes.map((provider) {
                      final serviceProviderId = provider['id'] as int;
                      final serviceProviderTypeName =
                      provider['service_provider_type']['name'] as String;
                      return DropdownMenuItem<int>(
                        value: serviceProviderId,
                        child: Text(serviceProviderTypeName),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300.h,
                      width: 300.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return distinctServiceProviderTypes.map<Widget>((provider) {
                        final serviceProviderTypeName =
                        provider['service_provider_type']['name'] as String;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child:Text(
                            serviceProviderTypeName,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),'assets/icons/Briefcase.png',),

              buildInfoColumn( TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Add Notes',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),'assets/icons/Document add.png',),

              buildInfoColumn( TextFormField(
                readOnly: true,
                onTap: () async {
                  _showAttachmentDialog(context);
                },
                decoration: const InputDecoration(
                  labelText: 'Add an Attachment',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey,),
                  ),
                ),
              ),'assets/icons/Paper clip.png',),
            ],
          ),
        ),
      ),
    );
  }
}
