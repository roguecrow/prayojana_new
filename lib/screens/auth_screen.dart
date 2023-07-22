import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../services/api_service.dart';
import 'member_screen.dart';

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

  int screenState = 0;
  bool isOtpButtonDisabled = false;
// Add a boolean variable

  Color blue = const Color(0xff8cccff);

  Future<void> verifyPhone(String number) async {
    setState(() {
      isOtpButtonDisabled = true; // Disable the "Get OTP" button while OTP request is in progress
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
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          isOtpButtonDisabled = false; // Re-enable the "Get OTP" button after OTP request is completed or failed
        });
      }
    });
  }

  Future<void> verifyOTP() async {
    await FirebaseAuth.instance.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verID,
        smsCode:otpPin,
      ),
    ).then((authResult) async {
      bool isTokenVerified = await getFirebaseAccessToken(authResult.user);
      if (isTokenVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MemberScreen(),
          ),
        );
      } else {
        showSnackBarText("User does not exist.");
      }
    });
  }

  Future<bool> getFirebaseAccessToken(User? user) async {
    if (user != null) {
      String? accessToken = await user.getIdToken();

      if (accessToken != null) {
        print("Firebase access token: $accessToken");
        final apiService = ApiService();
        var response = await apiService.postBearerToken(accessToken);
        if (response.statusCode == 200) {
          print(response.body);
          print('Token verified and successful');
          return true;
        } else {
          print('Token verification failed');
          return false;
        }
      }
    }
    return false;
  }

  Future<void> registerUserAndVerifyPhone() async {
    try {
      // Call the API to post the phone number and proceed with phone verification
      final apiService = ApiService();
      var response = await apiService.postUserData(countryDial + phoneController.text);
      print(response.body);
      if (response.statusCode == 200) {
        showSnackBarText("API call success, now verify phone number!");
        verifyPhone(countryDial + phoneController.text);
      } else {
        showSnackBarText("API call failed, try again later.");
      }
    } catch (e) {
      log(e.toString());
      showSnackBarText("Error occurred, try again later.");
    } finally {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          isOtpButtonDisabled = false; // Re-enable the "Get OTP" button after OTP request is completed or failed
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    bottom = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () {
        setState(() {
          screenState = 0;
        });
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight / 8),
                  child: Column(
                    children: [
                      Text(
                        "JOIN US",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 8,
                        ),
                      ),
                      Text(
                        "Create an account today!",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: screenWidth / 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  height: screenHeight / 1.5,
                  width: screenWidth,
                  color: Colors.white,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth / 12,
                      right: screenWidth / 12,
                      top: screenHeight / 17,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        screenState == 0 ? stateRegister() : stateOTP(),
                        GestureDetector(
                          onTap: isOtpButtonDisabled
                              ? null
                              : () {
                            if (screenState == 0) {
                              if (phoneController.text.isEmpty) {
                                showSnackBarText("Phone number is still empty!");
                              } else {
                                if (countryDial == "+1") {
                                  // Show a snackbar informing the user to select a country code
                                  showSnackBarText("Please select a country code.");
                                  return;
                                }
                                else {
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
                          child: Container(
                            height: 50,
                            width: screenWidth,
                            margin: EdgeInsets.only(bottom: screenHeight / 12),
                            decoration: BoxDecoration(
                              color: isOtpButtonDisabled ? Colors.grey : Colors.black, // Disable the button when isOtpButtonDisabled is true
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isOtpButtonDisabled
                                  ? CircularProgressIndicator(color: Colors.white) // Show a loading indicator on the button when isOtpButtonDisabled is true
                                  : Text(
                                "CONTINUE",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
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
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8,),
        IntlPhoneField(
          controller: phoneController,
          showCountryFlag: false,
          showDropdownIcon: true,
          initialCountryCode: "IN", // Set the default country code to India's code
          onChanged: (phone) {
            setState(() {
              countryDial = "+" + phone.countryCode;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }


  Widget stateOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "We just sent a code to ",
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: countryDial + phoneController.text,
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: "\nEnter the code here and we can continue!",
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        PinCodeTextField(
          appContext: context,
          length: 6,
          onChanged: (value) {
            setState(() {
              otpPin = value;
            });
          },
          pinTheme: PinTheme(
            activeColor: blue,
            selectedColor: Colors.black,
            inactiveColor: Colors.black26,
          ),
        ),
        const SizedBox(height: 20,),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Didn't receive the code? ",
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      screenState = 0;
                    });
                  },
                  child: Text(
                    "Resend",
                    style: GoogleFonts.montserrat(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget circle(double size) {
    return Container(
      height: screenHeight / size,
      width: screenHeight / size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
