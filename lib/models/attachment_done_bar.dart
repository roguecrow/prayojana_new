import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showCustomAttachmentAddedBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 50.h,
          width: 160.w,
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.0.h),
          decoration: BoxDecoration(
            color: Colors.black45 ,
            borderRadius: BorderRadius.circular(8.0.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: [
              Icon(
                Icons.download_done,
                color: Colors.white,
                size: 40.sp,
              ),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
