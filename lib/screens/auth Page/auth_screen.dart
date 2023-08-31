import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:prayojana_new/bottom_navigaton.dart';
import 'package:prayojana_new/firebase_access_token.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


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

  Future<void> verifyPhone(String number) async {
    setState(() {
      isOtpButtonDisabled = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        showSnackBarText("Auth Completed!");
      },
      verificationFailed: (FirebaseAuthException e) {
        showSnackBarText("Auth Failed!");
      },
      codeSent: (String verificationId, int? resendToken) {
        showSnackBarText("OTP Sent!");
        verID = verificationId;
        setState(() {
          screenState = 1;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showSnackBarText("Timeout!");
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          isOtpButtonDisabled = false;
        });
      }
    });
  }

  Future<void> verifyOTP() async {
    setState(() {
      isVerifyingOTP = true;
    });

    await FirebaseAuth.instance.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verID,
        smsCode: otpPin,
      ),
    ).then((authResult) async {
      await AccessToken().getFirebaseAccessToken(authResult.user);
      final apiService = ApiService();
      var response = await apiService.postBearerToken();
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavigator(),
          ),
        );
      } else {
        showSnackBarText("User does not exist.");
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isVerifyingOTP = false;
        });
      }
    });
  }



  Future<void> registerUserAndVerifyPhone() async {
    try {
      final apiService = ApiService();
      var response = await apiService.postUserData(countryDial + phoneController.text);
      if (response.statusCode == 200) {
        showSnackBarText("API call success, now verify phone number!");
        verifyPhone(countryDial + phoneController.text);
      } else {
        showSnackBarText("API call failed, try again later.");
      }
    } catch (e) {
      showSnackBarText("Error occurred, try again later.");
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
                            fontWeight: FontWeight.w700,
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
                                showSnackBarText("Phone number is still empty!");
                              } else {
                                if (countryDial == "+1") {
                                  showSnackBarText("Please select a country code.");
                                  return;
                                } else {
                                  registerUserAndVerifyPhone();
                                }
                              }
                            } else {
                              if (otpPin.length >= 6) {
                                verifyOTP();
                              } else {
                                showSnackBarText("Enter OTP correctly!");
                              }
                            }
                          },
                          child: ElevatedButton(
                            onPressed: isVerifyingOTP
                                ? null
                                : () {
                              if (screenState == 0) {
                                if (phoneController.text.isEmpty) {
                                  showSnackBarText("Phone number is still empty!");
                                } else {
                                  if (countryDial == "+1") {
                                    showSnackBarText("Please select a country code.");
                                    return;
                                  } else {
                                    registerUserAndVerifyPhone();
                                  }
                                }
                              } else {
                                if (otpPin.length >= 6) {
                                  verifyOTP();
                                } else {
                                  showSnackBarText("Enter OTP correctly!");
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Are you a new customer? ",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                              },
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff008fff),
                                ),
                              ),
                            ),
                          ],
                        ),
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

