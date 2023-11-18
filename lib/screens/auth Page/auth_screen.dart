// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/models/bottom_navigaton.dart';
import 'package:prayojana_new/firebase_access_token.dart';
import 'package:prayojana_new/models/drawer_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/firebase_api.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController phoneController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  double bottom = 0;

  String otpPin = "";
  String countryDial = "+1";
  String verID = "";
  bool isVerifyingOTP = false;

  int screenState = 0;
  bool isOtpButtonDisabled = false;


  // blue = const Color(0xffd1d5db);

  void showTopAlert(BuildContext context, String message) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

// Usage



  Future<void> verifyPhone(String number) async {
    print('number : $number');
    print('in verifyPhone - $screenState');
    setState(() {
      isOtpButtonDisabled = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 10),
      verificationCompleted: (PhoneAuthCredential credential) {
        showSnackBarText("Auth Completed!");
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Failed'),
              content: const Text('Quota Exceeded. Please try again after sometime!'),
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
      },
      codeSent: (String verificationId, int? resendToken) {
        showCustomTopSnackbar(context, 'OTP Sent!');
        verID = verificationId;
        setState(() {
          screenState = 1;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    ).whenComplete(() {
      print('verifyPhoneNumber called');
      print('otp sent');
      if (mounted) {
        setState(() {
          isOtpButtonDisabled = false;
        });
      }
    });
  }

  void showCustomTopSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0.h, // Adjust the top padding as needed
        left: 16.0.w,
        right: 16.0.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 6.0.h),
            decoration: BoxDecoration(
              color: message == 'Invalid OTP. Please try again.' ?  Colors.red : Colors.black45 ,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }


  Future<void> verifyOTP() async {
    print(screenState);
    setState(() {
      isVerifyingOTP = true;
    });

    try {
      final authResult = await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verID,
          smsCode: otpPin,
        ),
      );

      await AccessToken().getFirebaseAccessToken(authResult.user);
      final apiService = ApiService();
      var response = await apiService.postBearerToken();
      print('checkUser response body - ${response.body}');

      if (response.statusCode == 200) {
        // Store response body and user_id in local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginUserDetails', response.body);
        await prefs.setInt('userId', json.decode(response.body)['user_id']);
        await prefs.setInt('roleId', json.decode(response.body)['role_id']);
        //initiates fire firebase messaging api
        await FirebaseApi().initNotification();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavigator(),
          ),
        );
      } else {
        print(response.body);
        //showSnackBarText("User does not exist.");
        showCustomTopSnackbar(context, "User does not exist.");
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'invalid-verification-code') {
        showCustomTopSnackbar(context, "Invalid OTP. Please try again.");
      } else {
        print('Error: $e');
        //showSnackBarText("An error occurred. Please try again later.");
        showCustomTopSnackbar(context, "An error occurred. Please try again later.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isVerifyingOTP = false;
        });
      }
    }
  }



  Future<void> registerUserAndVerifyPhone() async {
    try {
      final apiService = ApiService();
      var response = await apiService.postUserData(countryDial + phoneController.text);
      if (response.statusCode == 200) {
        //showSnackBarText("API call success, now verify phone number!");
        verifyPhone(countryDial + phoneController.text);
      } else {
        //showSnackBarText("Mobile number not registered");
        showCustomTopSnackbar(context, 'Mobile number not registered');
      }
    } catch (e) {
      //showSnackBarText("Error occurred, try again later.");
      showCustomTopSnackbar(context, "Error occurred, try again later.");

    } finally {
      if (mounted) {
        setState(() {
          isOtpButtonDisabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenUtil().screenHeight;
    double screenWidth = ScreenUtil().screenWidth;
    double bottom = ScreenUtil().bottomBarHeight;


    return WillPopScope(
      onWillPop: () {
        setState(() {
          screenState = 0;
        });
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffd1d5db),
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          height:screenHeight,
          width: screenWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: screenHeight / 17,
                child: Padding(
                  padding: const EdgeInsets.all(105.0),
                  child: SizedBox(
                    child: Image.asset(
                      'assets/Prayojana_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  height: ScreenUtil().screenHeight / 1.5,
                  width: ScreenUtil().screenWidth,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().screenWidth / 12,
                      right: ScreenUtil().screenWidth / 12,
                      bottom: ScreenUtil().screenHeight / 3.5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sign in to your account",
                          style: GoogleFonts.inter(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: const Color(0xff000000),
                            height: 18.h / 22.h,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10,),

                        screenState == 0 ? stateRegister() : stateOTP(),
                        GestureDetector(
                          onTap: isVerifyingOTP
                              ? null
                              : () {
                            if (screenState == 0) {
                              if (phoneController.text.isEmpty) {
                                //showSnackBarText("Phone number is still empty!");
                                showCustomTopSnackbar(context, "Phone number is still empty!");
                              } else {
                                if (countryDial == "+1") {
                                 // showSnackBarText("Please select a country code.");
                                  showCustomTopSnackbar(context, "Please select a country code.");

                                  return;
                                } else {
                                  registerUserAndVerifyPhone();
                                }
                              }
                            } else {
                              if (otpPin.length >= 6) {
                                verifyOTP();
                              } else {
                                //showSnackBarText("Enter OTP correctly!");
                                showCustomTopSnackbar(context, "Enter OTP correctly!");
                              }
                            }
                          },
                          child: ElevatedButton(
                            onPressed: isVerifyingOTP
                                ? null
                                : () {
                              if (screenState == 0) {
                                if (phoneController.text.isEmpty) {
                                  //showSnackBarText("Phone number is still empty!");
                                  showCustomTopSnackbar(context, "Phone number is still empty!");
                                } else {
                                  if (countryDial == "+1") {
                                    //showSnackBarText("Please select a country code.");
                                    showCustomTopSnackbar(context, "Please select a country code.");

                                    return;
                                  } else {
                                    registerUserAndVerifyPhone();
                                  }
                                }
                              } else {
                                if (otpPin.length >= 6) {
                                  print('verifyOTP called');
                                  print('otpPin length: ${otpPin.length}');
                                  verifyOTP();
                                } else {
                                 // showSnackBarText("Enter OTP correctly!");
                                  showCustomTopSnackbar(context, "Enter OTP correctly!");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff006bbf),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              fixedSize: Size(screenWidth, ScreenUtil().setHeight(40)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: isVerifyingOTP
                                  ? const LoadingIndicator(
                                  indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                  colors: [Color(0xff006bbf)],       /// Optional, The color collections
                                  //strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                  //backgroundColor: Colors.black,      /// Optional, Background of the widget
                                  //pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
                                )
                                  : Text(
                                screenState == 0 ? "Get OTP" : "Verify Account",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       "Are you a new customer? ",
                        //       style: GoogleFonts.inter(
                        //         fontSize: 16.sp,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {
                        //         // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        //       },
                        //       child: Text(
                        //         "Sign Up",
                        //         style: GoogleFonts.inter(
                        //           fontSize: 16.sp,
                        //           fontWeight: FontWeight.w500,
                        //           color: const Color(0xff008fff),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBarText(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
    }
  }

  Widget stateRegister() {
    countryDial = "+91";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone number",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff374151),
            height: 20.h /14.h,
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 8.h),
        IntlPhoneField(
          controller: phoneController,
          showCountryFlag: false,
          showDropdownIcon: true,
          initialCountryCode: "IN",
          onChanged: (phone) {
            setState(() {
              countryDial = "+" + phone.countryCode;
            });
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff6b7280)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff6b7280)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal:  ScreenUtil().setWidth(16),
              vertical: 14.h,
            ),
            counterText: "",
            hintText: "+1 (555) 987-6543",
          ),
        ),
      ],
    );
  }

  Widget stateOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          "OTP",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff374151),
            height: 20.h / 14.h,
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 8.h,),
        Stack(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  otpPin = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'enter OTP',
                hintText: '******',
                border: OutlineInputBorder(),
              ),
            ),
            Positioned(
              right: ScreenUtil().setWidth(16), // Use ScreenUtil().setWidth() for the right position
              top: ScreenUtil().setHeight(14), // Use ScreenUtil().setHeight() for the top position
              child: TweenAnimationBuilder<Duration>(
                duration: const Duration(minutes: 1),
                tween: Tween(begin: const Duration(minutes: 1), end: Duration.zero),
                onEnd: () {
                  print('Timer ended');
                },
                builder: (BuildContext context, Duration value, Widget? child) {
                  final minutes = value.inMinutes;
                  final seconds = value.inSeconds % 60;
                  return Text(
                    '$minutes:$seconds',
                    textAlign: TextAlign.center,
                    style:TextStyle(
                      color: const Color(0xff6b7280),
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      screenState = 0;
                    });
                  },
                  child: Text(
                    "Change Phone number",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff4287bd),
                      //height: 3.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget circle(double size) {
    return Container(
      height: ScreenUtil().screenHeight / size, // Use ScreenUtil().screenHeight for height
      width: ScreenUtil().screenHeight / size, // Use ScreenUtil().screenHeight for width
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}

