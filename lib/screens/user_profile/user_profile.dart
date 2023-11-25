import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prayojana_new/screens/user_profile/edit_user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../graphql_queries.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {


  final Map<String, dynamic> userDetails;

  const ProfilePage({Key? key, required this.userDetails}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> userDetails = [];
  int? userId;
  String userName = '';
  String firstLetter = '';
  XFile? pickedFile;
  String? attachmentUrl;
  String? profilePic;



  @override
  void initState() {
    super.initState();
    //print(widget.userDetails);
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     userId = prefs.getInt('userId')!;
     print(userId);

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
          'query': getUserProfile(userId!), // Use the updateUserProfile function
          'variables': {'userId': userId},
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        setState(() {
          userDetails = List<Map<String, dynamic>>.from(data['data']['users']);
           userName = userDetails[0]['name'];
           firstLetter = userName[0];
           profilePic = userDetails[0]['people'][0]['profile_photo'];
        });
         print('userDetails - $userDetails');
         print(profilePic);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  Future<void> _updateProfile(String url) async {
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
          'query': updateUserProfilePhoto,
          'variables': {
            'user_id': userId,
            'url': url,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Profile Photo Updated Successfully');
        print('Response Body: ${response.body}');
        loadUserData();
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error updating profile photo: $error');
    }
  }


  Future<void> uploadFile(String filePath) async {
    print(filePath);
    try {
      String accessToken = await getFirebaseAccessToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://prayojana-api-v1.slashdr.com/rest/files/upload/profile/$userId?image'),
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
         _updateProfile(attachmentUrl!);
      } else {
        print('API Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error uploading file: $error');
      //showCustomTopSnackbar(context, "No Member selected !");
    }
  }

  Widget buildLabelValueWidget(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.h, bottom: 8.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align label to the left, value to the right
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w), // Add some space between label and value
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cropImage() async {
    if (pickedFile != null) {
      try {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile!.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            // CropAspectRatioPreset.ratio3x2,
            // CropAspectRatioPreset.original,
            // CropAspectRatioPreset.ratio4x3,
            // CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.black,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                activeControlsWidgetColor: Colors.blue,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            pickedFile = XFile(croppedFile.path);
          });
          print('croppedFile - ${croppedFile.path}');
          uploadFile(croppedFile.path);
          // Upload croppedFile as a profile picture or perform further actions
          // For example, update the profile picture using the croppedFile.
        }
      } catch (e) {
        print('Error cropping image: $e');
      }
    }
  }

// Inside your _ProfilePageState class

  Future<XFile?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      pickedFile = image;
      await _cropImage(); // Invoke cropping after getting the image from the camera
    }

    return image;
  }

  Future<XFile?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedFile = image;
      await _cropImage(); // Invoke cropping after getting the image from the gallery
    }

    return image;
  }



  Future<void> _showProfileDialog(BuildContext context) async {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile photo',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            IconButton.outlined(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Profile Picture'),
                                      content: const Text('Are you sure you want to delete your profile picture?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await _updateProfile('').then((value) => Navigator.of(context).pop()); // Call the function to delete the profile picture
                                            print('Profile picture deleted successfully');
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: profilePic!.isEmpty
                                  ? const SizedBox.shrink() // If profilePic is empty, don't display the delete icon
                                  : const Icon(Icons.delete, color: Colors.black87),
                            ),
                          ],
                        ),
                        Divider(
                          height: 10.0.h,
                          thickness: 1,
                        ),
                        // if (fileUrl != null && fileUrl != 'null')
                        SizedBox(height: 10.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                     await pickImageFromCamera();
                                    print('pickedFile - ${pickedFile!.path}');
                                    Navigator.of(context).pop(); // Close the bottom sheet
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  iconSize: 30.sp,
                                  color: Colors.blueAccent, // Customize the color as needed
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
                                    await pickImageFromGallery();
                                    print('pickedFile - ${pickedFile!.path}');
                                    Navigator.of(context).pop(); // Close the bottom sheet
                                  },
                                  icon: const Icon(Icons.insert_photo_rounded),
                                  iconSize: 30.sp,
                                  color: Colors.deepPurple, // Customize the color as needed
                                ),
                                 Text(
                                  'Gallery',
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




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: const Color(0xfff1f9ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Profile'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5.w),
            bottomRight: Radius.circular(5.w),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _navigateToUpdateProfile();
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: userDetails.isNotEmpty ?
      Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.w,
                        //backgroundColor: Colors.blue, // Default blue background color
                        child: profilePic != null &&
                            profilePic != ''
                            ? ClipOval(
                          child: Image.network(
                            profilePic!,
                            width: 100.w, // Adjust width and height as needed
                            height: 100.w,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Center(
                          child: Text(
                            firstLetter,
                            style: TextStyle(fontSize: 50.sp),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, // Adjust bottom positioning as needed
                        right: 0, // Adjust right positioning as needed
                        child: Container(
                         // padding: const EdgeInsets.all(0.001),  // Adjust padding as needed
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black45,
                          ),
                          child: Center(
                            child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.camera_alt,size: 24.0,),
                              onPressed: () {
                                _showProfileDialog(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    userDetails[0]['name'], // Access the name from userDetails
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0.h),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color:  const Color(0xfff1f9ff),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Date of Birth', userDetails[0]['people'][0]['dob'] ?? 'No Info'), // Accessing Date of Birth
                                buildLabelValueWidget('City', userDetails[0]['people'][0]['city'] ?? 'No Info'), // Accessing City
                                buildLabelValueWidget('Country', userDetails[0]['people'][0]['country'] ?? 'No Info'), // Accessing Country
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Info',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h,),
                        Container(
                          decoration: BoxDecoration(
                            color: const  Color(0xfff1f9ff),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabelValueWidget('Email', userDetails[0]['people'][0]['email'] ?? 'No Info'), // Accessing Email
                                buildLabelValueWidget('Phone Number', userDetails[0]['mobile_number'] ?? 'No Info'), // Accessing Phone Number
                                buildLabelValueWidget('What\'sApp Number', userDetails[0]['people'][0]['whatsapp'] ?? 'No Info'), // Accessing WhatsApp Number
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  void _navigateToUpdateProfile() async {
    final shouldUpdate= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserProfile(userDetails: userDetails,),),
    );

    if (shouldUpdate == true) {
      loadUserData();
    }
  }
}
