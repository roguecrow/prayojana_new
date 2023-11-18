import 'dart:async';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:prayojana_new/services/api_service.dart';


class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final String imageName;
  final int memberId;
  final int documentId;

  const FullScreenImage({super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.imageName,
    required this.memberId,
    required this.documentId,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool isDownloaded = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: Text(widget.imageName),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: PhotoView(
                imageProvider: NetworkImage(widget.imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () {
                      downloadImage(widget.imageUrl);
                      print('download clicked');
                      // Add your share action here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () async {
                      await deleteDocument();
                      // Add your delete action here
                    },
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Visibility(
              visible: isDownloaded,
              child: Container(
                height: 100.h,
                width: 100.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    Icon(
                      Icons.download_done,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    Text(
                      'Downloaded',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.imageName}.jpg';
      final file = await File(filePath).writeAsBytes(response.bodyBytes);
      print('Image downloaded to: ${file.path}');

      setState(() {
        isDownloaded = true;
      });

      Timer(const Duration(seconds: 3), () {
        setState(() {
          isDownloaded = false;
        });
      });
    } else {
      print('Failed to download image');
    }
  }

  Future <void> deleteDocument() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this document?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await MemberApi().deleteMemberDocument(widget.memberId, widget.documentId);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Pop out of the photo viewer
                print('deleted');
              },
            ),
          ],
        );
      },
    );
  }
}




