import 'package:flutter/material.dart';
import 'package:jinga/screen/phone_number_auth.dart';
import 'package:jinga/utilities/constants.dart';

class LoginHomeScreen extends StatelessWidget {
  static String id = 'login home screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image(
              image: AssetImage('assets/images/onboarding.png'),
            ),
            ListTile(
              title: Text(
                'Want some help?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 40,
                ),
              ),
              subtitle: Text(
                'Are you trying to find a solution at home ? Come with us lets make it happen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, PhoneNumberScreen.id);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  // margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity - 150,
                  decoration: BoxDecoration(
                    color: kcolor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
