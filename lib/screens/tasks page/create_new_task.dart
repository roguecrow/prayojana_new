//in here member drop down field used down below

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../services/api_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Member {
  final int id;
  final String name;

  Member({required this.id, required this.name});
}

Future<List<Member>> fetchMembers() async {
  String accessToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjYzODBlZjEyZjk1ZjkxNmNhZDdhNGNlMzg4ZDJjMmMzYzIzMDJmZGUiLCJ0eXAiOiJKV1QifQ.eyJodHRwczovL2hhc3VyYS5pby9qd3QvY2xhaW1zIjp7IngtaGFzdXJhLWFsbG93ZWQtcm9sZXMiOlsidXNlciJdLCJ4LWhhc3VyYS1kZWZhdWx0LXJvbGUiOiJ1c2VyIiwieC1oYXN1cmEtYWRtaW4iOiJ0cnVlIn0sImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wcmF5b2phbmEtZmEwN2IiLCJhdWQiOiJwcmF5b2phbmEtZmEwN2IiLCJhdXRoX3RpbWUiOjE2OTI3ODgyMzMsInVzZXJfaWQiOiI0dE9zR01mVnFNZDYxeW15allDY2NSS0JockcyIiwic3ViIjoiNHRPc0dNZlZxTWQ2MXlteWpZQ2NjUktCaHJHMiIsImlhdCI6MTY5Mjc4ODIzMywiZXhwIjoxNjkyNzkxODMzLCJwaG9uZV9udW1iZXIiOiIrOTE5Njc3MzkwOTY1IiwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJwaG9uZSI6WyIrOTE5Njc3MzkwOTY1Il19LCJzaWduX2luX3Byb3ZpZGVyIjoicGhvbmUifX0.QDBqgWv3FdnLqawtmsJMMAOk04Ql4GqMES-MNVsldwkAlaCe9RbhQRNt3rlJ32gU0rBVSliABGACepEwJWMGA42YpvwGyfm4XgcSoz4IgtNjHwYyjqI-rXGvXklBhhWmQVammwmyDUfSUW41cELxv0muy42dRBpX39-EcrCAV4DoHXKE4Fw0tZTL1b3nQnWIpd7H7WuxnwW9X0IFdykGRnnAOOGNImvVDzQV0gS5q4mP-oIQe2UwYf4JnmHUkJTLXmPdJTQykfzTr6oHV3oKTgEBIVeSzxD96I0gy6loOJ9ZgYUVjkiXbPt4-uCW0WYaFpir_aopKmX740MfLdXlVQ';
    final Map<String, String> headers = {
    'Content-Type': ApiConstants.contentType,
    'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
    'x-hasura-admin-secret': ApiConstants.adminSecret,
    'Authorization': 'Bearer $accessToken',
    // Add other headers if needed
  };

  final http.Response response = await http.get(Uri.parse(ApiConstants.carebuddyMembersUrl), headers: headers);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> memberData = responseData['memberData'] ?? [];

    List<Member> members = memberData.map<Member>((member) {
      return Member(
        id: member['id'] as int,
        name: member['name'] as String,
      );
    }).toList();

    return members;
  } else {
    print('Error fetching members: ${response.reasonPhrase}');
    return [];
  }
}


class CreateTask extends StatefulWidget {
  const CreateTask({Key? key}) : super(key: key);

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
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

  @override
  void initState() {
    super.initState();
    _fetchAvailableMembers();
    _fetchServiceProviderTypes();
  }

  Future<void> _fetchAvailableMembers() async {
    List<Member> availableMembers = await fetchMembers();
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text(
                          'Done',
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
                child: TextFormField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Task Title',
                    hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        //labelText: 'Select Member*',
                        labelStyle: TextStyle(fontSize: 18),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
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
                            maxHeight: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return _availableMembers.map<Widget>((Member member) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(
                                    member.name,
                                    style: const TextStyle(
                                      color: Colors.blue, // Customize the color as needed
                                    ),
                                  ),
                                  // onDeleted: () {
                                  //   setState(() {
                                  //     _selectedMembers.remove(member);
                                  //   });
                                  // },
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: TextFormField(
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
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: TextFormField(
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
                    suffixIcon: Icon(Icons.access_time), // Show time icon
                  ),
                ),
              ),
              const SizedBox(height: 30.0,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        //labelText: 'Service Provider*',
                        labelStyle: TextStyle(fontSize: 18),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<int>(
                          hint: const Text('Service Provider'),
                          isExpanded: true,
                          value: serviceProviderId,
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
                            maxHeight: 300,
                            width: 300,
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
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              //   child: DropdownButtonFormField<int>(
              //     value: serviceProviderId,
              //     items: distinctServiceProviderTypes.map((provider) {
              //       final serviceProviderId = provider['id'] as int;
              //       final serviceProviderTypeName =
              //       provider['service_provider_type']['name'] as String;
              //       return DropdownMenuItem<int>(
              //         value: serviceProviderId,
              //         child: Text(serviceProviderTypeName),
              //       );
              //     }).toList(),
              //     onChanged: (newValue) {
              //       setState(() {
              //         serviceProviderId = newValue;
              //       });
              //     },
              //     decoration: const InputDecoration(
              //       labelText: 'Service Provider*',
              //       labelStyle: TextStyle(fontSize: 18),
              //       border: UnderlineInputBorder(
              //         borderSide: BorderSide(color: Colors.grey),
              //       ),
              //     ),
              //     selectedItemBuilder: (BuildContext context) {
              //       return distinctServiceProviderTypes.map<Widget>((provider) {
              //         final serviceProviderTypeName =
              //         provider['service_provider_type']['name'] as String;
              //         return Align(
              //           alignment: Alignment.centerLeft,
              //           child:Text(
              //               serviceProviderTypeName,
              //             ),
              //         );
              //       }).toList();
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: TextFormField(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Add an Attachment',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey,),
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





