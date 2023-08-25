import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class CreateInteraction extends StatefulWidget {
  const CreateInteraction({Key? key}) : super(key: key);

  @override
  State<CreateInteraction> createState() => _CreateInteractionState();
}

class _CreateInteractionState extends State<CreateInteraction> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  List<Map<String, dynamic>> interactionTypes = [];
  List<dynamic> serviceProviderTypes = [];
  int? selectedInteractionTypeId;
  int? selectedInteractionStatusTypeId;
  List<String> memberNames = [];
  final _dropdownFocusNode = FocusNode();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String? selectedInteractionType;
  String? selectedInteractionStatusType;
  int? serviceProviderTypeId;
  int? serviceProviderId;

  @override
  void initState() {
    super.initState();
    _fetchInteractionTypes();
    _fetchServiceProviderTypes();
  }

  Widget buildInfoRow(String title, Widget content) {
    return Row(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.only(left: 20.0, top: 25.0),
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
            width: 200,
            padding: const EdgeInsets.only(top: 25.0,right: 20.0),
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
                        onPressed: () {
                          // Handle the "Schedule" button press
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text(
                          'Schedule',
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
                    hintText: 'Interaction Title',
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
              buildInfoRow('Members*', TextFormField(
                  controller: _membersController,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  maxLines: null,
                  decoration: InputDecoration(
                   // filled: true,
                    hintText: 'Type to search and add',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                    ),
                    suffixIcon: const Icon(Icons.add),
                  ),
                ),),
              buildInfoRow('Date*', TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: () {
                  _selectDate(context); // Function to open date picker
                },
                style: const TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  //fillColor: Colors.grey[300],
                  hintText: '08 Aug 2023',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                  ),
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
              )),
              buildInfoRow( 'Type*', DropdownButtonFormField<int>(
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
                  //filled: true,
                  hintText: 'select',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                  ),
                ),
              ),),
              // const Padding(
              //   padding: EdgeInsets.only(top: 20.0),
              //   child: Divider(// Adjust the height to control the thickness
              //     color: Colors.grey,  // Set the color of the divider
              //     endIndent: 20,
              //     indent: 20,
              //     //thickness: 1/2,
              //   ),
              // ),
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
                  //filled: true,
                  hintText: 'select',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                  ),
                ),
              ),),
              buildInfoRow( 'Notes',TextFormField(
                controller: _notesController, // Attach the TextEditingController
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: null, // Allow multiple lines of input
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Add Notes...',
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffd7d7d7)),
                  ),
                ),
              ),),
              buildInfoRow( 'Attachment', Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      //filled: true,
                      hintText: 'Photos,documents etc..',
                      //fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xffd7d7d7)),
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
            ],
          ),
        ),
      ),
    );
  }
}
