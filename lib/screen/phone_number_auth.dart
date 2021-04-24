import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jinga/utilities/anim/phone_animation.dart';
import 'package:jinga/screen/login_home.dart';
import 'package:jinga/screen/map_screen.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:jinga/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

// bool _autoValidate = false;

class PhoneNumberScreen extends StatefulWidget {
  static String id = 'phone_number_screen';

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String phoneNumber = '';
  final _formKey = GlobalKey<FormState>();
  bool _shadow = true;
  final _text = TextEditingController();

  @override
  void initState() {
    // _autoValidate = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 100, 10, 0),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(),
            child: Material(
              color: Colors.transparent,
              shadowColor: _shadow ? Colors.black : Colors.transparent,
              elevation: 12,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _text,
                  autofocus: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(25, 25, 10, 25),
                    prefixText: '+91 ',
                    prefixStyle: TextStyle(color: Colors.black),
                    hintStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: kcolor,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: kcolor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: kcolor, width: 2),
                    ),
                    hintText: 'Enter your 10 digit mobile number',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  validator: (value) {
                    if (value.length != 10) {
                      setState(() {
                        _shadow = false;
                      });
                      return 'Please enter a valid mobile number';
                    } else {
                      setState(() {
                        _shadow = true;
                      });
                      return null;
                    }
                  },
                ),
              ),
            ),
          ),
          PhoneAnim(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.arrow_forward_ios,
          size: 25,
          color: Colors.white,
        ),
        backgroundColor: kcolor,
        elevation: 12,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => OtpPage(
            //               phoneNo: phoneNumber,
            //             )));
            _requestOtp();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AbsorbPointer(
                  child: SpinKitFadingFour(
                    color: Colors.white,
                    size: 100,
                  ),
                );
              },
            );
            print(phoneNumber);
          }
        },
      ),
    );
  }

  Widget warning(String warning) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(40, 60, 40, 0),
          contentPadding: EdgeInsets.fromLTRB(40, 20, 40, 60),
          title: Text('Error verifing otp'),
          content: Text(warning),
        );
      },
    );
  }

  Future _requestOtp() async {
    //
    //
    FirebaseAuth _auth = FirebaseAuth.instance;
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) {
      // setState(() {
      //   _autoValidate = true;
      // });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AbsorbPointer(
            child: SpinKitFadingFour(
              color: Colors.white,
              size: 100,
            ),
          );
        },
      );
      _auth.signInWithCredential(phoneAuthCredential).then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen(
                process: MapProcess.login,
              ),
            ),
            ModalRoute.withName(LoginHomeScreen.id));
      });
    };
    //
    //
    PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException authException) async {
      print('verification failed: ' + authException.message.toString());

      warning(authException.message);
      await Future.delayed(const Duration(seconds: 5)).then((value) {
        Navigator.of(context).popUntil(ModalRoute.withName(LoginHomeScreen.id));
      });
    };
    //
    //
    // call back when code is sent
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('Please check phone for verification code');
      // Navigator.of(context).popUntil(ModalRoute.withName(WelcomePage.id));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
            verificationId: verificationId,
            phoneNo: phoneNumber,
            auth: _auth,
          ),
        ),
      );
    };
    //
    //
    PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout =
        (String verificatioId) async {
      print('Otp AutoRetrieval Time out $verificatioId');

      // Navigator.of(context).popUntil(ModalRoute.withName(WelcomePage.id));
    };
    //
    //
    String phoneNo = '+91' + phoneNumber;
    //
    //

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          verificationCompleted: verificationCompleted,
          verificationFailed: phoneVerificationFailed,
          codeSent: codeSent,
          timeout: Duration(seconds: 60),
          codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
    } catch (e) {
      warning(e.message);
      await Future.delayed(const Duration(seconds: 5)).then((value) {
        Navigator.of(context).popUntil(ModalRoute.withName(LoginHomeScreen.id));
      });
    }
  }
}

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String phoneNo;
  final FirebaseAuth auth;
  OtpPage({this.verificationId, this.phoneNo, this.auth});
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _pinPutController = TextEditingController();
  String _otp;
  bool _valid = true;
  final BoxDecoration _submittedFieldDecoration = BoxDecoration(
    color: kcolor,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black38,
        blurRadius: 5,
        offset: Offset(3, 0),
      )
    ],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 100),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Enter one time password (otp) sent to ....${widget.phoneNo.substring(6, 10)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 100,
              child: PinPut(
                onChanged: (value) {
                  _otp = value;
                  if (!_valid)
                    setState(() {
                      _valid = true;
                    });
                },
                controller: _pinPutController,
                fieldsCount: 6,
                autofocus: true,
                fieldsAlignment: MainAxisAlignment.spaceAround,
                eachFieldMargin: EdgeInsets.all(0),
                eachFieldHeight: 60,
                eachFieldWidth: 45,
                submittedFieldDecoration: _submittedFieldDecoration,
                selectedFieldDecoration: BoxDecoration(
                    color: Color(0xffd3d3d3),
                    border: Border.all(color: kcolor, width: 4),
                    borderRadius: BorderRadius.circular(10)),
                followingFieldDecoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kcolor, width: 3),
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            !_valid
                ? Container(
                    child: Text(
                      'Please enter valid Otp',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.right,
                    ),
                  )
                : Text(''),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(_otp);
          if (_otp.length != 6) {
            setState(() {
              _valid = false;
            });
          } else {
            // FocusScopeNode currentFocus = FocusScope.of(context);
            // if (currentFocus.hasPrimaryFocus) {
            //   currentFocus.unfocus();
            // }
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AbsorbPointer(
                  child: SpinKitFadingFour(
                    color: Colors.white,
                    size: 100,
                  ),
                );
              },
            );
            signInWithPhoneNumber();
          }
        },
        backgroundColor: kcolor,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Future signInWithPhoneNumber() async {
    final AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: _otp);
    try {
      final User user =
          (await widget.auth.signInWithCredential(authCredential)).user;
      debugPrint('User signed in :' + user.uid);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              process: MapProcess.login,
            ),
          ),
          ModalRoute.withName(LoginHomeScreen.id));
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AbsorbPointer(
            child: AlertDialog(
              title: Text(
                'Error validating otp',
                style: TextStyle(color: Colors.redAccent),
              ),
              content: Text(e.message.toString()),
            ),
          );
        },
      );
      await Future.delayed(Duration(seconds: 4)).then((value) {
        Navigator.popUntil(context, ModalRoute.withName(LoginHomeScreen.id));
      });
    }
  }
}
