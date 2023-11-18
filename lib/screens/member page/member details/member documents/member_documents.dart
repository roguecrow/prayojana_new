import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';
import '../../../../graphql_queries.dart';
import '../../../../models/image_viewer.dart';
import '../../../../services/api_service.dart';

class MemberDocuments extends StatefulWidget {
  const MemberDocuments({Key? key, required this.member}) : super(key: key);

  final Map<String, dynamic> member;

  @override
  State<MemberDocuments> createState() => _MemberDocumentsState();
}

class _MemberDocumentsState extends State<MemberDocuments> {
  final TextEditingController fileNameController = TextEditingController(); // Add this line
  List<dynamic> memberDocumentDetails = [];
  var memberId;
  bool isLoading = true;
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

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _fetchMemberDocumentsDetails();
    } else {
      print('Error: widget.member is null');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchMemberDocumentsDetails() async {
    memberId = widget.member['id'];
    print('Clicked Member ID: $memberId');
    List<dynamic>? documentDetails = await MemberApi().fetchMemberDocumentsDetails(memberId);
    if (documentDetails != null && documentDetails.isNotEmpty) {
      setState(() {
        memberDocumentDetails = documentDetails;
        isLoading = false;
        print(isLoading);
        print(memberDocumentDetails);
      });
      print(memberDocumentDetails);
    } else {
      setState(() {
        isLoading = false;
        memberDocumentDetails = [];
      });
      print(isLoading);
      print(memberDocumentDetails);
      print('member documents details is empty');
    }
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

  Future<void> uploadFile(String pickedFileName , String filePath) async {
    print(pickedFileName);
    print(filePath);
    try {
      String accessToken = await getFirebaseAccessToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://prayojana-api-v1.slashdr.com/rest/files/upload/member/$memberId?image'),
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
        print(response.body);
        await insertMemberDocument(memberId, attachmentUrl!,fileNameController.text);
      } else {
        print('API Error: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${response.reasonPhrase}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  Future<void> insertMemberDocument(int memberId, String image, String name) async {
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
        body: jsonEncode({'query': insertMemberDocumentMutation(memberId, image, name)}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int? affectedRows = data['data']['insert_member_documents']['affected_rows'];
        List<dynamic>? returningData = data['data']['insert_member_documents']['returning'];

        if (affectedRows != null && affectedRows > 0 && returningData != null && returningData.isNotEmpty) {
          // Successfully inserted member document, you can use returningData if needed
          print('Inserted Member Document: $returningData');
          _fetchMemberDocumentsDetails();
        } else {
          print('Failed to insert member document');
        }
      } else {
        print('API Error: ${response.reasonPhrase}');
        // Handle error scenario here
      }
    } catch (error) {
      print('Error Inserting member document: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,
            colors: [Color(0xff006bbf)],
          ),
        ),
      )
          : memberDocumentDetails.isNotEmpty
          ? Padding(
        padding:  EdgeInsets.all(6.0.h),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.h,
          ),
          itemCount: memberDocumentDetails.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (_isImageFile(memberDocumentDetails[index]['image'])) {
                  _navigateToImageViewer(
                      memberDocumentDetails[index]['image'],
                      'image$index',
                      memberDocumentDetails[index]['name'] ?? '',
                      memberDocumentDetails[index]['member_id'],
                      memberDocumentDetails[index]['id']
                  );
                }
                else {
                  // Open the respective app to view non-image files
                  _openFile(memberDocumentDetails[index]['image']);
                }
              },
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'image$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0.r), // Adjust the radius as needed
                      child: _isImageFile(memberDocumentDetails[index]['image'])
                          ? Image.network(
                        memberDocumentDetails[index]['image'],
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.insert_drive_file, // Use a document icon
                        size: 105.h,
                        color: Colors.blue, // Choose the color you prefer
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    memberDocumentDetails[index]['name'] ?? 'N/A',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      )
          : const Center(
        child: Text(
          'There are no documents to view',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showImagePickerBottomSheet();
        },
        backgroundColor: const Color(0xff018fff),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToImageViewer(url,tag,name,memId,docId) async {
    final shouldUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imageUrl: url,
          heroTag: tag,
          imageName: name , // Unique tag for Hero animation
          memberId: memId,
          documentId: docId,
        ),
      ),
    );

    if (shouldUpdate == true) {
      _fetchMemberDocumentsDetails();
    }
  }

  // Function to show the image picker bottom sheet
  Future<void> _showImagePickerBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Set to true to allow the bottom sheet to expand based on content
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select File',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Divider(
                        height: 20.0.h,
                        thickness: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0.h),
                        child: TextFormField(
                          controller: fileNameController,
                          maxLength: 25,
                          style: TextStyle(fontSize: 14.sp),
                          maxLines: null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      GestureDetector(
                        onTap: () async {
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
                        },
                        child: Container(
                          height: 150.h,
                          width: 250.h,
                          padding: EdgeInsets.all(10.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: pickedFile != null && pickedFile!.existsSync()
                              ? Image.file(
                            pickedFile!,
                            height: 120.h,
                            width: 250.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported, size: 60.sp, color: Colors.black45);
                            },
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20.sp, color: Colors.black45),
                              Text('Add', style: TextStyle(fontSize: 20.sp, color: Colors.black45)),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10.0.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                await uploadFile(pickedFileName!, pickedFile!.path).whenComplete(() {
                                  setState(() {
                                    pickedFileName = null;
                                    pickedFile = null;
                                    fileNameController.text = '';
                                  });

                                  Navigator.pop(context);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),
                                backgroundColor: const Color(0xff006bbf),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.0.r),
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isImageFile(String filePath) {
    // Check if the file has an image extension
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  Future<void> _openFile(String filePath) async {
    // Use the respective app to view the file
    final Uri fileUrl = Uri.parse(filePath);
    if (!await launchUrl(fileUrl)) {
      fileUrl;
    }
  }
}
