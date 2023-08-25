import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:prayojana_new/bottom_navigaton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

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

  Color blue = const Color(0xffd1d5db);

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
      bool isTokenVerified = await getFirebaseAccessToken(authResult.user);
      if (isTokenVerified) {
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


  Future<bool> getFirebaseAccessToken(User? user) async {
    if (user != null) {
      String? accessToken = await user.getIdToken();

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebaseAccessToken', accessToken);

        final apiService = ApiService();
        var response = await apiService.postBearerToken();
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
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
        backgroundColor: const Color(0xffd1d5db),
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          height: screenHeight,
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
                  height: screenHeight / 1.5,
                  width: screenWidth,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth / 12,
                      right: screenWidth / 12,
                      bottom: screenHeight / 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sign in to your account",
                          style: GoogleFonts.inter(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color: const Color(0xff000000),
                            height: 24 / 22,
                          ),
                          textAlign: TextAlign.left,
                        ),

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
                          child: Container(
                            height: 50,
                            width: screenWidth,
                            margin: EdgeInsets.only(bottom: screenHeight / 20),
                            decoration: BoxDecoration(
                              color: isVerifyingOTP ? Colors.grey : const Color(0xff006bbf),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: isVerifyingOTP
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                screenState == 0 ? "Get OTP" : "Verify Account",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Are you a new customer? ",
                              style: GoogleFonts.inter(
                                fontSize: 16,
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
                                  fontSize: 16,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff374151),
            height: 20 / 14,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8,),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff6b7280)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff6b7280)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
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
        const SizedBox(height: 20),
        Text(
          "OTP",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff374151),
            height: 20 / 14,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8,),
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
              right: 16,
              top: 20,
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
                    style: const TextStyle(
                      color: Color(0xff6b7280),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff4287bd),
                      height: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
