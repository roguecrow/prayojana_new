import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
import '../../../../other_app_navigator.dart';
import '../../../../services/api_service.dart';
import '../member profile/member_profile_edit.dart';
import 'member_health_edit.dart';

class MemberHealth extends StatefulWidget {
  const MemberHealth({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberHealth> createState() => _MemberHealthState();
}

class _MemberHealthState extends State<MemberHealth> {
  List<dynamic> memberHealthDetails = []; // Add this line
  List<dynamic> doctors = []; // Add this line
  List<dynamic> medicalCenters = []; // Add this line
  List<Map<String, dynamic>> medicalCentersList = [];
  List<Map<String, dynamic>> doctorsList = [];
  List<Map<String, dynamic>> doctorAddressList = [];

  String? selectedMedicalCenterId;
  int? selectDoctorId;
  String? selectedItemId;
  late int medicalCentersId = 0; // Or whatever initial value makes sense in your application


  late BuildContext _storedContext;
  bool isLoading = true; // Add this line
  String? planName; // Make planName nullable

  @override
  void initState() {
    super.initState();
    fetchMedicalCenterIds();
    fetchDoctorIds();
    if (widget.member != null) {
      _fetchMemberHealthDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future fetchMedicalCenterIds() async {
    String accessToken = await getFirebaseAccessToken();
    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': medicalCenterIds,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> medicalCenters = responseData['data']['medical_centers'];

      for (var center in medicalCenters) {
        medicalCentersList.add({'id': center['id'], 'name': center['name']});
      }

      //print('MEDICAL CENTER - $medicalCentersList');

    } else {
      throw Exception('Failed to load medical center IDs');
    }
  }

  Future fetchDoctorIds() async {
    String accessToken = await getFirebaseAccessToken();
    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': doctorIds,

      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> doctors = responseData['data']['doctors'];
      print('doctors whole data  -  $doctors');

      for (var doctor in doctors) {
        doctorsList.add({'id': doctor['id'], 'name': doctor['name']});
      }
     // print('DOCTOR Name  & Id - $doctorsList');

    } else {
      throw Exception('Failed to load medical center IDs');
    }
  }

  Future fetchDoctorAddress(int id) async {
    String accessToken = await getFirebaseAccessToken();
    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': getDoctorAddressDetails(id),
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> doctorAddresses = responseData['data']['doctor_addresses'];

      List<Map<String, dynamic>> addresses = [];

      for (var doctorAddress in doctorAddresses) {
        addresses.add({
          'id': doctorAddress['id'],
          'address': doctorAddress['address'],
        });
      }

      print('DOCTOR ADDRESS - $addresses');

      return addresses;

    } else {
      throw Exception('Failed to load doctor addresses');
    }
  }





  Future<void> _fetchMemberHealthDetails() async {
    var memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? healthDetails = await MemberApi().fetchMemberHealthDetails(memberId);
    if (healthDetails != null && healthDetails.isNotEmpty) {
      setState(() {
        memberHealthDetails = healthDetails;
        doctors = memberHealthDetails[0]['member_doctors'] ?? [];
       // print('doctors - $doctors');
      //  print('MEMBER MEDICALS - $doctors');
        medicalCenters = memberHealthDetails[0]['member_medical_centers'] ?? [];
        //print('SelectedmedicalcentersId - $medicalCentersId');
        //print('MEDICAL CENTERS - $medicalCenters');
        isLoading = false;
      });
    } else {
      print('Error fetching member details');
    }
  }

  void _showUpdateSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message,style: GoogleFonts.inter(),),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
      ),
      margin: const EdgeInsets.all(10), // Adjust the margin as needed
      behavior: SnackBarBehavior.floating, // Makes the snackbar float above the bottom
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      animation: _snackBarFadeAnimation(), // Use a custom animation
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Animation<double> _snackBarFadeAnimation() {
    return CurvedAnimation(
      parent: const AlwaysStoppedAnimation(1),
      curve: Curves.easeOut, // Adjust the curve as needed
    );
  }


  Future<void> insertDoctorDetails(int memberId, int doctorId, int doctorAddressId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': insertDoctorsDetails,
        'variables': {
          'member_id': memberId,
          'doctor_id': doctorId,
          'doctor_address_id': doctorAddressId,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['insert_member_doctors']['affected_rows'];
      print(affectedRows);
      print(responseString);

      if (affectedRows > 0) {
        // Data successfully inserted
        selectDoctorId = null;
        _fetchMemberHealthDetails();
        Navigator.pop(context, true);
        print('Data inserted successfully');
        // ignore: use_build_context_synchronously
        _showUpdateSnackBar(context, "Doctor details inserted successfully");
      } else {
        // Data insert failed
        print('Failed to insert data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }


  Future<void> _updateMemberDoctors(int id, int memberId, int doctorAddressId, int doctorId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': updateDoctorDetails,
        'variables': {
          'id': id,
          'member_id': memberId,
          'doctor_address_id': doctorAddressId,
          'doctor_id': doctorId,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['update_member_doctors']['affected_rows'];
      print(affectedRows);
      print(responseString);

      if (affectedRows > 0) {
        // Data successfully updated
        _fetchMemberHealthDetails();
        Navigator.pop(context, true);
        print('Data updated successfully');
        // ignore: use_build_context_synchronously
        _showUpdateSnackBar(context, "Doctor details updated successfully");
      } else {
        // Data update failed
        print('Failed to update data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }

  Future<void> _updateMemberMedicalCenterDetails(int id, int memberId, int medicalCenterId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': updateMemberMedicalCenterDetails,
        'variables': {
          'id': id,
          'member_id': memberId,
          'medical_center_id': medicalCenterId,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['update_member_medical_center']['affected_rows'];
      print(affectedRows);
      print(responseString);

      if (affectedRows > 0) {
        // Data successfully updated
        _fetchMemberHealthDetails();
        Navigator.pop(context, true);
        print('Data updated successfully');
        // ignore: use_build_context_synchronously
        _showUpdateSnackBar(context, "Medical Center updated successfully");

      } else {
        // Data update failed
        print('Failed to update data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }



  void _showDoctorInfo(BuildContext context, dynamic doctor) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.h),
                      child: const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        //_createDoctorsAndEditDoctors(context, docdata: doctor, isNewDoctor: false);
                        _createAndEditItem(context, false, true, doctor);
                        print('selected doctor - $doctor');
                        print('Edit Note Button Pressed');
                      },
                      icon: const Icon(Icons.edit_note),
                    ),
                  ],
                ),
                Divider(
                  height: 12.0.h,
                  thickness: 1,
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Name'),
                  subtitle: Text(doctor['doctor']['name']),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Mobile Number'),
                  subtitle: Text(doctor['doctor']['mobile_number']),
                ),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Notes'),
                  subtitle: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 100,
                      ),
                      child: Text(doctor['doctor']['notes']),
                    ),
                  ),
                ),
                // Displaying multiple addresses
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: doctor['doctor']['doctor_addresses'].length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isMatchingAddress = doctor['doctor_address_id'] ==
                        doctor['doctor']['doctor_addresses'][index]['id'];

                    return isMatchingAddress
                        ? ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text('Address ${index + 1}'),
                      subtitle: Text(
                          doctor['doctor']['doctor_addresses'][index]['address']),
                    )
                        : SizedBox.shrink(); // If it's not a matching address, return an empty SizedBox
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _createAndEditItem(BuildContext context, bool isNew, bool isDoctor, dynamic data) async {
    String? selectedItemId;
    String? selectedItemId2;
    String? itemId;
    List<Map<String, dynamic>> itemList;
    List<Map<String, dynamic>> itemList2 = [];

    if (isDoctor) {
      selectedItemId = data != null ? data['doctor']['id']?.toString() : null;
      selectDoctorId = data != null ? data['id'] : 0;
      itemId = selectDoctorId.toString();
      print('selectedItemId - $selectedItemId');
      print('itemId - $itemId');
      itemList = doctorsList;
      List<dynamic> doctorAddresses = data != null ? data['doctor']['doctor_addresses'] : [];
      itemList2 = doctorAddresses.map((address) => {'id': address['id'], 'address': address['address']}).toList();

      // Call fetchDoctorAddress if a doctor is selected
    } else {
      selectedItemId = data != null ? data['medical_center']['id'].toString() : null;
      data != null ? medicalCentersId = data['id'] : 0;
      itemId = medicalCentersId.toString();
      itemList = medicalCentersList;
    }


    //this causes error for editing
    // if (isDoctor && selectedItemId != null) {
    //   itemList2 = await fetchDoctorAddress(int.parse(selectedItemId));
    // }


    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isNew ? (isDoctor ? 'Assign Doctor' : 'Create Medical Center') : (isDoctor ? 'Update Doctor' : 'Edit Medical Center'),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Divider(
                      height: 12.0.h,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 100.h, top: 12.h),
                      child: Column(
                        children: [
                          DropdownButtonFormField2<String>(
                            value: selectedItemId,
                            onChanged: (String? newValue) async {
                              setState(() {
                                selectedItemId = newValue;
                                if (isDoctor && selectedItemId != null) {
                                  fetchDoctorAddress(int.parse(selectedItemId!)).then((addresses) {
                                    setState(() {
                                      itemList2 = addresses;
                                      selectedItemId2 = null; // Reset selectedItemId2 when selecting a new doctor
                                    });
                                  });
                                }
                                print('new selectedItemId - $selectedItemId');
                              });
                            },

                            items: itemList.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                              return DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(
                                  item['name'],
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 150.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                            ),
                            decoration: InputDecoration(
                              label: Text(isDoctor ? 'Select Doctor' : 'Select Medical Center'),
                              hintText: isDoctor ? 'Select Doctor' : 'Select Medical Center',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h,),
                          isDoctor
                              ? Visibility(
                            visible: selectedItemId != null,
                            child: DropdownButtonFormField2<String>(
                              value: selectedItemId2 ?? null,
                                onChanged: (String? newValue) {
                                setState(() {
                                  selectedItemId2 = newValue;
                                  print('new selectedItemId2 - $selectedItemId2');
                                  print('itemList2 - $itemList2');
                                  print('selectedItemId2 - $selectedItemId2');
                                });
                              },
                              items: itemList2.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                                return DropdownMenuItem<String>(
                                  value: item['id'].toString(),
                                  child: Text(
                                    item['address'],
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 150.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                              ),
                              decoration: InputDecoration(
                                label: const Text('Select Doctor Address'),
                                hintText: 'Select Doctor Address',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0.h),
                      child: ElevatedButton(
                        onPressed: () {
                          if (isDoctor) {
                            if (isNew) {
                              insertDoctorDetails(widget.member['id'], int.parse(selectedItemId!), int.parse(selectedItemId2!));

                            } else {
                              _updateMemberDoctors(int.parse(itemId!), widget.member['id'], int.parse(selectedItemId2!), int.parse(selectedItemId!));
                            }
                          } else {
                            if (isNew) {
                              _createNewMedicalCenter(int.parse(selectedItemId!), widget.member['id']);
                            } else {
                              _updateMemberMedicalCenterDetails(int.parse(itemId!), widget.member['id'], int.parse(selectedItemId!));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.maxFinite, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0.r),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }




  Future<void> _createNewMedicalCenter(int selectedMedicalCenterId, int memberId) async {
    String accessToken = await getFirebaseAccessToken();

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': insertMemberMedicalCenter,
        'variables': {
          'medical_center_id': selectedMedicalCenterId,
          'member_id': memberId,
        },
      }),
    );

    if (response.statusCode == 200) {
      String responseString = response.body;
      Map<String, dynamic> responseData = json.decode(responseString);
      int affectedRows = responseData['data']['insert_member_medical_center']['affected_rows'];
      print(affectedRows);
      print(responseString);

      if (affectedRows > 0) {
        // Data successfully inserted
        _fetchMemberHealthDetails();
        Navigator.pop(context, true);
        print('Data inserted successfully');
        _showUpdateSnackBar(context, "Medical Center inserted successfully");
      } else {
        // Data insertion failed
        print('Failed to insert data');
      }
    } else {
      print('API Error: ${response.reasonPhrase}');
    }
  }




  void _showMedicalCenterInfo(BuildContext context, dynamic center) {
    showModalBottomSheet(
      context: context,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left: 12.0.h),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: ()  {
                      Navigator.pop(context, true);
                      print('Edit Note Button Pressed'); // Add this line
                      //_createAndEditMedicalCenter(context, mcdata: center, isNewCenter: false);
                      _createAndEditItem(context, false, false, center);

                    },
                    icon: const Icon(Icons.edit_note),
                  ),
                ],
              ),
               Divider(
                height: 12.0.h,
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text('Medical Center Name'),
                subtitle: Text(center['medical_center']['name'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(center['medical_center']['phone'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Address'),
                subtitle: Text(center['medical_center']['address'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.type_specimen),
                title: const Text('Type'),
                subtitle: Text(center['medical_center']['medical_center_type']['name'] ?? 'N/A'),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildInfoRow(String label, String? value, {double fontSize = 14.0, FontWeight? fontWeight}) {
    return Padding(
      padding: EdgeInsets.all(10.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          value != null && label.toLowerCase() == 'location'
              ? GestureDetector(
            onTap: () {
              // Handle location click action here
              MapUtils.openMap(value);
              print('Location clicked: $value');
            },
            child: Container(
              width: 150, // Set a maximum width for the value text
              child: Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.blue, // Style it as a link
                  decoration: TextDecoration.underline, // Underline it
                ),
              ),
            ),
          )
              : label.toLowerCase() == 'agent number'
              ? GestureDetector(
            onTap: () {
              makeCall.makePhoneCall('tel:$value');
            },
            child: Container(
              width: 150, // Set a maximum width for the value text
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.blue, // Style it as a link
                  decoration: TextDecoration.underline, // Underline it
                ),
              ),
            ),
          )
              : Container(
            width: 150, // Set a maximum width for the value text
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?  Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      )
          : ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Health Information',
              style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(10.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildInfoRow('Blood Group', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['blood_group'] != null ? memberHealthDetails[0]['blood_group'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Vitacuro ID', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['vitacuro_id'] != null ? memberHealthDetails[0]['vitacuro_id'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Date Of Birth', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['dob'] != null ? memberHealthDetails[0]['dob'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('History', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['medical_history'] != null ? memberHealthDetails[0]['medical_history'] : 'N/A',fontSize: 14.0.sp),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Text(
              'Doctors',
              style: TextStyle(color: Colors.grey[600], fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 250.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              children: [
                // Button that looks like a list tile
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.0.h),
                  child: ElevatedButton(
                    onPressed: () {
                      print('button clicked');
                      // _createDoctorsAndEditDoctors(context, docdata: null, isNewDoctor: true);
                      _createAndEditItem(context, true, true, null);

                      // Add your create medical center logic here
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87, backgroundColor: Colors.white,
                      elevation: 0, // Remove the button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0.r),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        'Create New',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.add,
                        size: 20.0.h,
                        color: Colors.black54 ,
                        //semanticLabel: 'Create New Medical Center', // Optional label for accessibility
                        textDirection: TextDirection.ltr, // Optional text direction
                      ),
                    ),
                  ),
                ),
                // Scrollable list of medical centers
                Expanded(
                  child: Scrollbar(
                    child: doctors.isEmpty
                        ? Center(
                      child: Text(
                        'No doctors information available',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        dynamic doctor = doctors[index];
                        return InkWell(
                          onTap: () {
                            _showDoctorInfo(context, doctor);
                          },
                          splashColor: Colors.blue,
                          highlightColor: Colors.blue,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                            child: ListTile(
                              title: Text(
                                doctor['doctor']['name'] ?? 'N/A',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 12.0.h,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Medical Centers',
              style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 250.h, // Set a fixed height
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(8.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              children: [
                // Button that looks like a list tile
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.0.h),
                  child: ElevatedButton(
                    onPressed: () {
                      print('button clicked');
                     // _createAndEditMedicalCenter(context, mcdata: null, isNewCenter: true);
                      _createAndEditItem(context, true, false, null);


                      // Add your create medical center logic here
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87, backgroundColor: Colors.white,
                      elevation: 0, // Remove the button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0.r),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        'Create New',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.add,
                        size: 20.0.h,
                        color: Colors.black54 ,
                        semanticLabel: 'Create New Medical Center', // Optional label for accessibility
                        textDirection: TextDirection.ltr, // Optional text direction
                      ),
                    ),
                  ),
                ),
                // Scrollable list of medical centers
                Expanded(
                  child: Scrollbar(
                    child: medicalCenters.isEmpty
                        ? Center(
                      child: Text(
                        'No medical center information available',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: medicalCenters.length,
                      itemBuilder: (context, index) {
                        dynamic center = medicalCenters[index];
                        return InkWell(
                          onTap: () {
                            _showMedicalCenterInfo(context, center);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: Text(
                                center['medical_center']['name'] ?? 'N/A',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 12.0.h,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 22.0.w),
            child: Text(
              'Insurance',
              style: TextStyle(color: Colors.grey[600],fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0.h),
            padding: EdgeInsets.all(10.0.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Insure', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['insurer'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Policy Number', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['policy_number'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Valid Till', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['valid_till'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Agent Name', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['agent_name'] : 'N/A',fontSize: 14.0.sp),
                _buildInfoRow('Agent Number', memberHealthDetails.isNotEmpty && memberHealthDetails[0]['member_insurances'] != null && memberHealthDetails[0]['member_insurances'].isNotEmpty ? memberHealthDetails[0]['member_insurances'][0]['agent_number'] : 'N/A',fontSize: 14.0.sp),
                if (memberHealthDetails.isEmpty)
                  Center(
                    child: Text(
                      'No insurance information available.',
                      style: TextStyle(fontSize: 14.0.sp),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !isLoading, // Show the button only if isLoading is false
        child: FloatingActionButton.extended(
          onPressed: () {
            _navigateToMemberHealthEdit();
          },
          label: const Text('EDIT'),
          icon: const Icon(Icons.edit_outlined),
          backgroundColor: const Color(0xff018fff),
        ),
      ),
    );
  }


  void  _navigateToMemberHealthEdit() async {
    final shouldCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberHealth(memberHealthDetails: memberHealthDetails),
      ),
    );

    if (shouldCreate == true) {
      // Refresh the task data after updating
      _fetchMemberHealthDetails();
    }
  }
}

